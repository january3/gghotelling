# Calculate the T2 statistic for individual points

Calculate the T2 statistic or Mahalanobis distance for individual points

## Usage

``` r
outliers(
  x,
  level = 0.95,
  robust = FALSE,
  type = c("t2data", "t2mean", "c2data")
)
```

## Arguments

- x:

  A matrix or data frame with two columns

- level:

  Either coverage probability (for type = "t2data" or "data") or
  confidence level (for type = "t2mean").

- robust:

  If TRUE, then robust estimates of mean and covariance are used

- type:

  what type of statistic should be calculated; can be t2data (for data
  coverage), t2mean (for difference from a mean) or "c2data" (for
  coverage calculated with the χ² statistic)

## Value

A data frame with one row per point including the columns d2 (squared
mahalanobis distance) t2crit (critical T² value for the given level),
c2crit (critical χ² value for the given level) and is_outlier (logical,
whether d2 \> t2crit or d2 \> c2crit, depending on type).

## Details

The function can use a robust estimator of location and scatter using
the [`covMcd`](https://rdrr.io/pkg/robustbase/man/covMcd.html) function,
which uses the Maximum Covariance Determinant (MCD) estimator. Note that
while this results in ellipses which are more resistent to outliers, the
interpretation slightly changes, as the T² statistic used is only an
approximation in this case. In other words, use it for visualisation and
QC, but not for statistical testing.

## See also

[`hotelling_ellipse`](https://january3.github.io/gghotelling/reference/hotelling_ellipse.md)
for more information on the differences between t2data, t2mean and
c2data modes.
