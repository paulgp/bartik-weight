# Rotemberg Weight Package

This program estimates the Rotemberg weights outlined in
[Goldsmith-Pinkham, Sorkin and Swift (2018)](http://paulgp.github.io/papers/bartik_gpss.pdf). Each weight returned
corresponds to the misspecification elasticity for each individual
instrument when using the Bartik instrument defined by the
weights. Currently, this package is only available for Stata, but if
you are interested in implementing it for R, please do and let me
merge it into this repo!

## Installation

To install the Stata package, clone or download this repo, and then
copy `bartik_weight.ado` and `bartik_weight.sthlp` to your personal
ado folder. You can find this folder using the `sysdir` command.

## Example
In the code folder, I provide two examples of datasets whose datasets
are prepped to run through the `bartik_weight` function:
`example_ADH.do` and `example_BAR.do`

### Example 1: Canonical Bartik - `example_BAR.do`

There are N commuting zones with T time periods in this example, with
K industries. Hence, following Goldsmith-Pinkham, Sorkin and Swift
(2018), there are NT observations and KT instruments, where the
industries are defined in the initial period (1980), interacted with a
time fixed effect for 1980, 1990, and 2000. For this implementation,
the controls are also taken in the inital period, and interacted with
time fixed effects. Since we control for a commuting zone fixed
effect, we exclude one time period of the controls, since it is not
seperately identified.

For each of the KT instruments, `bartik_weight.ado` constructs a
Rotemberg weight. This weight corresponds to the misspecification
sensitivity for that industry-period pair. 

### Example 2: China Shock - `example_ADH.do`

There are N commuting zones with T time periods in this example, with
K industries. Hence, following Goldsmith-Pinkham, Sorkin and Swift
(2018), there are NT observations and KT instruments, interacted with
a time fixed effect for 1990, and 2000. In this example, industry
shares are defined using the lagged (previous decade) industry share
for a commuting zone. 

For each of the KT instruments, `bartik_weight.ado` constructs a
Rotemberg weight. This weight corresponds to the misspecification
sensisitivty for that industry-period pair. 

## How to construct a dataset from the `bartik_weight` output

The final output from the Stata packages is returned in three Stata
matrices. I provide examples on how to convert these outputs into
readable and labelled data in both examples above, and repeat the code
here:

```
bartik_weight, z(t*_`ind_stub'*)    weightstub(`growth_stub'*) x(`x') \\\
	y(`y')  controls(`controls') weight_var(`weight')
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
```

## Author

* Paul Goldsmith-Pinkham -- Contact me at @paulgp or paulgp [at] gmail [dot] com

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

