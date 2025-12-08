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



## KDE 

.expanded_range <- function(x, frac = .25) {

  r <- range(x)
  d <- diff(r) * frac
  r + c(-d, +d)
}

#' @rdname geom_kde
#' @format NULL
#' @usage NULL
#' @export
StatKDE <- ggproto(
  "StatKDE", Stat,
  
  required_aes = c("x", "y"),

  compute_group = function(data, scales, 
                           coverage = .95,
                           n = 100) {
    # data$x, data$y are original points for this group
    rx <- .expanded_range(data$x)
    ry <- .expanded_range(data$y)
    cnt <- MASS::kde2d(data$x, data$y, n = n, lims = c(rx, ry))
    
    z <- as.vector(cnt$z)

    # start from the top of the mountain, descend until we have 95% (or
    # whatever coverage the caller wants) of mass included
    ord <- order(z, decreasing = TRUE)

    cumprob <- cumsum(z[ ord ]) / sum(z)
    idx <- which(cumprob >= coverage)[1] - 1
    if(idx < 1) idx <- 1

    z_idx <- ord[idx]
    z_thr <- z[z_idx]

    poly <- grDevices::contourLines(cnt$x, cnt$y, cnt$z, levels = z_thr)

    if(length(poly) == 0L) return(NULL)

    ret <- lapply(seq_along(poly), function(i) {
      df <- data.frame(
        x = c(poly[[i]]$x, NA),
        y = c(poly[[i]]$y, NA)
        #,
        #group = interaction(data$group[1], i, drop = TRUE),

      )
    })
    
    ret <- do.call(rbind, ret) 
    ret <- ret[ -nrow(ret), ]

    # Keep the group's aesthetics (colour, etc.) from the first row
    defaults <- data[1, setdiff(names(data), c("x", "y")), drop = FALSE]
    rownames(defaults) <- NULL

    cbind(ret, defaults[ , , drop = FALSE])
  }  
)

#' @rdname geom_hotelling
#' @format NULL
#' @usage NULL
#' @export
GeomKDE <- ggproto(
  "GeomKDE", GeomPolygon,
  
  default_aes = aes(
    colour    = "black",  # default outline
    fill      = NA,       # default no fill
    linewidth = 0.5,
    linetype  = 1,
    alpha     = .25,
    subgroup  = NULL
  )
)

#' KDE contours for ggplot2
#'
#' Kernel density estimate contours for ggplot2
#' 
#' This function uses the \code{\link[MASS]{kde2d}} function to estimate density along
#' a grid, and then plots a contour for a selected coverage.
#'
#' @param n Number of grid points in each direction (passed to
#' \code{\link[MASS]{kde2d}})
#' @param coverage What fraction of the points should be enclosed by the
#' contour
#' @param ... Additional parameters passed to underlying [ggplot2::geom_polygon()]
#'   or to [ggplot2::layer()].
#' @inheritParams ggplot2::layer
#' @importFrom ggplot2 ggproto layer Stat GeomPolygon aes
#' @importFrom MASS kde2d
#' @examples
#' library(ggplot2)
#'   
#' pca <- prcomp(iris[, 1:4], scale.=TRUE)
#' df <- cbind(iris, pca$x)
#'   
#' # following is similar to geom_contour
#' pca <- prcomp(iris[, 1:4], scale.=TRUE)
#' df <- cbind(iris, pca$x)
#' p <- ggplot(df, aes(x = PC1, y = PC2, color=Species))
#' for(i in seq(.05, .95, length.out = 10)) {
#'   p <- p + geom_kde(aes(fill = Species), alpha =.05, coverage = i, n = 100)
#' }
#' p + geom_point()
#'
#' @seealso [geom_hull()] for simple convex contours and [geom_hotelling()]
#' for Hotelling T² ellipses.
#' @export
geom_kde <- function(mapping = NULL, data = NULL,
                            position = "identity",
                            ...,
                            coverage = .95,
                            n = 100,
                            show.legend = NA,
                            inherit.aes = TRUE) {
  layer(
    stat = StatKDE,      # use our Stat
    geom = GeomKDE,          # but standard geom_polygon drawing
    data = data,
    mapping = mapping,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(n = n, coverage = coverage, ...)
  )
}

