#' Calculate Hotelling or data ellipse around some points
#'
#' Calculate Hotelling or data ellipse around some points
#'
#' This functions calculates the T² Hotelling ellipse or a data ellipse for
#' the given coverage probability. There are three types of ellipses which
#' can be plotted:
#'
#'  * T² Hotelling data ellipses, showing data coverage (like the
#'  `type="t"` version of `stat_ellipse`)
#'  * normal multivariate distribution ellipses (like the `type="norm"`
#'  version of the `stat_ellipse`)
#'  * T² Hotelling confidence areas for the group means.
#'
#' @param x A two-column matrix or data frame like object
#' @param ci coverage probability (confidence interval)
#' @param npoints Number of points to estimate
#' @param type t2data - Hotelling T² data ellipse; t2mean - Hotelling
#' confidence interval for the mean; data - normal data elllipse
#'     (using χ² distribution).
#' @return A two-column matrix or data frame with npoints rows
#' @examples
#' df <- iris[ iris$Species == "setosa", 1:2 ]
#' eli <- hotelling_ellipse(df)
#' plot(df[,1], df[,2])
#' lines(eli)
#' @export
hotelling_ellipse <- function(x, ci = 0.95, npoints = 100, type = "t2data") {
  convert_to_df <- FALSE
  if(is.data.frame(x)) {
    convert_to_df <- TRUE
  }

  x <- as.matrix(x)
  if (ncol(x) != 2L) stop("x must have exactly 2 columns.")
  
  n <- nrow(x)
  p <- 2L
  if (n <= p) stop("Need n > p to compute Hotelling ellipse.")
  
  center <- colMeans(x)
  S <- cov(x)
  
  # Critical Hotelling T^2 value (for the DATA cloud, not mean CI)
  t2crit <- (p * (n - 1) / (n - p)) * qf(ci, df1 = p, df2 = n - p)
  c2   <- qchisq(ci, df = p)     # chi-square, df = p
  #fcrit <- stats::qf(conf, df1 = p, df2 = n - p)
  #c2 <- (p * (n - 1) / (n - p)) * fcrit / n  # divide by n for mean

  # Eigen-decomposition
  eig <- eigen(S)
  eigvals <- eig$values
  eigvecs <- eig$vectors
  
  # Semi-axis lengths of the ellipse
  if(type == "t2data") {
    message("computing Hotelling data")
    axes <- sqrt(t2crit * eigvals)
  } else if(type == "t2mean") {
    message("computing Hotelling mean")
    t2crit <- t2crit / n
    axes <- sqrt(t2crit * eigvals)
  } else {
    message("computing normal")
    axes <- sqrt(c2 * eigvals)
  }
  
  # Parametric angles
  theta <- seq(0, 2 * pi, length.out = npoints)
  circle <- rbind(cos(theta), sin(theta))  # 2 x npoints
  
  # Transform unit circle to a Hotelling ellipse
  ellipse <- t(center + eigvecs %*% (diag(axes) %*% circle))
  colnames(ellipse) <- c("x", "y")

  if(convert_to_df) {
    ellipse <- as.data.frame(ellipse)
  }

  ellipse
}

#' @rdname geom_hotelling
#' @format NULL
#' @usage NULL
#' @export
StatHotelling <- ggproto(
  "StatHotelling", Stat,
  
  required_aes = c("x", "y"),
  
  compute_group = function(data, scales, ci = 0.95, type = type, npoints = npoints) {
    eli <- hotelling_ellipse(data[ , c("x", "y")], ci = ci, type = type, npoints = npoints)

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
#' @param ci Confidence interval
#' @param ... Additional parameters passed to underlying `geom_polygon()`
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
                            type = TRUE,
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
    params = list(ci = ci, type = type, npoints = npoints, na.rm = na.rm, ...)
  )
}

