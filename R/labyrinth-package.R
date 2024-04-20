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
#' @import RcppProgress
#'
NULL

utils::globalVariables(c("."))

.onAttach <- function(libname, pkgname) {
  data_dir <- tools::R_user_dir("labyrinth")
  for (i in 1:3) {
    if (i == 3) {
      stop("Permission denied.")
    } else if (!dir.exists(data_dir)) {
      packageStartupMessage("Data directory is not exist. ",
                            "Creating data directory...")
      dir.create(data_dir, recursive = TRUE)
    } else {
      break
    }
  }
  TRUE
}
