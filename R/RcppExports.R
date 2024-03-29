# Generated by using Rcpp::compileAttributes() -> do not edit by hand
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

get_neighbors_s <- function(adj_matrix, node_id, neighbor_type) {
    .Call(`_labyrinth_get_neighbors_s`, adj_matrix, node_id, neighbor_type)
}

get_neighbors_d <- function(adj_matrix, node_id, neighbor_type) {
    .Call(`_labyrinth_get_neighbors_d`, adj_matrix, node_id, neighbor_type)
}

#' Do a Markon random walk (with restart) on an column-normalised adjacency
#' matrix.
#'
#' @noRd
#' @param p0  matrix of starting distribution
#' @param W  the column normalized adjacency matrix
#' @param r  restart probability
#' @param thresh  threshold to break as soon as new stationary distribution
#'   converges to the stationary distribution of the previous timepoint
#' @param niter  maximum number of iterations for the chain
#' @param do_analytical  boolean if the stationary distribution shall be
#'  computed solving the analytical solution or iteratively
#' @return  returns the matrix of stationary distributions p_inf
mrwr_ <- function(p0, W, r, thresh, niter, do_analytical) {
    .Call(`_labyrinth_mrwr_`, p0, W, r, thresh, niter, do_analytical)
}

#' Do a Markon random walk (with restart) on an column-normalised adjacency
#' matrix.
#'
#' @noRd
#' @param p0  matrix of starting distribution
#' @param W  the column normalized adjacency matrix
#' @param r  restart probability
#' @param thresh  threshold to break as soon as new stationary distribution
#'   converges to the stationary distribution of the previous timepoint
#' @param niter  maximum number of iterations for the chain
#' @param do_analytical  boolean if the stationary distribution shall be
#'  computed solving the analytical solution or iteratively
#' @return  returns the matrix of stationary distributions p_inf
mrwr_s <- function(p0, W, r, thresh, niter, do_analytical) {
    .Call(`_labyrinth_mrwr_s`, p0, W, r, thresh, niter, do_analytical)
}

transfer_activation_s <- function(graph, y, x, activation, loose = 1.0) {
    .Call(`_labyrinth_transfer_activation_s`, graph, y, x, activation, loose)
}

transfer_activation_d <- function(graph, y, x, activation, loose = 1.0) {
    .Call(`_labyrinth_transfer_activation_d`, graph, y, x, activation, loose)
}

activation_rate_s <- function(graph, strength, stm, loose = 1.0, threads = 0L, remove_first = FALSE, display_progress = TRUE) {
    .Call(`_labyrinth_activation_rate_s`, graph, strength, stm, loose, threads, remove_first, display_progress)
}

activation_rate_d <- function(graph, strength, stm, loose = 1.0, threads = 0L, remove_first = FALSE, display_progress = TRUE) {
    .Call(`_labyrinth_activation_rate_d`, graph, strength, stm, loose, threads, remove_first, display_progress)
}

sigmoid_t <- function(ax, ay, u = 1L) {
    .Call(`_labyrinth_sigmoid_t`, ax, ay, u)
}

spread_gram_s <- function(graph, last_activation, loose = 1.0, threads = 0L, display_progress = FALSE) {
    .Call(`_labyrinth_spread_gram_s`, graph, last_activation, loose, threads, display_progress)
}

spread_gram_d <- function(graph, last_activation, loose = 1.0, threads = 0L, display_progress = FALSE) {
    .Call(`_labyrinth_spread_gram_d`, graph, last_activation, loose, threads, display_progress)
}

gradient_s <- function(graph, activation, threads = 0L, display_progress = FALSE) {
    .Call(`_labyrinth_gradient_s`, graph, activation, threads, display_progress)
}

gradient_d <- function(graph, activation, threads = 0L, display_progress = FALSE) {
    .Call(`_labyrinth_gradient_d`, graph, activation, threads, display_progress)
}

