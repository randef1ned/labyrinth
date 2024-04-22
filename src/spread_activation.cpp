#include "../inst/include/labyrinth.h"

// [[Rcpp::plugins("cpp17")]]
template <typename T> double transfer_activation_t(T &graph, const int &y, const int &x, const ArrayXd &activation, const double loose) {
    // Equivalent with: ArrayXi all_neighbors = get_neighbors_t(graph, x, 0);
    double backward_neighbors_y, forward_neighbors_y, neighbors_y = 0;
    double numerator = 0.0, denominator = 1.0, ret = 0.0;
    if (x != y) {
        backward_neighbors_y = graph.coeff(y, x);
        forward_neighbors_y = graph.coeff(x, y);
        neighbors_y = std::max(backward_neighbors_y, forward_neighbors_y);
        numerator = activation[y] * loose;
    }

    if (neighbors_y == 0) {
        numerator = 0.0;
    } else if (numerator > 0) {
        // Find all neighbors of node x that are backward neighbors
        ArrayXi all_backward_neighbors; // get_neighbors_t(graph, x, 2);
        // Then, we ought to know the position of node y
        // y -> x: 1;
        // x -> y: 0.
        // If y->x is true, it means that all the neighbors of x are not included in the backward neighbors
        // If x->y is true, it means that all the neighbors of x are included except node y
        if (backward_neighbors_y) {
            all_backward_neighbors = get_neighbors_t(graph, x, 0);
            //all_backward_neighbors = all_backward_neighbors + (all_neighbors - all_backward_neighbors);
        } else {
            //all_backward_neighbors[y] = 1;
            all_backward_neighbors = get_neighbors_t(graph, x, 2);
            all_backward_neighbors[y] = 1;
        }
        denominator = (activation * all_backward_neighbors.cast<double>()).sum();
    }
    ret = numerator / denominator;
    return(ret);

}

// [[Rcpp::plugins("cpp17")]]
template <typename T> VectorXd activation_rate_t(T &graph, const ArrayXd &strength, const ArrayXd &stm, const double loose, int threads, bool remove_first, bool display_progress) {
    size_t element = graph.rows();
    // Build new activation_rate matrix
    MatrixXd activation_pattern(element, element);
    
    int max_threads = 1;
#ifdef _OPENMP
    max_threads = omp_get_max_threads();
    if (threads > 0 && threads <= max_threads) {
        omp_set_num_threads(threads);
    } else {
        threads = max_threads;
    }
# else
    threads = 1;
#endif
    if (display_progress) {
        Rprintf("Number of threads: %i, max threads: %i. \n", threads, max_threads);
    }

    // Iterate over all nodes
    Progress p(element, display_progress);
    #pragma omp parallel for schedule(dynamic, 1)
    for (int y = 0; y < element; y++) {
        // Find all neighbors ID in the graph
        ArrayXi neighbors = get_neighbors_t(graph, y, 0);
        
        if (!Progress::check_abort()) {
            p.increment();
            for (int neighbor_id = 0; neighbor_id < element; neighbor_id++) {
                if (neighbors[neighbor_id]) {
                    activation_pattern.coeffRef(y, neighbor_id) = transfer_activation_t(graph, y, neighbor_id, strength, loose);
                }
            }
        }
    }
    
    if (display_progress) {
        Rprintf("Solving activation patterns...\n");
    }
    
    // Build two matrices
    VectorXd coefficient_matrix = strength * stm * (-1.0);
    #pragma omp parallel for
    for (int i = 0; i < element; i++) {
        activation_pattern.diagonal()[i] = -1.0;
    }
    
    if (remove_first) {
        size_t removed_element = element - 1;
        activation_pattern = activation_pattern.rightCols(removed_element).bottomRows(removed_element);
        VectorXd shrinked_coefficient_matrix = coefficient_matrix.bottomRows(removed_element);
        coefficient_matrix.resize(0);
        coefficient_matrix = shrinked_coefficient_matrix;
    }
    BiCGSTAB<MatrixXd> solver;
    solver.compute(activation_pattern);
    VectorXd activated = solver.solve(coefficient_matrix);

    return(activated);
}

//' Calculate the received activation in Spreading Activation (f)
//'
//' @description 
//' This function calculates the next-time received activation value from node y 
//' to node x in the specific graph, based on the activation values of its 
//' neighbors (including y) and a weighting factor loose.
//' 
//' The formula is \eqn{f^{t+1}(x,j) = l \cdot s_k / \sum_{j} {s_j}}.
//'
//' @param graph A square \code{\link[base]{matrix}} (or 
//'   \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} representing the background 
//'   graph. Inside this adjacency matrix, each row and column of the matrix 
//'   represents a node in the graph. The values of the matrix should be either 0 
//'   or 1 (or either 0 or larger than 0), where a value of 0 indicates no 
//'   relations between two nodes. The diagonal of the matrix should be 0, as 
//'   there are no self-edges in the graph.
//' 
//' @param y The index or ID of the node for which to specify the attention place
//' 
//' @param x The index or ID of the neighbor of node y
//' 
//' @param activation A vector containing the last-time activation values of all 
//'   nodes. the sequence is the same as the matrix.
//' 
//' @param loose A scalar numeric between 0 and 1 that determines the loose (or 
//'   weight) in the calculation process. 
//'
//' @return A scalar value representing the activation value for node x
//' 
//' @examples
//' # make an adjacency matrix and randomly fill some cells with 1s
//' mat <- matrix(sample(c(0,1), 100, replace = TRUE), 10, 10)
//' diag(mat) <- 0 # remove self-loops
//'
//' transfer_activation_t(mat, 3, 2, 1:10)
//' 
// [[Rcpp::plugins("cpp17")]]
// [[Rcpp::export]]
double transfer_activation_s(MSpMat &graph, const int &y, const int &x, const ArrayXd &activation, const double loose = 1.0) {
    return(transfer_activation_t(graph, y, x, activation, loose));
}

//' Calculate the received activation in Spreading Activation (f)
//'
//' @description
//' This function calculates the next-time received activation value from node y
//' to node x in the specific graph, based on the activation values of its
//' neighbors (including y) and a weighting factor loose.
//'
//' The formula is \eqn{f^{t+1}(x,j) = l \cdot s_k / \sum_{j} {s_j}}.
//'
//' @param graph A square \code{\link[base]{matrix}} (or
//'   \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} representing the background
//'   graph. Inside this adjacency matrix, each row and column of the matrix
//'   represents a node in the graph. The values of the matrix should be either 0
//'   or 1 (or either 0 or larger than 0), where a value of 0 indicates no
//'   relations between two nodes. The diagonal of the matrix should be 0, as
//'   there are no self-edges in the graph.
//'
//' @param y The index or ID of the node for which to specify the attention place
//'
//' @param x The index or ID of the neighbor of node y
//'
//' @param activation A vector containing the last-time activation values of all
//'   nodes. the sequence is the same as the matrix.
//'
//' @param loose A scalar numeric between 0 and 1 that determines the loose (or
//'   weight) in the calculation process.
//'
//' @return A scalar value representing the activation value for node x
//'
//' @examples
//' # make an adjacency matrix and randomly fill some cells with 1s
//' mat <- matrix(sample(c(0,1), 100, replace = TRUE), 10, 10)
//' diag(mat) <- 0 # remove self-loops
//'
//' transfer_activation_d(mat, 3, 2, 1:10)
// [[Rcpp::plugins("cpp17")]]
// [[Rcpp::export]]
double transfer_activation_d(MMatrixXd &graph, const int &y, const int &x, const ArrayXd &activation, const double loose = 1.0) {
    return(transfer_activation_t(graph, y, x, activation, loose));
}

//' Calculate the next-time ACT activation rate
//'
//' @description
//' This function calculates the activation rate for each node in a graph based
//' on its connectivity to other nodes, the *relative strength* of the
//' connections, and a global loose factor.
//'
//' The ACT spreading activation formula is represented in Equation 1:
//'   \deqn{a(y) = \sum_x {f(x,y) \cdot a(x)} + c(y)},
//'  where c(y) represents the baseline activation of y.
//'   \eqn{\alpha} represents the proximity of a node in this network.
//'   \eqn{t} represents the iteration number
//'
//' @param graph A square \code{\link[base]{matrix}} (or
//'   \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} representing the background
//'   graph. Inside this adjacency matrix, each row and column of the matrix
//'   represents a node in the graph. The values of the matrix should be either 0
//'   or 1 (or either 0 or larger than 0), where a value of 0 indicates no
//'   relations between two nodes. The diagonal of the matrix should be 0, as
//'   there are no self-edges in the graph.
//'
//' @param strength A vector containing the *relative strength* of connections
//'   for each node in the graph, which is the same as the last time activation
//'   rates of all nodes. The sequence is the same as the matrix.
//'
//' @param stm A binary vector which indicating whether the node is activated, or
//'   in the short-term memory
//'
//' @param loose A scalar numeric between 0 and 1 that determines the loose (or
//'   weight) in the calculation process.
//'
//' @param remove_first A logical value indicating whether or not to exclude the
//'   first node from the calculation
//'
//' @return A vector containing the activation rate for each node in the graph
//'
//' @examples
//' library(magrittr)
//'
//' # make an adjacency matrix and randomly fill some cells with 1s
//' mat <- matrix(sample(c(0,1), 100, replace = TRUE), 10, 10)
//' diag(mat) <- 0 # remove self-loops
//'
//' graph <- matrix(nrow=7, ncol=7, data=c(
//'   0, 0, 0, 0, 0, 0, 0,
//'   1, 0, 0, 0, 0, 0, 0,
//'   1, 0, 0, 0, 0, 0, 0,
//'   0, 1, 0, 0, 0, 0, 0,
//'   0, 1, 1, 0, 0, 0, 0,
//'   0, 0, 1, 0, 0, 0, 0,
//'   0, 0, 0, 1, 1, 1, 0))
//' diag(graph) <- 0
//' colnames(graph) <- rownames(graph) <- seq_len(nrow(graph)) %>% 
//'   subtract(1) %>% as.character()
//'
//' initial_info <- data.frame(node = colnames(graph),
//'                            strength = c(2, 4, 3, 2, 2, 1, 5),
//'                            in_stm = c(rep(1, 3), rep(0, 4)))
//' 
//' activation_rate_t(graph, initial_info$strength, initial_info$in_stm, 
//'   loose = 0.8, remove_first = TRUE)
//' 
// [[Rcpp::plugins("cpp17")]]
// [[Rcpp::export]]
VectorXd activation_rate_s(MSpMat &graph, const ArrayXd &strength, const ArrayXd &stm, const double loose = 1.0, int threads = 0, bool remove_first = false, bool display_progress = true) {
    return(activation_rate_t(graph, strength, stm, loose, threads, remove_first, display_progress));
}

//' Calculate the next-time ACT activation rate
//'
//' @description
//' This function calculates the activation rate for each node in a graph based
//' on its connectivity to other nodes, the *relative strength* of the
//' connections, and a global loose factor.
//'
//' The ACT spreading activation formula is represented in Equation 1:
//'   \deqn{a(y) = \sum_x {f(x,y) \cdot a(x)} + c(y)},
//'  where c(y) represents the baseline activation of y.
//'   \eqn{\alpha} represents the proximity of a node in this network.
//'   \eqn{t} represents the iteration number
//'
//' @param graph A square \code{\link[base]{matrix}} (or
//'   \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} representing the background
//'   graph. Inside this adjacency matrix, each row and column of the matrix
//'   represents a node in the graph. The values of the matrix should be either 0
//'   or 1 (or either 0 or larger than 0), where a value of 0 indicates no
//'   relations between two nodes. The diagonal of the matrix should be 0, as
//'   there are no self-edges in the graph.
//'
//' @param strength A vector containing the *relative strength* of connections
//'   for each node in the graph, which is the same as the last time activation
//'   rates of all nodes. The sequence is the same as the matrix.
//'
//' @param stm A binary vector which indicating whether the node is activated, or
//'   in the short-term memory
//'
//' @param loose A scalar numeric between 0 and 1 that determines the loose (or
//'   weight) in the calculation process.
//'
//' @param remove_first A logical value indicating whether or not to exclude the
//'   first node from the calculation
//'
//' @return A vector containing the activation rate for each node in the graph
//'
//' @examples
//' library(magrittr)
//'
//' # make an adjacency matrix and randomly fill some cells with 1s
//' mat <- matrix(sample(c(0,1), 100, replace = TRUE), 10, 10)
//' diag(mat) <- 0 # remove self-loops
//'
//' graph <- matrix(nrow=7, ncol=7, data=c(
//'   0, 0, 0, 0, 0, 0, 0,
//'   1, 0, 0, 0, 0, 0, 0,
//'   1, 0, 0, 0, 0, 0, 0,
//'   0, 1, 0, 0, 0, 0, 0,
//'   0, 1, 1, 0, 0, 0, 0,
//'   0, 0, 1, 0, 0, 0, 0,
//'   0, 0, 0, 1, 1, 1, 0))
//' diag(graph) <- 0
//' colnames(graph) <- rownames(graph) <- seq_len(nrow(graph)) %>% 
//'   subtract(1) %>% as.character()
//'
//' initial_info <- data.frame(node = colnames(graph),
//'                            strength = c(2, 4, 3, 2, 2, 1, 5),
//'                            in_stm = c(rep(1, 3), rep(0, 4)))
//'
//' activation_rate_t(graph, initial_info$strength, initial_info$in_stm, 
//'   loose = 0.8, remove_first = TRUE)
// [[Rcpp::plugins("cpp17")]]
// [[Rcpp::export]]
VectorXd activation_rate_d(MMatrixXd &graph, const ArrayXd &strength, const ArrayXd &stm, const double loose = 1.0, int threads = 0, bool remove_first = false, bool display_progress = true) {
    return(activation_rate_t(graph, strength, stm, loose, threads, remove_first, display_progress));
}
