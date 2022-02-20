# Rotemberg Weight Package

This program estimates the Rotemberg weights outlined in
[Goldsmith-Pinkham, Sorkin and Swift (2019)](http://paulgp.github.io/papers/bartik_gpss.pdf). Each weight returned
corresponds to the misspecification elasticity for each individual
instrument when using the Bartik instrument defined by the
weights. The discussion below pertains to the Stata implementation -- see the R-code subdirectory for an R implementation. 

_Warning:_ The R implementation is currently slightly out of date. 

## Installation

Running

```{stata}
net install bartik_weight, from(https://raw.githubusercontent.com/paulgp/bartik-weight/master/code/)
```

will add the package  to your personal
ado folder. You can find this folder using the `sysdir` command.

## Example

In the code folder, we provide four example do-files that use the
`bartik_weight` function: `make_rotemberg_summary_ADH.do`,
`make_rotemberg_summary_BAR.do`,
`make_rotemberg_summary_CARD_college.do` and
`make_rotemberg_summary_CARD_hs.do`. We are only able to provide the
data for `make_rotemberg_summary_ADH.do` directly here, as the others
use data from IPUMS, which prohbits the posting of a full dataset. These files (and others) are available along with a discussion of the full replication here: <https://github.com/paulgp/gpss_replication>

### Example 1: China Shock - `make_rotemberg_summary_ADH.do`

There are L commuting zones with T time periods in this example, with
K industries. Hence, following Goldsmith-Pinkham, Sorkin and Swift
(2019), there are LT observations and KT instruments, interacted with
a time fixed effect for 1990, and 2000. In this example, industry
shares are defined using the lagged (previous decade) industry share
for a commuting zone. 

For each of the KT instruments, `bartik_weight.ado` constructs a
Rotemberg weight. This weight corresponds to the misspecification
sensisitivty for that industry-period pair. 

### Example 2: Canonical Bartik - `make_rotemberg_summary_BAR.do`

There are L commuting zones with T time periods in this example, with
K industries. Hence, following Goldsmith-Pinkham, Sorkin and Swift
(2019), there are LT observations and KT instruments, where the
industries are defined in the initial period (1980), interacted with a
time fixed effect for 1980, 1990, and 2000. For this implementation,
the controls are also taken in the inital period, and interacted with
time fixed effects. Since we control for a commuting zone fixed
effect, we exclude one time period of the controls, since it is not
seperately identified.

For each of the KT instruments, `bartik_weight.ado` constructs a
Rotemberg weight. This weight corresponds to the misspecification
sensitivity for that industry-period pair. 

### Example 3: Immigrant Enclave - `make_rotemberg_summary_CARD_hs.do` and `make_rotemberg_summary_CARD_college.do`
There are L commuting zones in this example, with K origin
countries. Hence, following Goldsmith-Pinkham, Sorkin and Swift
(2019), there are L observations and K instruments, where the origin
country shares are defined in 1980. The growth rates are the number of
people arriving in the US from country k. This is done seperately for
high-school level education and college-level education.

For each of the K instruments, `bartik_weight.ado` constructs a
Rotemberg weight. This weight corresponds to the misspecification
sensitivity for that origin-country. 


## How to construct a dataset from the `bartik_weight` output

The final output from the Stata packages is returned in three Stata
matrices. I provide examples on how to convert these outputs into
readable and labelled data in both examples above, and repeat the code
here:

```
bartik_weight, z(t*_`ind_stub'*)    weightstub(t*_`growth_stub'*) x(`x') y(`y') \\\
    controls(`controls'  ) weight_var(`weight')
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
```

## Author

* Paul Goldsmith-Pinkham -- Contact me at @paulgp or paulgp [at] gmail [dot] com

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

