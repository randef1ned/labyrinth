#' labyrinth
#' 
#' @title Labyrinth: A Simulation of Knowledge Networks
#' 
#' @name labyrinth-package
#' 
#' @aliases labyrinth
#' 
#' @description One paragraph description of what the package does
#'   as one or more full sentences. I can use Config/testthat/parallel as 
#'   true to boost the test efficiency. 
#' 
#' @examples
#' # if (!"devtools" %in% as.data.frame(installed.packages())$Package)
#' #   install.packages("devtools")
#' # devtools::install_github("randef1ned/labyrinth")
#' 
#' @useDynLib labyrinth, .registration = TRUE
#' 
#' @importFrom Rcpp sourceCpp
#' @importFrom RcppEigen fastLm
#' @importFrom RcppParallel RcppParallelLibs
#' @import RcppProgress
#' 
NULL

utils::globalVariables(c("."))
