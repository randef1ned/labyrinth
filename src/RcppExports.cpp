// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include "../inst/include/labyrinth.h"
#include <RcppEigen.h>
#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// get_neighbors_s
ArrayXi get_neighbors_s(const MSpMat& adj_matrix, const int& node_id, const int neighbor_type);
RcppExport SEXP _labyrinth_get_neighbors_s(SEXP adj_matrixSEXP, SEXP node_idSEXP, SEXP neighbor_typeSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const MSpMat& >::type adj_matrix(adj_matrixSEXP);
    Rcpp::traits::input_parameter< const int& >::type node_id(node_idSEXP);
    Rcpp::traits::input_parameter< const int >::type neighbor_type(neighbor_typeSEXP);
    rcpp_result_gen = Rcpp::wrap(get_neighbors_s(adj_matrix, node_id, neighbor_type));
    return rcpp_result_gen;
END_RCPP
}
// get_neighbors_d
ArrayXi get_neighbors_d(const MMatrixXd& adj_matrix, const int& node_id, const int neighbor_type);
RcppExport SEXP _labyrinth_get_neighbors_d(SEXP adj_matrixSEXP, SEXP node_idSEXP, SEXP neighbor_typeSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const MMatrixXd& >::type adj_matrix(adj_matrixSEXP);
    Rcpp::traits::input_parameter< const int& >::type node_id(node_idSEXP);
    Rcpp::traits::input_parameter< const int >::type neighbor_type(neighbor_typeSEXP);
    rcpp_result_gen = Rcpp::wrap(get_neighbors_d(adj_matrix, node_id, neighbor_type));
    return rcpp_result_gen;
END_RCPP
}
// transfer_activation_s
double transfer_activation_s(MSpMat& graph, const int& y, const int& x, const ArrayXd& activation, const double loose);
RcppExport SEXP _labyrinth_transfer_activation_s(SEXP graphSEXP, SEXP ySEXP, SEXP xSEXP, SEXP activationSEXP, SEXP looseSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< MSpMat& >::type graph(graphSEXP);
    Rcpp::traits::input_parameter< const int& >::type y(ySEXP);
    Rcpp::traits::input_parameter< const int& >::type x(xSEXP);
    Rcpp::traits::input_parameter< const ArrayXd& >::type activation(activationSEXP);
    Rcpp::traits::input_parameter< const double >::type loose(looseSEXP);
    rcpp_result_gen = Rcpp::wrap(transfer_activation_s(graph, y, x, activation, loose));
    return rcpp_result_gen;
END_RCPP
}
// transfer_activation_d
double transfer_activation_d(MMatrixXd& graph, const int& y, const int& x, const ArrayXd& activation, const double loose);
RcppExport SEXP _labyrinth_transfer_activation_d(SEXP graphSEXP, SEXP ySEXP, SEXP xSEXP, SEXP activationSEXP, SEXP looseSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< MMatrixXd& >::type graph(graphSEXP);
    Rcpp::traits::input_parameter< const int& >::type y(ySEXP);
    Rcpp::traits::input_parameter< const int& >::type x(xSEXP);
    Rcpp::traits::input_parameter< const ArrayXd& >::type activation(activationSEXP);
    Rcpp::traits::input_parameter< const double >::type loose(looseSEXP);
    rcpp_result_gen = Rcpp::wrap(transfer_activation_d(graph, y, x, activation, loose));
    return rcpp_result_gen;
END_RCPP
}
// activation_rate_s
VectorXd activation_rate_s(MSpMat& graph, const ArrayXd& strength, const ArrayXd& stm, const double loose, int threads, bool remove_first, bool display_progress);
RcppExport SEXP _labyrinth_activation_rate_s(SEXP graphSEXP, SEXP strengthSEXP, SEXP stmSEXP, SEXP looseSEXP, SEXP threadsSEXP, SEXP remove_firstSEXP, SEXP display_progressSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< MSpMat& >::type graph(graphSEXP);
    Rcpp::traits::input_parameter< const ArrayXd& >::type strength(strengthSEXP);
    Rcpp::traits::input_parameter< const ArrayXd& >::type stm(stmSEXP);
    Rcpp::traits::input_parameter< const double >::type loose(looseSEXP);
    Rcpp::traits::input_parameter< int >::type threads(threadsSEXP);
    Rcpp::traits::input_parameter< bool >::type remove_first(remove_firstSEXP);
    Rcpp::traits::input_parameter< bool >::type display_progress(display_progressSEXP);
    rcpp_result_gen = Rcpp::wrap(activation_rate_s(graph, strength, stm, loose, threads, remove_first, display_progress));
    return rcpp_result_gen;
END_RCPP
}
// activation_rate_d
VectorXd activation_rate_d(MMatrixXd& graph, const ArrayXd& strength, const ArrayXd& stm, const double loose, int threads, bool remove_first, bool display_progress);
RcppExport SEXP _labyrinth_activation_rate_d(SEXP graphSEXP, SEXP strengthSEXP, SEXP stmSEXP, SEXP looseSEXP, SEXP threadsSEXP, SEXP remove_firstSEXP, SEXP display_progressSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< MMatrixXd& >::type graph(graphSEXP);
    Rcpp::traits::input_parameter< const ArrayXd& >::type strength(strengthSEXP);
    Rcpp::traits::input_parameter< const ArrayXd& >::type stm(stmSEXP);
    Rcpp::traits::input_parameter< const double >::type loose(looseSEXP);
    Rcpp::traits::input_parameter< int >::type threads(threadsSEXP);
    Rcpp::traits::input_parameter< bool >::type remove_first(remove_firstSEXP);
    Rcpp::traits::input_parameter< bool >::type display_progress(display_progressSEXP);
    rcpp_result_gen = Rcpp::wrap(activation_rate_d(graph, strength, stm, loose, threads, remove_first, display_progress));
    return rcpp_result_gen;
END_RCPP
}
// sigmoid_t
VectorXd sigmoid_t(ArrayXd& ax, double& ay, int u);
RcppExport SEXP _labyrinth_sigmoid_t(SEXP axSEXP, SEXP aySEXP, SEXP uSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< ArrayXd& >::type ax(axSEXP);
    Rcpp::traits::input_parameter< double& >::type ay(aySEXP);
    Rcpp::traits::input_parameter< int >::type u(uSEXP);
    rcpp_result_gen = Rcpp::wrap(sigmoid_t(ax, ay, u));
    return rcpp_result_gen;
END_RCPP
}
// spread_gram_s
vector<double> spread_gram_s(MSpMat& graph, ArrayXd& last_activation, double loose);
RcppExport SEXP _labyrinth_spread_gram_s(SEXP graphSEXP, SEXP last_activationSEXP, SEXP looseSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< MSpMat& >::type graph(graphSEXP);
    Rcpp::traits::input_parameter< ArrayXd& >::type last_activation(last_activationSEXP);
    Rcpp::traits::input_parameter< double >::type loose(looseSEXP);
    rcpp_result_gen = Rcpp::wrap(spread_gram_s(graph, last_activation, loose));
    return rcpp_result_gen;
END_RCPP
}
// spread_gram_d
vector<double> spread_gram_d(MMatrixXd& graph, ArrayXd& last_activation, double loose);
RcppExport SEXP _labyrinth_spread_gram_d(SEXP graphSEXP, SEXP last_activationSEXP, SEXP looseSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< MMatrixXd& >::type graph(graphSEXP);
    Rcpp::traits::input_parameter< ArrayXd& >::type last_activation(last_activationSEXP);
    Rcpp::traits::input_parameter< double >::type loose(looseSEXP);
    rcpp_result_gen = Rcpp::wrap(spread_gram_d(graph, last_activation, loose));
    return rcpp_result_gen;
END_RCPP
}
// gradient_s
double gradient_s(MSpMat& graph, ArrayXd& activation);
RcppExport SEXP _labyrinth_gradient_s(SEXP graphSEXP, SEXP activationSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< MSpMat& >::type graph(graphSEXP);
    Rcpp::traits::input_parameter< ArrayXd& >::type activation(activationSEXP);
    rcpp_result_gen = Rcpp::wrap(gradient_s(graph, activation));
    return rcpp_result_gen;
END_RCPP
}
// gradient_d
double gradient_d(MMatrixXd& graph, ArrayXd& activation);
RcppExport SEXP _labyrinth_gradient_d(SEXP graphSEXP, SEXP activationSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< MMatrixXd& >::type graph(graphSEXP);
    Rcpp::traits::input_parameter< ArrayXd& >::type activation(activationSEXP);
    rcpp_result_gen = Rcpp::wrap(gradient_d(graph, activation));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_labyrinth_get_neighbors_s", (DL_FUNC) &_labyrinth_get_neighbors_s, 3},
    {"_labyrinth_get_neighbors_d", (DL_FUNC) &_labyrinth_get_neighbors_d, 3},
    {"_labyrinth_transfer_activation_s", (DL_FUNC) &_labyrinth_transfer_activation_s, 5},
    {"_labyrinth_transfer_activation_d", (DL_FUNC) &_labyrinth_transfer_activation_d, 5},
    {"_labyrinth_activation_rate_s", (DL_FUNC) &_labyrinth_activation_rate_s, 7},
    {"_labyrinth_activation_rate_d", (DL_FUNC) &_labyrinth_activation_rate_d, 7},
    {"_labyrinth_sigmoid_t", (DL_FUNC) &_labyrinth_sigmoid_t, 3},
    {"_labyrinth_spread_gram_s", (DL_FUNC) &_labyrinth_spread_gram_s, 3},
    {"_labyrinth_spread_gram_d", (DL_FUNC) &_labyrinth_spread_gram_d, 3},
    {"_labyrinth_gradient_s", (DL_FUNC) &_labyrinth_gradient_s, 2},
    {"_labyrinth_gradient_d", (DL_FUNC) &_labyrinth_gradient_d, 2},
    {NULL, NULL, 0}
};

RcppExport void R_init_labyrinth(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
