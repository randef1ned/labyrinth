#include "../inst/include/labyrinth.h"

//' Sigmoid function of Spreadgram - C++ version
//' 
//' @description
//' The Sigmoid function is one of the basic function in Spreadgram algorithm. 
//'   This function calculates the Sigmoid function of a specific node given the 
//'   activation rates of the nodes and its neighbors. 
//'   The equation writes
//'   \deqn{\sigma (x,y) = {{\exp [a(x)a(y)]} \over {1 + \exp [a(x)a(y)]}}}.
//' 
//' @param ax A vector of the activation rates of x, which is a set of the y's 
//'   neighbors
//' 
//' @param ay A scalar of the activation rate of node y.
//' 
//' @param u If \eqn{x \in N(y)} then \eqn{u = 1}, otherwise \eqn{u = 0}. 
//' 
//' @return A vector of sigma
//' 
//' @examples
//' sigmoid_t(c(1,2,3), 2)
//' 
// [[Rcpp::plugins("cpp17")]]
// [[Rcpp::export]]
ArrayXd sigmoid_t(const ArrayXd &ax, const double &ay, const int u = 1) {
    ArrayXd likelihood = 1.0 / (1.0 + (ax * ay).exp());
    ArrayXd sigma = (u == 1) ? (1.0 - likelihood) : likelihood;
    return(sigma);
}

template <typename T> vector<double> spread_gram_t(const T &graph, ArrayXd &last_activation, double loose, int threads, bool display_progress) {
    size_t n = graph.rows();
    vector<double> next_activation(n);
    
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

    Progress p(n, display_progress);
    #pragma omp parallel for schedule(dynamic, 1)
    for (size_t y = 0; y < n; y++) {
        // Find all neighbors ID in the graph
        ArrayXi neighbors = get_neighbors_t(graph, y, 0);
        ArrayXd neighbors_arr = neighbors.cast<double>();

        // Then, pick the last activation rate from the vector a: ax
        // VectorXd last_activated = last_activation * neighbors;
        ArrayXd last_activated = neighbors_arr * last_activation;
        neighbors.resize(0);                // garbage collection
        neighbors_arr.resize(0);            // garbage collection
        p.increment();

        if (last_activated.sum() == 0.0) {
            next_activation[y] = 0.0;
        } else {
            // Next, get a(y)
            // Compute the similarity between the node pairs (x,y) and sum them up
            ArrayXd remove_zeros = (last_activated != 0).cast<double>();
            double doubley = double(y) + 1.0;
            ArrayXd rate = 1 - sigmoid_t(last_activated, doubley, 1).array();
            rate = rate * loose * remove_zeros * last_activated;
            
            next_activation[y] = rate.sum() + last_activation[y];
        }
    }
    return(next_activation);
}

//' Simulate spreading activation in a network (Only once)
//' 
//' @description
//' The ACT spreading activation formula is represented in Equation 1:
//'   \deqn{a(y) = \sum_x {f(x,y) \cdot a(x)} + c(y)},
//'   where \eqn{c(y)} represents the baseline activation of y.
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
//' @param last_activation A vector that containing the last time activation 
//'   rates of all nodes. The sequence is the same as the matrix.
//' 
//' @param loose A scalar numeric between 0 and 1 that determines the loose (or 
//'   weight) in the calculation process. 
//' 
//' @return A numeric vector that contains new activation
//' 
//' @examples
//' # The graph G
//' data("graph", package = "labyrinth")
//' 
//' # The initial info
//' last_activation = c(2, 4, 3, 2, 2, 1, 5)
//' 
//' results <- spread_activation_t(graph, last_activation)
//' 
// [[Rcpp::plugins("cpp17")]]
// [[Rcpp::export]]
vector<double> spread_gram_s(const MSpMat &graph, ArrayXd &last_activation, double loose = 1.0, int threads = 0, bool display_progress = false) {
    // TODO: mention overloading, help needed
    return(spread_gram_t(graph, last_activation, loose, threads, display_progress));
}

//' Simulate spreading activation in a network (Only once)
//' 
//' @description
//' The ACT spreading activation formula is represented in Equation 1:
//'   \deqn{a(y) = \sum_x {f(x,y) \cdot a(x)} + c(y)},
//'   where \eqn{c(y)} represents the baseline activation of y.
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
//' @param last_activation A vector that containing the last time activation 
//'   rates of all nodes. The sequence is the same as the matrix.
//' 
//' @param loose A scalar numeric between 0 and 1 that determines the loose (or 
//'   weight) in the calculation process. 
//' 
//' @return A numeric vector that contains new activation
//' 
//' @examples
//' # The graph G
//' data("graph", package = "labyrinth")
//' 
//' # The initial info
//' last_activation = c(2, 4, 3, 2, 2, 1, 5)
//' 
//' results <- spread_activation_t(graph, last_activation)
//' 
// [[Rcpp::plugins("cpp17")]]
// [[Rcpp::export]]
vector<double> spread_gram_d(const MMatrixXd &graph, ArrayXd &last_activation, double loose = 1.0, int threads = 0, bool display_progress = false) {
    return(spread_gram_t(graph, last_activation, loose, threads, display_progress));
}

template <typename T> double gradient_t(const T &graph, ArrayXd &activation, int threads, bool display_progress) {
    size_t n = graph.rows();
    VectorXd gradient(n);
    // vector<double> gradient(n);

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

    Progress p(n, display_progress);
    #pragma omp parallel for schedule(dynamic, 1)
    // find neighbors line by line
    for (size_t node = 0; node < n; node++) {
        ArrayXi neighbors = get_neighbors_t(graph, node, 0);
        ArrayXd neighbors_arr = neighbors.cast<double>();
        p.increment();

        if (neighbors_arr.sum() == 0) {
            // gradient[node] = 0;
            gradient[node] = 0.0;
        } else {
            double ay = activation[node];
            ArrayXd ax = activation * neighbors_arr;
            ArrayXd is_zeros = (ax != 0).cast<double>();
            neighbors_arr = neighbors_arr * is_zeros;
            ax = ax * is_zeros;

            // consider if the node cannot be activated
            // vector<double> default_sigma = {0.5};
            ArrayXd default_sigma = ArrayXi::Ones(1).cast<double>() / 2.0;
            ArrayXd sigma = (neighbors_arr != 0.0).any() ? sigmoid_t(ax, ay, 1) : default_sigma;
            ArrayXd s = ax * (neighbors_arr - sigma) * is_zeros;
            gradient[node] = s.sum();
        }
    }
    double mean_gradient = gradient.mean();

    return(mean_gradient);
}

//' Compute gradient of Spreadgram - C++ version
//' 
//' @description
//' This function calculates the gradient of the computed activation rates for a 
//'   given background graph. The gradient is computed based on the Sigmoid 
//'   function and the log likelihood, which iteratively computes the error
//'   between each permutation. 
//'   
//' This function requires the background graph and the computed activation rates 
//'   as input.
//' 
//' @param graph A square \code{\link[base]{matrix}} (or 
//'   \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} representing the background 
//'   graph. Inside this adjacency matrix, each row and column of the matrix 
//'   represents a node in the graph. The values of the matrix should be either 0 
//'   or 1 (or either 0 or larger than 0), where a value of 0 indicates no 
//'   relations between two nodes. The diagonal of the matrix should be 0, as 
//'   there are no self-edges in the graph.
//'   
//' @param activation A numeric vector representing the computed activation rates 
//'   for each node in the graph. The length of the vector should be equal to the 
//'   number of nodes in the graph. This vector should contain the activation 
//'   rate for each node.
//'
//' @return A scalar representing the gradient of the computed activation rates.
//'   The gradient represents the rate of change of the activation rate.
//' 
//' @examples
//' # The graph G
//' data("graph", package = "labyrinth")
//' 
//' # The initial info
//' last_activation = c(2, 4, 3, 2, 2, 1, 5)
//' 
//' gradient(graph, last_activation)
//' 
// [[Rcpp::plugins("cpp17")]]
// [[Rcpp::export]]
double gradient_s(const MSpMat &graph, ArrayXd &activation, int threads = 0, bool display_progress = false) {
    // TODO: mention overloading, help needed
    return(gradient_t(graph, activation, threads, display_progress));
}

//' Compute gradient of Spreadgram - C++ version
//' 
//' @description
//' This function calculates the gradient of the computed activation rates for a 
//'   given background graph. The gradient is computed based on the Sigmoid 
//'   function and the log likelihood, which iteratively computes the error
//'   between each permutation. 
//'   
//' This function requires the background graph and the computed activation rates 
//'   as input.
//' 
//' @param graph A square \code{\link[base]{matrix}} (or 
//'   \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} representing the background 
//'   graph. Inside this adjacency matrix, each row and column of the matrix 
//'   represents a node in the graph. The values of the matrix should be either 0 
//'   or 1 (or either 0 or larger than 0), where a value of 0 indicates no 
//'   relations between two nodes. The diagonal of the matrix should be 0, as 
//'   there are no self-edges in the graph.
//'   
//' @param activation A numeric vector representing the computed activation rates 
//'   for each node in the graph. The length of the vector should be equal to the 
//'   number of nodes in the graph. This vector should contain the activation 
//'   rate for each node.
//'
//' @return A scalar representing the gradient of the computed activation rates.
//'   The gradient represents the rate of change of the activation rate.
//' 
//' @examples
//' # The graph G
//' data("graph", package = "labyrinth")
//' 
//' # The initial info
//' last_activation = c(2, 4, 3, 2, 2, 1, 5)
//' 
//' gradient(graph, last_activation)
//' 
// [[Rcpp::plugins("cpp17")]]
// [[Rcpp::export]]
double gradient_d(const MMatrixXd &graph, ArrayXd &activation, int threads = 0, bool display_progress = false) {
    return(gradient_t(graph, activation, threads, display_progress));
}
