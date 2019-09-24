

clear all
set matsize 1000

global data_path "../data/"
use $data_path/input_BAR2, clear

local controls male race_white native_born educ_hs educ_coll veteran nchild
local weight pop1980

local y wage_ch
local x emp_ch

local ind_stub init_sh_ind_
local growth_stub nat_empl_ind_

local time_var year
local cluster_var czone

qui tab year2, gen(year_)
drop year_1

levelsof `time_var', local(years)

/** Demean growth rates **/
egen mean_growth = rowmean(`growth_stub'*)
foreach growth of varlist `growth_stub'* {
	qui replace `growth' = `growth' - mean_growth
	}
drop mean_growth

/* Construct initial industry shares  and controls */
sort czone year
foreach ind_var of varlist sh_ind_* {
	gen `ind_var'_1980b = `ind_var' if year == 1980
	by czone (year): gen init_`ind_var' = `ind_var'_1980b[1]
	drop `ind_var'_1980b
	qui sum init_`ind_var'
	if r(mean) == 0 {
		drop init_`ind_var'
		if regexm("`ind_var'", "`ind_stub'(.*)") {
			local ind_num = regexs(1)
			}
		}
	}

foreach var of varlist init_sh_ind_* {
	if regexm("`var'", "init_sh_ind_(.*)") {
		local ind = regexs(1) 
		gen nat1980_empl_ind_`ind' = `growth_stub'`ind'
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
local growth_stub nat1980_empl_ind_



foreach year in `years' {
	foreach ind_var of varlist `ind_stub'* {
		gen t`year'_`ind_var' = `ind_var' * (year == `year')
		}
	foreach var of varlist `growth_stub'* {
		gen t`year'_`var'b = `var' if year == `year'
		egen t`year'_`var' = max(t`year'_`var'b), by(czone)
		drop t`year'_`var'b
		replace t`year'_`var' = 0 if t`year'_`var' == .
		}
	foreach ind_var of varlist `controls' {
		if `year' != 1980 {
			gen t`year'_`ind_var' = `ind_var' * (year == `year')
			}
		}
	}

qui desc t*_`growth_stub'*, varlist full
disp wordcount(r(varlist))
qui desc t*_`ind_stub'*, varlist
disp wordcount(r(varlist))

egen test = rowtotal(`ind_stub'*), 
foreach ind_var of varlist `ind_stub'* {
	replace `ind_var' = `ind_var' / test
	if regexm("`ind_var'", "`ind_stub'(.*)") {
		local ind_num = regexs(1)
		replace `growth_stub'`ind_num' = 0 if `growth_stub'`ind_num' == .
		gen b_`ind_num' = `ind_var' * `growth_stub'`ind_num'
		}
	}
egen z3 = rowtotal(b_*)
drop b_*


local controls t*_init_male t*_init_race_white t*_init_native_born t*_init_educ_hs t*_init_educ_coll t*_init_veteran t*_init_nchild year_*



drop if czone == .

foreach var of varlist `ind_stub'* {
	if regexm("`var'", "`ind_stub'(.*)") {
		local ind = regexs(1) 
		}
	tempvar temp
	qui gen `temp' = `var' * `growth_stub'`ind'
	qui regress `x' `temp' `controls' [aweight=`weight'], cluster(czone) absorb(czone)
	local pi_`ind' = _b[`temp']
	qui test `temp'
	local F_`ind' = r(F)
	qui reghdfe  `y' `temp' `controls'   [aweight=`weight'], cluster(czone) absorb(czone) 
	local gamma_`ind' = _b[`temp']
	qui ivreghdfe  `y' `controls' (`x'=`temp') [aweight=`weight'], cluster(czone) absorb(czone)
	local beta_`ind' = string(_b[`x'], "%9.3f") 
	drop `temp'
	}


foreach var of varlist `ind_stub'42 `ind_stub'351 `ind_stub'0 `ind_stub'362 `ind_stub'270 {
	if regexm("`var'", "`ind_stub'(.*)") {
		local ind = regexs(1) 
		}
	tempvar temp
	qui gen `temp' = `var' * `growth_stub'`ind'
	ch_weak, p(.05) beta_range(-10(.1)10)   y(`y') x(`x') z(`temp') weight(`weight') controls(`controls') cluster(czone) absorb(czone)
	disp r(beta_min) ,  r(beta_max)
	local ci_min_`ind' =string( r(beta_min), "%9.2f")
	local ci_max_`ind' = string( r(beta_max), "%9.2f")
	disp "`ind', `beta_`ind'', `F_`ind'', [`ci_min_`ind'', `ci_max_`ind'']"
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


bartik_weight, z(t*_`ind_stub'*)    weightstub(t*_`growth_stub'*) x(`x') y(`y')  controls(`controls') weight_var(`weight')  absorb(czone) 



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
total alpha1 if year == "1980"
mat b = e(b)
local sum_1980_alpha = string(b[1,1], "%9.3f")
total alpha1 if year == "1990"
mat b = e(b)
local sum_1990_alpha = string(b[1,1], "%9.3f")
total alpha1 if year == "2000"
mat b = e(b)
local sum_2000_alpha = string(b[1,1], "%9.3f")

sum alpha1 if year == "1980"
local mean_1980_alpha = string(r(mean), "%9.3f")
sum alpha1 if year == "1990"
local mean_1990_alpha = string(r(mean), "%9.3f")
sum alpha1 if year == "2000"
local mean_2000_alpha = string(r(mean), "%9.3f")

destring ind, replace
destring year, replace
merge 1:1 ind year using `tmp'
gen beta2 = alpha1 * beta1
gen indshare2 = alpha1 * (`ind_stub'pop)/`weight'
gen indshare_sd2 = alpha1 * `ind_stub'sd
gen G2 = alpha1 * G1

collapse (sum) alpha1 beta2 indshare2 indshare_sd2 G2 (mean) G1 , by(ind)
gen agg_beta = beta2 / alpha1
gen agg_indshare = indshare2 / alpha1
gen agg_indshare_sd = indshare_sd2 / alpha1
gen agg_g = G2/alpha1

preserve
	import excel using "../data/ind1990_labels.xlsx", clear cellrange(A4) allstring
	rename A ind
	rename B ind_name
	destring ind, replace
	
	replace ind_name = "Oil+Gas Extraction" if ind_name == "Oil and gas extraction"
	replace ind_name = "Motor Vehicles" if ind_name == "Motor vehicles and motor vehicle equipment"
	replace ind_name = "Guided Missiles" if ind_name == "Guided missiles, space vehicles, and parts"
	replace ind_name = "Paints" if ind_name == "Paints, varnishes, and related products"
	replace ind_name = "Cycles" if ind_name == "Cycles and miscellaneous transportation equipment"
	replace ind_name = "Funeral services" if ind_name == "Funeral service and crematories"
	replace ind_name = "Confectionery Products" if ind_name == "Sugar and confectionery products"
	replace ind_name = "Data Processing" if ind_name == "Computer and data processing services"
	replace ind_name = "Investment Companies" if ind_name == "Security, commodity brokerage, and investment companies"
	replace ind_name = "Livestock Production" if ind_name == "Agricultural production, livestock"
	replace ind_name = "Real Estate Offices" if ind_name == "Real estate, including real estate-insurance offices "
	replace ind_name = "Landscaping" if ind_name == "Landscape and horticultural services"
	replace ind_name = "Theaters" if ind_name == "Theaters and motion pictures"
	replace ind_name = "Misc Petroleum/Coal" if ind_name == "Miscellaneous petroleum and coal products"
	replace ind_name = "Metals and Minerals" if ind_name == "Metals and minerals, except petroleum"
	replace ind_name = "Membership organizations" if ind_name == "Membership organizations, n.e.c."
	replace ind_name = "Blast furnaces" if ind_name == "Blast furnaces, steelworks, rolling and finishing mills"
	replace ind_name = "Nursing" if ind_name == "Nursing and personal care facilities"
	replace ind_name = "Electrical machinery" if ind_name == "Electrical machinery, equipment, and supplies, n.e.c."
	replace ind_name = "Housing programs admin" if ind_name == "Administration of environmental quality and housing programs"
	replace ind_name = "Recreation services" if ind_name == "Miscellaneous entertainment and recreation services "
	replace ind_name = "Printing/publishing," if ind_name == "Printing, publishing, and allied industries, except newspapers"
	replace ind_name = "Other" if ind_name == "NA"
	tempfile ind_labels
	save `ind_labels'
restore
merge 1:1 ind using "`ind_labels'"
keep if _merge == 3

gsort -alpha1

/***
ind	alpha1	beta2	beta1	agg_beta
3571	.1826005	-.1130861	-.6087478	-.6193091
3944	.1375558	-.0173997	-.0609449	-.1264918
3651	.0853901	.0148397	.770126	.1737877
3661	.0662476	-.0208716	-.5065653	-.3150544
3577	.0601904	-.0182433	-.4240822	-.3030925
***/



capture file close fh
file open fh  using "../results/rotemberg_summary_bar.tex", write replace
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
foreach ind in 42 351 0 362 270 {
	qui sum alpha1 if ind == `ind'
   local alpha_`ind' = string(r(mean), "%9.3f")
	qui sum agg_g if ind == `ind'	
	local g_`ind' = string(r(mean), "%9.3f")
	/* qui sum agg_beta if ind == `ind'	 */
	/* local beta_`ind' = string(r(mean), "%9.3f") */
	qui sum agg_indshare if ind == `ind'	
	local share_`ind' = string(r(mean)*100, "%9.3f")
	tempvar temp
	qui gen `temp' = ind == `ind'
	gsort -`temp'
	local ind_name_`ind' = ind_name[1]
	drop `temp'
	}


/**** Make Overid Graph ***/
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
graph export "../results/overid_BAR.pdf", replace

gsort -alpha1
twoway (scatter F alpha1 if _n <= 5, mcolor(dblue) mlabel(ind_name  ) msize(0.5) mlabsize(2) ) (scatter F alpha1 if _n > 5, mcolor(dblue) msize(0.5) ), name(a, replace) xtitle("Rotemberg weight") ytitle("First stage F-statistic") yline(10, lcolor(black) lpattern(dash)) legend(off)
graph export "../results/F_vs_rotemberg_weight_BAR.pdf", replace

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
file write fh  "1980 & `sum_1980_alpha' & `mean_1980_alpha' \\" _n
file write fh  "1990 & `sum_1990_alpha' & `mean_1990_alpha' \\" _n
file write fh  "2000 & `sum_2000_alpha' & `mean_2000_alpha' \\" _n

/** Panel D **/
file write fh "\multicolumn{5}{l}{\textbf{Panel D: Top 5 Rotemberg weight industries} }\\" _n
file write fh  " & $\hat{\alpha}_{k}$ & \$g_{k}$ & $\hat{\beta}_{k}$ & 95 \% CI & Ind Share \\ \cmidrule(lr){2-6}" _n
foreach ind in 42 351 0 362 270 {
	if `ci_min_`ind'' != -10 & `ci_max_`ind'' != 10 {
		file write fh  "`ind_name_`ind'' & `alpha_`ind'' & `g_`ind'' & `beta_`ind'' & (`ci_min_`ind'',`ci_max_`ind'')  & `share_`ind'' \\ " _n
		}
	else  {
		file write fh  "`ind_name_`ind'' & `alpha_`ind'' & `g_`ind'' & `beta_`ind'' & \multicolumn{1}{c}{N/A}  & `share_`ind'' \\ " _n
		}
	}
file write fh "\multicolumn{5}{l}{\textbf{Panel E: Estimates of $\beta_{k}$ for positive and negative weights} }\\" _n
file write fh  " & $\alpha$-weighted Sum & Share of overall $\beta$ & Mean  \\ \cmidrule(lr){2-3}" _n
file write fh  " Negative & `agg_beta_neg' & `agg_beta_neg_share' &`agg_beta_neg2' \\" _n
file write fh  " Positive & `agg_beta_pos' & `agg_beta_pos_share' & `agg_beta_pos2' \\" _n
file write fh  "\bottomrule" _n
file close fh
