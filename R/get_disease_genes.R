#' Get disease impact score
#'
#' @param expr The expression matrix
#' 
#' @param max.iter Maximal number of iterations of the augumented Lagrange 
#'   multiplier algorithm, which is used in robust PCA algorithm.
#'
#' @return A vector of the disease impact score
#' @export
#' 
#' @importFrom stats sd
#' @importFrom rpca rpca
#' @importFrom matrixStats colMeans2 rowSums2
#' @examples
#' # no examples
#' # TODO: fill the examples
#' 
disease_impact_score <- function(expr, max.iter = 10000) {
  # scale the expression dataset by columns
  row_names <- rownames(expr)
  expr <- sweep(expr, 2, colMeans2(expr))
  expr_rpca <- rpca(expr, max.iter = max.iter)
  
  # only get the S, drop L
  # and compute the sum of variance
  if (!expr_rpca$convergence$converged) {
    stop("The feature extraction is not converged. Please enlarge the iterations")
  }
  sum_variance <- rowSums2(expr_rpca$S ^ 2) * sign(rowSums2(expr_rpca$S))
  
  if (!is.null(row_names)) {
    names(sum_variance) <- row_names
  }
  return(sum_variance)
}
