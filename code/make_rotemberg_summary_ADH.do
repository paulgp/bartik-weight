

set matsize 2000

/*** AKM ADH Data **/
insheet using "../data/ADHdata_AKM.csv", clear
gen year = 1990 + (t2=="TRUE")*10
drop t2

/*** BHJ SHARES **/
merge 1:m czone year using ../data/Lshares.dta, gen(merge_shares)
/*** BHJ SHOCKS **/
merge m:1 sic87dd year using "../data/shocks.dta", gen(merge_shocks)

rename ind_share share_emp_ind_bhj_
gen z_ = share_emp_ind_bhj_ * g
rename g g_
drop g_emp_ind-g_importsUSA
reshape wide share_emp_ind_bhj_ g z_, i(czone year) j(sic87dd)
egen z = rowtotal(z_*)


local controls reg_* l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource l_shind_manuf_cbp t2
local weight weight

local y d_sh_empl_mfg 
local x shock
local z z


local ind_stub share_emp_ind_bhj_
local growth_stub g_

local time_var year
local cluster_var czone

levelsof `time_var', local(years)

/** g_2141 and g_3761 = 0 for all years **/
drop g_2141 `ind_stub'2141
drop g_3761 `ind_stub'3761

forvalues t = 1990(10)2000 {
	foreach var of varlist `ind_stub'* {
		gen t`t'_`var' = (year == `t') * `var'
		}
	foreach var of varlist `growth_stub'* {
		gen t`t'_`var'b = `var' if year == `t'
		egen t`t'_`var' = max(t`t'_`var'b), by(czone)
		drop t`t'_`var'b
		}
	}

tab division, gen(reg_)
drop reg_1
tab year, gen(t)
drop t1

drop if czone == .

foreach var of varlist `ind_stub'* {
	if regexm("`var'", "`ind_stub'(.*)") {
		local ind = regexs(1) 
		}
	tempvar temp
	qui gen `temp' = `var' * `growth_stub'`ind'
	qui regress `x' `temp' `controls' [aweight=`weight'], cluster(czone)
	local pi_`ind' = _b[`temp']
	qui test `temp'
	local F_`ind' = r(F)
	qui regress `y' `temp' `controls' [aweight=`weight'], cluster(czone)
	local gamma_`ind' = _b[`temp']
	drop `temp'
	}

foreach var of varlist `ind_stub'3571 `ind_stub'3944 `ind_stub'3651 `ind_stub'3661 `ind_stub'3577 {
	if regexm("`var'", "`ind_stub'(.*)") {
		local ind = regexs(1) 
		}
	tempvar temp
	qui gen `temp' = `var' * `growth_stub'`ind'
	ch_weak, p(.05) beta_range(-10(.1)10)   y(`y') x(`x') z(`temp') weight(`weight') controls(`controls') cluster(czone)
	disp r(beta_min) ,  r(beta_max)
	local ci_min_`ind' =string( r(beta_min), "%9.2f")
	local ci_max_`ind' = string( r(beta_max), "%9.2f")
	disp "`ind', `beta_`ind'', `t_`ind'', [`ci_min_`ind'', `ci_max_`ind'']"
	drop `temp'
	}


preserve
keep `ind_stub'* czone year `weight'
reshape long `ind_stub', i(czone year) j(ind)
gen `ind_stub'pop = `ind_stub'*`weight'
collapse (sd) `ind_stub'sd = `ind_stub' (rawsum) `ind_stub'pop `weight' [aweight = `weight'], by(ind year)
tempfile tmp
save `tmp'
restore

bartik_weight, z(t*_`ind_stub'*)    weightstub(t*_`growth_stub'*) x(`x') y(`y') controls(`controls'  ) weight_var(`weight')

mat beta = r(beta)
mat alpha = r(alpha)
mat gamma = r(gam)
mat pi = r(pi)
mat G = r(G)
qui desc t*_`ind_stub'*, varlist
local varlist = r(varlist)



clear
svmat beta
svmat alpha
svmat gamma
svmat pi
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

/** Calculate Panel C: Variation across years in alpha **/
total alpha1 if year == "1990"
mat b = e(b)
local sum_1990_alpha = string(b[1,1], "%9.3f")
total alpha1 if year == "2000"
mat b = e(b)
local sum_2000_alpha = string(b[1,1], "%9.3f")

sum alpha1 if year == "1990"
local mean_1990_alpha = string(r(mean), "%9.3f")
sum alpha1 if year == "2000"
local mean_2000_alpha = string(r(mean), "%9.3f")

destring ind, replace
destring year, replace
merge 1:1 ind year using `tmp'
gen beta2 = alpha1 * beta1
gen indshare2 = alpha1 * (`ind_stub'pop/`weight')
gen indshare_sd2 = alpha1 * `ind_stub'sd
gen G2 = alpha1 * G1
collapse (sum) alpha1 beta2 indshare2 indshare_sd2 G2 (mean) G1 , by(ind)
gen agg_beta = beta2 / alpha1
gen agg_indshare = indshare2 / alpha1
gen agg_indshare_sd = indshare_sd2 / alpha1
gen agg_g = G2 / alpha1
rename ind sic
merge 1:1 sic using "../data/sic_code_desc"
rename sic ind
keep if _merge == 3
gen ind_name = subinstr(description, "Not Elsewhere Classified", "NEC", .)
replace ind_name = subinstr(ind_name, ", Except Dolls and Bicycles", "", .)

gsort -alpha1

capture file close fh
file open fh  using "../output/rotemberg_summary_adh.tex", write replace
file write fh "\toprule" _n

/** Panel A: Negative and Positive Weights **/
total alpha1 if alpha1 > 0
mat b = e(b)
local sum_pos_alpha = string(b[1,1], "%9.3f")
total alpha1 if alpha1 < 0
mat b = e(b)
local sum_neg_alpha = string(b[1,1], "%9.3f")

sum alpha1 if alpha1 > 0
local mean_pos_alpha = string(r(mean), "%9.3f")
sum alpha1 if alpha1 < 0
local mean_neg_alpha = string(r(mean), "%9.3f")

local share_pos_alpha = string(abs(`sum_pos_alpha')/(abs(`sum_pos_alpha') + abs(`sum_neg_alpha')), "%9.3f")
local share_neg_alpha = string(abs(`sum_neg_alpha')/(abs(`sum_pos_alpha') + abs(`sum_neg_alpha')), "%9.3f")



/** Panel B: Correlations of Industry Aggregates **/
gen F = .
gen agg_pi = .
gen agg_gamma = .
levelsof ind, local(industries)
foreach ind in `industries' {
	capture replace F = `F_`ind'' if ind == `ind'
	capture replace agg_pi = `pi_`ind'' if ind == `ind'
	capture replace agg_gamma = `gamma_`ind'' if ind == `ind'		
	}
corr alpha1 agg_g agg_beta F agg_indshare_sd
mat corr = r(C)
forvalues i =1/5 {
	forvalues j = `i'/5 {
		local c_`i'_`j' = string(corr[`i',`j'], "%9.3f")
		}
	}

/** Panel  D: Top 5 Rotemberg Weight Inudstries **/
foreach ind in 3571 3944 3651 3661 3577 {
	qui sum alpha1 if ind == `ind'
   local alpha_`ind' = string(r(mean), "%9.3f")
	qui sum agg_g if ind == `ind'	
	local g_`ind' = string(r(mean), "%9.3f")
	qui sum agg_beta if ind == `ind'	
	local beta_`ind' = string(r(mean), "%9.3f")
	qui sum agg_indshare if ind == `ind'	
	local share_`ind' = string(r(mean)*100, "%9.3f")
	tempvar temp
	qui gen `temp' = ind == `ind'
	gsort -`temp'
	local ind_name_`ind' = ind_name[1]
	drop `temp'
	}


/** Over ID Figures **/
gen omega = alpha1*agg_beta
total omega
mat b = e(b)
local b = b[1,1]

gen label_var = ind 
gen beta_lab = string(agg_beta, "%9.3f")


gen abs_alpha = abs(alpha1) 
gen positive_weight = alpha1 > 0
gen agg_beta_pos = agg_beta if positive_weight == 1
gen agg_beta_neg = agg_beta if positive_weight == 0
twoway (scatter agg_beta_pos agg_beta_neg F if F >= 5 [aweight=abs_alpha ], msymbol(Oh Dh) ), legend(label(1 "Positive Weights") label( 2 "Negative Weights")) yline(`b', lcolor(black) lpattern(dash)) xtitle("First stage F-statistic")  ytitle("{&beta}{subscript:k} estimate")
graph export "../output/overid_ADH.pdf", replace

gsort -alpha1
twoway (scatter F alpha1 if _n <= 5, mcolor(dblue) mlabel(ind_name  ) msize(0.5) mlabsize(2) ) (scatter F alpha1 if _n > 5, mcolor(dblue) msize(0.5) ), name(a, replace) xtitle("Rotemberg Weight") ytitle("First stage F-statistic") yline(10, lcolor(black) lpattern(dash)) legend(off)
graph export "../output/F_vs_rotemberg_weight_ADH.pdf", replace


/** Panel E: Weighted Betas by alpha weights **/
gen agg_beta_weight = agg_beta * alpha1

collapse (sum) agg_beta_weight alpha1 (mean)  agg_beta, by(positive_weight)
egen total_agg_beta = total(agg_beta_weight)
gen share = agg_beta_weight / total_agg_beta
gsort -positive_weight
local agg_beta_pos = string(agg_beta_weight[1], "%9.3f")
local agg_beta_neg = string(agg_beta_weight[2], "%9.3f")
local agg_beta_pos2 = string(agg_beta[1], "%9.3f")
local agg_beta_neg2 = string(agg_beta[2], "%9.3f")
local agg_beta_pos_share = string(share[1], "%9.3f")
local agg_beta_neg_share = string(share[2], "%9.3f")

/*** Write final table **/
/** Panel A **/
file write fh "\multicolumn{3}{l}{\textbf{Panel A: Negative and positive weights}}\\" _n
file write fh  " & Sum & Mean & Share \\  \cmidrule(lr){2-4}" _n
file write fh  "Negative & `sum_neg_alpha' & `mean_neg_alpha' & `share_neg_alpha' \\" _n
file write fh  "Positive & `sum_pos_alpha' & `mean_pos_alpha' & `share_pos_alpha' \\" _n

/** Panel B **/
file write fh "\multicolumn{5}{l}{\textbf{Panel B: Correlations of Industry Aggregates} }\\" _n
file write fh  " &$\alpha_k$ & \$g_{k}$ & $\beta_k$ & \$F_{k}$ & Var(\$z_k$) \\" _n
file write fh  "\cmidrule(lr){2-6} " _n
file write fh " & \\" _n
file write fh " $\alpha_k$             & 1\\" _n
file write fh " \$g_{k}$                &   `c_1_2'  & 1\\" _n
file write fh " $\beta_{k}$             &   `c_1_3'  & `c_2_3'    &1\\" _n
file write fh " \$F_{k}$                &   `c_1_4'  & `c_2_4'    &  `c_3_4'  & 1\\" _n
file write fh " Var(\$z_{k}$)           &   `c_1_5'  & `c_2_5'    &  `c_3_5'  &  `c_4_5'   &1\\" _n

/** Panel C **/
file write fh "\multicolumn{5}{l}{\textbf{Panel C: Variation across years in $\alpha_{k}$}}\\" _n
file write fh  " & Sum & Mean \\  \cmidrule(lr){2-3}" _n
file write fh  "1990 & `sum_1990_alpha' & `mean_1990_alpha' \\" _n
file write fh  "2000 & `sum_2000_alpha' & `mean_2000_alpha' \\" _n

/** Panel D **/
file write fh "\multicolumn{5}{l}{\textbf{Panel D: Top 5 Rotemberg weight industries} }\\" _n
file write fh  " & $\hat{\alpha}_{k}$ & \$g_{k}$ & $\hat{\beta}_{k}$ & 95 \% CI & Ind Share \\ \cmidrule(lr){2-6}" _n
foreach ind in 3571 3944 3651 3661 3577 {
	if `ci_min_`ind'' != -10 & `ci_max_`ind'' != 10 {
		file write fh  "`ind_name_`ind'' & `alpha_`ind'' & `g_`ind'' & `beta_`ind'' & (`ci_min_`ind'',`ci_max_`ind'')  & `share_`ind'' \\ " _n
		}
	else  {
		file write fh  "`ind_name_`ind'' & `alpha_`ind'' & `g_`ind'' & `beta_`ind'' & \multicolumn{1}{c}{N/A}  & `share_`ind'' \\ " _n
		}
	}

/** Panel E **/
file write fh "\multicolumn{5}{l}{\textbf{Panel E: Estimates of $\beta_{k}$ for positive and negative weights} }\\" _n
file write fh  " & $\alpha$-weighted Sum & Share of overall $\beta$ & Mean  \\ \cmidrule(lr){2-3}" _n
file write fh  " Negative & `agg_beta_neg' & `agg_beta_neg_share' &`agg_beta_neg2' \\" _n
file write fh  " Positive & `agg_beta_pos' & `agg_beta_pos_share' & `agg_beta_pos2' \\" _n
file write fh  "\bottomrule" _n
file close fh


