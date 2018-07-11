program define overid_chao, rclass
	syntax [if] [in], y(name) x(name) z(varlist) [controls(varlist)] [absorb(varname)] [WEIGHT_var(string)] 
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
        tempname a
        qui tab `absorb', gen(`a'_)
        drop `a'_1
        local controls2 "`controls' `a'_*"
    }
    else {
        local controls2 "`controls'"
    }
	_rmdcoll `y' `z' `controls2' 
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
	if "`new_controls'" != "" {
		mata: overid_chao("`y'", "`x'", "`new_z'", "`new_controls'", "`weight_var'")
		}
	else {
		mata: overid_chao_nocons("`y'", "`x'", "`new_z'",  "`weight_var'")
		}
    if "`absorb'" != "" {
        drop `a'_*
    }

	local delta = r(delta)
	local beta = r(beta)
	local T = r(T)
	local p = r(p)
	disp "HFUL Estimate is `delta'"
	disp "2SLS Estimate is `beta'"
	disp "Over ID Stat is `T'"
	disp "Prob is `p'"
   return scalar beta = `beta'
	return scalar delta = `delta'
	return scalar beta = `beta'
	return scalar T = `T'
	return scalar p = `p'		
end

mata:
	void overid_chao(string scalar yname, string scalar xname, string scalar Zname, string scalar Wname, string scalar weightname)
	{
		x = st_data(., xname)
		Z = st_data(., tokens(Zname))
		y = st_data(., yname)
		xbar = st_data(., (yname,xname) )
		W = st_data(., tokens(Wname))
		weight = diag(st_data(., weightname))
		n = rows(x)
		K = cols(Z)
		/** Adding ones **/
		WW = W, J(n,1,1)
		
		M_W = I(n) - WW*cholinv(WW'*weight*WW)*WW'*weight
		
		ZZ = M_W*Z
		xx = M_W*x
		yy = M_W*y
        
		
		xbar = (yy, xx)
		P =ZZ* cholinv(ZZ'*weight*ZZ)*ZZ' * weight
        
		
		P_ii = diagonal(P)
		O = eigenvalues(cholinv(xbar' *weight* xbar) * (xbar'*weight*P*xbar - xbar' *weight* diag(P_ii) * xbar))
        
		OO = O[1,2]
		alpha_hat = (OO  - ((1-OO)/n) )/(1-  ((1-OO)/n ))
		delta_hat = cholinv(x'*weight*P*x - x' *weight* diag(P_ii) * x - alpha_hat * x'*weight*x)  * (x'*weight*P*y - x'*weight * diag(P_ii) * y - alpha_hat * x'*weight*y)
		denom = (x'*weight*P*x - x' *weight* diag(P_ii) * x - alpha_hat * x'*weight*x)
		H = (x'*weight*P*y - x'*weight * diag(P_ii) * y - alpha_hat * x'*weight*y)
		delta_hat2 =  H / denom 
		beta_hat_2sls = cholinv(x'*weight*P*x)  * (x'*weight*P*y)

		epsilon = yy - delta_hat2*xx
		epsilon_2 = epsilon :* epsilon

		/*
		gam = (xx' * weight* epsilon) / (epsilon'* weight*epsilon)
		xx_hat = xx - epsilon* gam
		xx_dot = P  * xx_hat
		Z_tilde = weight*ZZ* cholinv(ZZ'*weight*ZZ)

		Sigma1 =  xx_dot'* diag(epsilon_2) * weight *xx_dot - xx_hat' * weight*  diag(P_ii)  * diag(epsilon_2) * xx_dot - xx_dot' * weight* diag(P_ii)*diag(epsilon_2) *xx_hat
		
		x_eps = xx_hat :* epsilon
		Sigma2 = J(K,1,1)' *((Z_tilde'*diag(x_eps)*weight* Z_tilde) :* (ZZ'*diag(x_eps)*weight*ZZ)) *J(K,1,1)

		Sigma = Sigma1 + Sigma2
		
		V = Sigma / (H*H)
		*/
		P_2 = P :* P
		P_ii_2 = P_ii :* P_ii
		weight_2 = weight :* weight
		V = (epsilon_2' * weight_2 * P_2 * epsilon_2 - epsilon_2' * weight_2 * diag(P_ii_2)  * epsilon_2) / K
		T = K + ((epsilon' * weight*  P * epsilon - epsilon' * weight*  diag(P_ii) * epsilon) / sqrt(V))
		
		st_numscalar("r(delta)", Re(delta_hat2))
		st_numscalar("r(beta)", Re(beta_hat_2sls))
		st_numscalar("r(T)", Re(T))
		st_numscalar("r(p)", 1-chi2(K-1, Re(T)))
		}

		void overid_chao_nocons(string scalar yname, string scalar xname, string scalar Zname, string scalar weightname)
	{
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
		xbar = (yy, xx)
		P =ZZ* cholinv(ZZ'*weight*ZZ)*ZZ' * weight
		P_ii = diagonal(P)
		O = eigenvalues(cholinv(xbar' *weight* xbar) * (xbar'*weight*P*xbar - xbar' *weight* diag(P_ii) * xbar))
		OO = O[1,2]
		alpha_hat = (OO  - ((1-OO)/n) )/(1-  ((1-OO)/n ))
		delta_hat = cholinv(x'*weight*P*x - x' *weight* diag(P_ii) * x - alpha_hat * x'*weight*x)  * (x'*weight*P*y - x'*weight * diag(P_ii) * y - alpha_hat * x'*weight*y)
		denom = (x'*weight*P*x - x' *weight* diag(P_ii) * x - alpha_hat * x'*weight*x)
		H = (x'*weight*P*y - x'*weight * diag(P_ii) * y - alpha_hat * x'*weight*y)
		delta_hat2 =  H / denom 
		beta_hat_2sls = cholinv(x'*weight*P*x)  * (x'*weight*P*y)

		epsilon = yy - delta_hat2*xx
		epsilon_2 = epsilon :* epsilon

		/*
		gam = (xx' * weight* epsilon) / (epsilon'* weight*epsilon)
		xx_hat = xx - epsilon* gam
		xx_dot = P  * xx_hat
		Z_tilde = weight*ZZ* cholinv(ZZ'*weight*ZZ)

		Sigma1 =  xx_dot'* diag(epsilon_2) * weight *xx_dot - xx_hat' * weight*  diag(P_ii)  * diag(epsilon_2) * xx_dot - xx_dot' * weight* diag(P_ii)*diag(epsilon_2) *xx_hat
		
		x_eps = xx_hat :* epsilon
		Sigma2 = J(K,1,1)' *((Z_tilde'*diag(x_eps)*weight* Z_tilde) :* (ZZ'*diag(x_eps)*weight*ZZ)) *J(K,1,1)

		Sigma = Sigma1 + Sigma2
		
		V = Sigma / (H*H)
		*/
		P_2 = P :* P
		P_ii_2 = P_ii :* P_ii
		weight_2 = weight :* weight
		V = (epsilon_2' * weight_2 * P_2 * epsilon_2 - epsilon_2' * weight_2 * diag(P_ii_2)  * epsilon_2) / K
		T = K + ((epsilon' * weight*  P * epsilon - epsilon' * weight*  diag(P_ii) * epsilon) / sqrt(V))
		
		st_numscalar("r(delta)", Re(delta_hat2))
		st_numscalar("r(beta)", Re(beta_hat_2sls))
		st_numscalar("r(T)", Re(T))
		st_numscalar("r(p)", 1-chi2(K-1, Re(T)))
		}

end
