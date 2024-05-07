library(word2vec)
library(tokenizers)
library(tidyverse)
library(fastmatch)
library(progressr)
library(future)
library(furrr)

compiler::enableJIT(3)

# Read stopwords
stopwords <- read_lines('data/stopwords/stopword_list.txt')
# Replace diseases to mesh IDs
mesh_terms <- read.csv('data/mesh/mesh.csv') %>%
  mutate(term = str_replace_all(term, '[[:punct:][:blank:]]+', ' '),
         mesh_id = paste0('MESHMESH', mesh_id)) %>%
  distinct() %>%
  split(.$mesh_id) %>%
  map(~ as.list(.$term)) %>%
  # map(~ str_split(.x, ' '))
  map(~ tokenize_words(.x)) %>%
  map(~ unique(.x))
drug_names <- read_lines('output/query_words.txt') %>%
  str_replace_all('[[:punct:][:blank:]]+', ' ') %>%
  as.list() %>%
  str_split(' OR ') %>%
  map(~ str_replace_all(.x, '"', '')) %>%
  map(~ tokenize_words(.x)) %>%
  set_names(paste0('DRUGDRUG', seq_along(.)))

## Function: 
# Replace diseases to mesh IDs
# Replace drugs to drug IDs
batch_replace <- function(text, mesh_terms) {
  # for each row, match with the mesh terms
  mesh_match <- list()
  ## search
  for (mh_name in names(mesh_terms)) {
    mesh_names <- mesh_terms[[mh_name]]    # cache different names of the same ID
    mesh_match[[mh_name]] <- c()
    # a list inside of this huge list
    mesh_name <- c()
    mh_match <- lapply(mesh_names, function(term) {
      term_match <- fmatch(term, text)
      return(term_match[!is.na(term_match)])
    })
    for (mh_id in seq_along(mh_match)) {
      mh <- mh_match[[mh_id]]
      if (length(mh) == length(mesh_names[[mh_id]])) {
        if (sum(mh == (seq_along(mh) + (mh[1] - 1))) == length(mh)) {
          mesh_match[[mh_name]] <- c(mesh_match[[mh_name]], list(mh))
        }
      }
    }
  }
  ## go through the whole match list
  ## 
  if (length(mesh_match)) {
    mesh_replacement <- lapply(mesh_match, function(mesh) {
      sapply(mesh, first)
    })
    mesh_removal <- unlist(mesh_match) %>%
      sort() %>%
      unique() %>%
      {.[is.na(fmatch(., mesh_replacement))]}
    # replace the "replacement"
    for (rep_name in names(mesh_replacement)) {
      for (rep_list in mesh_replacement[[rep_name]]) {
        for (rep in rep_list) {
          text[rep] <- rep_name
        }
      }
    }
    # delete the "removal"
    if (length(mesh_removal))
      text <- text[-mesh_removal]
  }
  return(text)
} %>% compiler::cmpfun()

handlers(list(
  handler_progress(
    format   = ":current/:total [:bar] :percent in :elapsed ETA: :eta",
    width    = 120,
    complete = "="
  )
))

#### Main function starts here:
plan(multisession, gc = TRUE)

names(drug_names) <- tolower(names(drug_names))
names(mesh_terms) <- tolower(names(mesh_terms))

save(mesh_terms, file = 'data/mesh/mesh.Rdata')

# core function: wrap it to function
save_unprocessed_data <- function() {
  con <- DBI::dbConnect(RMariaDB::MariaDB(), dbname = 'wos', host = '192.168.85.146', 
                        user = 'root', password = 'root')
  # For each drug, compute its disease IDs
  drug_id_list <- tbl(con, 'info_id') %>%
    select('drug_id') %>%
    distinct() %>%
    collect() %>%
    pull(drug_id) %>%
    as.character()
  
  # load existing progress
  existing_models <- list.files('models/splitted', full.names = FALSE, pattern = '.Rdata') %>%
    str_replace_all('.Rdata', '')
  drug_id_list <- sort(drug_id_list) %>%
    {.[!. %in% existing_models]}
  
  info_id <- tbl(con, 'info_id') %>%
    collect() %>%
    split(.$drug_id) %>%
    map(~.x$row_id)
  
  DBI::dbDisconnect(con)
  p <- progressor(steps = length(drug_id_list))
  future_walk(drug_id_list, function(drug) {
    con <- DBI::dbConnect(RMariaDB::MariaDB(), dbname = 'wos', host = 'localhost', 
                          user = 'root', password = 'root')
    
    # cat(drug, '\n')
    rows <- info_id[[drug]]
    info <- tbl(con, 'info') %>%
      filter(row_id %in% rows) %>%
      select(c(title:keywords)) %>%
      collect() %>%
      apply(1, paste, collapse = ' ') %>%
      as.list() %>%
      tokenize_words()
    
    p()
    save(info, file = paste0('models/splitted/', drug, '.Rdata'))
    
    DBI::dbDisconnect(con)
  }, .options = furrr_options(seed = TRUE))
}

save_skipgram <- function() {
  # load existing progress
  existing_models <- c(list.files('models/drugs', full.names = FALSE, pattern = '.Rdata'),
                       list.files('models/mesh', full.names = FALSE, pattern = '.Rdata')) %>%
    str_replace_all('.Rdata', '')
  drug_id_list <- list.files('models/splitted', full.names = FALSE, pattern = '.Rdata') %>%
    str_replace_all('.Rdata', '') %>%
    {.[!. %in% existing_models]}
  
  p <- progressor(steps = length(drug_id_list))
  future_walk(drug_id_list, function(drug) {
    # cat(drug, '\n')
    load(file.path('models/splitted', paste0(drug, '.Rdata')))
    info <- lapply(info, function(text) {
      text <- batch_replace(text, mesh_terms)
      text <- batch_replace(text, drug_names)
    })
    
    info <- map(info, paste, collapse = ' ') %>%
      tokenize_word_stems(stopwords = stopwords) %>%
      map(~paste(.x, collapse = ' ')) %>%
      unlist()
    
    save(info, file = paste0('models/replaced/', drug, '.Rdata'))
    p()
    models <- word2vec(info, type = 'skip-gram', dim = 300, threads = 1)
    # Predict and save drug correlations
    pred_drug <- predict(models, names(drug_names), type = 'embedding') %>% na.omit()
    if (nrow(pred_drug)) {
      pred_drug <- lapply(seq_len(nrow(pred_drug)), function(i) pred_drug[i, ]) %>%
        set_names(rownames(pred_drug))
      save(pred_drug, file = paste0('models/drugs/', drug, '.Rdata'))
    }
    
    # Predict and save mesh correlations
    pred_mesh <- predict(models, c(paste0('drugdrug', drug), names(mesh_terms)), type = 'embedding') %>% 
      na.omit()
    if (nrow(pred_mesh)) {
      pred_mesh <- lapply(seq_len(nrow(pred_mesh)), function(i) pred_mesh[i, ]) %>%
        set_names(rownames(pred_mesh))
      save(pred_mesh, file = paste0('models/mesh/', drug, '.Rdata'))
    }
  }, .options = furrr_options(seed = TRUE))
}

with_progress(save_unprocessed_data())
with_progress(save_skipgram())
