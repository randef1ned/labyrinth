# build clinical trials -> paper network
library(tidyverse)
library(igraph)
load('data/mesh/mesh.Rdata')
load('data/combined_names/combined.Rdata')

# turn the mesh data into strings
mesh_terms <- lapply(mesh_terms, function(terms) {
  lapply(terms, function(term) {
    paste(term, collapse = ' ')
  }) %>% unlist()
})

# turn the drug data into lower-case
drug_names <- lapply(extracted_names, function(name) {
  drug_name <- name[!((str_starts(name, 'CHEMBL') & (str_length(name) > 5)) | 
                        (str_starts(name, 'DB') & (str_length(name) == 7)))]
  return(str_to_lower(drug_name))
})

# combine the mesh_terms and drug_names
terms <- list(
  lapply(names(mesh_terms), function(id) {
    data.frame(term_id = id, term = mesh_terms[[id]])
  }) %>% bind_rows(),
  lapply(names(drug_names), function(id) {
    data.frame(term_id = id, term = drug_names[[id]])
  }) %>% bind_rows()
) %>% bind_rows()
rm(list = c('mesh_terms', 'drug_names', 'extracted_names'))

# read the clinical trial data
# use central database
central_files <- list.files('original_data/central/', all.files = TRUE, recursive = TRUE)

# combine them all
trial_details <- pbapply::pblapply(central_files, function(central_file) {
  details <- read_csv(file.path('original_data/central/', central_file),
                      quote = '"', col_types = "cccccccccccccccccccc", progress = FALSE) %>%
    rename(central_id = 1, keywords = 'Keywords', doi = 'DOI') %>%
    select(central_id, keywords, doi)
}) %>% bind_rows() %>%
  distinct() %>%
  mutate(keywords = str_to_lower(keywords),
         doi = str_to_lower(doi)) %>%
  filter(!is.na(keywords), str_length(keywords) > 0)
save(trial_details, file = 'data/central/trial_details.Rdata')

doi_links <- select(trial_details, -keywords) %>%
  drop_na() %>%
  distinct()
save(doi_links, file = 'data/central/doi_links.Rdata')

# extract the keywords and split them
library(future)
library(future.apply)
plan(multisession, workers = 12)
keywords <- str_split(trial_details$keywords, ';') %>%
  future_lapply(function(x) {
    keyword <- str_replace_all(x, '\\[.*\\]', '') %>%
      trimws()
    keyword <- tokenize_words(keyword) %>% 
      map(paste, collapse = ' ') %>% 
      unlist()
    return(keyword)
  }, future.packages = c('dplyr', 'stringr', 'tokenizers', 'purrr')) %>%
  set_names(trial_details$central_id)

# map the keywords to terms
mapped_all_keywords <- data.frame(
  keyword = unique(unname(unlist(keywords)))
) %>%
  left_join(terms, by = c(keyword = 'term')) %>%
  drop_na()

# Build a three-way network including drug, mesh, central_id and doi
triplet_network <- pbapply::pblapply(seq_along(keywords), function(k_id) {
  data.frame(central_id = names(keywords)[k_id], keyword = keywords[[k_id]])
}) %>% bind_rows() %>%
  left_join(mapped_all_keywords, by = 'keyword') %>% 
  drop_na() %>%
  select(-keyword) %>%
  mutate(type = as.factor(if_else(str_starts(term_id, 'drugdrug'), 'drug', 'mesh')),
         term_id = str_replace_all(term_id, 'drugdrug', '') %>%
           str_replace_all('meshmesh', '')) %>%
  left_join(doi_links, by = 'central_id')
save(triplet_network, file = 'data/central/triplet_network.Rdata')

# Convert the three-way network to a edge list network
drug_trials <- triplet_network %>%
  filter(type == 'drug') %>%
  select(central_id:term_id) %>%
  distinct() %>%
  split(.$term_id) %>%
  map(~.x$central_id)
save(drug_trials, file = 'data/central/drug_trials.Rdata')

# extract drug-mesh relationship pairs
id <- 0
row <- 0
drug_mesh_from <- c()
drug_mesh_to <- c()
pb <- txtProgressBar(min = 0, max = length(unlist(drug_trials)), style = 3)
for (trial_id in unlist(drug_trials)) {
  id <- id + 1
  setTxtProgressBar(pb, id)
  ids <- triplet_network[triplet_network$central_id == trial_id, ]
  drug_id <- ids$term_id[ids$type == 'drug']
  mesh_id <- ids$term_id[ids$type == 'mesh']
  outer <- expand.grid(unique(drug_id), unique(mesh_id), stringsAsFactors = FALSE)
  drug_id <- outer$Var1
  mesh_id <- outer$Var2
  for (i in seq_along(drug_id)) {
    row <- row + 1
    drug_mesh_from[row] <- drug_id[i]
    drug_mesh_to[row] <- mesh_id[i]
  }
}
close(pb)
rm(list = c('id', 'row', 'drug_mesh_from', 'drug_mesh_to', 'pb', 'drug_id', 'mesh_id', 'outer', 'i', 'ids'))

# The first network contains drug - disease
twoway_network <- data.frame(from = drug_mesh_from, to = drug_mesh_to, level = 1) %>%
  arrange(as.numeric(from)) %>%
  split(.$from) %>%
  map(~distinct(.x))
save(twoway_network, file = 'data/central/twoway_network.Rdata')

# The second network contains disease - clinical trials - doi pairs
# extract the central_id containing terms_id
central_id_with_terms <- triplet_network %>%
  filter(type == 'drug') %>%
  rename(drug_id = 2) %>%
  select(central_id, drug_id)

full_network <- pbapply::pblapply(twoway_network, function(x) {
  drug_id <- x$from[1]
  central_ids <- triplet_network$central_id[triplet_network$type == 'drug' & triplet_network$term_id == drug_id] %>%
    unique()
  subset_network <- triplet_network %>%
    filter(central_id %in% central_ids, type == 'mesh')
  trial_disease <- subset_network[, 1:2] %>% distinct()
  trial_doi <- subset_network[, c(1, 4)] %>% distinct() %>% drop_na()
  drug_network <- data.frame(
    from = c(x$from, trial_disease$term_id, trial_doi$central_id),
    to = c(x$to, trial_disease$central_id, trial_doi$doi),
    level = c(x$level, rep(2, nrow(trial_disease)), rep(3, nrow(trial_doi)))
  )
  return(drug_network)
}) %>%
  set_names(names(twoway_network))
save(full_network, file = 'data/central/full_network.Rdata')


# visualize the final network
