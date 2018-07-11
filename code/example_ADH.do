

global data_path "../data/"
adopath+"../code"
clear all
discard
set seed 12345
use $data_path/input_ADH, clear


local controls reg_* l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource l_shind_manuf_cbp
local weight timepwt48

local y d_sh_empl_mfg
local x d_tradeusch_pw
local z z2

local ind_stub sh_ind_
local growth_stub trade_

local time_var year
local cluster_var czone

levelsof `time_var', local(years)
foreach year in `years' {
	foreach ind_var of varlist `ind_stub'* {
		gen t`year'_`ind_var' = `ind_var' * (year == `year')*100
		}
	}

/* Demeaning Growth Rates */
egen mean_growth = rowmean(`growth_stub'*)
foreach growth of varlist `growth_stub'* {
	replace `growth' = `growth' - mean_growth
	}
drop mean_growth

forvalues t = 1990(10)2000 {
	forvalues k = 20(1)39 {
		egen agg_sh_ind_`k'_`t' = rowtotal(t`t'_sh_ind_`k'*)
		}
	}
bartik_weight, z(t*_`ind_stub'*)    weightstub(`growth_stub'*) x(`x') y(`y') controls(`controls'   ) weight_var(`weight') by(t2) absorb(t2)


mat beta = r(beta)
mat alpha = r(alpha)
mat G = r(G)
qui desc t*_`ind_stub'*, varlist
local varlist = r(varlist)



clear
svmat beta
svmat alpha
svmat G

gen ind = ""
gen year = ""
local t = 1
foreach var in `varlist' {
	if regexm("`var'", "t(.*)_`ind_stub'(.*)") {
		qui replace year = regexs(1) if _n == `t'
		qui replace ind = regexs(2) if _n == `t'
		}
	local t = `t' + 1
	}



