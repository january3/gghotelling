# this does not yet work like I would like it to work


#' Automatic plotting of PCA objects
#'
#' Automatic plotting of PCA objects
#'
#' The functions \code{autoplot.prcomp} and \code{autolayer.prcomp} are for
#' automatic plotting of prcomp objects, similar to
#' \code{ggfortify::autoplot.prcomp}.
#'
#' @param object An object of prcomp class
#' @param dims Dimensions to plot
#' @param group Groups of the data to be shown on the plot
#' @param type The type of the coverage / confidence area shown by \code{autolayer.prcomp}, can be one of t2data (T² Hotelling coverage), data (Mahalanobis coverage) or t2mean (confidence area for the group mean).
#' @param level Either coverage probability (for type = "t2data" and "data") or
#'           confidence level (for type = "t2mean").
#' @param labels optionally, a vector of labels for showing the outliers.
#'               If NULL, the outliers will be identified by row number.
#' @param biplot whether to show the loadings as well as the scores
#' @param ... ignored
#' @importFrom ggplot2 autolayer autoplot .data geom_point ggplot
#' @examples
#' pca <- prcomp(iris[,1:4], scale.=TRUE)
#'
#' library(ggplot2)
#' autoplot(pca, group = iris$Species) + 
#'   autolayer(pca, group = iris$Species)
#' @importFrom ggplot2 geom_segment arrow unit geom_label 
#' @importFrom ggplot2 scale_x_continuous scale_y_continuous sec_axis
#' @export
autoplot.prcomp <- function(object, dims=c(1, 2), biplot = FALSE, group = NULL, ...) {

  if(length(dims) != 2) {
    stop("Exactly two dimensions must be specified")
  }

  df <- object$x[ , dims, drop = FALSE ]
  df <- as.data.frame(df)

  c1 <- colnames(df)[1]
  c2 <- colnames(df)[2]

  p <- ggplot(df, aes(x = .data[[c1]], y = .data[[c2]], color = group)) + 
    geom_point()

  if(!biplot) {
    return(p)
  }

  load <- object$rotation[ , dims, drop = FALSE ]
  score_max <- max(abs(df))
  load_max <- max(abs(load))

  scale <- .9 * score_max / load_max
  load_df <- as.data.frame(load * scale)
  load_df$feature <- rownames(load)

  p <- p +
    geom_segment(data = load_df,
             aes(x = 0, y = 0, xend = .data[[c1]], yend = .data[[c2]]),
             arrow = arrow(length = unit(0.02, "npc")),
             colour = "red") +
    geom_label(data = load_df,
               aes(.data[[c1]], .data[[c2]], label = .data[["feature"]]),
               colour = "red", vjust = -.3) +
    scale_x_continuous(
      name = paste(c1, "scores"),
      sec.axis = sec_axis(~ . / scale, name = paste(c1, "loadings"))
    ) +
    scale_y_continuous(
      name = paste(c2, "scores"),
      sec.axis = sec_axis(~ . / scale, name = paste(c2, "loadings"))
    )

  p
}


#' @rdname autoplot.prcomp
#' @export
autolayer.prcomp <- function(object,  dims = c(1,2), group=NULL,
                             labels = NULL,
                             type = c("t2data", "t2mean", "data"), level = 0.95, ...) {
  type <- match.arg(type)

  df <- object$x[ , dims, drop = FALSE ]
  df <- as.data.frame(df)
  colnames(df) <- c("x", "y")

  if(!is.null(labels)) {
    df[["labels"]] <- labels
  } else {
    df[["labels"]] <- 1:nrow(df)
  }

  list(
    geom_hotelling(aes(x=.data[["x"]], y=.data[["y"]], color = group, fill = group),
                        alpha = .1,
                        data = df,
                        level = level,
                        type = type),
    stat_outliers(aes(x=.data[["x"]], y=.data[["y"]], label=labels),
                          data = df,
                          level = level,
                          type = type,
                          geom = "label", outlier_only = TRUE)
  )


}
