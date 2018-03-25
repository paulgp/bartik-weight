
#' ---
#' output: github_document
#' author: ""
#' date: ""
#' ---

library(tidyverse)
library(bartik.weight)

#' To replicate the Stata example [`example_ADH.do`](https://github.com/paulgp/bartik-weight/blob/master/code/example_ADH.do), the `bartik.weight` R package includes three ADH-related datasets.
#'
#' The main dataset contains variables at the CZ-year level:

ADH_master

#' The "local" dataset contains local industry shares at the CZ-year-industry level:

ADH_local

#' The "global" dataset contains the industry-year-specific growth of imports

ADH_global

#' To estimate the Rotemberg weights, it’s necessary to transform the local
#' tibble from long to wide format:

ADH_local %>%
    mutate(ind = str_glue("t{year}_sh_ind_{ind}")) %>%
    spread(ind, sh_ind_, fill = 0) %>%
    print() -> ADH_local2

#' Once all the data are in proper format, the `bw()` function will return the
#' weight, and the just-identified IV estimates:

# Prepare variables in the master tibble
y = "d_sh_empl_mfg"
x = "d_tradeusch_pw"
controls = c("reg_midatl", "reg_encen", "reg_wncen", "reg_satl",
             "reg_escen", "reg_wscen", "reg_mount", "reg_pacif", "l_sh_popedu_c",
             "l_sh_popfborn", "l_sh_empl_f", "l_sh_routine33", "l_task_outsource",
             "t2", "l_shind_manuf_cbp")
weight = "timepwt48"

# Prepare variables in the local tibble
Z = setdiff(names(ADH_local_wide), c("czone", "year"))

# Prepare variables in the global tibble
G = "trade_"

# Estimate the weight (alpha) and the IV estimates (beta)
bw = bw(ADH_master, y, x, controls, weight, ADH_local2, Z, ADH_global, G)
bw

#' The following table replicates parts of Panel D of Table 5 in
#' [Goldsmith-Pinkham, Sorkin and Swift (2018)](http://paulgp.github.io/papers/bartik_gpss.pdf):

bw %>%
    top_n(5, alpha) %>%
    arrange(desc(alpha)) %>%
    mutate(ind = case_when(
        ind == "3571" ~ "Electronic Computers",
        ind == "3944" ~ "Games and Toys",
        ind == "3651" ~ "Household Audio and Video",
        ind == "3661" ~ "Telephone Apparatus",
        ind == "3577" ~ "Computer Equipment"
    )) %>%
    rename(g = trade_) %>%
    knitr::kable(digits = 3, caption = "Top five Rotemberg weight industries")
