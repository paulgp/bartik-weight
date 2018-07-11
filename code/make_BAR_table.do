
set seed 12345
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
qui tab czone, gen(czone_)
drop czone_1

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
		if "`ind_var'" !=  "init_sh_ind_10" {
			gen t`year'_`ind_var' = `ind_var' * (year == `year')
			}
		}
	foreach ind_var of varlist `controls' {
		if `year' != 1980 {
			gen t`year'_`ind_var' = `ind_var' * (year == `year')
			}
		}
	}

local controls t*_init_male t*_init_race_white t*_init_native_born t*_init_educ_hs t*_init_educ_coll t*_init_veteran t*_init_nchild year_*


/* egen mean_growth = rowmean(`growth_stub'*) */
/* foreach growth of varlist `growth_stub'* { */
/* 	replace `growth' = `growth' - mean_growth */
/* 	} */
/* drop mean_growth */

foreach ind_var of varlist `ind_stub'* {
	if regexm("`ind_var'", "`ind_stub'(.*)") {
		local ind_num = regexs(1)
		replace `growth_stub'`ind_num' = 0 if `growth_stub'`ind_num' == .
		gen b_`ind_num' = `ind_var' * `growth_stub'`ind_num'
		}
	}
egen z2 = rowtotal(b_*)
drop b_*

foreach year in 1980 {
	foreach ind_var of varlist `ind_stub'* {
		capture drop t`year'_`ind_var' 
		}
}
set matsize 4000
global controls `controls'
global y `y'
global x `x'
global z `z'
global ind_stub `ind_stub'
global growth_stub `growth_stub'
global weight `weight'
tsset, clear

capture program drop test_and_compare
program define test_and_compare, rclass
	btsls, z(`2') x($x) y($y) controls(year_*) ktype("`1'") weight_var($weight) absorb(czone)
	local b_1 = r(beta)
	return scalar b_1 = `b_1'
	btsls, z(`2') x($x) y($y) controls($controls) ktype("`1'") weight_var($weight) absorb(czone)
	local b_2 = r(beta)
	return scalar b_2 = `b_2'
	return scalar diff = `b_1' - `b_2'
end


capture program drop test_and_compare_chao
program define test_and_compare_chao, rclass
	overid_chao, z(t*_init_sh_ind_*) x($x) y($y) controls(year_*)  weight_var($weight) absorb(czone)
	local b_1 = r(delta)
	return scalar b_1 = `b_1'
	overid_chao, z(t*_init_sh_ind_*) x($x) y($y) controls($controls )  weight_var($weight) absorb(czone)
	local b_2 = r(delta)
	return scalar b_2 = `b_2'
	return scalar diff = `b_1' - `b_2'
end

capture program drop liml_bootstrap
program define  liml_bootstrap, rclass
	reghdfe  $y  ($x =  t*_init_sh_ind_*) [aw=$weight], absorb( i.czone i.year) estimator(liml)
	local b_1 = _b[$x]
	reghdfe  $y c.($controls) ($x =  t*_init_sh_ind_*) [aw=$weight], absorb( i.czone i.year) estimator(liml)
	local b_2 = _b[$x]
	return scalar b_1 = `b_1'
	return scalar b_2 = `b_2'
	return scalar diff = `b_1' - `b_2'
end

local n = 100

estimates clear
qui reg `y' `x' i.year [aweight=`weight'], cluster(czone) absorb(czone)
local b1_ols = string(_b[`x'], "%12.2f")
local se1_ols = "(" + string(_se[`x'], "%12.2f") + ")"
qui reg `y' `x' i.year [aweight=`weight'], absorb(czone)
estimates store ols1
qui reg `y' `x' `controls'  [aweight=`weight'], cluster(czone) absorb(czone)
local b2_ols = string(_b[`x'], "%12.2f")
local se2_ols = "(" +  string(_se[`x'], "%12.2f") + ")"
qui reg `y' `x' `controls' i.year [aweight=`weight'], absorb(czone)
estimates store ols2
suest ols1 ols2, cluster(czone)
test [ols1_mean]`x'=[ols2_mean]`x'
local p_ols = "[" + string(r(p), "%12.2f") + "]"

bootstrap b1_bartik = r(b_1) b2_bartik = r(b_2) diff_bartik = r(diff), cluster(czone) reps(`n'): test_and_compare tsls z2
mat b = e(b)
mat V = vecdiag(e(V))
local b1_bartik = string(b[1,1], "%12.2f")
local b2_bartik = string(b[1,2], "%12.2f")
local se1_bartik = "(" + string(sqrt(V[1,1]), "%12.2f") + ")"
local se2_bartik = "(" + string(sqrt(V[1,2]), "%12.2f") + ")"
mat pval = r(table)
local p_bartik = "[" + string(pval[4,3], "%12.2f") + "]"

bootstrap b1_2sls = r(b_1) b2_2sls = r(b_2) diff_2sls = r(diff), cluster(czone) reps(`n'): test_and_compare tsls t*_init_sh_ind_*
mat b = e(b)
mat V = vecdiag(e(V))
local b1_2sls = string(b[1,1], "%12.2f")
local b2_2sls = string(b[1,2], "%12.2f")
local se1_2sls = "(" + string(sqrt(V[1,1]), "%12.2f") + ")"
local se2_2sls = "(" + string(sqrt(V[1,2]), "%12.2f") + ")"
mat pval = r(table)
local p_2sls = "[" + string(pval[4,3], "%12.2f") + "]"

ivregress 2sls  `y'  `controls' czone_* year_*  (`x'= t1990_init_sh_ind_* t2000_init_sh_ind_*  )  [aweight=`weight'], vce(robust)
estat overid, forceweights
local J_2sls = string(r(score), "%12.2f")
local Jp_2sls = "[" + string(r(p_score), "%12.2f") + "]"

bootstrap b1_mbtsls = r(b_1) b2_mbtsls = r(b_2) diff_mbtsls = r(diff), cluster(czone) reps(`n'): test_and_compare mbtsls t*_init_sh_ind_*
mat b = e(b)
mat V = vecdiag(e(V))
local b1_mbtsls = string(b[1,1], "%12.2f")
local b2_mbtsls = string(b[1,2], "%12.2f")
local se1_mbtsls = "(" + string(sqrt(V[1,1]), "%12.2f") + ")"
local se2_mbtsls = "(" + string(sqrt(V[1,2]), "%12.2f") + ")"
mat pval = r(table)
local p_mbtsls = "[" + string(pval[4,3], "%12.2f") + "]"

qui reghdfe  `y'  (`x' =  t*_`ind_stub'*) [aw=`weight'], absorb( i.czone i.year) estimator(liml)
local b1_liml = string(_b[`x'], "%12.2f")
local se1_liml = "(" + string(_se[`x'], "%12.2f") + ")"

qui reghdfe  `y' c.`controls' (`x' =  t*_`ind_stub'*) [aw=`weight'], absorb( i.czone i.year) estimator(liml)
local b2_liml = string(_b[`x'], "%12.2f")
local se2_liml = "(" + string(_se[`x'], "%12.2f") + ")"
local N = e(N)
local K = wordcount(e(insts)) - wordcount(e(exogr))
local L = wordcount(e(exogr))
local kappa = e(kappa) - 1
local J_liml  = (`N' - `K' - `L') * (`kappa' - 1)
local alpha_L =  `L' / `N'
local alpha_K =  `K' / `N'
local crit = normal(sqrt((1 - `alpha_L') / ( 1- `alpha_K' - `alpha_L'))*invnorm(0.95)) 
disp chi2(`J_liml', `K'-1)

bootstrap b1_liml = r(b_1) b2_liml = r(b_2) diff_liml = r(diff), cluster(czone) reps(`n'): liml_bootstrap

bootstrap b1_hful = r(b_1) b2_hful = r(b_2) diff_hful = r(diff), cluster(czone) reps(`n'): test_and_compare_chao
mat b = e(b)
mat V = vecdiag(e(V))
local b1_hful = string(b[1,1], "%12.2f")
local b2_hful = string(b[1,2], "%12.2f")
local se1_hful = "(" + string(sqrt(V[1,1]), "%12.2f") + ")"
local se2_hful = "(" + string(sqrt(V[1,2]), "%12.2f") + ")"
mat pval = r(table)
local p_hful = "[" + string(pval[4,3], "%12.2f") + "]"

overid_chao, z(t*_init_sh_ind_*) x($x) y($y) controls($controls )  weight_var($weight) absorb(czone)
local J_hful = string(r(T), "%12.2f")
local Jp_hful = "[" + string(r(p), "%12.2f") + "]"


capture file close fh
capture erase "bar_results.tex"
file open fh using "bar_results.tex", write replace

file write fh "OLS & `b1_ols' & `b2_ols' & `p_ols' & \\" _n
file write fh "    & `se1_ols'& `se2_ols'&         & \\" _n
file write fh "2SLS (Bartik) & `b1_bartik' & `b2_bartik' & `p_bartik' & \\" _n
file write fh "    & `se1_bartik' & `se2_bartik' &         & \\" _n
file write fh "2SLS & `b1_2sls' & `b2_2sls' & `p_2sls' & `J_2sls' \\" _n
file write fh "    & `se1_2sls'& `se2_2sls'&         & `Jp_2sls' \\" _n
file write fh "MBTSLS & `b1_mbtsls' & `b2_mbtsls' & `p_mbtsls' & \\" _n
file write fh "    & `se1_mbtsls'& `se2_mbtsls'&         & \\" _n
file write fh "LIML & `b1_liml' & `b2_liml' & `p_liml' & \\" _n
file write fh "    & `se1_liml'& `se2_liml'&         & \\" _n
file write fh "HFUL & `b1_hful' & `b2_hful' & `p_hful' & `J_hful' \\" _n
file write fh "    & `se1_hful'& `se2_hful'&         & `Jp_hful' \\" _n

file close fh
