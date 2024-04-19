#' @title A small example implemented from Anderson (1983)
#'
#' @format Adjacency \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} 
#'   representing an unweighted directed graph. Inside this adjacency matrix, 
#'   each row and column of the matrix represents a node in the graph. There are 
#'   7 nodes and 9 edges, and no self-loops inside the graph. 
#' 
#' @source 
#' Anderson, J. R. (1983). A spreading activation theory of memory. *Journal of 
#' verbal learning and verbal behavior*, *22*(3), 261-295.
#' https://doi.org/10.1016/S0022-5371(83)90201-3.
#' 
#' @examples
#' library(labyrinth)
#' 
#' data("graph", package = "labyrinth")
#' 
"graph"

#' @title A portion of the phonological network examined in Vitevitch (2008).
#' 
#' @description
#' Depicted are the word *speech*, phonological neighbors of *speech*, and the 
#'   phonological neighbors of those neighbors. It is taken from 
#'   \code{\link[spreadr:pnetm]{spreadr}} package. 
#'
#' @format Adjacency \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} 
#'   representing an unweighted directed graph. Inside this adjacency matrix, 
#'   each row and column of the matrix represents a node in the graph. There are 
#'   34 nodes and 96 edges, and no self-loops inside the graph. 
#' 
#' @references 
#' Chan, K. Y., & Vitevitch, M. S. (2009). The influence of the phonological 
#' neighborhood clustering coefficient on spoken word recognition. *Journal of 
#' experimental psychology: Human perception and performance*, *35*(6), 1934–1949. 
#' https://doi.org/10.1037/a0016902.
#' 
#' Siew C. S. Q. (2019). spreadr: An R package to simulate spreading activation 
#' in a network. *Behavior research methods*, *51*(2), 910–929. 
#' https://doi.org/10.3758/s13428-018-1186-5.
#' 
#' @examples
#' library(labyrinth)
#' 
#' data("speech", package = "labyrinth")
#' 
"speech"

#' @title NCBI Gene Information
#' 
#' @description
#' A data table containing meta information about NCBI genes, including their
#'   type and associated species.
#'
#' @format A \code{\link[data.table:data.table]{data.table}} with the following
#'   columns:
#' 
#' \describe{
#'   \item{type}{A character vector representing the type of species.}
#'   \item{species}{A character vector representing the species that NCBI supports in its online platform.}
#' }
#' 
#' @source 
#' This data was obtained from the National Center for Biotechnology Information
#'   (NCBI) Gene database (https://www.ncbi.nlm.nih.gov/gene).
#' 
#' @examples
#' library(labyrinth)
#' 
#' data("ncbi_info", package = "labyrinth")
#' 
"ncbi_info"

#' @title MeSH annotation data
#' 
#' @description 
#' A data frame containing annotated Medical Subject Headings (MeSH) terms and
#'   their associated group information.
#'
#' @format A \code{\link[data.table:data.table]{data.table}} with the following 
#'   columns:
#' \describe{
#'   \item{mesh_id}{A character vector representing the MeSH identifier.}
#'   \item{mesh_term}{A character vector representing the MeSH term.}
#'   \item{group_id}{A character vector representing the group identifier obtained from NCBI.}
#'   \item{group_name}{A character vector representing the group name obtained from NCBI.}
#' }
#'
#' @source
#' The MeSH terms were obtained from the National Library of Medicine's Medical
#'   Subject Headings (MeSH) database (https://www.nlm.nih.gov/mesh/), and the
#'   group information was obtained from the National Center for Biotechnology
#'   Information (NCBI).
#'
#' @examples
#' data(mesh_annot, package = "labyrinth")
"mesh_annot"

#' @title MeSH Hierarchy Network
#' 
#' @description
#' An edgelist network representing the hierarchical structure of the Medical
#'   Subject Headings (MeSH) terms.
#'
#' @format
#' A \code{\link[data.table:data.table]{data.table}} with the following columns:
#' \describe{
#'   \item{from_id}{A character vector representing the MeSH identifier of the parent term.}
#'   \item{to_id}{A character vector representing the MeSH identifier of the child term.}
#' }
#'
#' @details
#' The `mesh_hierarchy` data frame is an edgelist network, where each row
#'   represents a directed edge from a parent MeSH term (`from_id`) to a child
#'   MeSH term (`to_id`). This structure captures the hierarchical relationships
#'   between MeSH terms.
#'
#' @source
#' The MeSH hierarchy data was obtained from the National Library of Medicine's
#'   Medical Subject Headings (MeSH) database (https://www.nlm.nih.gov/mesh/).
#'
#' @examples
#' data(mesh_hierarchy, package = "labyrinth")
"mesh_hierarchy"

#' @title MeSH synonyms
#' 
#' @description
#' A data frame containing Medical Subject Headings (MeSH) identifiers and their
#'   associated synonyms.
#'
#' @format
#' A \code{\link[data.table:data.table]{data.table}} with the following columns:
#' \describe{
#'   \item{mesh_id}{A character vector representing the MeSH identifier.}
#'   \item{mesh_synonyms}{A character vector representing the synonyms associated with the MeSH identifier.}
#' }
#'
#' @details
#' The `mesh_synonyms` data frame provides a mapping between MeSH identifiers
#'   and their corresponding synonyms. Each row represents a MeSH identifier 
#'   (`mesh_id`) and its associated synonyms (`mesh_synonyms`), which can be 
#'   used for text mining, information retrieval, or other applications 
#'   involving MeSH terms.
#'
#' @source
#' The MeSH IDs was obtained from the National Library of Medicine's Medical
#'   Subject Headings (MeSH) database (https://www.nlm.nih.gov/mesh/). The
#'   synonyms were obtained from Cochrane Library 
#'   (https://www.cochranelibrary.com/advanced-search/mesh).
#'
#' @examples
#' data(mesh_synonyms, package = "labyrinth")
"mesh_synonyms"

#' @title Gene-disease associations
#' 
#' @description
#' A list containing gene-disease associations obtained from DisGeNET with the
#'   confidence level of 60%.
#'
#' @format 
#' A \code{\link[methods:namedList-class]{named list}}, where each element is a
#'   character vector representing the genes associated with a specific MeSH
#'   disease identifier (MeSH ID). The names of the list elements correspond to
#'   the MeSH IDs.
#'
#' @details
#' The `gene_disease` data set contains gene-disease associations extracted
#'   from the DisGeNET database with a confidence level of 60%. Each element of
#'   the list represents a MeSH disease identifier, and the corresponding
#'   character vector contains the gene identifiers associated with that
#'   disease.
#'
#' @source
#' The gene-disease associations were obtained from the DisGeNET database
#'   (https://www.disgenet.org/), which integrates information from various 
#'   sources to provide gene-disease associations.
#'
#' @examples
#' data(gene_disease, package = "labyrinth")
#' gene_disease[["D000168"]]
"gene_disease"

#' @title Protein-protein interaction network
#' 
#' @description
#' A sparse adjacency matrix representing a protein-protein interaction network
#'   compiled from multiple databases.
#'
#' @format
#' A \code{\link[Matrix:dgCMatrix-class]{dgCMatrix}} object from the 
#'   \code{\link[Matrix:Matrix]{Matrix}} package, where a value of 1 indicates
#'   a connection (interaction) between two genes, and 0 indicates no 
#'   connection. The rows and columns of the matrix correspond to gene 
#'   identifiers, and the matrix is square and symmetric, representing an 
#'   undirected adjacency network.
#'
#' @details
#' The `ppi` data set is a sparse adjacency matrix representing a 
#'   protein-protein interaction network. The network was compiled from seven 
#'   databases: KEGG, Reactome, Biocarta, NCI, SPIKE, HumanCyc, and Panther.
#'
#' The rows and columns of the matrix correspond to gene identifiers, and the 
#'   order of the genes is consistent across rows and columns. The matrix is 
#'   square and symmetric, representing an undirected network, where an 
#'   interaction between gene A and gene B is represented by a 1 in both the 
#'   (A, B) and (B, A) positions of the matrix.
#'
#' @source
#' The protein-protein interaction data was compiled from the following databases:
#'   \itemize{
#'     \item KEGG (https://www.genome.jp/kegg/)
#'     \item Reactome (https://reactome.org/)
#'     \item Biocarta (https://cgap.nci.nih.gov/Pathways/BioCarta_Pathways)
#'     \item NCI (https://cancer.gov/about-nci)
#'     \item SPIKE (https://www.cbrc.kaust.edu.sa/spike/)
#'     \item HumanCyc (https://humancyc.org/)
#'     \item Panther (http://www.pantherdb.org/)
#'   }
#'
#' @examples
#' library(Matrix)
#' data(ppi, package = "labyrinth")
#'
#' # Access a specific element of the matrix
#' ppi[1, 2]  # Interaction between gene 1 and gene 2
#'
#' # Convert to a dense matrix for visualization or analysis
#' dense_ppi <- as.matrix(ppi)
#'
"ppi"

#' @title Disease MeSH identifiers
#' @description
#' A character vector containing Medical Subject Headings (MeSH) identifiers for
#'   all human diseases.
#'
#' @format A character vector.
#'
#' @details
#' The `disease_ids` object is a character vector that contains MeSH identifiers
#'   (MeSH IDs) for various diseases. Each element in the vector represents a
#'   unique MeSH identifier, which can be used to identify and reference
#'   specific diseases in the MeSH taxonomy.
#'
#' MeSH identifiers are hierarchically organized and provide a standardized way
#'   of representing and categorizing diseases and other medical concepts.
#'
#' @source
#' The disease MeSH identifiers were obtained from the National Library of
#'   Medicine's Medical Subject Headings (MeSH) database 
#'   (https://www.nlm.nih.gov/mesh/).
#'
#' @examples
#' data(disease_ids, package = "labyrinth")
#' length(disease_ids)
#'
#' # Check if a specific MeSH identifier is present
#' "D000544" %in% disease_ids  # Alzheimer's disease
"disease_ids"

#' @title Slimmed drug annotation dataset
#' @description A data.table containing drug identifiers and their corresponding
#'   names.
#'
#' @format A data.table with the following columns:
#' \describe{
#'   \item{drug_id}{A character vector representing the drug identifier.}
#'   \item{drug_name}{A character vector representing the name of the drug.}
#' }
#'
#' @details 
#' The `drug_annot` data set provides a mapping between drug identifiers and
#'   their corresponding names. Each row represents a unique drug identifier
#'   (`drug_id`) and its associated name (`drug_name`).
#'
#' The drug identifiers and names in this data set are sourced from ChEMBL, 
#'   DrugBank, and CTD to extract synonyms for the same drug.
#' 
#' @source
#' The drug annotations were obtained from ChEMBL, DrugBank, and CTD.
#'
#' @examples
#' data(drug_annot, package = "labyrinth")
#'
#' # Access drug names for specific identifiers
#' drug_annot[drug_annot$drug_id == "2838", ]$drug_name  # Imatinib
#'
#' # Count the number of unique drugs
#' length(unique(drug_annot$drug_id))
"drug_annot"
