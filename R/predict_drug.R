#' @title Predict drug response scores based on disease weights
#' 
#' @description
#' This function predict drug response scores based on disease weights using 
#'   multiple methods. It takes a vector of disease weights and a sparse matrix 
#'   representing a drug-disease interaction model, and calculates the predicted 
#'   drug scores using one of three methods: random walk with restart (`rwr`), 
#'   original spreading activation (`sa`), or Spread-gram (`sg`). 
#' 
#' @param disease_weights A \code{\link[methods:namedList-class]{named vector}} 
#'   of disease weights. The names of the vector should correspond to the 
#'   disease IDs in the \link[labyrinth:disease_ids]{`disease_ids` dataset}.
#' 
#' @param model A square \code{\link[base]{matrix}} (or 
#'   \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} of the pre-trained model.
#' 
#' @param method A character string specifying the prediction method to use. 
#'   The drug scores can be predicted using one of these three methods: random
#'   walk with restart (`rwr`), original spreading activation (`sa`), or Spread-
#'   gram (`sg`). Default option is `rwr`.
#' 
#' @param restart_prob The restart probability for the random walk with restart 
#'   method. Default is 0.7.
#' 
#' @param threshold The convergence threshold for the iteration. Recommended 
#'   value is 1e-6 in `rwr` and 1 in `sg`.
#' 
#' @param max_iter The maximum number of iterations. Default value is 1e6.
#' 
#' @param loose The loose parameter for the original spreading activation 
#'   method. Default is 1.0.
#' 
#' @param print_weight_only A logical value indicating whether to print only the
#'   predicted drug weights. If TRUE, only one 
#'   \link[methods:numeric-class]{numeric vector} with all drug weights is 
#'   returned. If FALSE, a \link[methods:data.frame-class]{data frame} with drug 
#'   IDs, drug names, and drug weights is returned. Default value is FALSE.
#'
#' @return
#' The return value is based on `print_weight_only`. If TRUE, only one 
#'   \link[methods:numeric-class]{numeric vector} with all drug weights is 
#'   returned. If FALSE, a \link[methods:data.frame-class]{data frame} with drug 
#'   IDs, drug names, and drug weights is returned.
#' 
#' @seealso 
#' [random_walk()] for technical details of random walk with restart method.
#' [spread_gram()] for technical details of Spread-gram method.
#' [activation_rate()] for technical details of the original spreading
#'   activation method.
#' 
#' @export
#' 
#' @importFrom utils data head
#' @importFrom checkmate assert_numeric assert test_matrix assert_int assert_number
#' @importFrom dplyr group_by summarize left_join relocate arrange desc first %>%
#' @importFrom rlang .data
#' 
#' @examples
#' # Load example data to the environment
#' data("drug_annot", package = "labyrinth")
#' 
#' \donttest{
#' # Load models to the environment
#' model <- load_model()
#' 
#' # Construct disease weights
#' disease_weights <- sample(c(rep(0, 50), rep(1, 2)), 1098, replace = TRUE)
#' 
#' # Predict drug scores based on disease weights
#' drug_weights <- predict_drug(disease_weights, model, method = "rwr")
#' }
#' 
predict_drug <- function(disease_weights, model, method = c("rwr", "sg", "sa"), 
                         restart_prob = 0.7, threshold = 1e-6, max_iter = 1e6,
                         loose = 1.0, print_weight_only = FALSE) {
  method <- match.arg(method)
  
  # Load disease_ids. The variable `disease_weights` must be a named vector.
  e <- new.env()
  data("disease_ids", package = "labyrinth", envir = e)
  assert_numeric(disease_weights, lower = 0, finite = TRUE, any.missing = FALSE,
                 len = length(e$disease_ids), names = 'named', null.ok = FALSE)
  assert(all(names(disease_weights) == e$disease_ids))
  
  # Check model
  if (is.dgCMatrix(model)) {
    assert_dgCMatrix(model)
    sparse <- TRUE
  } else {
    assert(
      test_matrix(model, mode = "numeric", min.rows = 3, nrows = ncol(model),
                  ncols = nrow(model), any.missing = FALSE, all.missing = FALSE,
                  null.ok = FALSE),
      any(model >= 0),
      combine = "and"
    )
    sparse <- FALSE
  }
  
  # Check other fucking inputs
  assert_int(max_iter, lower = 2, na.ok = FALSE, coerce = TRUE, null.ok = FALSE)
  if (method == "rwr") {
    assert_number(restart_prob, lower = 0, upper = 1, na.ok = FALSE, 
                  finite = TRUE, null.ok = FALSE)
    assert_number(threshold, lower = 0, upper = 1, na.ok = FALSE, finite = TRUE,
                  null.ok = FALSE)
  } else {
    assert_number(loose, na.ok = FALSE, lower = 0, upper = 1, finite = TRUE, 
                  null.ok = FALSE)
    assert_number(threshold, lower = 0, na.ok = FALSE, finite = TRUE,
                  null.ok = FALSE)
  }

  # Program begins
  if (sparse) {
    drug_num <- model@Dim[1] - length(disease_weights)
  } else {
    drug_num <- nrow(model) - length(disease_weights)
  }
  initial_weights <- c(numeric(length = drug_num),
                       unname(disease_weights))
  if (method == "rwr") {
    conv_weights <- random_walk(p0 = initial_weights, graph = model, 
                                r = restart_prob, thresh = threshold,
                                niter = max_iter, return.pt.only = TRUE)
  } else if (method == "sg") {
    conv_weights <- spread_gram(model, initial_weights, loose = loose, 
                                max_iter = max_iter, threshold = threshold)
  } else {
    conv_weights <- activation_rate(model, initial_weights, initial_weights,
                                    loose = loose, threads = 0)
  }
  
  # Print results
  if (sparse) {
    drug_ids <- head(model@Dimnames[[1]], drug_num)
  } else {
    drug_ids <- head(colnames(model), drug_num)
  }
  drug_weights <- head(conv_weights, drug_num)
  
  if (print_weight_only) {
    names(drug_weights) <- drug_ids
  } else {
    drug_weights <- data.frame(drug_id = drug_ids, drug_weights = drug_weights)
    
    data("drug_annot", package = "labyrinth", envir = e)
    # Use the first appeared name for drugs
    drug_annot <- group_by(e$drug_annot, .data$drug_id) %>% 
      summarize(drug_name = first(.data$drug_name))
    drug_weights <- data.frame(drug_id = drug_ids, 
                               drug_weights = drug_weights) %>%
      left_join(drug_annot, by = 'drug_id') %>%
      relocate(.data$drug_id, .data$drug_name) %>%
      arrange(desc(.data$drug_weights))
      
    # drug_annot <- e$drug_annot[!duplicated(e$drug_annot$drug_id),]
    # drug_annot <- drug_annot[drug_annot$drug_id %fin% drug_ids, ]
    # drug_weights$drug_name <- drug_annot$drug_name
    # drug_weights$drug_weights <- drug_weights
  }
  return(drug_weights)
}