
#' ---
#' output: github_document
#' author: ""
#' date: ""
#' ---

library(tidyverse)
library(bartik.weight)

#' To replicate the Stata example [`example_BAR.do`](https://github.com/paulgp/bartik-weight/blob/master/code/example_BAR.do), the `bartik.weight` R package includes three BAR-related datasets.
#'
#' The main dataset contains variables at the CZ-year level:

BAR_master

#' The "local" dataset contains local industry shares at the CZ-year-industry level:

BAR_local

#' The "global" dataset contains the national industry-year-specific growth rates

BAR_global

#' To estimate the Rotemberg weights, it’s necessary to transform the local
#' tibble from long to wide format:

BAR_local %>%
    select(-sh_ind_) %>%
    mutate(ind = str_glue("t{year}_init_sh_ind_{ind}")) %>%
    spread(ind, init_sh_ind_, fill = 0) %>%
    print() -> BAR_local2

#' Once all the data are in proper format, the `bw()` function will return the
#' weight, and the just-identified IV estimates:

# Prepare variables in the master tibble
index = c("czone", "year")
y = "wage_ch"
x = "emp_ch"
weight = "pop1980"
controls = setdiff(names(BAR_master), c(index, y, x, weight))

# Prepare variables in the local tibble
Z = setdiff(names(BAR_local2), c(index))

# Prepare variables in the global tibble
G = "nat_empl_ind_"

# Estimate the weight (alpha) and the IV estimates (beta)
bw = bw(BAR_master, y, x, controls, weight, BAR_local2, Z, BAR_global, G)
bw

#' The following table replicates parts of Panel D of Table 2 in
#' [Goldsmith-Pinkham, Sorkin and Swift (2018)](http://paulgp.github.io/papers/bartik_gpss.pdf):

bw %>%
    top_n(5, alpha) %>%
    arrange(desc(alpha)) %>%
    mutate(ind = case_when(
        ind == "42"  ~ "Oil + Gas Extraction",
        ind == "0"   ~ "Other",
        ind == "351" ~ "Motor Vehicles",
        ind == "362" ~ "Guided Missiles",
        ind == "351" ~ "Motor Vehicles"
    )) %>%
    rename(g = nat_empl_ind_) %>%
    knitr::kable(digits = 3, caption = "Top five Rotemberg weight industries")
