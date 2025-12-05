
#' @rdname geom_hotelling
#' @format NULL
#' @usage NULL
#' @export
StatHotelling <- ggplot2::ggproto(
  "StatHotelling", ggplot2::Stat,
  
  required_aes = c("x", "y"),
  
  compute_group = function(data, scales, ci = 0.95) {
    s <- cov(data[, c("x", "y")])
    cc <- c(mean(data$x, na.rm = TRUE), mean(data$y, na.rm = TRUE))
    eli <- ellipse::ellipse(s, centre=cc, level = ci, npoints = 100)

    defaults <- data[1, setdiff(names(data), c("x", "y", "group")), drop = FALSE]
    rownames(defaults) <- NULL
    
    ret <- data.frame(
      x = eli[,1],
      y = eli[,2],
      group = data$group[1],
      
      # keep aesthetics constant across the whole polygon
      defaults
    )
    ret
  }
)

#' @rdname geom_hotelling
#' @format NULL
#' @usage NULL
#' @export
GeomHotelling <- ggplot2::ggproto(
  "GeomHotelling", ggplot2::GeomPolygon,
  
  default_aes = ggplot2::aes(
    colour    = "black",  # default outline
    fill      = NA,       # default no fill
    linewidth = 0.5,
    linetype  = 1,
    alpha     = NA,
    subgroup  = NULL
  )
)

#' Hotelling ellipses for ggplot2
#'
#' Hotelling ellipses for ggplot2
#' @param ci Confidence interval
#' @param ... Additional parameters passed to underlying `geom_polygon()`
#'   or to `ggplot2::layer()`.
#' @param na.rm Logical. Should missing values be removed? Default is FALSE.
#' @inheritParams ggplot2::layer
#' @importFrom ggplot2 ggproto layer Stat GeomPolygon
#' @importFrom ellipse ellipse
#' @examples
#' pca <- prcomp(iris[, 1:4], scale.=TRUE)
#' df <- cbind(iris, pca$x)
#' library(ggplot2)
#'   
#'   ggplot(df, aes(PC1, PC2)) +
#'     geom_hotelling(ci=.99) +
#'     geom_point()
#'   
#'   ggplot(df, aes(PC1, PC2, color=Species)) +
#'     geom_hotelling() +
#'     geom_point()
#'   
#'   ggplot(df, aes(PC1, PC2, color=Species)) +
#'     geom_hotelling(alpha=0.1, aes(fill = Species)) +
#'     geom_point()
#' @export
geom_hotelling <- function(mapping = NULL, data = NULL,
                            position = "identity",
                            ...,
                            ci = 0.95,
                            na.rm = FALSE,
                            show.legend = NA,
                            inherit.aes = TRUE) {
  ggplot2::layer(
    stat = StatHotelling,      # use our Stat
    geom = GeomHotelling,          # but standard geom_polygon drawing
    data = data,
    mapping = mapping,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(ci = ci, na.rm = na.rm, ...)
  )
}

