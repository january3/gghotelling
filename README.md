
# gghotelling

<!-- badges: start -->

[![R-CMD-check](https://github.com/january3/gghotelling/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/january3/gghotelling/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/january3/gghotelling/graph/badge.svg)](https://app.codecov.io/gh/january3/gghotelling)
<!-- badges: end -->

Show Hotelling ellipses with ggplot2.

## Installation

You can install the development version of gghotelling from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("january3/gghotelling")
```

## Example

The package defines a new geom, `geom_hotelling()`, which can be used to
add Hotelling ellipses to ggplot2 scatter plots.

``` r
library(ggplot2)
library(gghotelling)

pca <- prcomp(iris[, 1:4], scale.=TRUE)
df <- cbind(iris, pca$x)

ggplot(df, aes(PC1, PC2)) +
  geom_hotelling(ci=.99) +
  geom_point()
```

<img src="man/figures/README-example-1.png" width="100%" />

``` r

ggplot(df, aes(PC1, PC2, color=Species)) +
  geom_hotelling() +
  geom_point()
```

<img src="man/figures/README-example-2.png" width="100%" />

``` r

ggplot(df, aes(PC1, PC2, color=Species)) +
  geom_hotelling(alpha=0.1, aes(fill = Species)) +
  geom_point()
```

<img src="man/figures/README-example-3.png" width="100%" />
