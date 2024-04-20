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
    download.file(paste0("https://ftp.ncbi.nih.gov/gene/DATA/GENE_INFO/", type,
                         "/", species, ".gene_info.gz"),
                  ncbi, mode = "wb", cacheOK = TRUE)

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
#' @param gene.info.file the name of a gene information file downloaded from the
#'   NCBI.
#'
#' @param required.columns character vector of columns from the gene information
#'   file that are required in the output.
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
alias2SymbolUsingNCBI <- function(
    alias, gene.info.file,
    required.columns = c("GeneID", "Symbol", "description")) {
  #	Convert gene aliases to current symbols etc using a gene_info file
  # downloaded from the NCBI
  #	Gordon Smyth
  #	Created 2 March 2017. Last modified 9 June 2020.
  #	Check input. If necessary, read the gene info file.
  alias <- as.character(alias)
  if (is.data.frame(gene.info.file)) {
    OK <- all(fmatch(c("GeneID", "Symbol", "Synonyms"), names(gene.info.file)))
    if (!OK)
      stop("The gene.info.file must include columns GeneID, ",
           "Symbol and Synonyms")
    NCBI <- gene.info.file
    NCBI$Symbol <- as.character(NCBI$Symbol)
  } else {
    gene.info.file <- as.character(gene.info.file)
    NCBI <- read.delim(gene.info.file, comment.char = "", quote = "",
                       colClasses = "character")
  }

  #	Try matching to symbols
  m <- fmatch(alias, NCBI$Symbol)
  EntrezID <- NCBI$GeneID[m]

  #	For any rows that don't match symbols, try synonyms
  i <- which(is.na(EntrezID))
  if (any(i)) {
    S <- strsplit(NCBI$Synonyms, split = "\\|")
    N <- vapply(S, length, 1)
    Index <- rep.int(seq_len(nrow(NCBI)), times = N)
    IS <- data.frame(Index = Index, Synonym = unlist(S),
                     stringsAsFactors = FALSE)
    m <- fmatch(alias[i], IS$Synonym)
    EntrezID[i] <- NCBI$GeneID[IS$Index[m]]
    m <- fmatch(EntrezID, NCBI$GeneID)
  }

  NCBI[m, required.columns, drop = FALSE]
}

#' @title Load External Data
#'
#' @description
#' This function loads the external data to the R environment. If the required
#'   file is not found locally, it attempts to download the file from author's
#'   GitHub. In this package, it is used to download external data from
#'   \href{https://github.com/randef1ned/labyrinth/tree/master/extdata}{this}
#'   folder, such as the pre-trained model file, drug annotation file, etc.
#'
#' @details
#' The function first checks if the required file exists in the labyrinth
#'   directory (defined by \code{tools::R_user_dir('labyrinth')}). If the
#'   required file is not found, it attempts to download the file from GitHub
#'   repo up to five times. If the download fails after five attempts, an error
#'   is thrown. If the file is successfully downloaded or already exists
#'   locally, the function will return the file content.
#'
#' @param required_file Required file name without extensions from GitHub
#'   \href{https://github.com/randef1ned/labyrinth/tree/master/extdata}{repo}.
#'
#' @return The content of the required data.
#'
#' @export
#'
#' @importFrom tools R_user_dir
#' @importFrom utils download.file
#' @importFrom checkmate assert_string
#'
#' @examples
#' \donttest{
#' # Load the trained model
#' model <- load_data("model")
#'
#' # Load the drug annotation data
#' drug_annot <- load_data("drug_annot")
#' }
load_data <- function(required_file) {
  assert_string(required_file, na.ok = FALSE, min.chars = 3, max.chars = 30,
                null.ok = FALSE)
  required_file <- paste0(required_file, ".rda")

  # dirs
  user_dir <- R_user_dir("labyrinth")
  model_path <- file.path(user_dir, required_file)
  data_path <- system.file("extdata", required_file, package = "labyrinth")
  ext_data <- FALSE
  for (retry in 1:5) {
    if (retry == 5) {
      stop("Download failed.")
    } else if (nchar(data_path)[1]) {
      break
    } else if (file.exists(model_path)) {
      ext_data <- TRUE
      break
    } else {
      if (!dir.exists(user_dir)) {
        dir.create(user_dir, recursive = TRUE)
      }
      warning("No cached model file. Downloading...")
      download.file(paste0("https://raw.githubusercontent.com/",
                           "randef1ned/labyrinth/master/extdata/",
                           required_file), model_path)
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
