library(tidyverse)
Sys.setenv(http_proxy="http://127.0.0.1:1081")
Sys.setenv(https_proxy="http://127.0.0.1:1081")
library(TCGAbiolinks)
projects <- TCGAbiolinks:::getGDCprojects()$project_id
projects <- projects[grepl("^TCGA", projects, perl = TRUE)]

setwd('F:/labyrinth-ext')

# ############################################################
# TCGAbiolinks:::getProjectSummary('TCGA-COAD')
clinical_data <- GDCquery(
  project = projects, 
  data.category = 'Clinical',
  # data.type = 'Clinical Supplement', 
  data.format = 'BCR Biotab'
)
GDCdownload(clinical_data, method = 'client')
clinical <- GDCprepare(clinical_data, summarizedExperiment = FALSE)
save(clinical, file = 'original_data/tcga/clinical.Rdata', compress = 'xz')


# ############################################################
# Then process the downloaded clinical data
load('original_data/tcga/clinical.Rdata')
library(dataPreparation)
clinical <- lapply(clinical, function(x) {
  x[-(1:2), ]
})

# patient data
patients <- (function(x) {
  cancer_type <- str_split(x, '_') %>%
    map_chr(~tail(.x, 1)) %>% unique()
  return(paste0('clinical_patient_', cancer_type))
  })(names(clinical)) %>%
  {clinical[.]} %>%
  map(~mutate(.x, across(contains('uuid'), str_to_lower),
              across(everything(), ~na_if(., '[Not Available]')),
              across(everything(), ~na_if(., '[Not Applicable]')),
              across(everything(), ~na_if(., '[Not Evaluated]')),
              across(everything(), ~na_if(., '[Unknown]')))) %>%
  set_names(str_replace_all(names(.), 'clinical_patient_', '')) %>%
  compact() %>%
  map(~un_factor(.x) %>% find_and_transform_numerics() %>% find_and_transform_dates()) %>%
  map(~(function(dt, limit) {
    factor_cols <- lapply(dt, function(x) {
      len <- limit + 1
      if (!typeof(x) %in% c('integer', 'numeric', 'double')) {
        len <- table(x) %>% length()
        if (is.na(len) | is.null(len)) {
          len <- 0
        }
      }
      return(len)
    }) %>% 
      {.[. <= limit & . > 0]} %>%
      names()
    return(mutate(dt, across(any_of(factor_cols), as.factor)))
  })(.x, limit = 42)) %>% lapply(function(patient) {
    # remove all NAs and all same values
    select(patient, where(~any(!is.na(.x)))) %>%
      select(where(~n_distinct(.x) > 1))
  })

# follow-ups
follow_ups <- clinical[str_starts(names(clinical), 'clinical_follow_up_')] %>%
  map(~mutate(.x, across(contains('uuid'), str_to_lower),
              across(everything(), ~na_if(., '[Not Available]')),
              across(everything(), ~na_if(., '[Not Applicable]')),
              across(everything(), ~na_if(., '[Not Evaluated]')),
              across(everything(), ~na_if(., '[Unknown]'))))
disease <- str_split(names(follow_ups), '_') %>%
  map_chr(last)
follow_ups <- lapply(cancer_type, function(type) {
  bind_rows(follow_ups[disease == type])
}) %>% set_names(cancer_type) %>%
  compact() %>%
  map(~un_factor(.x) %>% find_and_transform_numerics() %>% find_and_transform_dates()) %>%
  map(~(function(dt, limit) {
    factor_cols <- lapply(dt, function(x) {
      len <- limit + 1
      if (!typeof(x) %in% c('integer', 'numeric', 'double')) {
        len <- table(x) %>% length()
        if (is.na(len) | is.null(len)) {
          len <- 0
        }
      }
      return(len)
    }) %>% 
      {.[. <= limit & . > 0]} %>%
      names()
    return(mutate(dt, across(any_of(factor_cols), as.factor)))
  })(.x, limit = 42)) %>% lapply(function(patient) {
    # remove all NAs and all same values
    select(patient, where(~any(!is.na(.x)))) %>%
      select(where(~n_distinct(.x) > 1))
  })

# other data
clinical_type <- c('omf', 'drug', 'nte', 'radiation')  # remove ablation & patient
# Check for the selection coverage
lapply(paste0('clinical_', clinical_type), function(x) {
  str_starts(names(clinical), pattern = x)
}) %>% pmap_int(sum)
# integrate these data
clinical <- lapply(clinical_type, function(type) {
  type <- paste0('clinical_', type)
  sub_names <- str_starts(names(clinical), type)
  sub_data <- clinical[sub_names] %>%
    set_names(names(clinical[sub_names]) %>%
                str_split('_') %>%
                map_chr(last)) %>%
    map2(names(.), \(x,y) mutate(x, cancer = y)) %>%
    bind_rows() %>%
    relocate(cancer)
  return(sub_data)
}) %>%
  set_names(clinical_type) %>%
  compact() %>%
  map(~mutate(.x, across(contains('uuid'), str_to_lower),
              across(everything(), ~na_if(., '[Not Available]')),
              across(everything(), ~na_if(., '[Not Applicable]')),
              across(everything(), ~na_if(., '[Not Evaluated]')),
              across(everything(), ~na_if(., '[Discrepancy]')),
              across(everything(), ~na_if(., '[Unknown]')))) %>%
  set_names(str_replace_all(names(.), 'clinical_patient_', '')) %>%
  map(~un_factor(.x) %>% find_and_transform_numerics() %>% find_and_transform_dates()) %>%
  map(~(function(dt, limit) {
    factor_cols <- lapply(dt, function(x) {
      len <- limit + 1
      if (!typeof(x) %in% c('integer', 'numeric', 'double')) {
        len <- table(x) %>% length()
        if (is.na(len) | is.null(len)) {
          len <- 0
        }
      }
      return(len)
    }) %>% 
      {.[. <= limit & . > 0]} %>%
      names()
    return(mutate(dt, across(any_of(factor_cols), as.factor)))
  })(.x, limit = 42)) %>% lapply(function(patient) {
    # remove all NAs and all same values
    select(patient, where(~any(!is.na(.x)))) %>%
      select(where(~n_distinct(.x) > 1))
  })

# save the data
save(clinical, file = 'data/tcga/clinical.Rdata', compress = 'xz')
save(follow_ups, file = 'data/tcga/follow_ups.Rdata', compress = 'xz')
save(patients, file = 'data/tcga/patients.Rdata', compress = 'xz')


# ############################################################
# Download pathology report (shutdown by GDC since May 2023)

# Process pathology report PDF


# ############################################################
# Download expression data and remain the raw counts
op <- pbapply::pboptions(type = 'tk')
pbapply::pbsapply(projects, function(x) {
  disease <- str_replace(x, 'TCGA-', '')
  file_name <- paste0('original_data/tcga/exp_', disease, '.Rdata')
  query_name <- paste0('original_data/tcga/query_', disease, '.Rdata')
  if (!file.exists(file_name)) {
    if (!file.exists(query_name)) {
      message('Failed to load query from cache')
      query <- GDCquery(project = x, data.category = 'Transcriptome Profiling', 
                        data.type = 'Gene Expression Quantification',  data.format = 'STAR - Counts')
      save(query, file = query_name)
    } else {
      load(query_name)
    }
    # GDCdownload(query, files.per.chunk = 512, method = 'client')
    # GDCdownload(query, files.per.chunk = 512, method = 'api')
    exp <- GDCprepare(query, summarizedExperiment = FALSE) %>%
      mutate(gene_type = as.factor(gene_type)) %>%
      select(gene_id:gene_type, starts_with('unstranded_')) %>%
      rename_with(~str_replace(.x, 'unstranded_', ''))
    message('save expression matrix')
    save(exp, file = file_name, compress = 'xz')
    rm(list = c('query', 'exp'))
    gc(verbose = FALSE)
  }
  NULL
})
