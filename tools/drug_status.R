library(tidyverse)

# Read drug indications data from ChEMBL
con <- DBI::dbConnect(RSQLite::SQLite(), 'original_data/chembl/chembl_32/chembl_32_sqlite/chembl_32.db')
drug_indication <- tbl(con, 'drug_indication') %>%
  left_join(select(tbl(con, 'molecule_dictionary'), molregno, chembl_id), by = 'molregno') %>%
  select(chembl_id, mesh_id, max_phase_for_ind) %>%
  collect()
save(drug_indication, file = 'data/chembl/drug_indications.Rdata')

# Map ChEMBL ID to drug_id
load("data/combined_names/map_chembl_to_id.Rdata")
drug_status <- left_join(drug_indication, map_chembl_to_id, by = 'chembl_id') %>%
  select(-chembl_id) %>%
  drop_na() %>%
  mutate(mesh_id = str_to_lower(mesh_id))

# Load the network and add initial weights
load("data/central/full_network.Rdata")
initial_weights <- lapply(names(full_network), function(drug_id) {
  drug_network <- full_network[[drug_id]]
  status <- drug_status[drug_status$drug_id == drug_id, ] %>%
    filter(max_phase_for_ind > 0) %>%
    rename(weight = 'max_phase_for_ind') %>%
    select(-drug_id)
  weights <- full_network[[drug_id]] %>%
    filter(level == 1) %>% pull(to) %>%
    unique() %>%
    data.frame(mesh_id = .)
  
  if (nrow(status)) {
    weights <- full_join(weights, status, by = 'mesh_id') %>%
      mutate(weight = replace_na(weight, 0),
             weight = as.integer(weight))
  } else {
    weights <- mutate(weights, weight = 0)
  }
  return(weights)
})

