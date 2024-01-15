#include "../inst/include/labyrinth.h"

// [[Rcpp::plugins("cpp17")]]
template <typename T>
ArrayXi get_neighbors_t(T &adj_matrix, const int &node_id, const int &neighbor_type) {
    size_t n = adj_matrix.rows();
    VectorXd neighbors, forward_neighbors, backward_neighbors;
    ArrayXi ret_neighbors;
    
    switch(neighbor_type) {
        case 1:    // forward
            neighbors = adj_matrix.row(node_id);
            break;
        case 2:    // backward
            neighbors = adj_matrix.col(node_id);
            break;
        default:    // both
            forward_neighbors = adj_matrix.row(node_id);
            backward_neighbors = adj_matrix.col(node_id);
            neighbors = forward_neighbors.cwiseMax(backward_neighbors);
            break;
    }

    ret_neighbors = neighbors.cwiseEqual(0).cast<int>().cwiseEqual(0).cast<int>().array();

    // efficiently set diagnoal as 0
    ret_neighbors[node_id] = 0;

    return(ret_neighbors);
}

// TODO: mention overloading, help needed
//' Get neighboring nodes in a graph (adjacency matrix)
//'
//' @description 
//' It returns the neighboring nodes of a specified node in a graph. The 
//' neighboring nodes can be returned in various formats, depending on the 
//' `return_type` parameter.
//'
//' @param adj_matrix A square \code{\link[base]{matrix}} (or 
//'   \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} representing the background 
//'   graph. Inside this adjacency matrix, each row and column of the matrix 
//'   represents a node in the graph. The values of the matrix should be either 0 
//'   or 1 (or either 0 or larger than 0), where a value of 0 indicates no 
//'   relations between two nodes. The diagonal of the matrix should be 0, as 
//'   there are no self-edges in the graph.
//' 
//' @param node_id The ID of the node whose neighbors are being retrieved. Node 
//'   name is also acceptable. 
//' 
//' @param neighbor_type The `neighbor_type` parameter specifies the type of 
//'   neighbors to include in the output: 
//'   - **0** (*both*): return all neighbors of the specific node, regarding the graph 
//'     as undirected. 
//'   - **1** (*forward*): return only the neighbors that are reachable from the 
//'     specified node, specifically means downstream neighbors in the directed 
//'     networks.
//'   - **2** (*backward*): return the upstream neighbors from the specific nodes. 
//'     Specifically, it will reverse the direction of all edges in the graph and 
//'     then return the downstream neighbors. 
//' 
//' @return A vector based on `return_type`. 
//' 
//' @examples
//' # make an adjacency matrix and randomly fill some cells with 1s
//' mat <- matrix(sample(c(0,1), 100, replace = TRUE), 10, 10)
//' diag(mat) <- 0 # remove self-loops
//' 
//' library(labyrinth)
//' # Get neighbors
//' get_neighbors_s(mat, 2, 0)
//' 
// [[Rcpp::plugins("cpp17")]]
// [[Rcpp::export]]
ArrayXi get_neighbors_s(MSpMat &adj_matrix, const int &node_id, const int neighbor_type) {
    return(get_neighbors_t(adj_matrix, node_id, neighbor_type));
}

//' Get neighboring nodes in a graph (adjacency matrix)
//'
//' @description 
//' It returns the neighboring nodes of a specified node in a graph. The 
//' neighboring nodes can be returned in various formats, depending on the 
//' `return_type` parameter.
//'
//' @param adj_matrix A square \code{\link[base]{matrix}} (or 
//'   \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} representing the background 
//'   graph. Inside this adjacency matrix, each row and column of the matrix 
//'   represents a node in the graph. The values of the matrix should be either 0 
//'   or 1 (or either 0 or larger than 0), where a value of 0 indicates no 
//'   relations between two nodes. The diagonal of the matrix should be 0, as 
//'   there are no self-edges in the graph.
//' 
//' @param node_id The ID of the node whose neighbors are being retrieved. Node 
//'   name is also acceptable. 
//' 
//' @param neighbor_type The `neighbor_type` parameter specifies the type of 
//'   neighbors to include in the output: 
//'   - **0** (*both*): return all neighbors of the specific node, regarding the graph 
//'     as undirected. 
//'   - **1** (*forward*): return only the neighbors that are reachable from the 
//'     specified node, specifically means downstream neighbors in the directed 
//'     networks.
//'   - **2** (*backward*): return the upstream neighbors from the specific nodes. 
//'     Specifically, it will reverse the direction of all edges in the graph and 
//'     then return the downstream neighbors. 
//' 
//' @return A vector based on `return_type`. 
//' 
//' @examples
//' # make an adjacency matrix and randomly fill some cells with 1s
//' mat <- matrix(sample(c(0,1), 100, replace = TRUE), 10, 10)
//' diag(mat) <- 0 # remove self-loops
//' 
//' library(labyrinth)
//' # Get neighbors
//' get_neighbors_s(mat, 2, 0)
//' 
// [[Rcpp::plugins("cpp17")]]
// [[Rcpp::export]]
ArrayXi get_neighbors_d(MMatrixXd &adj_matrix, const int &node_id, const int neighbor_type) {
    return(get_neighbors_t(adj_matrix, node_id, neighbor_type));
}
