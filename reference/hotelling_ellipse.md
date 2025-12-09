# Calculate Hotelling or data ellipse around some points

Calculate Hotelling or data ellipse around some points

## Usage

``` r
hotelling_ellipse(
  x,
  level = 0.95,
  npoints = 100,
  type = c("t2data", "t2mean", "c2data"),
  robust = FALSE
)
```

## Arguments

- x:

  A two-column matrix or data frame like object

- level:

  Either coverage probability (for type = "t2data" or "c2data") or
  confidence level (for type = "t2mean").

- npoints:

  Number of points to estimate

- type:

  t2data - Hotelling T2 data ellipse; t2mean - Hotelling confidence
  interval for the mean; c2data - normal data ellipse (using chi squared
  distribution).

- robust:

  If TRUE, then robust estimates of mean and covariance are used

## Value

A two-column matrix or data frame with npoints rows

## Details

Calculate the T2 Hotelling ellipse or a data ellipse for the given
coverage probability. There are three types of ellipses which can be
plotted:

- T2 Hotelling data ellipses, showing data coverage (like the `type="t"`
  version of `stat_ellipse`)

- normal multivariate distribution ellipses (like the `type="norm"`
  version of the `stat_ellipse`) which use Mahalonibis distance and
  chi-squared statistic

- T2 Hotelling confidence ellipses of the group means.

The latter (for group means) correspond to the confidence interval for
the mean in the univariate world, so the ellipses are very small
(depending on the number of points).

The function can also use a robust estimator of location and scatter
using the [`covMcd`](https://rdrr.io/pkg/robustbase/man/covMcd.html)
function, which uses the Maximum Covariance Determinant (MCD) estimator.
Note that while this results in ellipses which are more resistent to
outliers, the interpretation slightly changes, as the T2 statistic used
is only an approximation in this case. In other words, use it for
visualisation and QC, but not for statistical testing.

## See also

[`outliers()`](https://january3.github.io/gghotelling/reference/outliers.md)
for calculating per-point based T2 and Mahalonibis values and
[`geom_hotelling()`](https://january3.github.io/gghotelling/reference/geom_hotelling.md)
for plotting of the ellipse with ggplot

## Examples

``` r
df <- iris[ iris$Species == "setosa", 1:2 ]
eli <- hotelling_ellipse(df)
plot(df[,1], df[,2])
lines(eli)
```
