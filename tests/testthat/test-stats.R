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
  eli <- hotelling_ellipse(as.matrix(iris_subset), level = 0.95, npoints = 10, type = "c2data")
  eli <- hotelling_ellipse(as.matrix(iris_subset), level = 0.95, npoints = 10, type = "c2data", robust = TRUE)

  # is eli a matrix?
  expect_true(is.matrix(eli))

  expect_error(hotelling_ellipse(iris, level = 0.95, npoints = 10))
  expect_error(hotelling_ellipse(iris_subset[1:2, ], level = 0.95, npoints = 10))

})


test_that("hotelling point statistics are calculated correctly", {
  # use iris dataset for testing
  data(iris)
  iris_subset <- iris[ iris$Species == "setosa", 1:2 ]
  cols <- c("d2", "t2crit", "c2crit", "is_outlier")

  hp <- outliers(iris_subset, type = "t2mean")
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), length(cols))
  expect_true(all(cols %in% colnames(hp)))

  hp <- outliers(as.matrix(iris_subset), type = "t2data")
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), length(cols))
  expect_true(all(cols %in% colnames(hp)))

  hp <- outliers(as.matrix(iris_subset), type = "t2data", robust = TRUE)
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), length(cols))
  expect_true(all(cols %in% colnames(hp)))

  hp <- outliers(as.matrix(iris_subset), type = "c2data")
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), length(cols))
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

