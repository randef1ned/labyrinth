% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/spread_activation.R
\name{activation_rate}
\alias{activation_rate}
\title{Calculate the next-time ACT activation rate}
\usage{
activation_rate(
  graph,
  strength,
  stm,
  loose = 1,
  threads = 0,
  remove_first = FALSE,
  display_progress = TRUE
)
}
\arguments{
\item{graph}{A square \code{\link[base]{matrix}} (or 
\code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} representing the background 
graph. Inside this adjacency matrix, each row and column of the matrix 
represents a node in the graph. The values of the matrix should be either 0 
or 1 (or either 0 or larger than 0), where a value of 0 indicates no 
relations between two nodes. The diagonal of the matrix should be 0, as 
there are no self-edges in the graph.}

\item{strength}{A vector containing the *relative strength* of connections 
for each node in the graph, which is the same as the last time activation 
rates of all nodes. The sequence is the same as the matrix.}

\item{stm}{A binary vector which indicating whether the node is activated, or 
in the short-term memory}

\item{loose}{A scalar numeric between 0 and 1 that determines the loose (or 
weight) in the calculation process.}

\item{threads}{A scalar numeric indicating the parallel threads. Default is 0
(auto-detected).}

\item{remove_first}{A logical value indicating whether or not to exclude the 
first node from the calculation}

\item{display_progress}{A logical value indicating whether or not to show the
progress.}
}
\value{
A vector containing the activation rate for each node in the graph
}
\description{
This function calculates the activation rate for each node in a graph based 
on its connectivity to other nodes, the *relative strength* of the 
connections, and a global loose factor.

The ACT spreading activation formula is represented in Equation 1:
  \deqn{a(y) = \sum_x {f(x,y) \cdot a(x)} + c(y)},
 where c(y) represents the baseline activation of y.
  \eqn{\alpha} represents the proximity of a node in this network.
  \eqn{t} represents the iteration number
}
\examples{
library(magrittr)

graph <- matrix(nrow = 7, ncol=7, data=c(
  0, 0, 0, 0, 0, 0, 0,
  1, 0, 0, 0, 0, 0, 0,
  1, 0, 0, 0, 0, 0, 0,
  0, 1, 0, 0, 0, 0, 0,
  0, 1, 1, 0, 0, 0, 0,
  0, 0, 1, 0, 0, 0, 0,
  0, 0, 0, 1, 1, 1, 0))
diag(graph) <- 0
colnames(graph) <- rownames(graph) <- seq_len(nrow(graph)) \%>\% 
  subtract(1) \%>\% as.character()

initial_info <- data.frame(node = colnames(graph),
                           strength = c(2, 4, 3, 2, 2, 1, 5),
                           in_stm = c(rep(1, 3), rep(0, 4)))

activation_rate(graph, initial_info$strength, initial_info$in_stm, 
  loose = 0.8, remove_first = TRUE)

}
