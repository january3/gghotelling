#' Calculate the T2 statistic for individual points
#'
#' Calculate the T2 statistic or Mahalanobis distance for individual points
#'
#' The function can use a robust estimator of location and scatter
#' using the \code{\link[robustbase]{covMcd}} function, which uses the
#' Maximum Covariance Determinant (MCD) estimator. Note that while this
#' results in ellipses which are more resistent to outliers, the
#' interpretation slightly changes, as the T2 statistic used is only an
#' approximation in this case. In other words, use it for visualisation and
#' QC, but not for statistical testing.
#'
#' @param x A matrix or data frame with two columns
#' @param labels Optional labels to use on the plot instead of rownames
#' @param level Either coverage probability (for type = "t2data" or "c2data") or
#'           confidence level (for type = "t2mean").
#' @param type what type of statistic should be calculated; can be t2data
#'        (for data coverage), t2mean (for difference from a mean) or
#'        "c2data" (for coverage calculated with the chi squared statistic)
#' @inheritParams hotelling_ellipse
#' @return A data frame with one row per point including the columns d2
#' (squared mahalanobis distance)
#' t2crit (critical T squared value for the given level),
#' c2crit (critical X squared value for the given level)
#' and is_outlier
#' (logical, whether d2 > t2crit or d2 > c2crit, depending on type).
#' @examples
#' library(ggplot2)
#'
#' pca <- prcomp(iris[, 1:4], scale.=TRUE)
#' pca_df <- cbind(iris, pca$x)
#' outlier_stats <- outliers(pca_df[ , c("PC1", "PC2")], level = 0.95)
#'
#' # use plot_outliers() to directly plot them
#' plot_outliers(pca_df[ , c("PC1", "PC2")], level = 0.95)
#'
#' @seealso \code{\link{hotelling_ellipse}} for more information on the
#' differences between t2data, t2mean and c2data modes.
#' @importFrom stats mahalanobis
#' @export
outliers <- function(x, level = 0.95, robust = FALSE, type = c("t2data", "t2mean", "c2data")) {
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
  #Xc <- sweep(x, 2, center)
  #t2 <- rowSums((Xc %*% Sinv) * Xc)

  # mahalanobis squared distance
  d2 <- mahalanobis(x, center, S)

  # Hotelling T^2 critical value
  fcrit <- qf(level, df1 = p, df2 = n - p)

  # T2 and X2 critical values
  t2crit <- (p * (n - 1) / (n - p)) * fcrit
  c2crit <- qchisq(level, df = p)     # chi-square, df = p

  if (type == "t2mean") {
    # CI for the mean: boundary for (x - mean) uses t2crit/n
    t2crit <- t2crit / n
  }

  data <- data.frame(d2 = d2, t2crit = t2crit, c2crit = c2crit, is_outlier = d2 > t2crit)

  if(type == "c2data") {
    data$is_outlier = d2 > c2crit
  }

  data
}

#' @rdname outliers
#' @importFrom ggplot2 geom_segment scale_color_manual geom_hline geom_label annotate labs ggplot theme
#' @export
plot_outliers <- function(x, level = 0.95, robust = FALSE, type = c("t2data", "t2mean", "c2data"),
                          labels = NULL) {

  type <- match.arg(type)

  if(type == "t2mean") {
    stop("no outlier plots for t2mean")
  }

  df <- outliers(x, level=level, robust=robust, type=type)

  if(!is.null(labels)) {
    df$id <- labels
  } else {
    df$id <- rownames(df)
  }

  df$index <- 1:nrow(df)

  if(type == "t2data") {
    title <- "Mahalanobis distance (T\u00B2 statistic)"
    crit_title <- "T\u00B2 critical value"
    crit <- "t2crit"
  } else {
    title <- "Mahalanobis distance (\u03A7\u00B2 statistic)"
    crit_title <- "\u03A7\u00B2 critical value"
    crit <- "c2crit"
  }

  outlier_labels <- ifelse(df$is_outlier,
                             as.character(df$id), NA)

  ggplot(df, aes(x = .data[["index"]], y = sqrt(.data[["d2"]]))) +
    geom_segment(aes(xend = .data[["index"]], yend = 0), alpha = .3) +
    geom_point(aes(color = .data[["is_outlier"]]), size = 2) +
    scale_color_manual(values=c("TRUE"="red", "FALSE"="black")) +
    geom_label(aes(label = outlier_labels), nudge_y = 0.2, na.rm = TRUE) +
    geom_hline(aes(yintercept = sqrt(.data[[crit]])), color = "red", linetype = "dashed") +
    annotate("text", x = 1, y = sqrt(df[[crit]][1]) + 0.1,
             label = crit_title, color = "red", hjust = 0) +
    theme(legend.position = "none") +
    labs(y = title, x = "Index")
}

#' Calculate Hotelling or data ellipse around some points
#'
#' Calculate Hotelling or data ellipse around some points
#'
#' Calculate the T2 Hotelling ellipse or a data ellipse for
#' the given coverage probability. There are three types of ellipses which
#' can be plotted:
#'
#'  * T2 Hotelling data ellipses, showing data coverage (like the
#'  `type="t"` version of `stat_ellipse`)
#'  * normal multivariate distribution ellipses (like the `type="norm"`
#'  version of the `stat_ellipse`) which use Mahalonibis distance and
#'  chi-squared statistic
#'  * T2 Hotelling confidence ellipses of the group means.
#'
#' The latter (for group means) correspond to the confidence interval for
#' the mean in the univariate world, so the ellipses are very small
#' (depending on the number of points).
#'
#' The function can also use a robust estimator of location and scatter
#' using the \code{\link[robustbase]{covMcd}} function, which uses the
#' Maximum Covariance Determinant (MCD) estimator. Note that while this
#' results in ellipses which are more resistent to outliers, the
#' interpretation slightly changes, as the T2 statistic used is only an
#' approximation in this case. In other words, use it for visualisation and
#' QC, but not for statistical testing.
#'
#' @param x A two-column matrix or data frame like object
#' @param level Either coverage probability (for type = "t2data" or "c2data") or
#'           confidence level (for type = "t2mean").
#' @param npoints Number of points to estimate
#' @param robust If TRUE, then robust estimates of mean and covariance are
#'               used
#' @param type t2data - Hotelling T2 data ellipse; t2mean - Hotelling
#'             confidence interval for the mean; c2data - normal 
#'             data ellipse (using chi squared distribution).
#' @return A two-column matrix or data frame with npoints rows
#' @seealso [outliers()] for calculating per-point based T2 and
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
                              type = c("t2data", "t2mean", "c2data"),
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
  c2crit <- qchisq(level, df = p)

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
    axes <- sqrt(c2crit * eigvals)
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


