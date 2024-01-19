sigmoid_R <- function(ax, ay, u = 1) {
  likelihood <- magrittr::divide_by(1, 1 + exp(ax * ay))
  if (u == 1) {
    sigma <- 1 - likelihood
  } else {
    sigma <- likelihood
  }
  return(sigma)
}

gradient_R <- function(graph, activation) {
  # find neighbors line by line
  gradient <- sapply(1:nrow(graph), function(node) {
    neighbors <- get_neighbors(graph, node, return_type = "binary")
    
    # Consider if the node who do not have any neighbors
    if (sum(neighbors) == 0) {
      gradient <- 0
    } else {
      ay <- activation[node]
      
      ax <- activation * neighbors
      # u is the neighbors element
      u <- neighbors[ax != 0]
      ax <- ax[ax != 0]
      
      # Consider if the node can not be activated
      if (sum(u) == 0) {
        sigma <- 0.5
      } else {
        sigma <- sigmoid_R(ax, ay, 1)
      }
      
      gradient <- sum(ax * (u - sigma))
    }
    return(gradient)
  })
  return(mean(gradient))
}

spread_gram_R <- function(graph, last_activation, loose = 1.0) {
  #iterate all nodes
  next_activation <- sapply(1:nrow(graph), function(y) {
    # Find all neighbors ID in the graph
    neighbors <- get_neighbors(graph, y)
    
    # Then, pick the last activation rate from the vector a: ax
    last_activated <- last_activation * neighbors
    rate <- 0.0
    if (sum(last_activated)) {
      # Next, get a(y)
      ay <- last_activation[y]
      
      # Compute the similarity between the node pairs (x,y) and sum them up
      last_activated <- last_activated[last_activated != 0]
      rate <- (1 - sigmoid_R(last_activated, y, 1)) * last_activated * loose
      rate <- sum(rate) + ay
    }
    return(rate)
  })
  
  return(next_activation)
}

test_that("Test in example dataset", {
  # Load graph
  data("graph", package = "labyrinth")
  last_activation <- c(2, 4, 3, 2, 2, 1, 5)
  expect_equal(spread_gram_1(graph, last_activation),
               spread_gram_R(graph, last_activation))
  
  for (i in 1:nrow(graph)) {
    for (j in 1:nrow(graph)) {
      expect_equal(sigmoid(unname(graph[, i]), j),
                   sigmoid_R(unname(graph[, i]), j))
    }
  }
  
  expect_equal(gradient(graph, last_activation, verbose = FALSE),
               gradient_R(graph, last_activation))
})

test_that("Test in random graph with random parameters", {
  replicate(5, {
    graph <- random_graph()
    last_activation <- abs(round(rnorm(nrow(graph), mean = 1.5, sd = 1), digits = 1))
    expect_equal(spread_gram_1(graph, last_activation),
                 spread_gram_R(graph, last_activation))
    
    replicate(2, {
      test_row <- sample(x = 1:nrow(graph), size = 1, replace = FALSE)
      test_col <- sample(x = 1:nrow(graph), size = 1, replace = FALSE)
      
      expect_equal(sigmoid(unname(graph[, test_row]), test_col),
                   sigmoid_R(unname(graph[, test_row]), test_col))
    })
    
    expect_equal(gradient(graph, last_activation, verbose = FALSE),
                 gradient_R(graph, last_activation))
  })
})
