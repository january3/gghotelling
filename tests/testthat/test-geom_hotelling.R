test_that("geom_hotelling works correctly", {
  library(ggplot2)

  # Create a sample dataset
  set.seed(123)
  df <- data.frame(
    group = rep(c("A", "B"), each = 50),
    x = c(rnorm(50, mean = 5), rnorm(50, mean = 7)),
    y = c(rnorm(50, mean = 5), rnorm(50, mean = 7))
  )

  # Create a ggplot with geom_hotelling
  p <- ggplot(df, aes(x = x, y = y, color = group)) +
    geom_point() +
    geom_hotelling(aes(group = group), level = 0.95)

  # Test that the plot object is created successfully
  expect_s3_class(p, "ggplot")

  # Test that the layers include geom_hotelling
  layer_classes <- sapply(p$layers, function(layer) class(layer$geom)[1])
  expect_true("GeomHotelling" %in% layer_classes)

})


test_that("stat_outliers works correctly", {
  library(ggplot2)

  # Create a sample dataset
  set.seed(123)
  df <- data.frame(
    group = rep(c("A", "B"), each = 50),
    x = c(rnorm(50, mean = 5), rnorm(50, mean = 7)),
    y = c(rnorm(50, mean = 5), rnorm(50, mean = 7))
  )

  # Create a ggplot with stat_outliers
  p <- ggplot(df, aes(x = x, y = y, group = group)) +
    stat_outliers(aes(shape = group, color = after_stat(is_outlier)))

  # Test that the plot object is created successfully
  expect_s3_class(p, "ggplot")

  p <- ggplot(df, aes(x = x, y = y, group = group)) +
    stat_outliers(aes(shape = group, color = after_stat(is_outlier)), outlier_only = TRUE)
  expect_s3_class(p, "ggplot")

  # check that geom_label_repel works as well
  library(ggrepel)
  p <- ggplot(df, aes(x = x, y = y, group = group)) +
    stat_outliers(geom = "label_repel",
                          outlier_only = TRUE)
  expect_s3_class(p, "ggplot")

})


test_that("geom_bag works", {

  p <- ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_point() +
    geom_bag(aes(fill = Species), alpha = 0.3)
  expect_s3_class(p, "ggplot")

  p <- ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_point() +
    geom_bag(aes(fill = Species), alpha = 0.3, what = "loop")
  expect_s3_class(p, "ggplot")
})
