library(word2vec)
library(patchwork)
load('data/mesh/mesh.Rdata')
load('data/combined_names/combined.Rdata')
# some neccessary functions
# cosine similarity
cosine <- function(x, y) {
  # crossprod(x,y) / sqrt(crossprod(x)*crossprod(y))
  (x %*% y) / (sqrt(crossprod(x) * crossprod(y)))
}

# L2 norm
euclidean <- function(x, y) {
  return(sqrt(sum((x - y) ^ 2)))
}

# Manhattan distance
manhattan <- function(x, y) {
  return(sum(abs(x - y)))
}

# Tanimoto distance 广义Jaccard
tanimoto <- function(x, y) {
  return(sum(min(x, y)) / sum(max(x, y)))
}

# main program
library(DBI)
library(tidyverse)
con <- dbConnect(RSQLite::SQLite(), 'original_data/chembl/chembl_32/chembl_32_sqlite/chembl_32.db')
indications <- tbl(con, 'drug_indication') %>%
  select(drugind_id:mesh_id) %>%
  left_join((
    tbl(con, 'chembl_id_lookup') %>%
      filter(entity_type == 'COMPOUND', status == 'ACTIVE') %>%
      select(chembl_id, entity_id)
  ), by = c(molregno = 'entity_id')) %>%
  collect()
drug_list <- list.files('models/replaced/', full.names = FALSE, pattern = '.Rdata') %>%
  str_replace_all('.Rdata', '')

# map the chembl_id to drug_id
drug_pointers <- map(extracted_names, ~length(.x))
drug_pointers <- lapply(names(drug_pointers), function(i) {
    rep(i, drug_pointers[[i]])
  }) %>% unlist() %>% unname() %>%
  tibble(drug_id = ., chembl_id = unname(unlist(extracted_names)))
indications <- indications %>% 
  left_join(drug_pointers, by = 'chembl_id') %>%
  select(drug_id, mesh_id, max_phase_for_ind) %>%
  rename(max_phase = 'max_phase_for_ind') %>%
  mutate(max_phase = as.integer(max_phase),
         mesh_id = str_to_lower(mesh_id))

dbDisconnect(con)  
rm(con)

# iterate drug vectors
library(furrr)
library(progressr)
plan(multisession, gc = TRUE)
iterate_drugs <- function() {
  p <- progressor(steps = length(drug_list))
  future_walk(drug_list, function(drug) {
    if (file.exists(paste0('models/vector/', drug, '.bin'))) {
      ######## DELETE THE IF LINES
      if (!file.exists(paste0('models/mesh/', drug, '.Rdata'))) {
        models <- read.word2vec(paste0('models/vector/', drug, '.bin'))
      }
    } else {
      load(paste0('models/replaced/', drug, '.Rdata'))
      models <- word2vec(info, type = 'skip-gram', dim = 300, threads = 1)
      if (!write.word2vec(models, file = paste0('models/vector/', drug, '.bin'), type = 'bin')) {
        stop("Write model failed.\n")
      }
    }
    
    p()
    if (!file.exists(paste0('models/mesh/', drug, '.Rdata'))) {
      pred_mesh <- predict(models, 
                           c(paste0('drugdrug', drug), names(mesh_terms)), 
                           type = 'embedding') %>% na.omit()
      if (nrow(pred_mesh) > 1) {
        pred_mesh <- lapply(seq_len(nrow(pred_mesh)), function(i) pred_mesh[i, ]) %>%
          set_names(rownames(pred_mesh))
        save(pred_mesh, file = paste0('models/mesh/', drug, '.Rdata'))
      }
    }
  }, .options = furrr_options(seed = TRUE))
}

with_progress(iterate_drugs())

indications <- indications %>%
  mutate(drug_id = str_replace_all(drug_id, 'drugdrug', ''),
         drug_id = as.integer(drug_id)) %>%
  drop_na() %>%
  mutate(max_phase = pmax(0, max_phase))

distance <- indications %>%
  add_column(cosine = NA,
             euclidean = NA,
             manhattan = NA,
             dot = NA,
             cor = NA,
             rsp = NA,
             tan = NA) %>%
  arrange(drug_id)

# compute three types of distances
for (drug in drug_list) {
  drug <- as.integer(drug)
  if (file.exists(paste0('models/mesh/', drug, '.Rdata'))) {
    load(paste0('models/mesh/', drug, '.Rdata'))
    drug_vec <- unlist(pred_mesh[[1]])
    mesh_names <- names(pred_mesh[])[-1] %>%
      str_replace_all('meshmesh', '')
    query_mesh_id <- distance$mesh_id[distance$drug_id == drug]
    query_mesh_id <- intersect(query_mesh_id, mesh_names)
    for (mesh in query_mesh_id) {
      mesh_vec <- pred_mesh[[paste0('meshmesh', mesh)]]
      position <- distance$drug_id == drug & distance$mesh_id == mesh
      distance$cosine[position] <- cosine(drug_vec, mesh_vec)
      distance$euclidean[position] <- euclidean(drug_vec, mesh_vec) / sqrt(300)
      distance$manhattan[position] <- manhattan(drug_vec, mesh_vec) / 300
      distance$dot[position] <- word2vec_similarity(drug_vec, mesh_vec, type = 'dot')
      distance$cor[position] <- cor(drug_vec, mesh_vec)
      distance$rsp[position] <- cor(drug_vec, mesh_vec, method = 'spearman')
      distance$tan[position] <- tanimoto(drug_vec, mesh_vec)
    }
  }
}
``
distance <- drop_na(distance) %>%
  rename('Current phase' = 'max_phase')

ggstatsplot::ggbetweenstats(distance, x = 'Current phase', y = cosine, title = 'Cosine') +
ggstatsplot::ggbetweenstats(distance, x = 'Current phase', y = euclidean, title = 'Euclidean') +
ggstatsplot::ggbetweenstats(distance, x = 'Current phase', y = manhattan, title = 'Manhattan') +
ggstatsplot::ggbetweenstats(distance, x = 'Current phase', y = dot, title = 'Dot') +
ggstatsplot::ggbetweenstats(distance, x = 'Current phase', y = cor, title = 'Pearson correlation') + 
ggstatsplot::ggbetweenstats(distance, x = 'Current phase', y = rsp, title = 'Spearman correlation') +
  plot_layout(guides = 'collect') +
  plot_annotation(tag_levels = 'A')

library(M3C)
load('models/mesh/10.Rdata')
tsne(data.frame(pred_mesh), perplex = 20, text = str_replace_all(names(pred_mesh), 'meshmesh', ''))
