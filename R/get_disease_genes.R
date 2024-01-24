#' Get disease impact score
#'
#' @param expr The expression matrix
#' 
#' @param control A vector or scalar of the index of the normal samples.
#' 
#' @param max.iter Maximal number of iterations of the augumented Lagrange 
#'   multiplier algorithm, which is used in robust PCA algorithm.
#'
#' @return A vector of the disease impact score
#' @export
#' 
#' @importFrom checkmate assert_number assert_numeric assert_matrix
#' @importFrom stats sd
#' @importFrom rpca rpca
#' @importFrom matrixStats colMeans2 rowSums2
#' @examples
#' # no examples
#' # TODO: fill the examples
#' 
disease_impact_score <- function(expr, control, max.iter = 10000) {
  # check the input
  assert_matrix(expr, mode = 'numeric', any.missing = FALSE, all.missing = FALSE,min.cols = 2, null.ok = FALSE)
  assert_numeric(control, lower = 1, upper = ncol(expr), finite = TRUE, any.missing = FALSE, all.missing = FALSE, min.len = 1, max.len = ncol(expr) - 1, unique = TRUE, null.ok = FALSE)
  assert_number(max.iter, na.ok = FALSE, lower = 1, finite = TRUE, null.ok = FALSE)
  
  contrast <- seq_len(ncol(expr))[-control]
  
  # scale the expression dataset by columns
  row_names <- rownames(expr)
  expr <- sweep(expr, 2, colMeans2(expr))
  expr_rpca <- rpca(expr, max.iter = max.iter)
  
  # only get the S, drop L
  # and compute the sum of variance
  if (!expr_rpca$convergence$converged) {
    stop("The feature extraction is not converged. Please enlarge the iterations")
  }
  
  # Determine up- or down-regulation
  sum_contrast <- `if`(length(contrast) == 1, as.numeric(expr[, contrast]), rowSums2(expr[, contrast]))
  sum_control  <- `if`(length(control)  == 1, as.numeric(expr[, control]),  rowSums2(expr[, control]))
  sum_variance <- rowSums2(expr_rpca$S ^ 2) * sign(sum_contrast - sum_control)
  
  if (!is.null(row_names)) {
    names(sum_variance) <- row_names
  }
  return(sum_variance)
}
