transfer_activation_R <- function(graph, y, x, activation, loose = 1) {
  diag(graph) <- 0
  all_neighbors <- get_neighbors(graph, x)
  
  numerator <- activation[y] * loose
  denominator <- 1
  
  if (all_neighbors[y] == 0) {
    numerator <- 0
  } else if (numerator > 0) {
    # Find all neighbors of node x that are backward neighbors
    all_backward_neighbors <- get_neighbors(graph, x, neighbor_type = "backward")
    # Then, we ought to know the position of node y
    # y -> x: 1; 
    # x -> y: 0.
    #yx <- as.logical(all_neighbors_in_criterion[y])
    # If y->x is true, it means that all the neighbors of x are not included in the backward neighbors
    # If x->y is true, it means that all the neighbors of x are included except node y
    if (as.logical(all_backward_neighbors[y])) {
      all_backward_neighbors <- all_backward_neighbors + (all_neighbors - all_backward_neighbors)
    } else {
      all_backward_neighbors[y] <- 1
    }
    
    denominator <- sum(all_backward_neighbors * activation)
  }
  
  return(numerator / denominator)
}

activation_rate_R <- function(graph, strength, stm, loose = 1.0, remove_first = FALSE) {
  # build new activation_rate matrix
  activation_pattern <- graph * 0
  
  # iterate all nodes
  for (y in 1:nrow(graph)) {
    # Find all neighbors ID in the graph
    neighbors <- get_neighbors(graph, y, return_type = "binary")
    
    for (neighbor_id in seq_along(neighbors)) {
      # If neighbors[neighbor_id] == 0 then return 0
      # Else find the neighbor's neighbor
      activation_pattern[y, neighbor_id] <- neighbors[neighbor_id] * transfer_activation_R(graph, y, neighbor_id, strength, loose = loose)
    }
  }
  
  # Build two matrix
  coefficient_matrix <- strength * stm * (-1)
  diag(activation_pattern) <- -1
  activated <- solve(activation_pattern, coefficient_matrix)
  
  if (remove_first) {
    activation_pattern <- activation_pattern[-1, -1]
    coefficient_matrix <- coefficient_matrix[-1]
  }
  
  solved <- solve(activation_pattern, coefficient_matrix)
  return(unname(solved))
}

test_that("Test in example dataset", {
  # Load graph
  data("graph", package = "labyrinth")
  strength <- c(2, 4, 3, 2, 2, 1, 5)
  stm <- c(rep(1, 3), rep(0, 4))
  
  sapply(1:10 / 10, function(loose) {
    expect_equal(activation_rate(graph, strength, stm, loose),
                 activation_rate_R(graph, strength, stm, loose))
  })
  
  mat <- matrix(sample(c(0,1), 100, replace = TRUE), 10, 10)
  
  expect_equal(transfer_activation(mat, 3, 2, 1:10),
               transfer_activation_R(mat, 3, 2, 1:10))
})

test_that("Test in example dataset", {
  replicate(25, {
    # Load graph
    graph <- random_graph()
    n <- nrow(graph)
    strength <- runif(n, min = 1e-10, max = 2)
    stm_num <- round(runif(1, min = 1, max = n - 1))
    stm <- sample(c(rep(1, stm_num), rep(0, n - stm_num)), n, replace = FALSE)
    loose <- runif(1, min = 1e-10, max = 1)
    expect_equal(activation_rate(graph, strength, stm, loose),
                 activation_rate_R(graph, strength, stm, loose))
    
    replicate(5, {
      y <- sample(1:n, 1, replace = FALSE)
      x <- sample(1:n, 1, replace = FALSE)
      act <- abs(rnorm(n, mean = 1, sd = 1))
      expect_equal(transfer_activation(graph, y, x, act),
                   transfer_activation_R(graph, y, x, act))
    })
  })
})
