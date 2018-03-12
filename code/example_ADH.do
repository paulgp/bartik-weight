

discard
global data_path "../data/"
adopath+"../code"
use $data_path/input_ADH, clear


local controls reg_* l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 l_shind_manuf_cbp
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
		gen t`year'_`ind_var' = `ind_var' * (year == `year')
		}
	}

bartik_weight, z(t*_`ind_stub'*)    weightstub(`growth_stub'*) x(`x') y(`y')  controls(`controls') weight_var(`weight')
mat beta = r(beta)
mat alpha = r(alpha)
mat G = r(G)
qui desc t*_`ind_stub'*, varlist
local varlist = r(varlist)
/*
clear
svmat beta
svmat alpha
svmat G

gen ind = ""
gen year = ""
local t = 1
foreach var in `varlist' {
	disp "`var'"
	if regexm("`var'", "t(.*)_`ind_stub'(.*)") {
		replace year = regexs(1) if _n == `t'
		replace ind = regexs(2) if _n == `t'
		}
	local t = `t' + 1
	}

/* TODO:
* make weight optional
*/


