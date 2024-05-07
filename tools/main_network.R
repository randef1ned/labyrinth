library(tidyverse)
library(igraph)
library(DBI)

# Update gene symbol to the latest
update.gene.symbol <- function(gene.pool) {
  checkmate::assert_character(gene.pool, min.chars = 1)
  
  # https://ftp.ncbi.nih.gov/gene/DATA/GENE_INFO/Mammalia/Homo_sapiens.gene_info.gz
  lookup <- limma::alias2SymbolUsingNCBI(gene.pool, 'original_data/ncbi/Homo_sapiens.gene_info.gz') %>%
    pull(Symbol)
  return(lookup)
}

####################### FIRST STEP: construct the drug-indication network
# Load ChEMBL disease-drug relationships
conn <- dbConnect(RSQLite::SQLite(), 'original_data/chembl/chembl_32/chembl_32_sqlite/chembl_32.db')
# Load drug names
load("data/combined_names/combined.Rdata")
extracted_names <- lapply(names(extracted_names), function(drug_id) {
  drug_names <- extracted_names[[drug_id]]
  chembl_id <- drug_names[str_starts(drug_names, 'CHEMBL')]
  drug_id <- str_replace_all(drug_id, 'drugdrug', '')
  if (length(chembl_id)) {
    data.frame(drug_id = drug_id,
               chembl_id = chembl_id)
  } else {
    data.frame(drug_id = character(), chembl_id = character())
  }
}) %>% bind_rows()

# Load drug indications
load("data/combined_names/drug_indications.Rdata")
edge_list <- drug_indication %>%
  left_join(extracted_names, by = 'chembl_id') %>%
  select(-chembl_id) %>%
  rename(weight = 'max_phase_for_ind') %>%
  relocate(drug_id, mesh_id, weight) %>%
  arrange(drug_id) %>%
  drop_na() %>%
  filter(weight != 0) %>%
  mutate(weight = weight + 1,
         weight = case_when(weight == 0 ~ 0.5, 
                            .default = weight))
under_trials <- filter(edge_list, weight > 1)
under_investigation <- filter(edge_list, weight < 1)

# Load text-mining disease-drug relationships
cosine <- function(x, y) {
  (crossprod(x,y) / sqrt(crossprod(x)*crossprod(y)))[1, 1]
}
for (drug_file in list.files('models/mesh', full.names = FALSE, pattern = '.Rdata')) {
  load(paste0('models/mesh/', drug_file))
  drug_id <- str_replace(drug_file, '.Rdata', '')
  mesh_id <- str_replace_all(names(pred_mesh), 'meshmesh', '') %>%
    str_to_upper()
  
  # Delete the items that appeared in the "under_trials"
  mesh_id <- mesh_id[!mesh_id %in% under_trials$mesh_id[under_trials$drug_id == drug_id]]
  if (!length(mesh_id))
    next
  if (str_starts(mesh_id[[1]], 'DRUGDRUG')) {
    mesh_id <- mesh_id[-1]
    if (!length(mesh_id))
      next
    drug_profile <- pred_mesh[[1]]
    pred_mesh <- pred_mesh[paste0('meshmesh', str_to_lower(mesh_id))]
    drug_distance <- data.frame(
      mesh_id = mesh_id,
      weight = sapply(pred_mesh[paste0('meshmesh', str_to_lower(mesh_id))], function(x) {
        mean(cosine(drug_profile, x), 1)
      })
    )
  } else {
    drug_distance <- data.frame(
      mesh_id = mesh_id,
      weight = 0.75
    )
  }
  under_investigation <- bind_rows(under_investigation, 
                                   mutate(drug_distance, drug_id = drug_id))
}
rm(list = c('mesh_id', 'drug_profile', 'drug_id', 'pred_mesh', 'drug_distance', 'drug_file'))

# Find the maximum value to the duplicated nodes
# Initial weight
drug_indication_list <- bind_rows(under_trials, under_investigation) %>%
  group_by(drug_id, mesh_id) %>%
  summarize(weight = max(weight))
save(drug_indication_list, file = 'data/network/drug_indication_list.Rdata')

rm(list = ls())
gc()

####################### SECOND STEP: compute drug-disease ADR effect
load('data/network/drug_indication_list.Rdata')
load('data/network/trial_disease.Rdata')

# Load background PPI: string
conf_level <- 40
STRING <- data.table::fread('original_data/string/9606.protein.links.v12.0.txt.gz') %>%
  filter(combined_score > conf_level * 10) %>%
  select(-combined_score) %>%
  rownames_to_column('edge_id') %>%
  pivot_longer(!edge_id, names_to = 'key', values_to = 'protein_id')
alias <- data.table::fread('original_data/string/9606.protein.aliases.v12.0.txt.gz') %>%
  rename(protein_id = 1) %>%
  filter(source == 'Ensembl_HGNC') %>%
  select(-source) %>%
  rename(symbol = 2)
alias <- alias[!duplicated(alias$protein_id), ]
STRING <- STRING %>% left_join(alias, by = 'protein_id') %>%
  select(-protein_id) %>%
  pivot_wider(names_from = 'key', values_from = 'symbol') %>%
  select(!edge_id) %>% 
  drop_na()
rm(alias)
graph <- graph_from_edgelist(as.matrix(STRING), directed = FALSE) %>%
  simplify(remove.loops = TRUE, remove.multiple = TRUE) %>%
  delete.vertices(which(degree(.) == 0))
save(graph, file = paste0('data/string/graph_', conf_level * 10, '.Rdata'))
rm(list = c('graph', 'STRING'))

# Load disease-related genes
conn <- dbConnect(RSQLite::SQLite(), 'original_data/disgenet/disgenet_2020.db')
disease <- tbl(conn, 'disease2class') %>%
  left_join(tbl(conn, 'diseaseAttributes'), by = 'diseaseNID') %>%
  left_join(tbl(conn, 'diseaseClass'), by = 'diseaseClassNID') %>%
  collect()
mappings <- data.table::fread('original_data/disgenet/disease_mappings.tsv.gz') %>%
  filter(vocabulary == 'MSH') %>%
  select(diseaseId, code) %>%
  rename(mesh_id = 'code') %>%
  distinct() %>%
  # we only retain the mesh ids started with "D"
  filter(str_starts(mesh_id, 'D'))
gene_disease <- tbl(conn, 'geneDiseaseNetwork') %>%
  left_join(tbl(conn, 'diseaseAttributes'), by = 'diseaseNID') %>%
  left_join(tbl(conn, 'geneAttributes'), by = 'geneNID') %>%
  filter(score > conf_level / 100) %>%
  select(geneName, diseaseId) %>%  # No diseaseName
  collect() %>%
  left_join(mappings, by = 'diseaseId') %>%
  drop_na() %>%
  distinct() %>%
  select(-diseaseId) %>%
  mutate(geneName = update.gene.symbol(geneName)) %>%
  distinct()
# gene_disease <- split(gene_disease$geneName, gene_disease$mesh_id)
save(gene_disease, file = paste0('data/disgenet/gene_disease_', conf_level, '.Rdata'), compress = 'xz')
dbDisconnect(conn)
rm(list = c('gene_disease', 'drug_indication_list', 'disease', 'mappings', 'conf_level', 'conn'))

# Load drug-related genes
conn <- dbConnect(RSQLite::SQLite(), 'original_data/chembl/chembl_32/chembl_32_sqlite/chembl_32.db')

chembl_targets <- tbl(conn, 'chembl_id_lookup') %>%
  filter(status == 'ACTIVE' & entity_type == 'COMPOUND') %>%
  # inner_join(tbl(conn, 'drugs'), by = 'chembl_id') %>%
  inner_join(tbl(conn, 'drug_mechanism') %>%
               rename(entity_id = molregno), by = 'entity_id') %>%
  # select(drugbank_id, chembl_id, tid) %>%
  # rename(drug_id = drugbank_id) %>%
  left_join(tbl(conn, 'chembl_id_lookup') %>%
              filter(status == 'ACTIVE' & entity_type == 'TARGET') %>%
              select(chembl_id, entity_id) %>%
              rename(target = chembl_id, tid = entity_id), by = 'tid') %>%
  select(chembl_id, target) %>%
  collect() %>%
  left_join(extracted_names, by = 'chembl_id') %>%
  left_join(read_csv('original_data/chembl/chembl_target.csv', na = '', show_col_types = FALSE) %>%
              select(target, hgnc_symbol) %>%
              drop_na() %>%
              distinct(), by = 'target', relationship = 'many-to-many') %>%
  select(drug_id, hgnc_symbol) %>%
  filter(hgnc_symbol != '') %>%
  drop_na() %>%
  rename(target = hgnc_symbol)
save(chembl_targets, file = 'data/chembl/chembl_targets.Rdata')

load('data/drugbank/db_targets.Rdata')
load("data/combined_names/combined.Rdata")
extracted_names <- lapply(names(extracted_names), function(drug_id) {
  drug_names <- extracted_names[[drug_id]]
  db_id <- drug_names[str_starts(drug_names, 'DB')]
  drug_id <- str_replace_all(drug_id, 'drugdrug', '')
  if (length(db_id)) {
    data.frame(drug_id = drug_id,
               db_id = db_id)
  } else {
    data.frame(drug_id = character(), db_id = character())
  }
}) %>% bind_rows()
drug_targets <- left_join(rename(db_targets, db_id = 'drug_id'), extracted_names, by = 'db_id') %>%
  select(-db_id) %>%
  rename(target = 'gene_target') %>%
  bind_rows(chembl_targets) %>%
  mutate(target = update.gene.symbol(target)) %>%
  drop_na() %>%
  distinct()
dbDisconnect(con)

# Save final drug target information
save(drug_targets, file = 'data/network/drug_targets.Rdata')
rm(list = c('db_targets', 'chembl_targets', 'drugs', 'extracted_names', 'drug_targets', 'conn'))

# Compute ADR effects
# Random walk: starting node (drug targets)
load('data/string/graph_400.Rdata')
load('data/network/drug_targets.Rdata')
load('data/network/drug_indication_list.Rdata')
drug_targets <- filter(drug_targets, target %in% V(graph)$name)
drug_list <- split(drug_targets$target, drug_targets$drug_id)
network <- as_adjacency_matrix(graph, type = 'both', sparse = TRUE)

# speadr packaeg was modified
cl <- parallel::makeCluster(6)
parallel::clusterExport(cl, 'network')
op <- pbapply::pboptions(type = 'txt', txt.width = 300)
genes_pt <- pbapply::pblapply(drug_list, function(initial) {
  # Sys.sleep(runif(1, min = 0, max = 10))
  p0 <- (colnames(network) %in% initial) / length(initial)
  mat <- as.matrix(network)
  results <- diffusr::random.walk(p0, mat, r = 0, thresh = 1e-4)$p.inf[, 1]
  rm(mat)
  invisible(gc(verbose = FALSE))
  return(results)
}, cl = cl)
save(genes_pt, file = 'data/string/genes_pt.Rdata', compress = 'xz')
parallel::stopCluster(cl)

load('data/disgenet/gene_disease_40.Rdata')
gene_disease <- split(gene_disease$geneName, gene_disease$mesh_id)
nodes <- colnames(network)
cl <- parallel::makeCluster(16)
parallel::clusterExport(cl, c('nodes', 'gene_disease'))
drug_adr <- pbapply::pbsapply(genes_pt, function(pt) {
  adr <- sapply(gene_disease, function(disease) {
    sum(pt[nodes %in% disease])
  })
  return(adr)
}, cl = cl)
parallel::stopCluster(cl)
save(drug_adr, file = 'data/network/drug_adr.Rdata', compress = 'xz')
rm(list = ls())

####################### THIRD STEP: construct disease-trial network
mesh_terms <- data.table::fread('data/mesh/mesh.csv')
trial_files <- list.files('original_data/central/', pattern = '.csv',full.names = TRUE, recursive = TRUE)
cl <- parallel::makeCluster(16)
parallel::clusterExport(cl, 'mesh_terms')
parallel::clusterEvalQ(cl, library(tidyverse))
trial_disease <- pbapply::pblapply(trial_files, function(tf) {
  dat <- data.table::fread(tf, header = TRUE) %>%
    select(Keywords, DOI) %>%
    mutate(Keywords = str_to_lower(Keywords)) %>%
    drop_na()
  
  if (nrow(dat)) {
    trial_disease <- lapply(1:nrow(dat), function(i) {
      keywords <- str_split(dat$Keywords[i], ';') %>%
        unlist() %>%
        str_replace_all("\\[.*?\\]", '') %>%
        trimws()
      disease <- mesh_terms$mesh_id[mesh_terms$term %in% keywords]
      if (length(disease)) {
        data.frame(disease = disease,
                   doi = dat$DOI[i])
      }
    }) %>% bind_rows() %>%
      distinct()
  } else {
    trial_disease <- data.frame(disease = character(0),
                                doi = character(0))
  }
  return(trial_disease)
}, cl = cl) %>% bind_rows()
trial_disease <- filter(trial_disease, doi != '') %>%
  mutate(doi = str_to_lower(doi)) %>%
  distinct() %>%
  arrange(disease)
parallel::stopCluster(cl)
save(trial_disease, file = 'data/network/trial_disease.Rdata', compress = 'xz')
## FAILED. Just read all nodes information. 

####################### FOURTH STEP: compute sigma

# list the first three characters in each row
conn <- dbConnect(RSQLite::SQLite(), 'original_data/wos/info.db')
months <- tbl(conn, 'info') %>%
  select(pub_date) %>%
  mutate(pub_date = str_sub(pub_date, end = 3)) %>%
  distinct() %>%
  collect()
dbDisconnect(conn)
rm(months)

# convert date string to datetime
season <- list('FAL' = 'SEP', 'WIN' = 'DEC', 'SPR' = 'MAR', 'SUM' = 'JUN')
months <- str_to_upper(month(1:12, label = TRUE))
string_to_date <- function(dates) {
  month_set <- str_sub(dates, start = 1, end = 3)
  has_day <- rep(TRUE, length(month_set))
  replaced_month <- (month_set %in% names(season))
  dates <- str_replace_all(dates, '[.]|,|;', ' ') %>%
    trimws() %>%
    str_replace('AUG1', 'AUG 1') %>%
    str_replace('JULY1', 'JUL 1') %>%
    str_replace('OCT1', 'OCT 1') %>%
    str_replace('SEPT1', 'SEP 1') %>%
    str_replace('AUG.JAN', 'JAN') %>%
    str_replace('DEC 13 20 2021', 'DEC 13 2021') %>%
    str_replace('FEB 29', 'MAR 1')
  dates[replaced_month] <- sapply(dates[replaced_month], 
                                  function(pub_date) {
                                    month <- str_sub(pub_date, start = 1, end = 3)
                                    pub_date <- str_replace(pub_date, month, season[[month]])
                                    })
  has_day[!(month_set %in% months | replaced_month)] <- FALSE
  #sapply(dates, function(pub_date) {
  #  month <- str_sub(pub_date, start = 1, end = 3)
  #  has_day <- TRUE
  #  if (month %in% names(season)) {
  #    pub_date <- str_replace(pub_date, month, season[[month]])
  #  } else if (!month %in% months) {
  #    has_day <- FALSE
  #  }
  #  if (has_day) {
  #    return(mdy(pub_date))
  #  } else {
  #    return(my(pub_date))
  #  }
  #}) %>% unname()
  pub_date <- rep(0, length(dates))
  pub_date[has_day] <- mdy(dates[has_day])
  pub_date[!has_day] <- my(dates[!has_day])
  return(pub_date)
}
compute_sigma <- function(drug.id) {
  file_path <- paste0('D:/models/citations/', drug.id, '.tsv')
  if (file.exists(file_path)) {
    edge_network <- data.table::fread(file_path, header = FALSE, fill = TRUE, sep = '\t') %>%
      rename(from = 1, to = 2)
    
    query_dois <- unique(edge_network$from)
    # all_dois <- unique(c(edge_network$from, edge_network$to))
    conn <- DBI::dbConnect(RSQLite::SQLite(), 'original_data/wos/info.db')
    
    # How to compute sigma?
    # https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7758403/
    # Sigma = (betweenness centrality + 1)^burstness
    # sigma_3 = \sqrt[3]{\rho_burst * \rho_centrality * \rho_citation}
    
    # Compute betweenness
    edge_graph <- graph_from_data_frame(edge_network)
    centrality <- betweenness(edge_graph, query_dois)
    
    # Compute burstness
    information <- tbl(conn, 'info') %>%
      filter(drug_id == drug.id && doi %in% query_dois) %>%
      select(doi, pub_date, cite_count) %>%
      collect() %>%
      left_join(tibble(doi = query_dois, centrality = centrality), by = 'doi') %>%
      mutate(pub_date = string_to_date(pub_date)) %>%
      drop_na()
    
    # NOTE: as_date() function can convert it into datetime format
    
    # make reverse queries
    reversed <- edge_network %>%
      filter(to %in% query_dois)
    reversed_doi <- pull(reversed, from) %>%
      unique()
    
    reversed_id <- tbl(conn, 'info_doi') %>%
      filter(doi %in% reversed_doi) %>%
      collect() %>%
      filter(!duplicated(.$doi)) %>%
      pull(row_id)
    reversed_information <- tbl(conn, 'info') %>%
      filter(row_id %in% reversed_id) %>%
      select(doi, pub_date, cite_count) %>%
      collect() %>%
      mutate(pub_date = string_to_date(pub_date),
             centrality = betweenness(edge_graph, .$doi))
    information <- bind_rows(information, reversed_information) %>%
      distinct()
    
    
    # A cited B <=> A->B
    # get A's burst
    # for convenience, we just find the maximum value of the identified bursts
    # burstness = max(end) / current_date, where current_date = 19500 ("2023-05-23")
    burstness <- split(reversed, reversed$to) %>%
      lapply(function(x) {
        nodes <- unique(unname(unlist(x)))
        pub_date <- filter(information, doi %in% nodes) %>%
          pull(pub_date) %>%
          sort()
        # I don't know why there are duplicated nodes. add some more offsets
        offsets <- sum(duplicated(pub_date)) + 1
        pub_date[duplicated(pub_date)] <- pub_date[duplicated(pub_date)] + 1 / offsets * seq(from = 1, to = offsets - 1)
        if (length(pub_date)) {
          bursts <- bursts::kleinberg(pub_date) %>%
            mutate(sig = (end - start) / 19500)
          return(sum(bursts$sig))
        } else {
          return(0)
        }
      }) %>%
      unlist()
    if (length(burstness)) {
      burstness <- burstness %>%
        data.frame(doi = names(.), burstness = .) %>%
        `rownames<-`(NULL)
      inf_w_burstness <- left_join(information, burstness, by = 'doi') %>%
        replace_na(list(burstness = 0))
      
      sigma <- data.frame(drug_id = drug.id,
                          doi = inf_w_burstness$doi, 
                          sigma = (inf_w_burstness$centrality + 1)^inf_w_burstness$burstness,
                          sigma3 = curt(inf_w_burstness$cite_count * inf_w_burstness$centrality * inf_w_burstness$burstness)) %>%
        `rownames<-`(NULL)
    } else {
      # inf_w_burstness <- information
      # inf_w_burstness$burstness <- 0
      sigma <- data.frame()
    }
    
    DBI::dbDisconnect(conn)
  } else {
    sigma <- data.frame()
  }
  return(sigma)
}
curt <- function(x, n = 3) {
  exp((1/n) * log(x))
}

# cl <- parallel::makeCluster(parallel::detectCores())
# parallel::clusterExport(cl, c('compute_sigma', 'curt', 'string_to_date', 'season', 'months'))
# parallel::clusterEvalQ(cl, {
#   library(tidyverse)
#   library(igraph)
# })

library(progressr)
library(future.apply)
plan(future.callr::callr, workers = 16, gc = TRUE)
handlers(global = TRUE)
# handlers("progress")
handlers('debug')
drug_ids <- 1:16716 #sample(1:16716, size = 1670)

calculate_sigma <- function(drug_id, p) {
  p(sprintf("x=%g", drug_id))
  compute_sigma(drug_id)
}

with_progress({
  p <- progressr::progressor(along = drug_ids)
  all_sigmas <- future_lapply(drug_ids, calculate_sigma, p = p, 
                              future.packages = c('tidyverse', 'igraph'))
  # future.globals = c('months', 'season', 'curt', 'string_to_date'))
})

all_sigmas <- all_sigmas %>%
  pbapply::pblapply(function(sigmas) {
    if (ncol(sigmas)) {
      return(filter(sigmas, sigma > 1, sigma3 > 0) %>% drop_na())
    } else {
      return(sigmas)
    }
  }) %>% bind_rows()

save(all_sigmas, file = 'data/network/all_sigmas.Rdata', compress = 'xz')
rm(list = c('season', 'drug_ids', 'months', 'p', 'calculate_sigma', 'compute_sigma', 'curt', 'string_to_date'))

####################### FIFTH STEP: discover literature-disease relationship
load('data/central/triplet_network.Rdata')
load('data/central/trial_details.Rdata')
load('data/combined_names/combined.Rdata')
load('data/network/all_sigmas.Rdata')

trial_details <- drop_na(trial_details) %>%
  mutate(keywords = str_replace_all(keywords, "\\[.*?\\]", ''),
         keywords = str_replace_all(keywords, '; ', ';'))
trial_drug <- split(str_to_lower(trial_details$keywords), trial_details$central_id)
trial_drug <- pbapply::pblapply(trial_drug, function(x) {
  individual_keyword <- str_split(x, ';')
  if (length(individual_keyword)) {
    individual_keyword <- unlist(individual_keyword)
  }
  individual_keyword <- unique(trimws(individual_keyword))
  return(individual_keyword)
})

extracted_names <- lapply(names(extracted_names), function(drug_id) {
  drug_names <- extracted_names[[drug_id]]
  chembl_id <- drug_names[!(str_starts(drug_names, 'CHEMBL') | str_starts(drug_names, 'DB') & str_length(drug_names) == 7)]
  drug_id <- str_replace_all(drug_id, 'drugdrug', '')
  if (length(chembl_id)) {
    data.frame(drug_id = drug_id,
               names = chembl_id)
  } else {
    data.frame()
  }
}) %>% bind_rows() %>%
  mutate(names = str_to_lower(names))

# Map keyword to drug (clinical trials in central)
library(fastmatch)
cl <- parallel::makeCluster(16)
parallel::clusterExport(cl, 'extracted_names')
parallel::clusterEvalQ(cl, library(fastmatch))
trial_drug <- pbapply::pblapply(trial_drug, function(x) {
  extracted_names$drug_id[extracted_names$names %fin% x]
}, cl = cl)

trial_drug <- map(trial_drug, ~length(.x) > 0) %>%
  unlist() %>%
  {.[.]} %>%
  names() %>%
  trial_drug[.]
trial_drug <- lapply(trial_drug, unique)
save(trial_drug, file = 'data/central/trial_drug.Rdata', compress = 'xz')
parallel::stopCluster(cl)
rm(cl)

# Map details to disease (papers)
mesh_terms <- data.table::fread('data/mesh/mesh.csv')
mesh_terms$term <- tokenizers::tokenize_words(mesh_terms$term) %>%
  map(~paste(.x, sep = ' ', collapse = ' ')) %>%
  unlist()

# drug_ids <- sample(1:16716, size = 167)
library(future.apply)
library(progressr)
plan(future.callr::callr, workers = 16, gc = TRUE)
handlers(global = TRUE)
handlers("progress")
# handlers('debug')
drug_ids <- 1:16716 #sample(1:16716, size = 1670)

with_progress({
  p <- progressr::progressor(along = drug_ids)
  literature_mesh <- future_lapply(drug_ids, function(drug.id) {
    p(sprintf("x=%g", drug.id))
    conn <- dbConnect(RSQLite::SQLite(), 'original_data/wos/info.db')
    keywords <- tbl(conn, 'info') %>%
      filter(drug_id == drug.id) %>%
      select(doi, keywords) %>%
      collect() %>%
      mutate(keywords = str_to_lower(keywords),
             keywords = str_replace_all(keywords, '; ', ';')) %>%
      filter(keywords != '', doi != '') #%fin% all_sigmas$doi[all_sigmas$drug_id == drug.id])
    dbDisconnect(conn)
    
    keywords <- split(keywords$keywords, keywords$doi)
    keywords <- lapply(keywords, function(x) {
      individual_keyword <- str_split(x, ';')
      if (length(individual_keyword)) {
        individual_keyword <- unlist(individual_keyword)
      }
      return(individual_keyword)
    }) %>%
      lapply(function(x) {
        tokenizers::tokenize_words(x) %>%
          map(~paste(.x, sep = ' ', collapse = ' ')) %>%
          unlist()
      })
    
    literature_mesh <- lapply(names(keywords), function(doi) {
      keyword <- keywords[[doi]]
      mesh_id <- unique(mesh_terms$mesh_id[mesh_terms$term %fin% keyword])
      if (length(mesh_id)) {
        ret <- data.frame(drug_id = drug.id,
                          doi = doi,
                          mesh_id = mesh_id)
      } else {
        ret <- data.frame()
      }
      return(ret)
    }) %>%
      bind_rows()
  }, future.packages = c('tidyverse', 'DBI', 'fastmatch'))
  # future.globals = c('months', 'season', 'curt', 'string_to_date'))
})
literature_meshid <- bind_rows(literature_meshid) %>%
  mutate(drug_id = as.character(drug_id))
save(literature_meshid, file = 'data/wos/literature_meshid.Rdata', compress = 'xz')
rm(list = c('p', 'drug_ids', 'cl', 'all_sigmas', 'mesh_terms'))

####################### SIXTH STEP: construct the final network
# load('data/network/drug_indication_list.Rdata')
load('data/central/full_network.Rdata')
load('data/central/twoway_network.Rdata')
load('data/wos/literature_meshid.Rdata')

# Combine two-way network from central and wos
central_meshid <- bind_rows(twoway_network) %>%
  select(-level) %>%
  rename(drug_id = 1, mesh_id = 2) %>%
  mutate(drug_id = as.numeric(drug_id),
         mesh_id = str_to_upper(mesh_id))

central_meshid <- pbapply::pblapply(names(full_network), function(drug_id) {
  drug_info <- full_network[[drug_id]]
  mesh_trials <- filter(drug_info, level == 2) %>%
    select(-level) %>%
    split(.$from) %>%
    map(~unique(.x$to))
  trial_paper <- filter(drug_info, level == 3) %>%
    select(-level)
  
  trial_paper_network <- lapply(names(mesh_trials), function(mesh_id) {
    trials <- mesh_trials[[mesh_id]]
    # trials <- mesh_trials[[7]]
    papers <- trial_paper$to[trial_paper$from %fin% trials]
    if (length(papers)) {
      ret <- data.frame(doi = papers, mesh_id = mesh_id)
    } else {
      ret <- data.frame()
    }
    return(ret)
  }) %>% bind_rows()
  if (nrow(trial_paper_network)) {
    trial_paper_network$drug_id <- drug_id
  }
  return(trial_paper_network)
}) %>% bind_rows() %>%
  relocate(drug_id)
save(central_meshid, file = 'data/central/central_meshid.Rdata', compress = 'xz')
rm(list = c('twoway_network', 'full_network'))

# Load sigmas
load('data/network/all_sigmas.Rdata')
all_sigmas <- mutate(all_sigmas, drug_id = as.character(drug_id)) %>%
  group_by(drug_id, doi) %>%
  summarize(sigma = mean(sigma), sigma3 = mean(sigma3))
literature_meshid <- left_join(literature_meshid, all_sigmas, by = c('drug_id', 'doi')) %>%
  replace_na(list(sigma = 1, sigma3 = 0))
central_meshid <- left_join(central_meshid, all_sigmas, by = c('drug_id', 'doi')) %>%
  replace_na(list(sigma = 1, sigma3 = 0))

lit_network <- group_by(literature_meshid, drug_id, mesh_id) %>%
  summarize(n = n(), sigma = sum(sigma), sigma3 = sum(sigma3)) %>%
  mutate(sigma = sigma / n, sigma3 = sigma3 / n)
ct_network <- group_by(central_meshid, drug_id, mesh_id) %>%
  summarize(n = n(), sigma = sum(sigma), sigma3 = sum(sigma3)) %>%
  mutate(sigma = sigma / n, sigma3 = sigma3 / n)

# integrate the network
tm_network <- full_join(
  rename(lit_network, sigma_lit = 'sigma', sigma3_lit = 'sigma3', n_lit = 'n'),
  rename(ct_network, sigma_ct = 'sigma', sigma3_ct = 'sigma3', n_ct = 'n'),
  by = c('drug_id', 'mesh_id')
) %>%
  replace_na(list(n_lit = 0, n_ct = 0,
                  sigma_lit = 1, sigma_ct = 1,
                  sigma3_lit = 0, sigma3_ct = 0))

save(tm_network, file = 'data/network/tm_network.Rdata', compress = 'xz')

# combine the weight of the networks except the prior biological knowledge
# Finally, I decided to use Sigma instead of sigma3
load('data/network/drug_indication_list.Rdata')
final_network <- mutate(tm_network, sigma = mean(c(sigma_lit, sigma_ct))) %>%
  select(drug_id, mesh_id, sigma) %>%
  full_join(drug_indication_list, by = c('drug_id', 'mesh_id')) %>%
  replace_na(list(weight = 0.5, sigma = 1))
rm(list = c('all_sigmas', 'drug_indication_list', 'central_meshid', 'literature_meshid', 
            'lit_network', 'ct_network'))

# include the prior biological knowledge
load('data/interactome/background.Rdata')

graph <- simplify(graph, remove.loops = TRUE, remove.multiple = TRUE) %>%
  delete.vertices(which(degree(.) == 0))
save(graph, file = 'data/interactome/graph.Rdata', compress = 'xz')

load('data/interactome/graph.Rdata')
calculate_between <- function(graph, set_a, set_b) {
  estimate_between <- c(shortest.paths(graph, v = set_a, to = set_b) %>%
                          matrixStats::colMins(),
                        shortest.paths(graph, v = set_b, to = set_a) %>%
                          matrixStats::colMins())
  return(mean(estimate_between))
}
calculate_within <- function(graph, given_set) {
  if (length(given_set) > 1) {
    within <- shortest.paths(graph, v = given_set, to = given_set) %>%
      apply(2, function(x) {
        x[order(x)][2]
      }) %>% mean()
  } else {
    within <- 0
  }
  return(within)
}

# construct the distance matrix
load('data/disgenet/gene_disease_40.Rdata')
drug_targets <- filter(drug_targets, target %fin% V(graph)$name)
drug_list <- split(drug_targets$target, drug_targets$drug_id)
gene_disease <- filter(gene_disease, geneName %fin% V(graph)$name)
disease_list <- split(gene_disease$geneName, gene_disease$mesh_id)

cl <- parallel::makeCluster(16)
parallel::clusterExport(cl, c('graph', 'disease_list', 'calculate_between', 'calculate_within'))
parallel::clusterEvalQ(cl, {
  library(tidyverse)
  library(igraph)
})
# op <- pbapply::pboptions(type = 'txt', txt.width = 300)
disease_within <- map_dbl(disease_list, ~calculate_within(graph, .x))
drug_within <- map_dbl(drug_list, ~calculate_within(graph, .x))

disease_drug_between <- pbapply::pbsapply(drug_list, function(targets) {
  between <- map_dbl(disease_list, ~calculate_between(graph, targets, .x))
}, cl = cl)
within_a <- t(rep(disease_within, length(drug_list)) %>% matrix(ncol = length(drug_list)))
within_b <- rep(drug_within, length(disease_list)) %>% matrix(ncol = length(disease_list))
disease_drug_separation <- t(disease_drug_between) - (within_a + within_b) / 2

save(disease_drug_separation, file = 'data/network/drug_disease_separation.Rdata', compress = 'xz')
parallel::stopCluster(cl)
rm(list = c('cl', 'disease_within', 'drug_within', 'within_a', 'within_b', 'disease_drug_between',
            'disease_list', 'gene_disease', 'drug_list', 'drug_targets'))

# normalize the separation to [4, 1]
# disease_drug_separation <- scales::rescale(disease_drug_separation, to = c(4, 1))

# normalize the sigma to [1, 4]
# final_network$sigma <- scales::rescale(final_network$sigma, to = c(1, 4))

drug_disease_weight <- data.frame(
  drug_id = rep(rownames(disease_drug_separation), ncol(disease_drug_separation)),
  mesh_id = map(colnames(disease_drug_separation), ~rep(.x, nrow(disease_drug_separation))) %>% unlist(),
  separation = as.vector(disease_drug_separation)
) %>% left_join(final_network, by = c('drug_id', 'mesh_id'))

# get the median and MAD using the sigma except 1.00
sigmas <- drug_disease_weight %>%
  select(drug_id, mesh_id, sigma) %>%
  drop_na() %>%
  mutate(sigmas = predict(bestNormalize::yeojohnson(sigma)))
sigmas$sigmas <- (sigmas$sigmas - median(sigmas$sigmas)) / mad(sigmas$sigmas)

drug_disease_weight <- select(drug_disease_weight, -sigma) %>%
  left_join(sigmas, by =  c('drug_id', 'mesh_id')) %>%
  replace_na(list(sigma = 0.99, sigmas = -1.31, weight = 0.4)) %>%
  mutate(
    sigmas = pnorm(sigmas) + 1,
    separations = pnorm(labyrinth::robust_zscore(predict(bestNormalize::yeojohnson(separation))), lower.tail = FALSE) + 1,
    score = sqrt(sigmas * separations) - 1
  )
# drug_disease_weight$log_score[drug_disease_weight$score == 0] <- 0

save(drug_disease_weight, file = 'data/network/drug_disease_weight.Rdata', compress = 'xz')
# c <- bestNormalize::yeojohnson(enormous_network$sigma)
# c <- predict(c)
# nortest::ad.test(enormous_network$sigma)

a <- filter(drug_disease_weight, mesh_id == 'D000437') %>% arrange(desc(score))
b <- filter(drug_disease_weight, mesh_id == 'D001943') %>% arrange(desc(score))

b <- suppressMessages({
  a %>%
    
})

a <- suppressMessages({
  drug_disease_weight %>%
    mutate(weight = if_else(weight > 3, 1, 0)) %>%
    pROC::roc(weight, score)
})
a
plot(a)
a %>%
  mutate(weight = if_else(weight > 3, 1, 0)) %>%
  ggplot(aes(x = weight, y = sum_weights)) +
  geom_smooth(method = "lm", se=FALSE, 
              color="black", formula = y ~ x) +
  geom_point()

pROC::roc(a$sum_weights, a$weight)
class_weight <- mutate(drug_disease_weight, weight = case_when(weight < 2 ~ 1, .default = round(weight, 1)))
b <- pROC::multiclass.roc(class_weight$weight, class_weight$score)

bb <- mutate(enormous_network,
             sigmas = sqrt(sigma)) %>%
  filter(mesh_id == 'D001943') %>% arrange(-sum_weight)
