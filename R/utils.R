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
#' @importFrom limma alias2SymbolUsingNCBI
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
    dir <- ncbi_info$dir[ncbi_info$species == species]
    download.file(paste0("https://ftp.ncbi.nih.gov/gene/DATA/GENE_INFO/", dir, "/", species, ".gene_info.gz"), ncbi, mode = "wb", cacheOK = TRUE)
    
  }
  lookup <- alias2SymbolUsingNCBI(gene.pool, ncbi)$Symbol
  return(lookup)
}