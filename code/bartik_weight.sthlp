

{smcl}
{* *! version 1.0.0  March 13, 2018 @ 15:42:12}{...}
{viewerjumpto "Syntax" "bartk_weight##syntax"}{...}
{viewerjumpto "Description" "bartik_weight##description"}{...}
{viewerjumpto "Details" "bartik_weight##details"}{...}
{viewerjumpto "Remarks" "bartik_weight##remarks"}{...}
{viewerjumpto "Examples" "bartik_weight##examples"}{...}
{viewerjumpto "Stored Results" "bartik_weight##stored_results"}{...}
{title:Title}

{phang}
{bf:bartik_weight} {hline 2} Calculate Rotemberg Weights from Goldsmith-Pinkham, Sorkin and Swift (2018)


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:bartik_weight}
{cmd:, y({varname}) x({varname}) z({varlist}) weightstub({varlist})} [{it:options}]

{synoptset 20 tabbed}{...}
{synoptline}
{syntab:Main}
{synopt:{opt y(varname)}}outcome variable{p_end}
{synopt:{opt x(varname)}}endogeous variable{p_end}
{synopt:{opt z(varlist)}}variable list of instruments {p_end}
{synopt:{opt weightstub(varlist)}}variable list of weights {p_end}
{syntab:Options}
{synopt:{opt controls(varlist)}}list of control variables{p_end}
{synopt:{opt absorb(varname)}}fixed effect to absorb{p_end}
{synopt:{opt weight_var(varname)}}name of analytic weight variable for regression{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd} {cmd:bartik_weight} calculates the Rotemberg weights over the
instruments specified in the {varlist} of {it:z(varlist)} using the
weights defined by {it:weightstub()}. The data needs to be stored in a
{it: wide} fashion, with a {it:varlist} of instruments and growth
rates that make up the underlying Bartik instrument.

{pstd} For more details, see the {help bartik_weight##remarks:remarks}
and Goldsmith-Pinkham, Sorkin and Swift (2018).




{marker details}{...}
{title:Details}

{dlgtab:Main}

{phang}{opt y(varname)} specifies the outcome variable in the structural equation. {opt y()} is required.

{phang}{opt x(varname)} specifies the endogeneous variable in the structural equation. {opt x()} is required. 

{phang}{opt z(varlist)} specifies the {it:varlist} instruments used to
make up the Bartik instrument. See Goldsmith-Pinkham, Sorkin and Swift
(2018) for a full description. {opt z()} is required.

{phang}{opt weightstub(varlist)} specifies the {it:varlist} weights
used to make up the weight matrix for the Rotemberg weights. These
weights will be collapsed to constract a single matrix. See
Goldsmith-Pinkham, Sorkin and Swift (2018) for a full
description. {opt weightstub()} is required.

{phang}
{opt generate(newvar)} creates {it:newvar} containing the whatever
values.


{dlgtab:Options}

{phang} {opt controls(varlist)} is the list of variables used as
controls in the main regression. In cases with a variable that
generates a lot of fixed effects (such as a location F.E.), the {opt absorb(varname)}
option can be used, and the program will construct
temporary variables to run the regression.

{phang} {opt absorb(varname)} specifies the categorical variable,
which is to be included in the regression as if it were specified by
dummy variables.

{phang}{opt weight_var(varname)} specifies the weight variable used to
weight the regression. In a standard regression, the {it:varname}
would be the variable used in {cmd:[aweight=varname]}.


{marker remarks}{...}
{title:Remarks}

{pstd} This program estimates the Rotemberg weights outlined in
Goldsmith-Pinkham, Sorkin and Swift (2018). Each weight returned in
{cmd:r(alpha)} corresponds to the misspecification elasticity for each
individual instrument, when using the Bartik instrument defined by the
weights in {opt weightstub()}.

{pstd} The key errors or issues that can come up are that the
instruments or controls are collinear. For two example of do-files
implementing this process, see {it:example_BAR.do} and {it:example_ADH.do} which
implement the program using real data. 

{pstd}
For detailed information on the Rotemberg weights statistic, see Goldsmith-Pinkham, Sorkin and Swift (2018).


{marker examples}{...}
{title:Examples}

{phang}Three simple examples: 
{phang2}{cmd:. bartik_weight, z(ind_sh_*)  weightstub(growth_*) x(emp_ch) y(wage_ch) {p_end}}

{phang2}{cmd:. bartik_weight, z(t*_init_sh_ind_*)    weightstub(nat_empl_ind_*) x(emp_ch) y(wage_ch)  controls(`controls') weight_var(pop1980)  absorb(czone)}{p_end}

{phang2}{cmd:. bartik_weight, z(t*_sh_ind_*)  weightstub(trade_*) x(d_tradeusch_pw) y(d_sh_empl_mfg)  controls(`controls') weight_var(timepwt48)}{p_end}

{phang}  For code to convert returned matrices into a dataset, see example_ADH.do or example_BAR.do.

{marker stored_results}{...}
{title:Stored results}

{pstd}

{cmd:bartik_weight} stores the following in {cmd:r()}:

{synoptset 24 tabbed}{...}
{p2col 5 24 28 2: Matrices}{p_end}
{synopt:{cmd:r(alpha)}}Rotemberg weight vector{p_end}
{synopt:{cmd:r(beta)}}just-identified coefficient vector{p_end}
{synopt:{cmd:r(G)}}growth weight vector{p_end}
{p2colreset}{...}

