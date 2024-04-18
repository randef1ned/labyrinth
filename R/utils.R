#' Update gene symbol using NCBI Entrez Gene
#'
#' @param gene.pool The gene list
#' 
#' @param ncbi The location to the NCBI file directory
#' 
#' @param species Optional. To specify the species
#' 
#' @return A vector with the latest gene symbols
#' 
#' @export
#'
#' @importFrom checkmate assert_character
#' @importFrom utils data download.file
#' 
#' @examples
#' library(labyrinth)
#' \donttest{update_gene_symbol('IL-6')}
#' 
update_gene_symbol <- function(gene.pool, ncbi = NA, species = c(
  "Homo_sapiens", "Mus_musculus", "Pan_troglodytes", "Rattus_norvegicus", 
  "Archaea", "Bacteria", "Escherichia_coli_str._K-12_substr._MG1655", 
  "Pseudomonas_aeruginosa_PAO1", "Ascomycota", "Microsporidia", "Bos_taurus", 
  "Penicillium_rubens", "Saccharomyces_cerevisiae", "Anopheles_gambiae", 
  "Caenorhabditis_elegans", "Drosophila_melanogaster", "Canis_familiaris", 
  "Sus_scrofa", "Danio_rerio", "Gallus_gallus", "Xenopus_laevis", 
  "Xenopus_tropicalis", "Arabidopsis_thaliana", "Chlamydomonas_reinhardtii", 
  "Oryza_sativa", "Zea_mays", "Plasmodium_falciparum", "Retroviridae")) {
  
  assert_character(gene.pool, min.chars = 1)
  assert_character(ncbi, len = 1, all.missing = TRUE)
  species <- match.arg(species)
  assert_character(species, len = 1, all.missing = TRUE)
  
  if (is.na(ncbi)) {
    ncbi <- tempfile()
    e <- new.env()
    data("ncbi_info", package = "labyrinth", envir = e)
    ncbi_info <- e$ncbi_info
    type <- ncbi_info$type[ncbi_info$species == species]
    download.file(paste0("https://ftp.ncbi.nih.gov/gene/DATA/GENE_INFO/", type, "/", species, ".gene_info.gz"), ncbi, mode = "wb", cacheOK = TRUE)
    
  }
  lookup <- alias2SymbolUsingNCBI(gene.pool, ncbi)$Symbol
  return(lookup)
}


##  ALIAS2SYMBOL.R
## Function comes from https://git.bioconductor.org/packages/limma
## Modified using fastmatch::fmatch() function

#' Convert Gene Aliases to Official Gene Symbols
#' 
#' @description
#' Maps gene alias names to official gene symbols.
#' 
#' @param alias character vector of gene aliases
#' 
#' @param gene.info.file the name of a gene information file downloaded from the NCBI.
#' 
#' @param required.columns character vector of columns from the gene information file that are required in the output.
#' 
#' @return A data frame with the latest gene symbols
#' 
#' @export
#'
#' @importFrom utils read.delim
#' @importFrom fastmatch fmatch
#' 
#' @examples
#' library(labyrinth)
#' \donttest{update_gene_symbol('IL-6')}
#' 
alias2SymbolUsingNCBI <- function(alias, 
                                  gene.info.file, 
                                  required.columns = c("GeneID", "Symbol", "description")) {
  #	Convert gene aliases to current symbols etc using a gene_info file downloaded from the NCBI
  #	Gordon Smyth
  #	Created 2 March 2017. Last modified 9 June 2020.
  #	Check input. If necessary, read the gene info file.
  alias <- as.character(alias)
  if(is.data.frame(gene.info.file)) {
    OK <- all(c("GeneID","Symbol","Synonyms") %in% names(gene.info.file))
    if(!OK) stop("The gene.info.file must include columns GeneID, Symbol and Synonyms")
    NCBI <- gene.info.file
    NCBI$Symbol <- as.character(NCBI$Symbol)
  } else {
    gene.info.file <- as.character(gene.info.file)
    NCBI <- read.delim(gene.info.file,comment.char="",quote="",colClasses="character")
  }
  
  #	Try matching to symbols
  m <- fmatch(alias,NCBI$Symbol)
  EntrezID <- NCBI$GeneID[m]
  
  #	For any rows that don't match symbols, try synonyms
  i <- which(is.na(EntrezID))
  if(any(i)) {
    S <- strsplit(NCBI$Synonyms,split="\\|")
    N <- vapply(S,length,1)
    Index <- rep.int(1:nrow(NCBI),times=N)
    IS <- data.frame(Index=Index,Synonym=unlist(S),stringsAsFactors=FALSE)
    m <- fmatch(alias[i],IS$Synonym)
    EntrezID[i] <- NCBI$GeneID[IS$Index[m]]
    m <- fmatch(EntrezID,NCBI$GeneID)
  }
  
  NCBI[m,required.columns,drop=FALSE]
}

#' @title Load Trained Model
#' 
#' @description
#' This function loads the pre-trained labyrinth model to the R environment. If 
#'   the model file is not found locally, it attempts to download the file from 
#'   author's GitHub.
#'
#' @details
#' The function first checks if the model file exists in the labyrinth directory
#'   (defined by \code{tools::R_user_dir('labyrinth')}). If the model file is 
#'   not found, it attempts to download the file from GitHub repo up to five 
#'   times. If the download fails after five attempts, an error is thrown. If 
#'   the file is successfully downloaded or already exists locally, trained 
#'   model file is loaded into the current environment.
#'
#' @return The loaded model object.
#'
#' @export
#'
#' @importFrom tools R_user_dir
#' @importFrom utils download.file
#' 
#' @examples
#' \donttest{
#' # Load the model
#' model <- load_model()
#' }
load_model <- function() {
  # dirs
  model_path <- file.path(R_user_dir('labyrinth'), 'model.rda')
  data_path <- system.file('extdata', 'model.rda', package = 'labyrinth')
  ext_data <- FALSE
  for (retry in 1:5) {
    if (retry == 5) {
      stop('Download failed.')
    } else if (length(data_path)) {
      break
    } else if (file.exists(model_path)) {
      ext_data <- TRUE
      break
    } else {
      warning('No cached model file. Downloading...')
      download.file('https://raw.githubusercontent.com/randef1ned/labyrinth/master/extdata/model.rda', model_path)
    }
  }
  e <- new.env()
  if (ext_data) {
    load(model_path, envir = e)
  } else {
    load(data_path, envir = e)
  }
  return(e$model)
}
