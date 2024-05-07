# Read the network into memory
library(tidyverse)
library(igraph)
library(DBI)
compute_sigma <- function(drug.id) {
  edge_network <- data.table::fread(paste0('D:/models/citations/', drug.id, '.tsv'), header = FALSE) %>%
    rename(from = 1, to = 2)
  
  query_dois <- unique(edge_network$from)
  # all_dois <- unique(c(edge_network$from, edge_network$to))
  conn <- dbConnect(RSQLite::SQLite(), 'original_data/wos/info.db')
  
  # How to compute sigma?
  # https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7758403/
  # Sigma = (betweenness centrality + 1)^burstness
  # sigma_3 = \sqrt[3]{\rho_burst * \rho_centrality * \rho_citation}
  
  # Compute betweenness
  edge_graph <- graph_from_data_frame(edge_network)
  centrality <- betweenness(edge_graph, query_dois)
  
  # convert date string to datetime
  string_to_date <- function(string_collection) {
    sapply(string_collection, function(pub_date) {
      switch (str_count(pub_date, ' '),
              my(pub_date),
              mdy(pub_date)
      )
    }) %>% unname()
  }
  # Compute burstness
  information <- tbl(conn, 'info') %>%
    filter(drug_id == drug.id && doi %in% query_dois) %>%
    select(doi, pub_date, cite_count) %>%
    collect() %>%
    left_join(tibble(doi = query_dois, centrality = centrality), by = 'doi') %>%
    mutate(pub_date = string_to_date(pub_date))
  
  # NOTE: as_date() function can convert it into datetime format
  
  # make reverse queries
  reversed <- edge_network %>%
    filter(to %in% query_dois)
  reversed_doi <- pull(reversed, from) %>%
    unique()
  
  reversed_information <- tbl(conn, 'info_doi') %>%
    filter(doi %in% reversed_doi) %>%
    collect() %>%
    filter(!duplicated(.$doi)) %>%
    pull(row_id)
  reversed_information <- tbl(conn, 'info') %>%
    filter(row_id %in% reversed_information) %>%
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
      burst <- max(bursts::kleinberg(pub_date)$end)
      return(burst / 19500)
    }) %>%
    unlist() %>%
    data.frame(doi = names(.), burstness = .) %>%
    `rownames<-`(NULL)
  
  inf_w_burstness <- information %>%
    left_join(burstness, by = 'doi') %>%
    replace_na(list(burstness = 0))
  
  curt <- function(x, n = 3) {
    exp((1/n) * log(x))
  }
  sigma <- data.frame(doi = inf_w_burstness$doi,
                      sigma = (inf_w_burstness$centrality + 1)^inf_w_burstness$burstness,
                      sigma3 = curt(inf_w_burstness$cite_count * inf_w_burstness$centrality * inf_w_burstness$burstness)) %>%
    `rownames<-`(NULL)
  dbDisconnect(conn)
  return(sigma)
}

drug_id <- 1
all_sigmas <- compute_sigma(drug_id)

