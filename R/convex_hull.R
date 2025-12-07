#' @rdname geom_hull 
#' @format NULL
#' @usage NULL
#' @export
GeomHull <- ggproto(
  "GeomHull", GeomPolygon,
  default_aes = aes(
    colour = "black",
    fill   = NA,
    alpha  = NA,
    linetype = 1,
    linewidth = 0.5
  )
)


#' @rdname geom_hull 
#' @format NULL
#' @usage NULL
#' @importFrom grDevices chull
#' @export
StatHull <- ggproto(
  "StatHull", Stat,
  required_aes = c("x", "y"),

  compute_group = function(data, scales) {
    if (nrow(data) < 3L) {
      return(data)  # nothing to hull, just return points
    }
    idx <- chull(data$x, data$y)
    data[idx, , drop = FALSE]
  }
)

#' Draw a convex hull around a group of points
#'
#' Draw a convex hull around a group of points
#' 
#' @param na.rm Logical. Should missing values be removed? Default is FALSE.
#' @param ... Additional parameters passed to underlying `ggplot2::geom_polygon()`
#'   or to `ggplot2::layer()`.
#' @inheritParams ggplot2::layer
#' @examples
#' # nothing
#' library(ggplot2)
#' ggplot(iris, aes(Sepal.Length, Sepal.Width, color=Species)) +
#'   geom_hull(mapping = aes(fill = Species), alpha=.1) +
#'   geom_point()
#' @export
geom_hull <- function(mapping = NULL, data = NULL,
                      position = "identity",
                      ...,
                      na.rm = FALSE,
                      show.legend = NA,
                      inherit.aes = TRUE) {
  layer(
    stat = StatHull,
    geom = GeomHull,
    data = data,
    mapping = mapping,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      ...
    )
  )
}


