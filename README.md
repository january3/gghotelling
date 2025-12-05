
# gghotelling

<!-- badges: start -->

[![R-CMD-check](https://github.com/january3/gghotelling/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/january3/gghotelling/actions/workflows/R-CMD-check.yaml)
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

This is a basic example which shows you how to solve a common problem:

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
