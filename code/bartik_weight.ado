
program define bartik_weight, rclass
	syntax [if] [in], z(varlist) weightstub(varlist)  y(varname) x(varname) [absorb(varname)] [controls(varlist)] [weight_var(varname)] [by(varname)]
	local share_stub `sharestub'
	local weight_stub `weightstub'
	local x `x'
	local y `y'
	disp "Controls: `controls'"
	disp "X variable is `x'"
	disp "Y variable is `y'"
	if "`weight_var'" == "" {
		tempvar weight_var
		gen `weight_var' = 1
		}
	if "`absorb'" != "" {
		disp "Absorbing `absorb'"
		tempname abs
		qui tab `absorb', gen(`abs'_)
		drop `abs'_1
		local absorb_var `abs'_*
		local controls "`controls' `absorb_var'"
		}
	if "`by'" != "" {
		disp "BY variable: `by'"
		local by by(`by')
		}
	else {
		disp "No BY variable "
		}
	preserve
	collapse (first) `weight_stub', `by'
	foreach var of varlist `weight_stub' {
		qui replace `var' = 0 if `var' == .
		}
	tempname g
	mkmat `weight_stub', mat(`g')
	restore
	if "`controls'" == "" {
		mata: weights_nocontrols("`y'", "`x'", "`z'", "`weight_var'", "`g'")
		}
	else {
		mata: weights("`y'", "`x'", "`z'", "`controls'", "`weight_var'", "`g'")
		}
	mat alpha = r(alpha)
	mat beta = r(beta)
	mat gam = r(gam)
	mat pi = r(pi)
	mat G = r(G)
	if "`absorb'" != "" {
		drop `abs'_*
		}
	return matrix alpha = alpha
	return matrix beta = beta
	return matrix gam = gam
	return matrix pi = pi
	return matrix G = G
end

mata:
	void weights(string scalar yname, string scalar xname, string scalar Zname, string scalar Wname, string scalar weightname, string scalar Gname)
	{
		G = st_matrix(Gname)
		G = rowshape(G, 1)'
		x = st_data(., xname)
		Z = st_data(., tokens(Zname))
		y = st_data(., yname)
		xbar = st_data(., (yname,xname) )
		W = st_data(., tokens(Wname))
		weight = diag(st_data(., weightname))
		weight2 = st_data(., weightname)
		n = rows(x)
		K = cols(Z)
		K
		rows(G)
		/** Adding ones **/
		WW = W, J(n,1,1)
		M_W = I(n) - WW*cholinv(WW'*weight*WW)*WW'*weight
		ZZ = M_W*Z
		xx = M_W*x
		yy = M_W*y
		alpha = (diag(G) * Z' * weight* xx) / (G' * Z' * weight* xx)
		beta = (Z' * weight* yy) :/ (Z' * weight* xx)
		gam = (Z' * weight* yy) :/ ((ZZ' :* ZZ') * weight2)
		pi = (ZZ' * weight* xx) :/ ((ZZ' :* ZZ') * weight2)
		alpha' * beta
		st_matrix("r(alpha)", alpha)
		st_matrix("r(beta)", beta)
		st_matrix("r(gam)", gam)
		st_matrix("r(pi)", pi)
		st_matrix("r(G)", G)
		}

	void weights_nocontrols(string scalar yname, string scalar xname, string scalar Zname, string scalar weightname, string scalar Gname)
	{
		G = st_matrix(Gname)
		G = rowshape(G, 1)'
		x = st_data(., xname)
		Z = st_data(., tokens(Zname))
		y = st_data(., yname)
		xbar = st_data(., (yname,xname) )
		weight = diag(st_data(., weightname))
		n = rows(x)
		K = cols(Z)
		/** Adding ones **/
		WW = J(n,1,1)
		M_W = I(n) - WW*cholinv(WW'*weight*WW)*WW'*weight
		
		ZZ = M_W*Z
		xx = M_W*x
		yy = M_W*y

		alpha = (diag(G) * Z' * weight* xx) / (G' * Z' * weight* xx)
		beta = (Z' * weight* yy) :/ (Z' * weight* xx)
		gam = (Z' * weight* yy) :/ (((Z' * weight) :* Z') * J(n,1,1))
		pi = (Z' * weight* xx) :/ (((Z' * weight) :* Z') * J(n,1,1))

		st_matrix("r(alpha)", alpha)
		st_matrix("r(beta)", beta)
		st_matrix("r(gam)", gam)
		st_matrix("r(pi)", pi)
		st_matrix("r(G)", G)
		}
	
end        
