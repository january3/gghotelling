

#' @rdname stat_hotelling_points 
#' @format NULL
#' @usage NULL
#' @export
StatHotellingPoints <- ggproto(
  "StatHotellingPoints",
  Stat,
  required_aes = c("x", "y"),

  compute_group = function(data, scales,
                           outlier_only = FALSE,
                           type = c("t2data", "t2mean", "data"),
                           level = 0.95) {


    X <- cbind(data$x, data$y)
    t2_df <- hotelling_points(X, level = level, type = type)

    data$t2 <- t2_df$t2
    data$t2crit <- t2_df$t2crit
    data$is_outlier <- t2_df$is_outlier

    if(outlier_only) {
      data <- data[ data$is_outlier, , drop=FALSE ]
    }

    data
  }
)

#' Calculate per-point T² Hotelling statistic 
#'
#' Calculate per-point T² Hotelling statistic for use in ggplot
#'
#' This calculates the T² Hotelling statistic for each point in the plot,
#' group-wise. This allows to use the statistics `is_outlier` and `t2` to be
#' used as graphical parameters, e.g. for coloring the points (see Examples
#' below) using the `ggplot2::after_stat()` function.
#'
#' @param outlier_only Only return the statistic for outliers
#' @inheritParams geom_hotelling
#' @inheritParams ggplot2::layer
#' @examples
#' pca <- prcomp(iris[, 1:4], scale.=TRUE)
#' df <- cbind(iris, pca$x)
#'
#' library(ggplot2)
#' ggplot(df, aes(PC1, PC2, group=Species)) +
#'   geom_hotelling(alpha=0.1, aes(fill = Species)) +
#'   scale_color_manual(values=c("TRUE"="red", "FALSE"="grey")) +
#'   stat_hotelling_points(aes(color = after_stat(is_outlier)))
#'
#' ggplot(df, aes(PC1, PC2, group=Species)) +
#'   geom_hotelling(alpha=0.1, level = .75, aes(fill = Species)) +
#'   stat_hotelling_points(level = .75, 
#'                         size=2, 
#'                         aes(shape = Species, 
#'                         color = after_stat(t2)))
#'
#' # label the outliers
#' ggplot(df, aes(PC1, PC2, group=Species, label=rownames(df))) +
#'   geom_hotelling(level = 0.75, alpha=0.1, aes(fill = Species)) +
#'   geom_point(aes(color = Species)) +
#'   stat_hotelling_points(level = .75, geom="label", 
#'                         outlier_only = TRUE)
#'
#' @export
stat_hotelling_points <- function(mapping = NULL, data = NULL,
                                  geom = "point", position = "identity",
                                  ...,
                                  type = c("t2data", "data", "t2mean"),
                                  level = 0.95,
                                  outlier_only = FALSE,
                                  na.rm = FALSE,
                                  show.legend = NA,
                                  inherit.aes = TRUE) {
  type <- match.arg(type)

  layer(
    stat = StatHotellingPoints, 
    data = data, 
    mapping = mapping,
    geom = geom, 
    position = position, 
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      type = type,
      outlier_only = outlier_only,
      level = level,
      na.rm = na.rm,
      ...
    )
  )
}



#' @rdname geom_hotelling
#' @format NULL
#' @usage NULL
#' @export
StatHotelling <- ggproto(
  "StatHotelling", Stat,
  
  required_aes = c("x", "y"),
  
  compute_group = function(data, scales, level = 0.95, type = type, npoints = npoints) {
    eli <- hotelling_ellipse(data[ , c("x", "y")], level = level, type = type, npoints = npoints)

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
GeomHotelling <- ggproto(
  "GeomHotelling", GeomPolygon,
  
  default_aes = aes(
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
#'
#' This geom adds data or confidence ellipses to the plot. See
#' `hotelling_ellipse()` documentation for more information.
#'
#' @param level Either coverage probability (for type = "t2data" or "data") or
#'           confidence level (for type = "t2mean").
#' @param ... Additional parameters passed to underlying `ggplot2::geom_polygon()`
#'   or to `ggplot2::layer()`.
#' @param na.rm Logical. Should missing values be removed? Default is FALSE.
#' @inheritParams ggplot2::layer
#' @inheritParams hotelling_ellipse
#' @importFrom ggplot2 ggproto layer Stat GeomPolygon aes
#' @importFrom stats qchisq cov qf
#' @examples
#' pca <- prcomp(iris[, 1:4], scale.=TRUE)
#' df <- cbind(iris, pca$x)
#' library(ggplot2)
#'   
#'   ggplot(df, aes(PC1, PC2)) +
#'     geom_hotelling(level=.99) +
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
                            level = 0.95,
                            type = "t2data",
                            npoints = 100,
                            na.rm = FALSE,
                            show.legend = NA,
                            inherit.aes = TRUE) {
  layer(
    stat = StatHotelling,      # use our Stat
    geom = GeomHotelling,          # but standard geom_polygon drawing
    data = data,
    mapping = mapping,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(level = level, type = type, npoints = npoints, na.rm = na.rm, ...)
  )
}

