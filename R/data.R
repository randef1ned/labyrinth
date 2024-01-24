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

#' NCBI Info
#' 
#' @description
#' TODO: enhance documentation
#'
#' @format A \code{\link[base:data.frame]{data.frame}} representing the 
#'   information of NCBI genes.
#' 
#' @examples
#' library(labyrinth)
#' 
#' data("ncbi_info", package = "labyrinth")
#' 
"ncbi_info"
