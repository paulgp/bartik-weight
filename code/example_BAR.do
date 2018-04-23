

discard
global data_path "../data/"
adopath+"../code"
use $data_path/input_BAR, clear

local controls male race_white native_born educ_hs educ_coll veteran nchild
local weight pop1980

local y wage_ch
local x emp_ch

local ind_stub sh_ind_
local growth_stub nat_empl_ind_

local time_var year
local cluster_var czone

qui tab year2, gen(year_)
drop year_1

levelsof `time_var', local(years)

/* Construct initial industry shares  and controls */
sort czone year
foreach ind_var of varlist `ind_stub'* {
	gen `ind_var'_1980b = `ind_var' if year == 1980
	by czone (year): gen init_`ind_var' = `ind_var'_1980b[1]
	drop `ind_var'_1980b
	qui sum init_`ind_var'
	if r(mean) == 0 {
		drop init_`ind_var'
		if regexm("`ind_var'", "`ind_stub'(.*)") {
			local ind_num = regexs(1)
			drop nat_empl_ind_`ind_num'
			}
		}
	}


sort czone year
foreach control of varlist `controls' {
	gen `control'_1980b = `control' if year == 1980
	by czone (year): gen init_`control' = `control'_1980b[1]
	drop `control'_1980b
}

local ind_stub init_sh_ind_
local controls init_male init_race_white init_native_born init_educ_hs init_educ_coll init_veteran init_nchild

foreach year in `years' {
	foreach ind_var of varlist `ind_stub'* {
		gen t`year'_`ind_var' = `ind_var' * (year == `year')
		}
	foreach ind_var of varlist `controls' {
		if `year' != 1980 {
			gen t`year'_`ind_var' = `ind_var' * (year == `year')
			}
		}
	}


local controls t*_init_male t*_init_race_white t*_init_native_born t*_init_educ_hs t*_init_educ_coll t*_init_veteran t*_init_nchild year_*

bartik_weight, z(t*_`ind_stub'*)    weightstub(`growth_stub'*) x(`x') y(`y')  controls(`controls') weight_var(`weight')  absorb(czone) by(year)

mat beta = r(beta)
mat alpha = r(alpha)
mat G = r(G)
qui desc t*_`ind_stub'*, varlist
local varlist = r(varlist)

clear
svmat beta
svmat alpha
svmat G

qui gen ind = ""
qui gen year = ""
local t = 1
foreach var in `varlist' {
	if regexm("`var'", "t(.*)_`ind_stub'(.*)") {
		qui replace year = regexs(1) if _n == `t'
		qui replace ind = regexs(2) if _n == `t'
		}
	local t = `t' + 1
	}



