# KDE contours for ggplot2

Kernel density estimate contours for ggplot2

## Usage

``` r
geom_kde(
  mapping = NULL,
  data = NULL,
  position = "identity",
  ...,
  coverage = 0.95,
  n = 100,
  show.legend = NA,
  inherit.aes = TRUE
)
```

## Arguments

- mapping:

  Set of aesthetic mappings created by
  [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html). If
  specified and `inherit.aes = TRUE` (the default), it is combined with
  the default mapping at the top level of the plot. You must supply
  `mapping` if there is no plot mapping.

- data:

  The data to be displayed in this layer. There are three options:

  If `NULL`, the default, the data is inherited from the plot data as
  specified in the call to
  [`ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html).

  A `data.frame`, or other object, will override the plot data. All
  objects will be fortified to produce a data frame. See
  [`fortify()`](https://ggplot2.tidyverse.org/reference/fortify.html)
  for which variables will be created.

  A `function` will be called with a single argument, the plot data. The
  return value must be a `data.frame`, and will be used as the layer
  data. A `function` can be created from a `formula` (e.g.
  `~ head(.x, 10)`).

- position:

  A position adjustment to use on the data for this layer. This can be
  used in various ways, including to prevent overplotting and improving
  the display. The `position` argument accepts the following:

  - The result of calling a position function, such as
    [`position_jitter()`](https://ggplot2.tidyverse.org/reference/position_jitter.html).
    This method allows for passing extra arguments to the position.

  - A string naming the position adjustment. To give the position as a
    string, strip the function name of the `position_` prefix. For
    example, to use
    [`position_jitter()`](https://ggplot2.tidyverse.org/reference/position_jitter.html),
    give the position as `"jitter"`.

  - For more information and other ways to specify the position, see the
    [layer
    position](https://ggplot2.tidyverse.org/reference/layer_positions.html)
    documentation.

- ...:

  Additional parameters passed to underlying
  [`ggplot2::geom_polygon()`](https://ggplot2.tidyverse.org/reference/geom_polygon.html)
  or to
  [`ggplot2::layer()`](https://ggplot2.tidyverse.org/reference/layer.html).

- coverage:

  What fraction of the points should be enclosed by the contour

- n:

  Number of grid points in each direction (passed to
  [`kde2d`](https://rdrr.io/pkg/MASS/man/kde2d.html))

- show.legend:

  logical. Should this layer be included in the legends? `NA`, the
  default, includes if any aesthetics are mapped. `FALSE` never
  includes, and `TRUE` always includes. It can also be a named logical
  vector to finely select the aesthetics to display. To include legend
  keys for all levels, even when no data exists, use `TRUE`. If `NA`,
  all levels are shown in legend, but unobserved levels are omitted.

- inherit.aes:

  If `FALSE`, overrides the default aesthetics, rather than combining
  with them. This is most useful for helper functions that define both
  data and aesthetics and shouldn't inherit behaviour from the default
  plot specification, e.g.
  [`annotation_borders()`](https://ggplot2.tidyverse.org/reference/annotation_borders.html).

## Details

This function uses the
[`kde2d`](https://rdrr.io/pkg/MASS/man/kde2d.html) function to estimate
density along a grid, and then plots a contour for a selected coverage.

## See also

[`geom_hull()`](https://january3.github.io/gghotelling/reference/geom_hull.md)
for simple convex contours and
[`geom_hotelling()`](https://january3.github.io/gghotelling/reference/geom_hotelling.md)
for Hotelling T² ellipses.

## Examples

``` r
library(ggplot2)
  
pca <- prcomp(iris[, 1:4], scale.=TRUE)
df <- cbind(iris, pca$x)
  
# following is similar to geom_contour
pca <- prcomp(iris[, 1:4], scale.=TRUE)
df <- cbind(iris, pca$x)
p <- ggplot(df, aes(x = PC1, y = PC2, color=Species))
for(i in seq(.05, .95, length.out = 10)) {
  p <- p + geom_kde(aes(fill = Species), alpha =.05, coverage = i, n = 100)
}
p + geom_point()

```
