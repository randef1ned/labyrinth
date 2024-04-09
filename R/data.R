#' A small example implemented from Anderson (1983)
#'
#' @format Adjacency \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} 
#'   representing an unweighted directed graph. Inside this adjacency matrix, 
#'   each row and column of the matrix represents a node in the graph. There are 
#'   7 nodes and 9 edges, and no self-loops inside the graph. 
#' 
#' @source 
#' Anderson, J. R. (1983). A spreading activation theory of memory. *Journal of 
#' verbal learning and verbal behavior*, *22*(3), 261-295.
#' https://doi.org/10.1016/S0022-5371(83)90201-3.
#' 
#' @examples
#' library(labyrinth)
#' 
#' data("graph", package = "labyrinth")
#' 
"graph"

#' A portion of the phonological network examined in Vitevitch (2008).
#' 
#' @description
#' Depicted are the word *speech*, phonological neighbors of *speech*, and the 
#'   phonological neighbors of those neighbors. It is taken from 
#'   \code{\link[spreadr:pnetm]{spreadr}} package. 
#'
#' @format Adjacency \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} 
#'   representing an unweighted directed graph. Inside this adjacency matrix, 
#'   each row and column of the matrix represents a node in the graph. There are 
#'   34 nodes and 96 edges, and no self-loops inside the graph. 
#' 
#' @references 
#' Chan, K. Y., & Vitevitch, M. S. (2009). The influence of the phonological 
#' neighborhood clustering coefficient on spoken word recognition. *Journal of 
#' experimental psychology: Human perception and performance*, *35*(6), 1934–1949. 
#' https://doi.org/10.1037/a0016902.
#' 
#' Siew C. S. Q. (2019). spreadr: An R package to simulate spreading activation 
#' in a network. *Behavior research methods*, *51*(2), 910–929. 
#' https://doi.org/10.3758/s13428-018-1186-5.
#' 
#' @examples
#' library(labyrinth)
#' 
#' data("speech", package = "labyrinth")
#' 
"speech"

#' NCBI Gene Information
#' 
#' @description
#' A data table containing meta information about NCBI genes, including their
#'   type and associated species.
#'
#' @format A \code{\link[data.table:data.table]{data.table}} with the following
#'   columns:
#' 
#' \describe{
#'   \item{type}{A character vector representing the type of species.}
#'   \item{species}{A character vector representing the species that NCBI supports in its online platform.}
#' }
#' 
#' @source 
#' This data was obtained from the National Center for Biotechnology Information
#'   (NCBI) Gene database (https://www.ncbi.nlm.nih.gov/gene).
#' 
#' @examples
#' library(labyrinth)
#' 
#' data("ncbi_info", package = "labyrinth")
#' 
"ncbi_info"

#' MeSH Annotation Data
#' 
#' @description 
#' A data frame containing annotated Medical Subject Headings (MeSH) terms and
#'   their associated group information.
#'
#' @format A \code{\link[data.table:data.table]{data.table}} with the following 
#'   columns:
#' \describe{
#'   \item{mesh_id}{A character vector representing the MeSH identifier.}
#'   \item{mesh_term}{A character vector representing the MeSH term.}
#'   \item{group_id}{A character vector representing the group identifier obtained from NCBI.}
#'   \item{group_name}{A character vector representing the group name obtained from NCBI.}
#' }
#'
#' @source
#' The MeSH terms were obtained from the National Library of Medicine's Medical
#'   Subject Headings (MeSH) database (https://www.nlm.nih.gov/mesh/), and the
#'   group information was obtained from the National Center for Biotechnology
#'   Information (NCBI).
#'
#' @examples
#' data(mesh_annot, package = "labyrinth")
"mesh_annot"

#' MeSH Hierarchy Network
#' @description
#' An edgelist network representing the hierarchical structure of the Medical
#'   Subject Headings (MeSH) terms.
#'
#' @format
#' A \code{\link[data.table:data.table]{data.table}} with the following columns:
#' \describe{
#'   \item{from_id}{A character vector representing the MeSH identifier of the parent term.}
#'   \item{to_id}{A character vector representing the MeSH identifier of the child term.}
#' }
#'
#' @details
#' The `mesh_hierarchy` data frame is an edgelist network, where each row
#'   represents a directed edge from a parent MeSH term (`from_id`) to a child
#'   MeSH term (`to_id`). This structure captures the hierarchical relationships
#'   between MeSH terms.
#'
#' @source
#' The MeSH hierarchy data was obtained from the National Library of Medicine's
#'   Medical Subject Headings (MeSH) database (https://www.nlm.nih.gov/mesh/).
#'
#' @examples
#' data(mesh_hierarchy, package = "labyrinth")
"mesh_hierarchy"

