#' Check if a matrix is `dgCMatrix` class
#'
#' @param mat The matrix to check
#'
#' @return A boolean variable
#' 
#' @export
#'
#' @importFrom methods is
#' 
is.dgCMatrix <- function(mat) {
  return(is(mat, 'dgCMatrix'))
}

#' Check if the sparse matrix valid
#'
#' @param adj_mat The sparse matrix to check
#'
#' @export
#'
assert_dgCMatrix <- function(adj_matrix) {
  if (adj_matrix@Dim[1] != adj_matrix@Dim[2]) {
    stop(paste("Error: Assertion on 'adj_matrix' failed: Must have exactly",
               adj_matrix@Dim[2], "rows, but has", 
               adj_matrix@Dim[1] ,"rows."))
  } else if (adj_matrix@Dim[1] < 4) {
    stop(paste("Error: Assertion on 'adj_matrix' failed: Must have at least 3 rows, but has",
               adj_matrix@Dim[1] ,"rows."))
  }
}