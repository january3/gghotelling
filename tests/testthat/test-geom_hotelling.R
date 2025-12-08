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

test_that("hotelling statistics are calculated correctly", {
  # use iris dataset for testing
  data(iris)
  iris_subset <- iris[ iris$Species == "setosa", 1:2 ]

  eli <- hotelling_ellipse(iris_subset, level = 0.95, npoints = 10)

  # is eli a data frame?
  expect_s3_class(eli, "data.frame")

  expect_equal(nrow(eli), 10)
  expect_equal(ncol(eli), 2)

  eli <- hotelling_ellipse(as.matrix(iris_subset), level = 0.95, npoints = 10)
  eli <- hotelling_ellipse(as.matrix(iris_subset), level = 0.95, npoints = 10, type = "t2mean")
  eli <- hotelling_ellipse(as.matrix(iris_subset), level = 0.95, npoints = 10, type = "data")
  eli <- hotelling_ellipse(as.matrix(iris_subset), level = 0.95, npoints = 10, type = "data", robust = TRUE)

  # is eli a matrix?
  expect_true(is.matrix(eli))

  expect_error(hotelling_ellipse(iris, level = 0.95, npoints = 10))
  expect_error(hotelling_ellipse(iris_subset[1:2, ], level = 0.95, npoints = 10))

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


test_that("hotelling point statistics are calculated correctly", {
  # use iris dataset for testing
  data(iris)
  iris_subset <- iris[ iris$Species == "setosa", 1:2 ]
  cols <- c("t2", "t2crit", "c2", "c2crit", "is_outlier")

  hp <- outliers(iris_subset, type = "t2mean")
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), 5)
  expect_true(all(cols %in% colnames(hp)))

  hp <- outliers(as.matrix(iris_subset), type = "t2data")
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), 5)
  expect_true(all(cols %in% colnames(hp)))

  hp <- outliers(as.matrix(iris_subset), type = "t2data", robust = TRUE)
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), 5)
  expect_true(all(cols %in% colnames(hp)))

  hp <- outliers(as.matrix(iris_subset), type = "data")
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), 5)
  expect_true(all(cols %in% colnames(hp)))

  expect_error(outliers(iris))
  expect_error(outliers(iris_subset[1:2, ]))

})

test_that(".expanded_range works correctly", {
  # Test the .expanded_range function
  r <- .expanded_range(1:10)
  expect_equal(r, c(-1.25, 12.25))

  r <- .expanded_range(1:100, scale = 0.2)
  expect_equal(r, c(-18.8, 119.8))

})
