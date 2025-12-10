# Bag plots

Bag plots for ggplot2

## Usage

``` r
geom_bag(
  mapping = NULL,
  data = NULL,
  position = "identity",
  ...,
  what = c("bag", "loop"),
  type = c("hdepth", "projdepth", "sprojdepth", "dprojdepth"),
  na.rm = FALSE,
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

- what:

  What to plot. Either "bag" (the inner bag region) or "loop" (the outer
  loop).

- type:

  Determines the depth function used to construct the bagplot:
  `"hdepth"` for halfspace depth, `"projdepth"` for projection depth,
  `"sprojdepth"` for skewness-adjusted projection depth and
  `"dprojdepth"` for directional projection depth.  
  Defaults to `"hdepth"`.

- na.rm:

  Logical. Should missing values be removed? Default is FALSE.

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

Bag plots are 2-dimensional generalizations of box plots. This geom adds
a bag region (which contains 50% of the data points, just like the "box"
in "box plots") to the plot, plus the "loop" which can be used to
identify potential outliers.

geom_bag() is just a wrapper around the `[aplpack]{bagplot()}` function
which actually does the calculations, .and the arguments are passed on
to that function.

The geom either plots the inner "bag" or the outer "loop", but not both.
If you need both, you can add two geom_bag layers to your ggplot object.

## Examples

``` r
library(ggplot2)
ggplot(iris, aes(x = Sepal.Width, y = Sepal.Length, color = Species)) +
  geom_point() +
  geom_bag(aes(fill = Species), alpha = .1, what = "loop") +
  geom_bag(aes(fill = Species), alpha = .3)

```
