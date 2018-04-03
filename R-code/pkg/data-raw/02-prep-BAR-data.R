
library(tidyverse)
library(haven)

# Download the BAR data ---------------------------------------------------

url = "https://raw.githubusercontent.com/paulgp/bartik-weight/master/data/input_BAR.dta"
fil = "data-raw/input_BAR.dta"

if (!file.exists(fil)) download.file(url, fil)
read_dta(fil) %>% print() -> BAR

# Prepare BAR master file: czone-year level variables ---------------------

index = c("czone", "year")
y = "wage_ch"
x = "emp_ch"
weight = "pop1980"
controls = c("male", "race_white", "native_born", "educ_hs", "educ_coll", "veteran", "nchild")

BAR %>%
    arrange(czone, year) %>%
    select(one_of(index, y, x, weight)) %>%
    print() -> master_main_vars

BAR %>%
    arrange(czone, year) %>%
    select(one_of(index, controls)) %>%
    gather(var, val, -czone, -year) %>%
    mutate(init_val = if_else(year == 1980, val, NA_real_)) %>%
    group_by(czone, var) %>%
    mutate(init_val = max(init_val, na.rm = TRUE)) %>%
    ungroup() %>%
    select(-val) %>%
    mutate(var = str_glue("t{year}_init_{var}")) %>%
    spread(var, init_val, fill = 0) %>%
    select(-contains("t1980")) %>%
    select(one_of(index),
           contains("_init_male"),
           contains("_init_race_white"),
           contains("_init_native_born"),
           contains("_init_educ_hs"),
           contains("_init_educ_coll"),
           contains("_init_veteran"),
           contains("_init_nchild")) %>%
    print() -> master_controls_set1

BAR %>%
    arrange(czone, year) %>%
    select(one_of(index)) %>%
    mutate(year2 = str_glue("t{year}"), dummy = 1) %>%
    spread(year2, dummy, fill = 0) %>%
    select(-t1980) %>%
    print() -> master_controls_set2

BAR %>%
    arrange(czone, year) %>%
    select(one_of(index)) %>%
    group_by(year) %>%
    mutate(czone2 = row_number() %>% formatC(width = 3, flag = "0")) %>%
    ungroup() %>%
    mutate(czone2 = str_glue("cz{czone2}"), dummy = 1) %>%
    spread(czone2, dummy, fill = 0) %>%
    select(-cz001) %>%
    print() -> master_controls_set3

master_main_vars %>%
    left_join(master_controls_set1) %>%
    left_join(master_controls_set2) %>%
    left_join(master_controls_set3) %>%
    print() -> BAR_master

# Prepare BAR local file: czone-year-industry level local shares ----------

BAR %>%
    select(one_of(index), contains("sh_ind_")) %>%
    gather(ind, sh_ind_, -czone, -year) %>%
    mutate(ind = str_replace(ind, "sh_ind_", "")) %>%
    arrange(czone, year, ind) %>%
    print() -> BAR_local

BAR_local %>%
    filter(year == 1980) %>%
    group_by(ind) %>%
    summarise(mean_sh_ind_ = mean(sh_ind_)) %>%
    filter(mean_sh_ind_ == 0) %>%
    select(ind) %>%
    print() -> invalid_ind

BAR_local %>%
    anti_join(invalid_ind) %>%
    mutate(init_sh_ind_ = if_else(year == 1980, sh_ind_, NA_real_)) %>%
    group_by(czone, ind) %>%
    mutate(init_sh_ind_ = max(init_sh_ind_, na.rm = TRUE)) %>%
    ungroup() %>%
    arrange(czone, year, ind) %>%
    print() -> BAR_local

BAR_local %>%
    select(-sh_ind_) %>%
    mutate(ind = str_glue("t{year}_init_sh_ind_{ind}")) %>%
    spread(ind, init_sh_ind_, fill = 0) %>%
    print() -> BAR_local_wide

# Prepare BAR global file: industry-year level growth rate ----------------

BAR %>%
    select(year, contains("nat_empl_ind_")) %>%
    slice(1:3) %>%
    gather(ind, nat_empl_ind_, -year) %>%
    mutate(ind = str_replace(ind, "nat_empl_ind_", "")) %>%
    anti_join(invalid_ind) %>%
    mutate(nat_empl_ind_ = if_else(is.na(nat_empl_ind_), 0, nat_empl_ind_)) %>%
    arrange(year, ind) %>%
    print() -> BAR_global

# Save them! --------------------------------------------------------------

devtools::use_data(BAR_master, BAR_local, BAR_local_wide, BAR_global,
                   overwrite = TRUE)

