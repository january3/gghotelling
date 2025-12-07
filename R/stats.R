#' Calculate the T2 statistic for individual points
#'
#' Calculate the T2 statistic or Mahalanobis distance for individual points
#'
#' The function can use a robust estimator of location and scatter
#' using the \code{\link[robustbase]{covMcd}} function, which uses the
#' Maximum Covariance Determinant (MCD) estimator. Note that while this
#' results in ellipses which are more resistent to outliers, the
#' interpretation slightly changes, as the T² statistic used is only an
#' approximation in this case. In other words, use it for visualisation and
#' QC, but not for statistical testing.
#'
#' @param x A matrix or data frame with two columns
#' @param level Either coverage probability (for type = "t2data" or "data") or
#'           confidence level (for type = "t2mean").
#' @param type what type of statistic should be calculated; can be t2data
#'        (for data coverage), t2mean (for difference from a mean) or
#'        "data" (for Mahalanobis distance)
#' @inheritParams hotelling_ellipse
#' @return A data frame with one row per point including the columns t2 (t2
#' statistic), t2crit (critical t2 value for the given level) and is_outlier
#' (logical, whether t2 > t2crit).
#' @seealso \code{\link{hotelling_ellipse}} for more information on the
#' differences between t2data, t2mean and data modes.
#' @importFrom stats mahalanobis
#' @export
hotelling_points <- function(x, level = 0.95, robust = FALSE, type = c("t2data", "t2mean", "data")) {
  type <- match.arg(type)

  x <- as.matrix(x)
  if (ncol(x) != 2L) stop("x must have exactly 2 columns.")
  
  n <- nrow(x)
  p <- 2L
  if (n <= p) stop("Need n > p to compute Hotelling ellipse.")

  if(robust) {
    r <- covMcd(x)
    center <- r$center
    S <- r$cov
  } else {
    center <- colMeans(x)
    S <- cov(x)
  }
  
  Sinv <- solve(S)

  # subtract means
  Xc <- sweep(x, 2, center)
  t2 <- rowSums((Xc %*% Sinv) * Xc)
  c2 <- mahalanobis(x, center, S)

  # Hotelling T^2 critical value
  fcrit <- qf(level, df1 = p, df2 = n - p)
  t2crit <- (p * (n - 1) / (n - p)) * fcrit
  c2crit <- qchisq(level, df = p)     # chi-square, df = p

  if (type == "t2mean") {
    # CI for the mean: boundary for (x - mean) uses t2crit/n
    t2crit <- t2crit / n
  }

  data <- data.frame(t2 = t2, t2crit = t2crit, c2 = c2, c2crit = c2crit, is_outlier = t2 > t2crit)

  if(type == "data") {
    data$is_outlier = c2 > c2crit
  }

  data
}

#' Calculate Hotelling or data ellipse around some points
#'
#' Calculate Hotelling or data ellipse around some points
#'
#' Calculate the T² Hotelling ellipse or a data ellipse for
#' the given coverage probability. There are three types of ellipses which
#' can be plotted:
#'
#'  * T² Hotelling data ellipses, showing data coverage (like the
#'  `type="t"` version of `stat_ellipse`)
#'  * normal multivariate distribution ellipses (like the `type="norm"`
#'  version of the `stat_ellipse`) which use Mahalonibis distance and
#'  chi-squared statistic
#'  * T² Hotelling confidence ellipses of the group means.
#'
#' The latter (for group means) correspond to the confidence interval for
#' the mean in the univariate world, so the ellipses are very small
#' (depending on the number of points).
#'
#' The function can also use a robust estimator of location and scatter
#' using the \code{\link[robustbase]{covMcd}} function, which uses the
#' Maximum Covariance Determinant (MCD) estimator. Note that while this
#' results in ellipses which are more resistent to outliers, the
#' interpretation slightly changes, as the T² statistic used is only an
#' approximation in this case. In other words, use it for visualisation and
#' QC, but not for statistical testing.
#'
#' @param x A two-column matrix or data frame like object
#' @param level Either coverage probability (for type = "t2data" or "data") or
#'           confidence level (for type = "t2mean").
#' @param npoints Number of points to estimate
#' @param robust If TRUE, then robust estimates of mean and covariance are
#'               used
#' @param type t2data - Hotelling T² data ellipse; t2mean - Hotelling
#'             confidence interval for the mean; data - normal 
#'             data elllipse (using χ² distribution).
#' @return A two-column matrix or data frame with npoints rows
#' @seealso [hotelling_points()] for calculating per-point based T² and
#' Mahalonibis values and [geom_hotelling()] for plotting of the ellipse with
#' ggplot
#' @examples
#' df <- iris[ iris$Species == "setosa", 1:2 ]
#' eli <- hotelling_ellipse(df)
#' plot(df[,1], df[,2])
#' lines(eli)
#' @importFrom robustbase covMcd
#' @export
hotelling_ellipse <- function(x, level = 0.95, npoints = 100, 
                              type = c("t2data", "t2mean", "data"),
                              robust = FALSE) {
  convert_to_df <- FALSE

  if(is.data.frame(x)) {
    convert_to_df <- TRUE
  }

  type <- match.arg(type)

  x <- as.matrix(x)
  if (ncol(x) != 2L) stop("x must have exactly 2 columns.")
  
  n <- nrow(x)
  p <- 2L
  if (n <= p) stop("Need n > p to compute Hotelling ellipse.")
  
  if(robust) {
    r <- covMcd(x)
    center <- r$center
    S <- r$cov
  } else {
    center <- colMeans(x)
    S <- cov(x)
  }
  
  # Critical Hotelling T^2 value
  t2crit <- (p * (n - 1) / (n - p)) * qf(level, df1 = p, df2 = n - p)
  c2   <- qchisq(level, df = p)

  # Eigen-decomposition
  eig <- eigen(S)
  eigvals <- eig$values
  eigvecs <- eig$vectors
  
  # Semi-axis lengths of the ellipse
  if(type == "t2data") {
    #message("computing Hotelling data")
    axes <- sqrt(t2crit * eigvals)
  } else if(type == "t2mean") {
    #message("computing Hotelling mean")
    t2crit <- t2crit / n
    axes <- sqrt(t2crit * eigvals)
  } else {
    #message("computing normal")
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



