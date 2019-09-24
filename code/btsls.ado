

program define btsls, rclass
	syntax [if] [in], z(varlist)  y(varname) x(varname) ktype(string) [absorb(varname)] [controls(varlist)] [weight_var(varname)]
	local x `x'
	local y `y'
	marksample touse
*	disp "Controls: `controls'"
	disp "X variable is `x'"
	disp "Y variable is `y'"
	if "`weight_var'" == "" {
		tempvar weight_var_new
		gen `weight_var_new' = 1
		}
	else {
		tempvar weight_var_total
		qui egen `weight_var_total' = total(`weight_var')
		qui count
		tempvar weight_var_new
		gen `weight_var_new' = (r(N)/`weight_var_total') * `weight_var'
		}
	if "`absorb'" != "" {
		disp "Absorbing `absorb'"
		tempname abs
		qui tab `absorb', gen(`abs'_)
		drop `abs'_1
		local absorb_var `abs'_*
		local controls "`controls' `absorb_var'"
		}
	/*
	_rmdcoll `y' `z' `controls' 
	local z_list = r(varlist)
	local wordcount = wordcount("`z_list'")
	local new_z ""
	local new_controls ""
	forvalues i=1/`wordcount' {
		local test_var = word("`z_list'", `i')
		if ~regexm("`test_var'", "^o\.") {
			if regexm("`z'", "(^`test_var' )|( `test_var'$)|(^`test_var'$)") {
				local new_z "`new_z' `test_var'"
				}
			else if regexm("`z'", "( `test_var' )") {
				local new_z "`new_z' `test_var'"
				}
			else {
				local new_controls "`new_controls' `test_var'"
				}
			}
	}
	*/
	local new_z "`z'"
	local new_controls "`controls'"	
	local K = wordcount("`new_z'")
	local L = wordcount("`new_controls'")
	qui count
	local N = r(N)
	tempname kappa
	if "`ktype'" == "tsls" | "`ktype'" == "2sls" {
		scalar `kappa' = 1
		}
	else if "`ktype'" == "liml" {
		scalar `kappa' = 1
		}
	else if "`ktype'" == "btsls" {
		scalar `kappa' = 1/(1-((`K' - 2)/`N'))
		}
	else if "`ktype'" == "mbtsls" {
		scalar `kappa' = (1-(`L'/`N'))/(1-(`K'/`N') - (`L'/`N'))
		}
	else {
		error "Not a valid kappa type! tsls, liml, btsls, or mbtsls"
		}
	if "`new_controls'" == "" {
		mata: weights_nocontrols("`y'", "`x'", "`new_z'",  "`weight_var_new'", "`kappa'")
		}
	else {
		mata: weights("`y'", "`x'", "`new_z'", "`new_controls'", "`weight_var_new'", "`kappa'")
		}
	mat beta = r(beta)
	local beta = beta[1,1]
	if "`absorb'" != "" {
		capture drop `abs'_*
		}
	return scalar beta = `beta'
end


mata:
	void weights(string scalar yname, string scalar xname, string scalar Zname, string scalar Wname, string scalar weightname, string scalar kappaname)
	{
		x = st_data(., xname)
		Z = st_data(., tokens(Zname))
		y = st_data(., yname)
		W = st_data(., tokens(Wname))
		weight = st_data(., weightname)
		kappa = st_numscalar(kappaname)
		n = rows(x)
		K = cols(Z)
		x = sqrt(weight) :* x
		y = sqrt(weight) :* y
		Z = sqrt(weight) :* Z
		/** Adding ones **/
		WW = J(n,1,1), W
		WW = sqrt(weight) :* WW
		WW_inv = quadcross(WW, WW)
		P_W = WW* invsym(WW_inv)* WW' 
		M_W = I(n) - P_W
		ZZ = quadcross(M_W,Z)
		xx = quadcross(M_W,x)
		yy = quadcross(M_W,y)
		ZZ_inv = quadcross(ZZ, ZZ)
		M_Z = I(n) - ZZ*invsym(ZZ_inv)*ZZ'
		temp = I(n)  - kappa*M_Z
		xx_proj = quadcross(temp, xx)
		xx_proj_xx = quadcross(xx_proj, xx)
		xx_proj_yy = quadcross(xx_proj, yy)
		beta = cholinv(xx_proj_xx) * (xx_proj_yy)
		st_matrix("r(beta)", beta)
	}

	void weights_nocontrols(string scalar yname, string scalar xname, string scalar Zname, string scalar weightname, string scalar kappaname)
	{
		x = st_data(., xname)
		Z = st_data(., tokens(Zname))
		y = st_data(., yname)
		weight = st_data(., weightname)
		kappa = st_numscalar(kappaname)
		n = rows(x)
		K = cols(Z)
		x = sqrt(weight) :* x
		y = sqrt(weight) :* y
		Z = sqrt(weight) :* Z
		/** Adding ones **/
		WW = J(n,1,1)
		WW = sqrt(weight) :* WW
		WW_inv = quadcross(WW, WW)
		P_W = WW* cholinv(WW_inv)* WW' 
		M_W = I(n) - P_W
		ZZ = quadcross(M_W,Z)
		xx = quadcross(M_W,x)
		yy = quadcross(M_W,y)
		ZZ_inv = quadcross(ZZ, ZZ)
		M_Z = I(n) - ZZ*cholinv(ZZ_inv)*ZZ'
		temp = I(n)  - kappa*M_Z
		xx_proj = quadcross(temp, xx)
		xx_proj_xx = quadcross(xx_proj, xx)
		xx_proj_yy = quadcross(xx_proj, yy)
		beta = cholinv(xx_proj_xx) * (xx_proj_yy)
		st_matrix("r(beta)", beta)
	}

end
