#if defined(WIN32) || defined(_WIN32) || defined(WIN64) || defined(_WIN64)
#define WINDOWS 1
#else
#define WINDOWS 0
#endif

#ifdef INTEL_MKL_VERSION 
#define EIGEN_USE_MKL_ALL
#endif
#define EIGEN_VECTORIZE_SSE4_2

// include standard C++ headers
#include <cstdint>
#include <numeric>
#include <algorithm>
#include <omp.h>
#include <execution>

// headers in this file are loaded in RcppExports.cpp
#include "hash.h"
// #include "RcppSparse.h"

// we only include RcppEigen.h which pulls Rcpp.h in for us
#include <RcppEigen.h>
#include <RcppParallel.h>
#include <progress.hpp>
#include <progress_bar.hpp>

// via the depends attribute we tell Rcpp to create hooks for
// RcppEigen so that the build process will know what to do
//
// [[Rcpp::depends(RcppEigen)]]
// [[Rcpp::plugins(openmp)]]
// [[Rcpp::depends(RcppParallel)]]
// [[Rcpp::depends(RcppProgress)]]
// [[Rcpp::depends(diffusr)]]

// other headers are loaded when C++ functions in src/ are being compiled.
// using namespace RcppSparse;
using namespace Rcpp;
using namespace Eigen;
using namespace std;

using Eigen::Map;           // 'maps' rather than copies
using Eigen::MatrixXd;      // variable size matrix, double precision
using Eigen::VectorXd;      // variable size vector, double precision
using Eigen::ArrayXd;
using Eigen::SparseMatrix;

typedef Eigen::MappedSparseMatrix<double> MSpMat;
typedef Eigen::Map<MatrixXd> MMatrixXd;
typedef Eigen::SparseMatrix<double> SpMat;

ArrayXi get_neighbors_s(const MSpMat &adj_matrix, const int &node_id, const int neighbor_type = 0);
ArrayXi get_neighbors_d (const MatrixXd &adj_matrix, const int &node_id, const int neighbor_type = 0);
template <typename T> ArrayXi get_neighbors_t(const T &adj_matrix, const int &node_id, const int &neighbor_type);
vector<double> spread_activation_t(const MSpMat &graph, VectorXd &last_activation, double loose);

#include <diffusr_RcppExports.h>

