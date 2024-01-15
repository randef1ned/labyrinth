#' Get neighboring nodes in a graph (adjacency matrix)
#' 
#' @description
#' It returns the neighboring nodes of a specified node in a graph. The 
#' neighboring nodes can be returned in various formats, depending on the 
#' `return_type` parameter.
#'
#' @param adj_matrix A square \code{\link[base]{matrix}} (or 
#'   \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} representing the background 
#'   graph. Inside this adjacency matrix, each row and column of the matrix 
#'   represents a node in the graph. The values of the matrix should be either 0 
#'   or 1 (or either 0 or larger than 0), where a value of 0 indicates no 
#'   relations between two nodes. The diagonal of the matrix should be 0, as 
#'   there are no self-edges in the graph.
#' 
#' @param node_id The ID of the node whose neighbors are being retrieved. Node 
#'   name is also acceptable. 
#' 
#' @param neighbor_type The `neighbor_type` parameter specifies the type of 
#'   neighbors to include in the output: 
#'   - **both**: return all neighbors of the specific node, regarding the graph 
#'     as undirected. 
#'   - **forward**: return only the neighbors that are reachable from the 
#'     specified node, specifically means downstream neighbors in the directed 
#'     networks.
#'   - **backward**: return the upstream neighbors from the specific nodes. 
#'     Specifically, it will reverse the direction of all edges in the graph and 
#'     then return the downstream neighbors. 
#' 
#' @param return_type The `return_type` paramater specifies the type of return:
#'   - **binary**: return a binary vector of length equal to the total number of 
#'     all nodes in the graph. The elements of vector will be set to 1 for nodes 
#'     that are neighbors of the specific nodes, and 0 for all other nodes. 
#'   - **name**: return a character vector containing the names of all neighbor
#'     nodes.
#'   - **id**: return a integer vector containing IDs of all neighbor nodes.
#'
#' @return A vector based on `return_type`. 
#' 
#' @export
#' 
#' @references 
#' https://www.ibm.com/docs/en/cognos-analytics/11.1.0?topic=terms-modified-z-score
#' 
#' @seealso
#' \code{\link{scale}}, \code{\link{mad}}
#' 
#' @useDynLib labyrinth
#' 
#' @importFrom checkmate assert_int assert_matrix
#' @importFrom Rcpp sourceCpp
#' 
#' @examples
#' # make an adjacency matrix and randomly fill some cells with 1s
#' mat <- matrix(sample(c(0,1), 100, replace = TRUE), 10, 10)
#' diag(mat) <- 0 # remove self-loops
#' 
#' library(labyrinth)
#' # Get neighbors
#' get_neighbors(mat, 2)
#' 
get_neighbors <- function(adj_matrix, node_id, 
                          neighbor_type = c('both', 'forward', 'backward'), 
                          return_type = c('binary', 'name', 'id')) {
  # Check input
  assert_int(node_id, lower = 1)
  
  # neighbor_type should convert to int
  neighbor_type <- match.arg(neighbor_type)
  return_type <- match.arg(return_type)
  
  neighbor_type <- which(neighbor_type == c('both', 'forward', 'backward')) - 1
  
  # adj_matrix can be either sparse or dense
  if (is.dgCMatrix(adj_matrix)) {
    assert_dgCMatrix(adj_matrix)
    neighbors <- get_neighbors_s(adj_matrix, node_id - 1, neighbor_type)
  } else {
    assert_matrix(adj_matrix, mode = 'numeric', nrows = ncol(adj_matrix), ncols = nrow(adj_matrix), min.rows = 3, any.missing = FALSE, all.missing = FALSE, null.ok = FALSE)
    neighbors <- get_neighbors_d(adj_matrix, node_id - 1, neighbor_type)
  }
  
  if (return_type == 'name') {
    neighbors <- colnames(adj_matrix)[which(neighbors == 1)]
  } else if (return_type == 'id') {
    neighbors <- which(neighbors == 1)
  }
  
  return(neighbors)
}

