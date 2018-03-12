

{smcl}
{* *! version 1.0.0  March 12, 2018 @ 18:56:24}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Details" "examplehelpfile##details"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
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

{pstd}
{cmd:bartik_weight} calculates the Rotemberg weights over the instruments specified in the {varlist} of {it:z(varlist)} using the weights defined by {it:weightstub(varlist)}. To work correctly, the data needs to be stored in a {it: wide} fashion, with a variable list of instruments and growth rates that make up the underlying Bartik instrument.

The program returns a matrix of 


{marker details}{...}
{title:Details}

{dlgtab:Main}

{phang}
{opt detail} displays detailed output of the calculation.

{phang}
{opt meanonly} restricts the calculation to be based on only the means.  The
default is to use a trimmed mean.

{phang}
{opt format} requests that the summary statistics be displayed using
the display formats associated with the variables, rather than the default
{cmd:g} display format; see
{findalias frformats}.

{phang}
{opt separator(#)} specifies how often to insert separation lines
into the output.  The default is {cmd:separator(5)}, meaning that a
line is drawn after every 5 variables.  {cmd:separator(10)} would draw a line
after every 10 variables.  {cmd:separator(0)} suppresses the separation line.

{phang}
{opth generate(newvar)} creates {it:newvar} containing the whatever
values.


{marker remarks}{...}
{title:Remarks}

{pstd}
For detailed information on the whatever statistic, see {bf:[R] intro}.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. whatever mpg weight}{p_end}

{phang}{cmd:. whatever mpg weight, meanonly}{p_end}
