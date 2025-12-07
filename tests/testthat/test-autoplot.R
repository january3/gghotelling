test_that("autoplot.prcomp works correctly", {
  library(ggplot2)

  # Perform PCA on the iris dataset
  pca_result <- prcomp(iris[, 1:4], center = TRUE, scale. = TRUE)

  # Create an autoplot of the PCA result
  p <- autoplot(pca_result, data = iris, group = 'Species')

  # Test that the plot object is created successfully
  expect_s3_class(p, "ggplot")

  p <- autoplot(pca_result, data = iris, group = 'Species') +
    autolayer(pca_result, data = iris, group = 'Species')
  expect_s3_class(p, "ggplot")
  

})
