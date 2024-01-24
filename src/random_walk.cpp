#include "../inst/include/labyrinth.h"
//' Do a Markon random walk (with restart) on an column-normalised adjacency
//' matrix.
//'
//' @noRd
//' @param p0  matrix of starting distribution
//' @param W  the column normalized adjacency matrix
//' @param r  restart probability
//' @param thresh  threshold to break as soon as new stationary distribution
//'   converges to the stationary distribution of the previous timepoint
//' @param niter  maximum number of iterations for the chain
//' @param do_analytical  boolean if the stationary distribution shall be
//'  computed solving the analytical solution or iteratively
//' @return  returns the matrix of stationary distributions p_inf
// [[Rcpp::export]]
VectorXd mrwr_(const MatrixXd& p0, const MatrixXd &W, const double r, const double thresh, const int niter, const bool do_analytical) {
    return diffusr::mrwr_(p0, W, r, thresh, niter, do_analytical);
}

//' Do a Markon random walk (with restart) on an column-normalised adjacency
//' matrix.
//'
//' @noRd
//' @param p0  matrix of starting distribution
//' @param W  the column normalized adjacency matrix
//' @param r  restart probability
//' @param thresh  threshold to break as soon as new stationary distribution
//'   converges to the stationary distribution of the previous timepoint
//' @param niter  maximum number of iterations for the chain
//' @param do_analytical  boolean if the stationary distribution shall be
//'  computed solving the analytical solution or iteratively
//' @return  returns the matrix of stationary distributions p_inf
// [[Rcpp::export]]
VectorXd mrwr_s(const MatrixXd &p0, const SpMat &W, const double r, const double thresh, const int niter, const bool do_analytical) {
    return diffusr::mrwr_s(p0, W, r, thresh, niter, do_analytical);
}
