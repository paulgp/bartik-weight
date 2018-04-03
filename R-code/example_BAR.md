example\_BAR.R
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
[`example_BAR.do`](https://github.com/paulgp/bartik-weight/blob/master/code/example_BAR.do),
the `bartik.weight` R package includes three BAR-related datasets.

The main dataset contains variables at the CZ-year level:

``` r
BAR_master
```

    ## # A tibble: 2,166 x 742
    ##    czone year    wage_ch    emp_ch pop1980 t1990_init_male t2000_init_male
    ##    <dbl> <dbl+l>   <dbl>     <dbl>   <dbl>           <dbl>           <dbl>
    ##  1  100. 1980     0.0662  0.0104   2.16e-3             0.              0. 
    ##  2  100. 1990     0.0481  0.0103   2.16e-3            15.4             0. 
    ##  3  100. 2000     0.0249 -0.00339  2.16e-3             0.             15.4
    ##  4  200. 1980     0.0914  0.0204   6.87e-4             0.              0. 
    ##  5  200. 1990     0.0387  0.0364   6.87e-4            15.6             0. 
    ##  6  200. 2000     0.0184  0.00103  6.87e-4             0.             15.6
    ##  7  301. 1980     0.0612  0.0180   2.14e-4             0.              0. 
    ##  8  301. 1990     0.0368  0.000401 2.14e-4            16.3             0. 
    ##  9  301. 2000     0.0234 -0.00573  2.14e-4             0.             16.3
    ## 10  302. 1980     0.0677  0.0159   2.58e-3             0.              0. 
    ## # ... with 2,156 more rows, and 735 more variables:
    ## #   t1990_init_race_white <dbl>, t2000_init_race_white <dbl>,
    ## #   t1990_init_native_born <dbl>, t2000_init_native_born <dbl>,
    ## #   t1990_init_educ_hs <dbl>, t2000_init_educ_hs <dbl>,
    ## #   t1990_init_educ_coll <dbl>, t2000_init_educ_coll <dbl>,
    ## #   t1990_init_veteran <dbl>, t2000_init_veteran <dbl>,
    ## #   t1990_init_nchild <dbl>, t2000_init_nchild <dbl>, t1990 <dbl>,
    ## #   t2000 <dbl>, cz002 <dbl>, cz003 <dbl>, cz004 <dbl>, cz005 <dbl>,
    ## #   cz006 <dbl>, cz007 <dbl>, cz008 <dbl>, cz009 <dbl>, cz010 <dbl>,
    ## #   cz011 <dbl>, cz012 <dbl>, cz013 <dbl>, cz014 <dbl>, cz015 <dbl>,
    ## #   cz016 <dbl>, cz017 <dbl>, cz018 <dbl>, cz019 <dbl>, cz020 <dbl>,
    ## #   cz021 <dbl>, cz022 <dbl>, cz023 <dbl>, cz024 <dbl>, cz025 <dbl>,
    ## #   cz026 <dbl>, cz027 <dbl>, cz028 <dbl>, cz029 <dbl>, cz030 <dbl>,
    ## #   cz031 <dbl>, cz032 <dbl>, cz033 <dbl>, cz034 <dbl>, cz035 <dbl>,
    ## #   cz036 <dbl>, cz037 <dbl>, cz038 <dbl>, cz039 <dbl>, cz040 <dbl>,
    ## #   cz041 <dbl>, cz042 <dbl>, cz043 <dbl>, cz044 <dbl>, cz045 <dbl>,
    ## #   cz046 <dbl>, cz047 <dbl>, cz048 <dbl>, cz049 <dbl>, cz050 <dbl>,
    ## #   cz051 <dbl>, cz052 <dbl>, cz053 <dbl>, cz054 <dbl>, cz055 <dbl>,
    ## #   cz056 <dbl>, cz057 <dbl>, cz058 <dbl>, cz059 <dbl>, cz060 <dbl>,
    ## #   cz061 <dbl>, cz062 <dbl>, cz063 <dbl>, cz064 <dbl>, cz065 <dbl>,
    ## #   cz066 <dbl>, cz067 <dbl>, cz068 <dbl>, cz069 <dbl>, cz070 <dbl>,
    ## #   cz071 <dbl>, cz072 <dbl>, cz073 <dbl>, cz074 <dbl>, cz075 <dbl>,
    ## #   cz076 <dbl>, cz077 <dbl>, cz078 <dbl>, cz079 <dbl>, cz080 <dbl>,
    ## #   cz081 <dbl>, cz082 <dbl>, cz083 <dbl>, cz084 <dbl>, cz085 <dbl>,
    ## #   cz086 <dbl>, cz087 <dbl>, …

The “local” dataset contains local industry shares at the
CZ-year-industry level:

``` r
BAR_local
```

    ## # A tibble: 493,848 x 5
    ##    czone year      ind    sh_ind_ init_sh_ind_
    ##    <dbl> <dbl+lbl> <chr>    <dbl>        <dbl>
    ##  1  100. 1980      0     0.000987     0.000987
    ##  2  100. 1980      10    0.0173       0.0173  
    ##  3  100. 1980      100   0.00276      0.00276 
    ##  4  100. 1980      101   0.00271      0.00271 
    ##  5  100. 1980      102   0.000303     0.000303
    ##  6  100. 1980      11    0.00647      0.00647 
    ##  7  100. 1980      110   0.000812     0.000812
    ##  8  100. 1980      111   0.00309      0.00309 
    ##  9  100. 1980      112   0.000110     0.000110
    ## 10  100. 1980      120   0.00238      0.00238 
    ## # ... with 493,838 more rows

The “global” dataset contains the national industry-year-specific growth
rates

``` r
BAR_global
```

    ## # A tibble: 684 x 3
    ##    year      ind   nat_empl_ind_
    ##    <dbl+lbl> <chr>         <dbl>
    ##  1 1980      0           0.00712
    ##  2 1980      10         -0.00775
    ##  3 1980      100        -0.00156
    ##  4 1980      101        -0.00755
    ##  5 1980      102        -0.0149 
    ##  6 1980      11         -0.0145 
    ##  7 1980      110        -0.0233 
    ##  8 1980      111        -0.00780
    ##  9 1980      112        -0.00952
    ## 10 1980      120        -0.0140 
    ## # ... with 674 more rows

To estimate the Rotemberg weights, it’s necessary to transform the local
tibble from long to wide format:

``` r
BAR_local %>%
    select(-sh_ind_) %>%
    mutate(ind = str_glue("t{year}_init_sh_ind_{ind}")) %>%
    spread(ind, init_sh_ind_, fill = 0) %>%
    print() -> BAR_local2
```

    ## # A tibble: 2,166 x 686
    ##    czone year     t1980_init_sh_ind… t1980_init_sh_ind… t1980_init_sh_ind…
    ##    <dbl> <dbl+lb>              <dbl>              <dbl>              <dbl>
    ##  1  100. 1980               0.000987            0.0173             0.00276
    ##  2  100. 1990               0.                  0.                 0.     
    ##  3  100. 2000               0.                  0.                 0.     
    ##  4  200. 1980               0.00105             0.0198             0.00290
    ##  5  200. 1990               0.                  0.                 0.     
    ##  6  200. 2000               0.                  0.                 0.     
    ##  7  301. 1980               0.000599            0.0130             0.00111
    ##  8  301. 1990               0.                  0.                 0.     
    ##  9  301. 2000               0.                  0.                 0.     
    ## 10  302. 1980               0.00155             0.00828            0.00388
    ## # ... with 2,156 more rows, and 681 more variables:
    ## #   t1980_init_sh_ind_101 <dbl>, t1980_init_sh_ind_102 <dbl>,
    ## #   t1980_init_sh_ind_11 <dbl>, t1980_init_sh_ind_110 <dbl>,
    ## #   t1980_init_sh_ind_111 <dbl>, t1980_init_sh_ind_112 <dbl>,
    ## #   t1980_init_sh_ind_120 <dbl>, t1980_init_sh_ind_121 <dbl>,
    ## #   t1980_init_sh_ind_122 <dbl>, t1980_init_sh_ind_130 <dbl>,
    ## #   t1980_init_sh_ind_132 <dbl>, t1980_init_sh_ind_140 <dbl>,
    ## #   t1980_init_sh_ind_141 <dbl>, t1980_init_sh_ind_142 <dbl>,
    ## #   t1980_init_sh_ind_150 <dbl>, t1980_init_sh_ind_151 <dbl>,
    ## #   t1980_init_sh_ind_152 <dbl>, t1980_init_sh_ind_160 <dbl>,
    ## #   t1980_init_sh_ind_161 <dbl>, t1980_init_sh_ind_162 <dbl>,
    ## #   t1980_init_sh_ind_171 <dbl>, t1980_init_sh_ind_172 <dbl>,
    ## #   t1980_init_sh_ind_180 <dbl>, t1980_init_sh_ind_181 <dbl>,
    ## #   t1980_init_sh_ind_182 <dbl>, t1980_init_sh_ind_190 <dbl>,
    ## #   t1980_init_sh_ind_191 <dbl>, t1980_init_sh_ind_192 <dbl>,
    ## #   t1980_init_sh_ind_20 <dbl>, t1980_init_sh_ind_200 <dbl>,
    ## #   t1980_init_sh_ind_201 <dbl>, t1980_init_sh_ind_210 <dbl>,
    ## #   t1980_init_sh_ind_211 <dbl>, t1980_init_sh_ind_212 <dbl>,
    ## #   t1980_init_sh_ind_220 <dbl>, t1980_init_sh_ind_221 <dbl>,
    ## #   t1980_init_sh_ind_222 <dbl>, t1980_init_sh_ind_230 <dbl>,
    ## #   t1980_init_sh_ind_231 <dbl>, t1980_init_sh_ind_232 <dbl>,
    ## #   t1980_init_sh_ind_241 <dbl>, t1980_init_sh_ind_242 <dbl>,
    ## #   t1980_init_sh_ind_250 <dbl>, t1980_init_sh_ind_251 <dbl>,
    ## #   t1980_init_sh_ind_252 <dbl>, t1980_init_sh_ind_261 <dbl>,
    ## #   t1980_init_sh_ind_262 <dbl>, t1980_init_sh_ind_270 <dbl>,
    ## #   t1980_init_sh_ind_271 <dbl>, t1980_init_sh_ind_272 <dbl>,
    ## #   t1980_init_sh_ind_280 <dbl>, t1980_init_sh_ind_281 <dbl>,
    ## #   t1980_init_sh_ind_282 <dbl>, t1980_init_sh_ind_290 <dbl>,
    ## #   t1980_init_sh_ind_291 <dbl>, t1980_init_sh_ind_292 <dbl>,
    ## #   t1980_init_sh_ind_30 <dbl>, t1980_init_sh_ind_300 <dbl>,
    ## #   t1980_init_sh_ind_301 <dbl>, t1980_init_sh_ind_31 <dbl>,
    ## #   t1980_init_sh_ind_310 <dbl>, t1980_init_sh_ind_311 <dbl>,
    ## #   t1980_init_sh_ind_312 <dbl>, t1980_init_sh_ind_32 <dbl>,
    ## #   t1980_init_sh_ind_320 <dbl>, t1980_init_sh_ind_321 <dbl>,
    ## #   t1980_init_sh_ind_322 <dbl>, t1980_init_sh_ind_331 <dbl>,
    ## #   t1980_init_sh_ind_332 <dbl>, t1980_init_sh_ind_340 <dbl>,
    ## #   t1980_init_sh_ind_341 <dbl>, t1980_init_sh_ind_342 <dbl>,
    ## #   t1980_init_sh_ind_350 <dbl>, t1980_init_sh_ind_351 <dbl>,
    ## #   t1980_init_sh_ind_352 <dbl>, t1980_init_sh_ind_360 <dbl>,
    ## #   t1980_init_sh_ind_361 <dbl>, t1980_init_sh_ind_362 <dbl>,
    ## #   t1980_init_sh_ind_370 <dbl>, t1980_init_sh_ind_371 <dbl>,
    ## #   t1980_init_sh_ind_372 <dbl>, t1980_init_sh_ind_380 <dbl>,
    ## #   t1980_init_sh_ind_381 <dbl>, t1980_init_sh_ind_390 <dbl>,
    ## #   t1980_init_sh_ind_391 <dbl>, t1980_init_sh_ind_392 <dbl>,
    ## #   t1980_init_sh_ind_40 <dbl>, t1980_init_sh_ind_400 <dbl>,
    ## #   t1980_init_sh_ind_401 <dbl>, t1980_init_sh_ind_402 <dbl>,
    ## #   t1980_init_sh_ind_41 <dbl>, t1980_init_sh_ind_410 <dbl>,
    ## #   t1980_init_sh_ind_411 <dbl>, t1980_init_sh_ind_412 <dbl>,
    ## #   t1980_init_sh_ind_42 <dbl>, t1980_init_sh_ind_420 <dbl>,
    ## #   t1980_init_sh_ind_421 <dbl>, t1980_init_sh_ind_422 <dbl>,
    ## #   t1980_init_sh_ind_432 <dbl>, t1980_init_sh_ind_440 <dbl>, …

Once all the data are in proper format, the `bw()` function will return
the weight, and the just-identified IV estimates:

``` r
# Prepare variables in the master tibble
index = c("czone", "year")
y = "wage_ch"
x = "emp_ch"
weight = "pop1980"
controls = setdiff(names(BAR_master), c(index, y, x, weight))

# Prepare variables in the local tibble
Z = setdiff(names(BAR_local2), c(index))

# Prepare variables in the global tibble
G = "nat_empl_ind_"

# Estimate the weight (alpha) and the IV estimates (beta)
bw = bw(BAR_master, y, x, controls, weight, BAR_local2, Z, BAR_global, G)
bw
```

    ## # A tibble: 684 x 5
    ##    year      ind   nat_empl_ind_      alpha   beta
    ##    <dbl+lbl> <chr>         <dbl>      <dbl>  <dbl>
    ##  1 1980      0           0.00712  0.0344     0.735
    ##  2 1980      10         -0.00775 -0.00350   -1.22 
    ##  3 1980      100        -0.00156  0.000166   0.590
    ##  4 1980      101        -0.00755 -0.000595   0.979
    ##  5 1980      102        -0.0149  -0.00283    0.923
    ##  6 1980      11         -0.0145   0.00397    1.86 
    ##  7 1980      110        -0.0233   0.00264    1.26 
    ##  8 1980      111        -0.00780  0.000569  -1.04 
    ##  9 1980      112        -0.00952  0.000255  -2.12 
    ## 10 1980      120        -0.0140   0.0000408  9.49 
    ## # ... with 674 more rows

The following table replicates parts of Panel D of Table 2 in
[Goldsmith-Pinkham, Sorkin and Swift
(2018)](http://paulgp.github.io/papers/bartik_gpss.pdf):

``` r
bw %>%
    top_n(5, alpha) %>%
    arrange(desc(alpha)) %>%
    mutate(ind = case_when(
        ind == "42"  ~ "Oil + Gas Extraction",
        ind == "0"   ~ "Other",
        ind == "351" ~ "Motor Vehicles",
        ind == "362" ~ "Guided Missiles",
        ind == "351" ~ "Motor Vehicles"
    )) %>%
    rename(g = nat_empl_ind_) %>%
    knitr::kable(digits = 3, caption = "Top five Rotemberg weight industries")
```

| year | ind                  |       g | alpha |  beta |
| ---: | :------------------- | ------: | ----: | ----: |
| 2000 | Oil + Gas Extraction |   0.080 | 0.156 | 1.169 |
| 1990 | Other                | \-0.033 | 0.098 | 0.752 |
| 2000 | Motor Vehicles       | \-0.030 | 0.092 | 1.351 |
| 1980 | Guided Missiles      |   0.101 | 0.081 | 0.174 |
| 1990 | Motor Vehicles       |   0.031 | 0.077 | 1.606 |

Top five Rotemberg weight industries
