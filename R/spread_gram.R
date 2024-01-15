#' Simulate spreading activation in a network (Main function)
#' 
#' @description
#' The ACT spreading activation formula is represented in Equation 1:
#'   \deqn{a(y) = \sum_x {f(x,y) \cdot a(x)} + c(y)},
#'   where \eqn{c(y)} represents the baseline activation of y.
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
#' @param last_activation A vector that containing the last time activation 
#'   rates of all nodes. The sequence is the same as the matrix.
#' 
#' @param loose A scalar numeric between 0 and 1 that determines the loose (or 
#'   weight) in the calculation process. 
#' 
#' @param max_iter Max iteration times.
#' 
#' @param threshold End threshold
#' 
#' @param verbose Show verbose message
#' 
#' @return A numeric vector that contains new activation
#' 
#' @export
#' 
#' @useDynLib labyrinth
#' 
#' @importFrom checkmate assert_numeric assert_matrix assert_number
#' @importFrom Rcpp sourceCpp
#' 
#' @examples
#' # The graph G
#' data("graph", package = "labyrinth")
#' 
#' # The initial info
#' last_activation = c(2, 4, 3, 2, 2, 1, 5)
#' 
#' results <- spread_gram(graph, last_activation)
#' 
spread_gram <- function(graph, last_activation, loose = 1.0, max_iter = 1e5, threshold = 1, verbose = TRUE) {
  assert_numeric(last_activation, any.missing = FALSE, null.ok = FALSE, finite = TRUE, min.len = 4, len = nrow(graph))
  assert_number(loose, na.ok = FALSE, lower = 0, upper = 1, finite = TRUE, null.ok = FALSE)
  
  iter <- 0
  min_iter <- max(round(max_iter / 100), 500)
  last_gradient <- rep(max_iter, 20)
  act <- last_activation
  convergence <- FALSE
  while (iter < max_iter) {
    # Compute 
    if (is.dgCMatrix(graph)) {
      assert_dgCMatrix(graph)
      act <- spread_gram_s(graph, act)
    } else {
      assert_matrix(graph, nrows = ncol(graph), ncols = nrow(graph), min.rows = 3)
      act <- spread_gram_d(graph, act)
    }
    
    # Compute loss
    loss <- gradient(graph, act)
    last_gradient <- c(last_gradient[-1], loss)
    if (iter %% 1e4 == 0) {
      message('Iterated #', iter, ' times. Current loss: ', loss)
    }
    ## Check if convergence
    if ((loss < threshold) | ((iter > min_iter) & all(last_gradient == last_gradient[1]))) {
      if (verbose) {
        message('Convergent at #', iter, ' times. Current loss: ', loss)
      }
      convergence <- TRUE
      break
    }
    iter <- iter + 1
  }
  if (!convergence) {
    message('Not convergent after #', iter, ' times. Current loss: ', loss)
  }
  return(act)
}

#' Simulate spreading activation in a network (Only once)
#' 
#' @description
#' The ACT spreading activation formula is represented in Equation 1:
#'   \deqn{a(y) = \sum_x {f(x,y) \cdot a(x)} + c(y)},
#'   where \eqn{c(y)} represents the baseline activation of y.
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
#' @param last_activation A vector that containing the last time activation 
#'   rates of all nodes. The sequence is the same as the matrix.
#' 
#' @param loose A scalar numeric between 0 and 1 that determines the loose (or 
#'   weight) in the calculation process. 
#' 
#' @return A numeric vector that contains new activation
#' 
#' @useDynLib labyrinth
#' 
#' @importFrom checkmate assert_numeric assert_matrix assert_number
#' @importFrom Rcpp sourceCpp
#' 
#' @examples
#' # The graph G
#' data("graph", package = "labyrinth")
#' 
#' # The initial info
#' last_activation = c(2, 4, 3, 2, 2, 1, 5)
#' 
#' results <- spread_gram_1(graph, last_activation)
#' 
spread_gram_1 <- function(graph, last_activation, loose = 1.0) {
  assert_numeric(last_activation, any.missing = FALSE, null.ok = FALSE, finite = TRUE, min.len = 4, len = nrow(graph))
  assert_number(loose, na.ok = FALSE, lower = 0, upper = 1, finite = TRUE, null.ok = FALSE)
  
  if (is.dgCMatrix(graph)) {
    assert_dgCMatrix(graph)
    act <- spread_gram_s(graph, last_activation)
  } else {
    assert_matrix(graph, mode = 'numeric', nrows = ncol(graph), ncols = nrow(graph), min.rows = 3, any.missing = FALSE, all.missing = FALSE, null.ok = FALSE)
    act <- spread_gram_d(graph, last_activation)
  }
  return(act)
}

#' Sigmoid function of Spreadgram
#' 
#' @description
#' The Sigmoid function is one of the basic function in Spreadgram algorithm. 
#'   This function calculates the Sigmoid function of a specific node given the 
#'   activation rates of the nodes and its neighbors. 
#'   The equation writes
#'   \deqn{\sigma (x,y) = {{\exp [a(x)a(y)]} \over {1 + \exp [a(x)a(y)]}}}.
#' 
#' @param ax A vector of the activation rates of x, which is a set of the y's 
#'   neighbors
#' 
#' @param ay A scalar of the activation rate of node y.
#' 
#' @param u If \eqn{x \in N(y)} then \eqn{u = 1}, otherwise \eqn{u = 0}. 
#' 
#' @return A vector of sigma
#' 
#' @export
#' 
#' @useDynLib labyrinth
#' 
#' @importFrom checkmate assert_numeric assert_number
#' @importFrom Rcpp sourceCpp
#' 
#' @examples
#' 
#' sigmoid(1:4, 2)
#' 
sigmoid <- function(ax, ay, u = 1) {
  assert_numeric(ax, any.missing = FALSE, null.ok = FALSE, finite = TRUE, min.len = 4)
  assert_number(ay, na.ok = FALSE, lower = 0, finite = TRUE, null.ok = FALSE)
  assert_number(u, na.ok = FALSE, lower = 0, upper = 1, finite = TRUE, null.ok = FALSE)
  return(sigmoid_t(ax, ay, u))
}

#' Compute gradient of Spreadgram
#' 
#' @description
#' This function calculates the gradient of the computed activation rates for a 
#'   given background graph. The gradient is computed based on the Sigmoid 
#'   function and the log likelihood, which iteratively computes the error
#'   between each permutation. 
#'   
#' This function requires the background graph and the computed activation rates 
#'   as input.
#' 
#' @param graph A square \code{\link[base]{matrix}} (or 
#'   \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} representing the background 
#'   graph. Inside this adjacency matrix, each row and column of the matrix 
#'   represents a node in the graph. The values of the matrix should be either 0 
#'   or 1 (or either 0 or larger than 0), where a value of 0 indicates no 
#'   relations between two nodes. The diagonal of the matrix should be 0, as 
#'   there are no self-edges in the graph.
#' 
#' @param activation A numeric vector representing the computed activation rates 
#'   for each node in the graph. The length of the vector should be equal to the 
#'   number of nodes in the graph. This vector should contain the activation 
#'   rate for each node.
#' 
#' @return A scalar representing the gradient of the computed activation rates.
#'   The gradient represents the rate of change of the activation rate.
#' 
#' @export
#' 
#' @useDynLib labyrinth
#' 
#' @importFrom checkmate assert_numeric assert_matrix
#' @importFrom Rcpp sourceCpp
#' 
#' @examples
#' # The graph G
#' data("graph", package = "labyrinth")
#' 
#' # The initial info
#' last_activation = c(2, 4, 3, 2, 2, 1, 5)
#' 
#' gradient(graph, last_activation)
#' 
gradient <- function(graph, activation) {
  assert_numeric(activation, any.missing = FALSE, null.ok = FALSE, finite = TRUE, min.len = 4, len = nrow(graph))
  
  if (is.dgCMatrix(graph)) {
    assert_dgCMatrix(graph)
    grad <- gradient_s(graph, activation)
  } else {assert_matrix(graph, mode = 'numeric', nrows = ncol(graph), ncols = nrow(graph), min.rows = 3, any.missing = FALSE, all.missing = FALSE, null.ok = FALSE)
    grad <- gradient_d(graph, activation)
  }
  return(grad)
}

