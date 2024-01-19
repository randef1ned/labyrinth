#' Calculate the next-time ACT activation rate
#' 
#' @description
#' This function calculates the activation rate for each node in a graph based 
#' on its connectivity to other nodes, the *relative strength* of the 
#' connections, and a global loose factor.
#' 
#' The ACT spreading activation formula is represented in Equation 1:
#'   \deqn{a(y) = \sum_x {f(x,y) \cdot a(x)} + c(y)},
#'  where c(y) represents the baseline activation of y.
#'   \eqn{\alpha} represents the proximity of a node in this network.
#'   \eqn{t} represents the iteration number
#' 
#' @param graph A square \code{\link[base]{matrix}} (or 
#'   \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} representing the background 
#'   graph. Inside this adjacency matrix, each row and column of the matrix 
#'   represents a node in the graph. The values of the matrix should be either 0 
#'   or 1 (or either 0 or larger than 0), where a value of 0 indicates no 
#'   relations between two nodes. The diagonal of the matrix should be 0, as 
#'   there are no self-edges in the graph.
#' 
#' @param strength A vector containing the *relative strength* of connections 
#'   for each node in the graph, which is the same as the last time activation 
#'   rates of all nodes. The sequence is the same as the matrix.
#' 
#' @param stm A binary vector which indicating whether the node is activated, or 
#'   in the short-term memory
#' 
#' @param loose A scalar numeric between 0 and 1 that determines the loose (or 
#'   weight) in the calculation process. 
#' 
#' @param threads A scalar numeric indicating the parallel threads. Default is 0
#'   (auto-detected).
#' 
#' @param remove_first A logical value indicating whether or not to exclude the 
#'   first node from the calculation
#'
#' @param display_progress A logical value indicating whether or not to show the
#'   progress.
#'
#' @return A vector containing the activation rate for each node in the graph
#' 
#' @export
#' 
#' @useDynLib labyrinth
#' 
#' @importFrom checkmate assert_numeric assert_matrix assert_number assert_logical
#' @importFrom Rcpp sourceCpp
#' 
#' @examples
#' library(magrittr)
#' 
#' graph <- matrix(nrow = 7, ncol=7, data=c(
#'   0, 0, 0, 0, 0, 0, 0,
#'   1, 0, 0, 0, 0, 0, 0,
#'   1, 0, 0, 0, 0, 0, 0,
#'   0, 1, 0, 0, 0, 0, 0,
#'   0, 1, 1, 0, 0, 0, 0,
#'   0, 0, 1, 0, 0, 0, 0,
#'   0, 0, 0, 1, 1, 1, 0))
#' diag(graph) <- 0
#' colnames(graph) <- rownames(graph) <- seq_len(nrow(graph)) %>% 
#'   subtract(1) %>% as.character()
#' 
#' initial_info <- data.frame(node = colnames(graph),
#'                            strength = c(2, 4, 3, 2, 2, 1, 5),
#'                            in_stm = c(rep(1, 3), rep(0, 4)))
#' 
#' activation_rate(graph, initial_info$strength, initial_info$in_stm, 
#'   loose = 0.8, remove_first = TRUE)
#' 
activation_rate <- function(graph, strength, stm, loose = 1.0, threads = 0,
                            remove_first = FALSE, display_progress = TRUE) {
  assert_numeric(strength, any.missing = FALSE, null.ok = FALSE, finite = TRUE, min.len = 4, len = nrow(graph))
  assert_numeric(stm, any.missing = FALSE, null.ok = FALSE, finite = TRUE, min.len = 4, len = nrow(graph))
  assert_number(loose, na.ok = FALSE, lower = 0, upper = 1, finite = TRUE, null.ok = FALSE)
  assert_number(threads, na.ok = FALSE, lower = 0, finite = TRUE, null.ok = FALSE)
  assert_logical(remove_first, len = 1, any.missing = FALSE, null.ok = FALSE)
  assert_logical(display_progress, len = 1, any.missing = FALSE, null.ok = FALSE)
  
  if (is.dgCMatrix(graph)) {
    assert_dgCMatrix(graph)
    act <- activation_rate_s(graph, strength, stm, loose, threads,
                             remove_first, display_progress)
  } else {
    assert_matrix(graph, nrows = ncol(graph), ncols = nrow(graph), min.rows = 3)
    act <- activation_rate_d(graph, strength, stm, loose, threads,
                             remove_first, display_progress)
  }
  return(act)
}

#' Calculate the received activation in Spreading Activation (f)
#' 
#' @description
#' This function calculates the next-time received activation value from node y 
#' to node x in the specific graph, based on the activation values of its 
#' neighbors (including y) and a weighting factor loose.
#' 
#' The formula is \eqn{f^{t+1}(x,j) = l \cdot s_k / \sum_{j} {s_j}}.
#' 
#' @param graph A square \code{\link[base]{matrix}} (or 
#'   \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} representing the background 
#'   graph. Inside this adjacency matrix, each row and column of the matrix 
#'   represents a node in the graph. The values of the matrix should be either 0 
#'   or 1 (or either 0 or larger than 0), where a value of 0 indicates no 
#'   relations between two nodes. The diagonal of the matrix should be 0, as 
#'   there are no self-edges in the graph.
#' 
#' @param y The index or ID of the node for which to specify the attention place
#' 
#' @param x The index or ID of the neighbor of node y
#' 
#' @param activation A vector containing the last-time activation values of all 
#'   nodes. the sequence is the same as the matrix.
#' 
#' @param loose A scalar numeric between 0 and 1 that determines the loose (or 
#'   weight) in the calculation process. 
#'
#' @return A scalar value representing the activation value for node x
#' 
#' @export
#' 
#' @useDynLib labyrinth
#' 
#' @importFrom checkmate assert_numeric assert_matrix assert_number
#' @importFrom Rcpp sourceCpp
#' 
#' @examples
#' # make an adjacency matrix and randomly fill some cells with 1s
#' mat <- matrix(sample(c(0,1), 100, replace = TRUE), 10, 10)
#' diag(mat) <- 0 # remove self-loops
#' 
#' transfer_activation(mat, 3, 2, 1:10)
#' 
transfer_activation <- function(graph, y, x, activation, loose = 1) {
  assert_numeric(activation, any.missing = FALSE, null.ok = FALSE, finite = TRUE, min.len = 4, len = nrow(graph))
  assert_number(y, na.ok = FALSE, lower = 1, upper = nrow(graph), finite = TRUE, null.ok = FALSE)
  assert_number(x, na.ok = FALSE, lower = 1, upper = nrow(graph), finite = TRUE, null.ok = FALSE)
  assert_number(loose, na.ok = FALSE, lower = 0, upper = 1, finite = TRUE, null.ok = FALSE)
  
  if (is.dgCMatrix(graph)) {
    assert_dgCMatrix(graph)
    act <- transfer_activation_s(graph, y - 1, x - 1, activation, loose)
  } else {assert_matrix(graph, mode = 'numeric', nrows = ncol(graph), ncols = nrow(graph), min.rows = 3, any.missing = FALSE, all.missing = FALSE, null.ok = FALSE)
    act <- transfer_activation_d(graph, y - 1, x - 1, activation, loose)
  }
  return(act)
}
