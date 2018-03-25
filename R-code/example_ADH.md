example\_ADH.R
================

``` r
library(tidyverse)
```

    ## ── Attaching packages ───────────────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 2.2.1.9000     ✔ purrr   0.2.4     
    ## ✔ tibble  1.4.2          ✔ dplyr   0.7.4     
    ## ✔ tidyr   0.8.0          ✔ stringr 1.3.0     
    ## ✔ readr   1.1.1.9000     ✔ forcats 0.3.0

    ## ── Conflicts ──────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ✖ dplyr::vars()   masks ggplot2::vars()

``` r
library(bartik.weight)
```

To replicate the Stata example
[`example_ADH.do`](https://github.com/paulgp/bartik-weight/blob/master/code/example_ADH.do),
the `bartik.weight` R package includes three ADH-related datasets.

The main dataset contains variables at the CZ-year level:

``` r
ADH_master
```

    ## # A tibble: 1,444 x 20
    ##    czone  year d_sh_empl_mfg d_tradeusch_pw timepwt48 reg_midatl reg_encen
    ##    <dbl> <dbl>         <dbl>          <dbl>     <dbl>      <dbl>     <dbl>
    ##  1  100. 1990.        -3.81            5.29  0.00211          0.        0.
    ##  2  100. 2000.        -4.62            6.62  0.00207          0.        0.
    ##  3  200. 1990.        -0.681           3.03  0.000732         0.        0.
    ##  4  200. 2000.        -6.97           10.3   0.000815         0.        0.
    ##  5  301. 1990.        -2.17            2.06  0.000261         0.        0.
    ##  6  301. 2000.        -3.78            6.20  0.000240         0.        0.
    ##  7  302. 1990.        -2.83            1.08  0.00257          0.        0.
    ##  8  302. 2000.        -3.95            3.11  0.00260          0.        0.
    ##  9  401. 1990.        -5.04            1.02  0.00171          0.        0.
    ## 10  401. 2000.        -4.96            2.99  0.00176          0.        0.
    ## # ... with 1,434 more rows, and 13 more variables: reg_wncen <dbl>,
    ## #   reg_satl <dbl>, reg_escen <dbl>, reg_wscen <dbl>, reg_mount <dbl>,
    ## #   reg_pacif <dbl>, l_sh_popedu_c <dbl>, l_sh_popfborn <dbl>,
    ## #   l_sh_empl_f <dbl>, l_sh_routine33 <dbl>, l_task_outsource <dbl>,
    ## #   t2 <dbl>, l_shind_manuf_cbp <dbl>

The “local” dataset contains local industry shares at the
CZ-year-industry level:

``` r
ADH_local
```

    ## # A tibble: 563,160 x 4
    ##    czone  year ind    sh_ind_
    ##    <dbl> <dbl> <chr>    <dbl>
    ##  1  100. 1990. 2011  0.0101  
    ##  2  100. 1990. 2015  0.      
    ##  3  100. 1990. 2022  0.000433
    ##  4  100. 1990. 2023  0.00209 
    ##  5  100. 1990. 2024  0.000991
    ##  6  100. 1990. 2026  0.00401 
    ##  7  100. 1990. 2032  0.      
    ##  8  100. 1990. 2033  0.000499
    ##  9  100. 1990. 2034  0.      
    ## 10  100. 1990. 2035  0.000340
    ## # ... with 563,150 more rows

The “global” dataset contains the industry-year-specific growth of
imports

``` r
ADH_global
```

    ## # A tibble: 780 x 3
    ##     year ind     trade_
    ##    <dbl> <chr>    <dbl>
    ##  1 1990. 2011   1.21   
    ##  2 1990. 2015   7.46   
    ##  3 1990. 2022   0.00698
    ##  4 1990. 2023   3.16   
    ##  5 1990. 2024   0.     
    ##  6 1990. 2026   0.0333 
    ##  7 1990. 2032   0.176  
    ##  8 1990. 2033   3.78   
    ##  9 1990. 2034  12.2    
    ## 10 1990. 2035   5.11   
    ## # ... with 770 more rows

To estimate the Rotemberg weights, it’s necessary to transform the local
tibble from long to wide format:

``` r
ADH_local %>%
    mutate(ind = str_glue("t{year}_sh_ind_{ind}")) %>%
    spread(ind, sh_ind_, fill = 0) %>%
    print() -> ADH_local2
```

    ## # A tibble: 1,444 x 782
    ##    czone  year t1990_sh_ind_2011 t1990_sh_ind_2015 t1990_sh_ind_2022
    ##    <dbl> <dbl>             <dbl>             <dbl>             <dbl>
    ##  1  100. 1990.          0.0101             0.               0.000433
    ##  2  100. 2000.          0.                 0.               0.      
    ##  3  200. 1990.          0.00165            0.00714          0.      
    ##  4  200. 2000.          0.                 0.               0.      
    ##  5  301. 1990.          0.000581           0.               0.      
    ##  6  301. 2000.          0.                 0.               0.      
    ##  7  302. 1990.          0.0215             0.00341          0.      
    ##  8  302. 2000.          0.                 0.               0.      
    ##  9  401. 1990.          0.000242           0.00274          0.      
    ## 10  401. 2000.          0.                 0.               0.      
    ## # ... with 1,434 more rows, and 777 more variables:
    ## #   t1990_sh_ind_2023 <dbl>, t1990_sh_ind_2024 <dbl>,
    ## #   t1990_sh_ind_2026 <dbl>, t1990_sh_ind_2032 <dbl>,
    ## #   t1990_sh_ind_2033 <dbl>, t1990_sh_ind_2034 <dbl>,
    ## #   t1990_sh_ind_2035 <dbl>, t1990_sh_ind_2037 <dbl>,
    ## #   t1990_sh_ind_2041 <dbl>, t1990_sh_ind_2043 <dbl>,
    ## #   t1990_sh_ind_2044 <dbl>, t1990_sh_ind_2045 <dbl>,
    ## #   t1990_sh_ind_2046 <dbl>, t1990_sh_ind_2047 <dbl>,
    ## #   t1990_sh_ind_2048 <dbl>, t1990_sh_ind_2051 <dbl>,
    ## #   t1990_sh_ind_2062 <dbl>, t1990_sh_ind_2064 <dbl>,
    ## #   t1990_sh_ind_2066 <dbl>, t1990_sh_ind_2067 <dbl>,
    ## #   t1990_sh_ind_2068 <dbl>, t1990_sh_ind_2074 <dbl>,
    ## #   t1990_sh_ind_2075 <dbl>, t1990_sh_ind_2076 <dbl>,
    ## #   t1990_sh_ind_2077 <dbl>, t1990_sh_ind_2079 <dbl>,
    ## #   t1990_sh_ind_2082 <dbl>, t1990_sh_ind_2083 <dbl>,
    ## #   t1990_sh_ind_2084 <dbl>, t1990_sh_ind_2085 <dbl>,
    ## #   t1990_sh_ind_2086 <dbl>, t1990_sh_ind_2087 <dbl>,
    ## #   t1990_sh_ind_2091 <dbl>, t1990_sh_ind_2095 <dbl>,
    ## #   t1990_sh_ind_2096 <dbl>, t1990_sh_ind_2097 <dbl>,
    ## #   t1990_sh_ind_2098 <dbl>, t1990_sh_ind_2099 <dbl>,
    ## #   t1990_sh_ind_2111 <dbl>, t1990_sh_ind_2131 <dbl>,
    ## #   t1990_sh_ind_2211 <dbl>, t1990_sh_ind_2221 <dbl>,
    ## #   t1990_sh_ind_2231 <dbl>, t1990_sh_ind_2241 <dbl>,
    ## #   t1990_sh_ind_2252 <dbl>, t1990_sh_ind_2253 <dbl>,
    ## #   t1990_sh_ind_2257 <dbl>, t1990_sh_ind_2258 <dbl>,
    ## #   t1990_sh_ind_2273 <dbl>, t1990_sh_ind_2281 <dbl>,
    ## #   t1990_sh_ind_2284 <dbl>, t1990_sh_ind_2295 <dbl>,
    ## #   t1990_sh_ind_2296 <dbl>, t1990_sh_ind_2297 <dbl>,
    ## #   t1990_sh_ind_2298 <dbl>, t1990_sh_ind_2299 <dbl>,
    ## #   t1990_sh_ind_2311 <dbl>, t1990_sh_ind_2321 <dbl>,
    ## #   t1990_sh_ind_2322 <dbl>, t1990_sh_ind_2323 <dbl>,
    ## #   t1990_sh_ind_2325 <dbl>, t1990_sh_ind_2329 <dbl>,
    ## #   t1990_sh_ind_2331 <dbl>, t1990_sh_ind_2335 <dbl>,
    ## #   t1990_sh_ind_2337 <dbl>, t1990_sh_ind_2339 <dbl>,
    ## #   t1990_sh_ind_2341 <dbl>, t1990_sh_ind_2342 <dbl>,
    ## #   t1990_sh_ind_2353 <dbl>, t1990_sh_ind_2369 <dbl>,
    ## #   t1990_sh_ind_2371 <dbl>, t1990_sh_ind_2381 <dbl>,
    ## #   t1990_sh_ind_2384 <dbl>, t1990_sh_ind_2385 <dbl>,
    ## #   t1990_sh_ind_2386 <dbl>, t1990_sh_ind_2389 <dbl>,
    ## #   t1990_sh_ind_2391 <dbl>, t1990_sh_ind_2392 <dbl>,
    ## #   t1990_sh_ind_2393 <dbl>, t1990_sh_ind_2394 <dbl>,
    ## #   t1990_sh_ind_2395 <dbl>, t1990_sh_ind_2396 <dbl>,
    ## #   t1990_sh_ind_2399 <dbl>, t1990_sh_ind_2411 <dbl>,
    ## #   t1990_sh_ind_2421 <dbl>, t1990_sh_ind_2426 <dbl>,
    ## #   t1990_sh_ind_2429 <dbl>, t1990_sh_ind_2431 <dbl>,
    ## #   t1990_sh_ind_2434 <dbl>, t1990_sh_ind_2435 <dbl>,
    ## #   t1990_sh_ind_2436 <dbl>, t1990_sh_ind_2439 <dbl>,
    ## #   t1990_sh_ind_2448 <dbl>, t1990_sh_ind_2449 <dbl>,
    ## #   t1990_sh_ind_2451 <dbl>, t1990_sh_ind_2452 <dbl>,
    ## #   t1990_sh_ind_2491 <dbl>, t1990_sh_ind_2493 <dbl>,
    ## #   t1990_sh_ind_2499 <dbl>, t1990_sh_ind_2514 <dbl>, …

Once all the data are in proper format, the `bw()` function will return
the weight, and the just-identified IV estimates:

``` r
# Prepare variables in the master tibble
y = "d_sh_empl_mfg"
x = "d_tradeusch_pw"
controls = c("reg_midatl", "reg_encen", "reg_wncen", "reg_satl",
             "reg_escen", "reg_wscen", "reg_mount", "reg_pacif", "l_sh_popedu_c",
             "l_sh_popfborn", "l_sh_empl_f", "l_sh_routine33", "l_task_outsource",
             "t2", "l_shind_manuf_cbp")
weight = "timepwt48"

# Prepare variables in the local tibble
Z = setdiff(names(ADH_local_wide), c("czone", "year"))

# Prepare variables in the global tibble
G = "trade_"

# Estimate the weight (alpha) and the IV estimates (beta)
bw = bw(ADH_master, y, x, controls, weight, ADH_local2, Z, ADH_global, G)
bw
```

    ## # A tibble: 780 x 5
    ##     year ind     trade_        alpha     beta
    ##    <dbl> <chr>    <dbl>        <dbl>    <dbl>
    ##  1 1990. 2011   1.21    -0.00102      -2.80  
    ##  2 1990. 2015   7.46    -0.0104       -1.06  
    ##  3 1990. 2022   0.00698  0.000000663   7.74  
    ##  4 1990. 2023   3.16     0.0000676     8.82  
    ##  5 1990. 2024   0.       0.            3.93  
    ##  6 1990. 2026   0.0333   0.0000218    -0.0432
    ##  7 1990. 2032   0.176    0.00000474   13.6   
    ##  8 1990. 2033   3.78     0.0000286    29.0   
    ##  9 1990. 2034  12.2     -0.00188       0.923 
    ## 10 1990. 2035   5.11    -0.000357      1.59  
    ## # ... with 770 more rows

The following table replicates parts of Panel D of Table 5 in
[Goldsmith-Pinkham, Sorkin and Swift
(2018)](http://paulgp.github.io/papers/bartik_gpss.pdf):

``` r
bw %>%
    top_n(5, alpha) %>%
    arrange(desc(alpha)) %>%
    mutate(ind = case_when(
        ind == "3571" ~ "Electronic Computers",
        ind == "3944" ~ "Games and Toys",
        ind == "3651" ~ "Household Audio and Video",
        ind == "3661" ~ "Telephone Apparatus",
        ind == "3577" ~ "Computer Equipment"
    )) %>%
    rename(g = trade_) %>%
    knitr::kable(digits = 3, caption = "Top five Rotemberg weight industries")
```

| year | ind                       |       g | alpha |    beta |
| ---: | :------------------------ | ------: | ----: | ------: |
| 2000 | Electronic Computers      | 189.117 | 0.140 | \-0.620 |
| 2000 | Games and Toys            | 320.636 | 0.098 | \-0.179 |
| 2000 | Household Audio and Video | 218.216 | 0.055 | \-0.147 |
| 2000 | Telephone Apparatus       |  94.577 | 0.051 | \-0.308 |
| 2000 | Computer Equipment        |  41.678 | 0.047 | \-0.232 |

Top five Rotemberg weight industries
