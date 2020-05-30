
<!-- README.md is generated from README.Rmd. Please edit that file -->
voweltrajectories
=================

<!-- badges: start -->
<!-- badges: end -->
The goal of voweltrajectories is to simplify the process of analyzing change in vowel trajectories over time. Typical linear regressions use point measurements, usually vowel midpoints, which miss variation that may occur at the onset or offset. Generallized additive mixed models (GAMMs) and smoothing spline ANOVA (SSANOVA) improve on this by allowing analysis of formant trajectories, but must analyze each formant separately. This package implements the methods used in Brickhouse (2019) to analyze diachronic convergence of multiple formants simultaneously using the discrete cosine transform (DCT) as implemented in the `dtt` package.

Installation
------------

The package is not yet available on CRAN. When it has been accepted, you can install the released version of voweltrajectories from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("voweltrajectories")
```

Example
-------

To us the package, we first want to create some vowel data. The data created by the functions below follow a cubic function with random jitter. IF you have your own data to work with, you can skip this step.

``` r
## Create arbitrary data
formants <- function(x,o=5,g=0.01,h=-6,b=500,m=0,sd=3) {
  y = g*(x-o)**3 + h*(x-o) + b + rnorm(1,m,sd)
  return(y)
}
### Vowel One
f1.v1 = data.frame(replicate(10,sapply(1:10,formants)))
f2.v1 = data.frame(replicate(10,sapply(1:10,formants,g=-0.1,b=700,sd=5)))
### Vowel Two
f1.v2 = data.frame(replicate(10,sapply(1:10,formants,h=-5)))
f2.v2 = data.frame(replicate(10,sapply(1:10,formants,g=0.1,b=700,sd=7)))

v1 = data.frame(
  f1=as.numeric(unlist(f1.v1)),
  f2=as.numeric(unlist(f2.v1)),
  vowel="a",
  index=as.numeric(replicate(10,1:10)))
v2 = data.frame(
  f1=as.numeric(unlist(f1.v2)),
  f2=as.numeric(unlist(f2.v2)),
  vowel="b",
  index=as.numeric(replicate(10,1:10)))
vowels=rbind(v1,v2)
```

Next we determine the elbow point of the graph. This is the number of coefficients to use for the model and is determined by finding the point where adding another coefficient doesn't significantly improve the model fit.

``` r
library(voweltrajectories)
#> Loading required package: dtt
## Determine the number of DCT coefficients to use for each formant
f1.n = getelbow(getprederr(rbind(f1.v1,f1.v2)))
         # We want the optimal number of coefficients for both vowels
         # so we combine both vowels' F1s for the elbow analysis
         # using rbind(). The same for F2 below.
f2.n = getelbow(getprederr(rbind(f2.v1,f2.v2)))

# Since the data is random, we'll pretend that
#  the values are 3 and 4 respectively
f1.n = 3
f2.n = 4
```

Using the ideal number found from the previous step, we uae `getdct()` to compute the coefficients.

``` r
## Get the DCT coefficient sets
f1.v1.dct = getdct(f1.v1,f1.n)
f2.v1.dct = getdct(f2.v1,f2.n)
f1.v2.dct = getdct(f1.v2,f1.n)
f2.v2.dct = getdct(f2.v2,f2.n)
```

Before computing the distance, the coefficient sets for F1 and F2 models need to be combined into one data frame. A methodological choice must be made here as to whether the first coefficient should be included. That coefficient is proportional to the mean of the trajectory, and so it is redundant if the mean values are being analyzed separately. By excluding it, the distance will measure who similar the trajectory shapes are, regardless of upward or downward shift. Including the first parameter causes the distance measurement to take into account the vertical displacement at the expense of reduced statistical power. In this example, we exclude the first parameter.

``` r
## Make ordered sets of coefficients
v1.sets = cbind(f1.v1.dct[,2:f1.n],f2.v1.dct[,2:f2.n])
v2.sets = cbind(f1.v2.dct[,2:f1.n],f2.v2.dct[,2:f2.n])
```

Finally, use `dctdistance()` to get the distance between the two vowel trajectories. The values are unitless, but as distance measurements they can be interpreted in the same way as distance in physical space. Higher values mean that the F1 *and* F2 trajectories of the two vowels are farther apart, while lower values mean they are closer. A value of 0 means that the F1 and F2 trajectories of the first vowel are identical to the respective F1 and F2 values of the second vowel.

``` r
## Compute the distance between sets
summary(dctdistance(v1.sets,v2.sets))
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>   16.89   21.06   24.15   27.50   28.26   52.68
```

References
==========

Brickhouse, Christian (11 October 2019) "Diachronic change in formant dynamics of California low back vowels: an improved analysis method using the Discrete Cosine Transform", poster presented at *New Ways of Anaylzing Variation 48*. Eugene, Oregon.
