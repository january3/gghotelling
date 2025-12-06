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
    geom_hotelling(aes(group = group), ci = 0.95)

  # Test that the plot object is created successfully
  expect_s3_class(p, "ggplot")

  # Test that the layers include geom_hotelling
  layer_classes <- sapply(p$layers, function(layer) class(layer$geom)[1])
  expect_true("GeomHotelling" %in% layer_classes)

})

test_that("hotelling statistics are calculated correctly", {
  # use iris dataset for testing
  data(iris)
  iris_subset <- iris[ iris$Species == "setosa", 1:2 ]

  eli <- hotelling_ellipse(iris_subset, ci = 0.95, npoints = 10)

  # is eli a data frame?
  expect_s3_class(eli, "data.frame")

  expect_equal(nrow(eli), 10)
  expect_equal(ncol(eli), 2)

  eli <- hotelling_ellipse(as.matrix(iris_subset), ci = 0.95, npoints = 10)

  eli <- hotelling_ellipse(as.matrix(iris_subset), ci = 0.95, npoints = 10, type = "t2mean")
  eli <- hotelling_ellipse(as.matrix(iris_subset), ci = 0.95, npoints = 10, type = "data")

  # is eli a matrix?
  expect_true(is.matrix(eli))

  expect_error(hotelling_ellipse(iris, ci = 0.95, npoints = 10))
  expect_error(hotelling_ellipse(iris_subset[1:2, ], ci = 0.95, npoints = 10))

})

test_that("stat_hotelling_points works correctly", {
  library(ggplot2)

  # Create a sample dataset
  set.seed(123)
  df <- data.frame(
    group = rep(c("A", "B"), each = 50),
    x = c(rnorm(50, mean = 5), rnorm(50, mean = 7)),
    y = c(rnorm(50, mean = 5), rnorm(50, mean = 7))
  )

  # Create a ggplot with stat_hotelling_points
  p <- ggplot(df, aes(x = x, y = y, group = group)) +
    stat_hotelling_points(aes(shape = group, color = after_stat(outside)))

  # Test that the plot object is created successfully
  expect_s3_class(p, "ggplot")

  p <- ggplot(df, aes(x = x, y = y, group = group)) +
    stat_hotelling_points(aes(shape = group, color = after_stat(outside)), outlier_only = TRUE)
  expect_s3_class(p, "ggplot")

  # check that geom_label_repel works as well
  library(ggrepel)
  p <- ggplot(df, aes(x = x, y = y, group = group)) +
    stat_hotelling_points(geom = "label_repel",
                          outlier_only = TRUE)
  expect_s3_class(p, "ggplot")

})


test_that("hotelling point statistics are calculated correctly", {
  # use iris dataset for testing
  data(iris)
  iris_subset <- iris[ iris$Species == "setosa", 1:2 ]

  hp <- hotelling_points(iris_subset, type = "t2mean")
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), 3)
  expect_true(all(c("t2", "t2crit", "outside") %in% colnames(hp)))

  hp <- hotelling_points(as.matrix(iris_subset), type = "t2data")
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), 3)
  expect_true(all(c("t2", "t2crit", "outside") %in% colnames(hp)))

  expect_error(hotelling_points(iris))
  expect_error(hotelling_points(iris_subset[1:2, ]))

})
