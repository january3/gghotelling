test_that("geom_hull works correctly", {
  library(ggplot2)

  # Create a sample dataset
  set.seed(123)
  df <- data.frame(
    group = rep(c("A", "B"), each = 50),
    x = c(rnorm(50, mean = 5), rnorm(50, mean = 7)),
    y = c(rnorm(50, mean = 5), rnorm(50, mean = 7))
  )

  # Create a ggplot with geom_hull
  p <- ggplot(df, aes(x = x, y = y, color = group)) +
    geom_point() +
    geom_hull(aes(group = group))

  # Test that the plot object is created successfully
  expect_s3_class(p, "ggplot")

  # Test that the layers include geom_hull
  layer_classes <- sapply(p$layers, function(layer) class(layer$geom)[1])
  expect_true("GeomHull" %in% layer_classes)

})


test_that("geom_kde works correctly", {
  library(ggplot2)

  # Create a sample dataset
  data(iris)
  p <- ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_point() +
    geom_kde(aes(fill = Species), alpha = 0.3, coverage = 0.95)

  # Test that the plot object is created successfully
  expect_s3_class(p, "ggplot")

  # Test that the layers include geom_kde
  layer_classes <- sapply(p$layers, function(layer) class(layer$geom)[1])
  expect_true("GeomKDE" %in% layer_classes)

})
