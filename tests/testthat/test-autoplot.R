test_that("autoplot.prcomp works correctly", {
  library(ggplot2)

  # Perform PCA on the iris dataset
  pca_result <- prcomp(iris[, 1:4], center = TRUE, scale. = TRUE)

  p <- autoplot(pca_result, data = iris, group = 'Species')
  expect_s3_class(p, "ggplot")

  p <- autoplot(pca_result, data = iris, group = 'Species', biplot = TRUE)
  expect_s3_class(p, "ggplot")

  p <- autoplot(pca_result, data = iris, group = 'Species') +
    autolayer(pca_result, data = iris, group = 'Species')
  expect_s3_class(p, "ggplot")
  
  p <- autoplot(pca_result, data = iris, group = 'Species') +
    autolayer(pca_result, data = iris, group = 'Species', labels = iris$Species)
  expect_s3_class(p, "ggplot")

  expect_error(autoplot(pca_result$rotation))

  expect_error(autoplot(pca_result, dims = 1), "Exactly two dimensions must be specified")
 
})
