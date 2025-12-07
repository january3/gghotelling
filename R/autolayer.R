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
#' @param type The type of the coverage / confidence area shown by \code{autolayer.prcomp}, can be one of t2data or t2mean.
#' @param ci coverage / confidence level for \code{autolayer.prcomp}
#' @param ... ignored
#' @importFrom ggplot2 autolayer autoplot .data geom_point ggplot
#' @examples
#' pca <- prcomp(iris[,1:4], scale.=TRUE)
#'
#' library(ggplot2)
#' autoplot(pca, group = iris$Species) + 
#'   autolayer(pca, group = iris$Species)
#' @export
autoplot.prcomp <- function(object, dims=c(1, 2), group = NULL, ...) {

  df <- object$x[ , dims, drop = FALSE ]
  df <- as.data.frame(df)

  c1 <- colnames(df)[1]
  c2 <- colnames(df)[2]

  ggplot(df, aes(x = .data[[c1]], y = .data[[c2]], color = group)) +
    geom_point()

}


#' @rdname autoplot.prcomp
#' @export
autolayer.prcomp <- function(object,  dims = c(1,2), group=NULL,
                             type = c("t2data", "t2mean"), ci = 0.95, ...) {
  type <- match.arg(type)

  df <- object$x[ , dims, drop = FALSE ]
  df <- as.data.frame(df)
  colnames(df) <- c("x", "y")

  geom_hotelling(aes(x=.data[["x"]], y=.data[["y"]], color = group, fill = group),
                        alpha = .1,
                        data = df,
                        ci = ci,
                        type = type)


}
