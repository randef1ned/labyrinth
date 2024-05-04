- [Setup](#setup)
- [Data preparation](#data-preparation)
- [Reproducibility example](#reproducibility-example)
  - [Labyrinth learns mechanisms that mediate specific drug
    response](#labyrinth-learns-mechanisms-that-mediate-specific-drug-response)
- [Session info](#session-info)

## Setup

The `labyrinth` framework was initially developed and tested on Fedora
39 with R 4.3, this vignette aims to demonstrate its ease of use on the
Windows Subsystem for Linux (WSL) environment. Specifically, we will be
presenting the results using [Fedora Remix for
WSL](https://github.com/WhitewaterFoundry/Fedora-Remix-for-WSL).

To get started, you will need to prepare the following dependencies.

1.  **Fedora** or **Red Hat Enterprise Linux** with or without WSL.

2.  **R 4.3**.

3.  **Required libraries**.

``` r
# pROC ggthemes 
library(tidyverse, igraph)
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.1
    ## ✔ ggplot2   3.5.1     ✔ tibble    3.2.1
    ## ✔ lubridate 1.9.3     ✔ tidyr     1.3.1
    ## ✔ purrr     1.0.2     
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

``` r
library(patchwork)
library(labyrinth)
```

With these installed and loaded, you will have a consistent environment
for running the `labyrinth`.

## Data preparation

``` r
drug_disease_weight <- load_data('drug_disease_weight')
```

Load the pre-trained model.

``` r
model <- load_data('model')
dim(model)
```

    ## [1] 7686 7686

The labyrinth model is trained by integrating knowledge from two major
sources: text-based information from medical corpora and biological
knowledge from functional interaction networks.

For the text-based component, labyrinth: 1. Extracts drug information
(nomenclature, targets, and indications) from databases like DrugBank,
CTD, and ChEMBL. 2. Obtains clinical trial data from the Cochrane
Library. 3. Mines co-occurrence patterns in published literature from
the Web of Science corpus. 4. Preprocesses the text data from over 10
million publications, including stop word removal and term vectorization
using Skip-gram models. 5. Quantifies structured drug-disease
relationships based on clinical trial phases, citation analysis, and
network proximity between gene sets.

For the biological component, labyrinth evaluates the network proximity
between drug target modules and disease gene modules within a functional
interactome network.

The text-based and biological knowledge matrices are then integrated
through probabilistic computations, simulating the process of storing
relevant knowledge in long-term memory for decision-making.

## Reproducibility example

### Labyrinth learns mechanisms that mediate specific drug response

To validate our approach, we initially evaluated the predictive accuracy
across various diseases. This involved assessing the Spearman
correlations between the priority scores assigned by labyrinth and the
established weights in clinical trials, alongside proximity metrics for
each drug-disease pair. Labyrinth exhibited moderate to high
correlations, with coefficients of 0.60 for clinical trials and 0.80 for
proximity, respectively.

``` r
roc0 <- mutate(drug_disease_weight, weight = if_else(weight > 1, 1, 0)) %>%
  pROC::roc(weight, score)
```

    ## Setting levels: control = 0, case = 1

    ## Setting direction: controls < cases

``` r
roc1 <- mutate(drug_disease_weight, weight = if_else(weight > 1.8, 1, 0)) %>%
  pROC::roc(weight, score)
```

    ## Setting levels: control = 0, case = 1
    ## Setting direction: controls < cases

``` r
roc2 <- mutate(drug_disease_weight, weight = if_else(weight > 2, 1, 0)) %>%
  pROC::roc(weight, score)
```

    ## Setting levels: control = 0, case = 1
    ## Setting direction: controls < cases

``` r
roc3 <- mutate(drug_disease_weight, weight = if_else(weight > 3, 1, 0)) %>%
  pROC::roc(weight, score)
```

    ## Setting levels: control = 0, case = 1
    ## Setting direction: controls < cases

``` r
roc4 <- mutate(drug_disease_weight, weight = if_else(weight > 4, 1, 0)) %>%
  pROC::roc(weight, score)
```

    ## Setting levels: control = 0, case = 1
    ## Setting direction: controls < cases

``` r
p1 <- pROC::ggroc(list(
  roc0, roc1, roc2, roc3, roc4
)) +
  scale_color_manual('Drug trials', labels = c(
    paste('Stage 0:', round(roc0$auc, 3)),
    paste('Stage 1:', round(roc1$auc, 3)),
    paste('Stage 2:', round(roc2$auc, 3)),
    paste('Stage 3:', round(roc3$auc, 3)),
    paste('Stage 4:', round(roc4$auc, 3))
  ), values = c('#cf4e9c', '#835921', '#8d59a3', '#368db9', '#302c2d')) +
  ggthemes::theme_clean() +
  theme(legend.position = 'left')
rm(list = c('roc0', 'roc1', 'roc2', 'roc3', 'roc4'))
```

Subsequently, we extended our analysis to encompass all human diseases,
aiming to assess the predictive performance across five clinical trial
phases, including pre-clinical, phases 1 to 3, and approved treatments.
We evaluated the prediction performance by Receiver Operating
Characteristic Area Under the Curve (ROC-AUC). As illustrated in Figure
3A, the ROC-AUC values for all stages surpassed 0.90, indicating a
predictive success rate of over 90% in distinguishing between drugs
classified for clinical trial or non-clinical trial.

``` r
# We perform ROC analysis in every single disease
disease_pred <- split(select(drug_disease_weight, weight, score), drug_disease_weight$mesh_id) %>%
  map(~ arrange(.x, desc(weight)))
disease_pred <- pbapply::pblapply(names(disease_pred), function(n) {
  x <- disease_pred[[n]]
  if (nth(x$weight, 2) > 1.5) {
    ci <- suppressMessages({
      x %>%
        mutate(weight = if_else(weight > 1.5, 1, 0)) %>%
        pROC::roc(weight, score, ci = TRUE) %>%
        {as.numeric(.$ci)}
    })
    ret <- data.frame(mesh_id = n, ci_lower = ci[1], ci_upper = ci[3], auc = ci[2])
  } else {
    ret <- data.frame()
  }
  return(ret)
}) %>% bind_rows()

# Next, we divide the ROC and average them based on MeSH structures 
mesh_ids <- unique(drug_disease_weight$mesh_id)

data("mesh_annot")
disease_cluster <- distinct(mesh_annot) %>%
  mutate(parent_group = str_to_sentence(group_name)) %>%
  select(!group_name) %>%
  arrange(group_id) %>%
  left_join(disease_pred, by = 'mesh_id') %>%
  drop_na()

disease_color <- group_by(disease_cluster, group_id) %>%
  summarize(color = median(auc) > 0.911)
p2 <- mutate(disease_cluster, parent_group = fct_reorder(parent_group, -group_id)) %>%
  left_join(disease_color, by = 'group_id') %>%
ggplot(aes(x = parent_group, y = auc, fill = color)) +
  geom_boxplot(alpha = 0.4) +
  geom_hline(aes(yintercept = 0.911), linetype = 'dashed') +
  labs(x = 'Disease categories',
      y = 'Prediction AUCs') +
  coord_flip() +
  scale_fill_manual(values = c('#9fcdc9', '#d4bfe0')) +
  ggthemes::theme_clean() +
  theme(legend.position = 'none',
        axis.text.y = element_text('Arial Narrow'))
```

Notably, labyrinth exhibited high predictive accuracy in determining
drug usability for Stage 3 across all disease categories except for
occupational and stomatognathic diseases (Figure 3B). Also,
cardiovascular, endocrine system diseases, and neoplasms garnered the
most significant benefits from labyrinth. Detailed ROC-AUC predictions
for all diseases are provided in Additional File 1.

``` r
design <- "
  11#222
  222222
  222222
"
p1 + p2 + plot_layout(guides = 'collect') +
  plot_annotation(tag_levels = 'A') &
  theme(legend.position = 'bottom')
```

<div class="figure">

<img src="img/unnamed-chunk-5-1.png" />
</div>
![](img/unnamed-chunk-5-1.png)

### Reproducibility statement

All other results in the article can be reproduced using standard R
code.

## Session info

``` r
devtools::session_info()
```

    ## ─ Session info ───────────────────────────────────────────────────────────────
    ##  setting  value
    ##  version  R version 4.3.3 (2024-02-29)
    ##  os       Fedora Remix for WSL
    ##  system   x86_64, linux-gnu
    ##  ui       X11
    ##  language (EN)
    ##  collate  en_US.UTF-8
    ##  ctype    en_US.UTF-8
    ##  tz       Asia/Shanghai
    ##  date     2024-05-04
    ##  pandoc   3.1.11 @ /usr/lib/rstudio/resources/app/bin/quarto/bin/tools/x86_64/ (via rmarkdown)
    ## 
    ## ─ Packages ───────────────────────────────────────────────────────────────────
    ##  package           * version    date (UTC) lib source
    ##  backports           1.4.1      2021-12-13 [1] CRAN (R 4.3.2)
    ##  cachem              1.0.8      2023-05-01 [1] CRAN (R 4.3.2)
    ##  checkmate           2.3.1      2024-01-09 [1] local
    ##  cli                 3.6.2      2023-12-11 [1] CRAN (R 4.3.2)
    ##  codetools           0.2-20     2024-03-31 [1] CRAN (R 4.3.3)
    ##  colorspace          2.1-0      2023-01-23 [1] CRAN (R 4.3.2)
    ##  devtools            2.4.5      2022-10-11 [1] CRAN (R 4.3.2)
    ##  diffusr             0.2.3      2024-04-23 [1] Github (randef1ned/diffusr@af0aaaa)
    ##  digest              0.6.35     2024-03-11 [1] CRAN (R 4.3.3)
    ##  dplyr             * 1.1.4      2023-11-17 [1] CRAN (R 4.3.2)
    ##  ellipsis            0.3.2      2021-04-29 [1] CRAN (R 4.3.2)
    ##  evaluate            0.23       2023-11-01 [1] CRAN (R 4.3.2)
    ##  fansi               1.0.6      2023-12-08 [1] CRAN (R 4.3.2)
    ##  farver              2.1.1      2022-07-06 [1] CRAN (R 4.3.2)
    ##  fastmap             1.1.1      2023-02-24 [1] CRAN (R 4.3.2)
    ##  fastmatch           1.1-4      2023-08-18 [1] CRAN (R 4.3.3)
    ##  forcats           * 1.0.0      2023-01-29 [1] CRAN (R 4.3.2)
    ##  fs                  1.6.4      2024-04-25 [1] CRAN (R 4.3.3)
    ##  generics            0.1.3      2022-07-05 [1] CRAN (R 4.3.2)
    ##  ggplot2           * 3.5.1      2024-04-23 [1] CRAN (R 4.3.3)
    ##  ggthemes            5.1.0      2024-02-10 [1] CRAN (R 4.3.3)
    ##  glue                1.7.0      2024-01-09 [1] CRAN (R 4.3.2)
    ##  gtable              0.3.5      2024-04-22 [1] CRAN (R 4.3.3)
    ##  highr               0.10       2022-12-22 [1] CRAN (R 4.3.2)
    ##  hms                 1.1.3      2023-03-21 [1] CRAN (R 4.3.2)
    ##  htmltools           0.5.8.1    2024-04-04 [1] CRAN (R 4.3.3)
    ##  htmlwidgets         1.6.4      2023-12-06 [1] CRAN (R 4.3.2)
    ##  httpuv              1.6.15     2024-03-26 [1] CRAN (R 4.3.3)
    ##  igraph              2.0.3      2024-03-13 [1] CRAN (R 4.3.3)
    ##  knitr               1.46       2024-04-06 [1] CRAN (R 4.3.3)
    ##  labeling            0.4.3      2023-08-29 [1] CRAN (R 4.3.2)
    ##  labyrinth         * 0.2.3      2024-05-04 [1] local
    ##  later               1.3.2      2023-12-06 [1] CRAN (R 4.3.2)
    ##  lattice             0.22-6     2024-03-20 [1] CRAN (R 4.3.3)
    ##  lifecycle           1.0.4      2023-11-07 [1] CRAN (R 4.3.2)
    ##  lubridate         * 1.9.3      2023-09-27 [1] CRAN (R 4.3.2)
    ##  magrittr            2.0.3      2022-03-30 [1] CRAN (R 4.3.2)
    ##  Matrix              1.6-5      2024-01-11 [1] CRAN (R 4.3.2)
    ##  MatrixGenerics      1.14.0     2023-10-24 [1] Bioconductor
    ##  matrixStats         1.3.0      2024-04-11 [1] CRAN (R 4.3.3)
    ##  memoise             2.0.1      2021-11-26 [1] CRAN (R 4.3.2)
    ##  memuse              4.2-3      2023-01-24 [1] CRAN (R 4.3.2)
    ##  mime                0.12       2021-09-28 [1] CRAN (R 4.3.2)
    ##  miniUI              0.1.1.1    2018-05-18 [1] CRAN (R 4.3.2)
    ##  munsell             0.5.1      2024-04-01 [1] CRAN (R 4.3.3)
    ##  patchwork         * 1.2.0      2024-01-08 [1] CRAN (R 4.3.2)
    ##  pbapply             1.7-2      2023-06-27 [1] CRAN (R 4.3.2)
    ##  pillar              1.9.0      2023-03-22 [1] CRAN (R 4.3.2)
    ##  pkgbuild            1.4.4      2024-03-17 [1] CRAN (R 4.3.3)
    ##  pkgconfig           2.0.3      2019-09-22 [1] CRAN (R 4.3.2)
    ##  pkgload             1.3.4      2024-01-16 [1] CRAN (R 4.3.2)
    ##  plyr                1.8.9      2023-10-02 [1] CRAN (R 4.3.2)
    ##  pROC                1.18.5     2023-11-01 [1] CRAN (R 4.3.3)
    ##  profvis             0.3.8      2023-05-02 [1] CRAN (R 4.3.2)
    ##  promises            1.3.0      2024-04-05 [1] CRAN (R 4.3.3)
    ##  pryr                0.1.6      2023-01-17 [1] CRAN (R 4.3.2)
    ##  purrr             * 1.0.2      2023-08-10 [1] CRAN (R 4.3.2)
    ##  R6                  2.5.1      2021-08-19 [1] CRAN (R 4.3.2)
    ##  Rcpp                1.0.12     2024-01-09 [1] CRAN (R 4.3.2)
    ##  RcppEigen           0.3.4.0.0  2024-02-28 [1] CRAN (R 4.3.2)
    ##  RcppProgress        0.4.2      2024-01-19 [1] Github (kforner/rcpp_progress@e7a32d7)
    ##  readr             * 2.1.5      2024-01-10 [1] CRAN (R 4.3.2)
    ##  remotes             2.5.0.9000 2024-04-23 [1] Github (r-lib/remotes@5b7eb08)
    ##  rlang               1.1.3      2024-01-10 [1] CRAN (R 4.3.2)
    ##  rmarkdown           2.26       2024-03-05 [1] CRAN (R 4.3.2)
    ##  rpca                0.2.3      2015-07-31 [1] CRAN (R 4.3.2)
    ##  rstudioapi          0.16.0     2024-03-24 [1] CRAN (R 4.3.3)
    ##  scales              1.3.0      2023-11-28 [1] CRAN (R 4.3.2)
    ##  sessioninfo         1.2.2      2021-12-06 [1] CRAN (R 4.3.2)
    ##  shiny               1.8.1.1    2024-04-02 [1] CRAN (R 4.3.3)
    ##  sparseMatrixStats   1.14.0     2023-10-24 [1] Bioconductor
    ##  stringi             1.8.3      2023-12-11 [1] CRAN (R 4.3.2)
    ##  stringr           * 1.5.1      2023-11-14 [1] CRAN (R 4.3.2)
    ##  tibble            * 3.2.1      2023-03-20 [1] CRAN (R 4.3.2)
    ##  tidyr             * 1.3.1      2024-01-24 [1] CRAN (R 4.3.2)
    ##  tidyselect          1.2.1      2024-03-11 [1] CRAN (R 4.3.3)
    ##  tidyverse         * 2.0.0      2023-02-22 [1] CRAN (R 4.3.2)
    ##  timechange          0.3.0      2024-01-18 [1] CRAN (R 4.3.2)
    ##  tzdb                0.4.0      2023-05-12 [1] CRAN (R 4.3.2)
    ##  urlchecker          1.0.1      2021-11-30 [1] CRAN (R 4.3.2)
    ##  usethis             2.2.3      2024-02-19 [1] CRAN (R 4.3.2)
    ##  utf8                1.2.4      2023-10-22 [1] CRAN (R 4.3.2)
    ##  vctrs               0.6.5      2023-12-01 [1] CRAN (R 4.3.2)
    ##  withr               3.0.0      2024-01-16 [1] CRAN (R 4.3.2)
    ##  xfun                0.43       2024-03-25 [1] CRAN (R 4.3.3)
    ##  xtable              1.8-4      2019-04-21 [1] CRAN (R 4.3.2)
    ##  yaml                2.3.8      2023-12-11 [1] CRAN (R 4.3.2)
    ## 
    ##  [1] /home/syc/R/x86_64-redhat-linux-gnu-library/4.3
    ##  [2] /usr/lib64/R/library
    ##  [3] /usr/share/R/library
    ## 
    ## ──────────────────────────────────────────────────────────────────────────────
