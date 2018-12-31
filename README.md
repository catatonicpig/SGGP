
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SGGP

[![Travis-CI Build
Status](https://travis-ci.org/CollinErickson/SGGP.svg?branch=master)](https://travis-ci.org/CollinErickson/SGGP)
[![Coverage
Status](https://img.shields.io/codecov/c/github/CollinErickson/SGGP/master.svg)](https://codecov.io/github/CollinErickson/SGGP?branch=master)

The goal of SGGP is to provide a sequential design of experiment
algorithm that can efficiently use many points and interpolate exactly.

## Installation

You can install SGGP from github with:

``` r
# install.packages("devtools")
devtools::install_github("CollinErickson/SGGP")
```

## Example

To create a SGGP object:

``` r
## basic example code
library(SGGP)
d <- 8
SG <- SGGPcreate(d=d,201)
print(SG)
#> SGGP object
#>    d = 8
#>    number of design points = 201
#>    number of unevaluated design points = 201
#>    Available functions:
#>      - SGGPfit(SGGP, Y) to update parameters with new data
#>      - sGGPpred(Xp, SGGP) to predict at new points
#>      - SGGPappend(SGGP, batchsize) to add new design points
```

A new `SGGP` object has design points that should be evaluated next,
either from `SG$design` or `SG$design_unevaluated`.

``` r
f <- function(x) {x[1]^2 + (0.5-x[2])^3 + sin(x[3])}
Y <- apply(SG$design, 1, f)
```

Once you have evaluated the design points, you can fit the object with
`SGGPfit`.

``` r
SG <- SGGPfit(SG, Y)
SG
#> SGGP object
#>    d = 8
#>    number of design points = 201
#>    number of unevaluated design points = 0
#>    Available functions:
#>      - SGGPfit(SGGP, Y) to update parameters with new data
#>      - sGGPpred(Xp, SGGP) to predict at new points
#>      - SGGPappend(SGGP, batchsize) to add new design points
```
