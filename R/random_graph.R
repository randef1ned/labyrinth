#' Generate random graph
#'
#' @param n_element Generate n nodes in random graph
#' @param float Whether to generate weighted graph
#' @param sparse Whether to generate sparse matrix
#'
#' @return A matrix
#' 
#' @noRd
#' 
#' @importFrom stats rnorm runif
#' @importFrom methods as
#' @examples
#' # Generate a random graph
#' graph <- random_graph()
#' 
#' # Generate a random graph with sparse matrix
#' graph <- random_graph(sparse = TRUE)
#' 
#' # Generate a random graph with 10 nodes
#' graph <- random_graph(n_element = 10)
#' 
random_graph <- function(n_element = sample(10:500, 1), float = sample(0:1, 1), sparse = sample(0:1, 1)) {
  while(TRUE) {
    random_nums <- rnorm(n_element^2, mean = 2, sd = 1)
    random_nums[random_nums < 2.6] <- 0
    random_nums[random_nums != 0] <- 1
    if (sum(random_nums) > n_element / 10)
      break
  }
  
  if (sparse) {
    graph <- Matrix::Matrix(nrow = n_element, ncol = n_element, data = random_nums, sparse = TRUE)
    graph <- as(graph, 'dgCMatrix')
  } else {
    graph <- matrix(nrow = n_element, ncol = n_element, data = random_nums)
  }
  colnames(graph) <- rownames(graph) <- as.character(seq_len(n_element) - 1)
  
  if (float & sparse) {
    graph@x <- abs(rnorm(length(graph@x), mean = 2, sd = 1))
  } else if (float) {
    graph[graph == 1] <- runif(length(graph[graph == 1]), min = 0.01, max = 3.00)
  }
  return(graph)
}
