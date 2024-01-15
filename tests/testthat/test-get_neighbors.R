get_neighbors_R <- function(adj_matrix, node_id, neighbor_type = c('both', 'forward', 'backward'),
                            return_type = c('binary', 'name', 'id')) {
  # adjacency matrix structure:
  #   A B C
  # A 0 1 0  // B->A
  # B 1 0 1  // A->B C->B
  # C 1 0 0  // A->C
  neighbor_type <- match.arg(neighbor_type)
  return_type <- match.arg(return_type)
  diag(adj_matrix) <- 0
  
  # A bug in R-4.3.2: as.logical would return wrong results
  # Fuck R
  forward_neighbors <- as.logical(adj_matrix[node_id, ])
  backward_neighbors <- as.logical(adj_matrix[, node_id])
  neighbors <- switch(neighbor_type,
                      forward = forward_neighbors,
                      backward = backward_neighbors,
                      both = pmax(backward_neighbors, forward_neighbors))
  neighbors <- as.integer(neighbors)
  
  nodes <- switch(return_type,
                  binary = neighbors,
                  name = colnames(adj_matrix)[which(neighbors > 0)],
                  id = unname(which(neighbors > 0))
  )
  return(nodes)
}

expect_equal(sort(get_neighbors(graph, 173, neighbor_type = 'backward',
                                return_type = 'id')),
             sort(get_neighbors_R(graph, 173, neighbor_type = 'backward',
                                  return_type = 'id')))

test_that("Test get_neighbors in original Anderson's paper", {
  graph <- Matrix::Matrix(nrow = 7, ncol = 7, data = c(
    0, 0, 0, 0, 0, 0, 0,
    1, 0, 0, 0, 0, 0, 0,
    1, 0, 0, 0, 0, 0, 0,
    0, 1, 0, 0, 0, 0, 0,
    0, 1, 1, 0, 0, 0, 0,
    0, 0, 1, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 0), sparse = TRUE)
  graph <- as(graph, 'dgCMatrix')
  colnames(graph) <- rownames(graph) <- as.character(seq_len(nrow(graph)) - 1)
  initial_info <- data.frame(node = colnames(graph),
                             strength = c(2, 4, 3, 2, 2, 1, 5),
                             in_stm = c(rep(1, 3), rep(0, 4)))
  
  for (i in 1:nrow(graph)) {
    expect_equal(get_neighbors(graph, i),
                 get_neighbors_R(graph, i))
  }
})

test_that("Test get_neighbors in large matrix", {
  replicate(25, {
    graph <- random_graph()
    save(graph, file = 'graph.Rdata')
    
    for (g in c('both', 'forward', 'backward')) {
      for (r in c('binary', 'name', 'id')) {
        node <- sample(1:nrow(graph), 1)
        expect_equal(sort(get_neighbors(graph, node, neighbor_type = g,
                                        return_type = r)),
                     sort(get_neighbors_R(graph, node, neighbor_type = g,
                                          return_type = r)))
      }
    }
  })
})

