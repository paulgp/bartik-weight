
library(tidyverse)
library(haven)

# Download the ADH data ---------------------------------------------------

url = "https://raw.githubusercontent.com/paulgp/bartik-weight/master/data/input_ADH.dta"
fil = "data-raw/input_ADH.dta"

if (!file.exists(fil)) download.file(url, fil)
read_dta(fil) %>% print() -> ADH

# Prepare ADH master file: czone-year level variables ---------------------

index = c("czone", "year")
y = "d_sh_empl_mfg"
x = "d_tradeusch_pw"
weight = "timepwt48"
controls = c("reg_midatl", "reg_encen", "reg_wncen", "reg_satl", "reg_escen", "reg_wscen", "reg_mount", "reg_pacif", "l_sh_popedu_c", "l_sh_popfborn", "l_sh_empl_f", "l_sh_routine33", "l_task_outsource", "t2", "l_shind_manuf_cbp")

ADH %>%
    select(one_of(index, y, x, weight, controls)) %>%
    arrange(czone, year) %>%
    print() -> ADH_master

# Prepare ADH local file: czone-year-industry level local shares ----------

ADH %>%
    select(one_of(index), contains("sh_ind_")) %>%
    gather(ind, sh_ind_, -czone, -year) %>%
    mutate(ind = str_replace(ind, "sh_ind_", "")) %>%
    arrange(czone, year, ind) %>%
    print() -> ADH_local

ADH_local %>%
    mutate(ind = str_glue("t{year}_sh_ind_{ind}")) %>%
    spread(ind, sh_ind_, fill = 0) %>%
    print() -> ADH_local_wide

# Prepare ADH global file: industry-year level growth rate ----------------

ADH %>%
    select(year, contains("trade_")) %>%
    slice(1:2) %>%
    gather(ind, trade_, -year) %>%
    mutate(ind = str_replace(ind, "trade_", "")) %>%
    arrange(year, ind) %>%
    print() -> ADH_global

# Save them! --------------------------------------------------------------

devtools::use_data(ADH_master, ADH_local, ADH_local_wide, ADH_global,
                   overwrite = TRUE)
