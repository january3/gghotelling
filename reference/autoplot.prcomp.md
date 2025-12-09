# Automatic plotting of PCA objects

Automatic plotting of PCA objects

## Usage

``` r
# S3 method for class 'prcomp'
autoplot(object, dims = c(1, 2), biplot = FALSE, group = NULL, ...)

# S3 method for class 'prcomp'
autolayer(
  object,
  dims = c(1, 2),
  group = NULL,
  labels = NULL,
  type = c("t2data", "t2mean", "c2data"),
  level = 0.95,
  ...
)
```

## Arguments

- object:

  An object of prcomp class

- dims:

  Dimensions to plot

- biplot:

  whether to show the loadings as well as the scores

- group:

  Groups of the data to be shown on the plot

- ...:

  ignored

- labels:

  optionally, a vector of labels for showing the outliers. If NULL, the
  outliers will be identified by row number.

- type:

  The type of the coverage / confidence area shown by
  `autolayer.prcomp`, can be one of t2data (T² Hotelling coverage),
  c2data (χ² coverage) or t2mean (T² based confidence area for the group
  mean).

- level:

  Either coverage probability (for type = "t2data" and "c2data") or
  confidence level (for type = "t2mean").

## Details

The functions `autoplot.prcomp` and `autolayer.prcomp` are for automatic
plotting of prcomp objects, similar to `ggfortify::autoplot.prcomp`.

## Examples

``` r
pca <- prcomp(iris[,1:4], scale.=TRUE)

library(ggplot2)
autoplot(pca, group = iris$Species) + 
  autolayer(pca, group = iris$Species)
```
