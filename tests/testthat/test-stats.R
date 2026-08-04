test_that("hotelling statistics are calculated correctly", {
  # use iris dataset for testing
  data(iris)
  iris_subset <- iris[ iris$Species == "setosa", 1:2 ]

  eli <- hotelling_ellipse(iris_subset, level = 0.95, npoints = 10)
  expect_s3_class(eli, "data.frame")
  expect_equal(nrow(eli), 10)
  expect_equal(ncol(eli), 2)
  expect_all_true(abs(eli[["x"]] -
c(5.83477670874117, 5.41587022536314, 4.80518090833754, 4.28845707615641,
  4.107479552643, 4.34692973239038, 4.89476621510242, 5.49465022199386,
  5.86588935927208, 5.83477670874117)) < 1e-6)
  expect_all_true(abs(eli[["y"]] - c(4.342, 4.332, 3.899, 3.246, 2.678, 2.461,
                                   2.696, 3.274, 3.924, 4.342)) < 1e-3)

  eli <- hotelling_ellipse(as.matrix(iris_subset), level = 0.95, npoints = 10)
  expect_type(eli, "double")
  expect_equal(nrow(eli), 10)
  expect_equal(ncol(eli), 2)

  eli <- hotelling_ellipse(as.matrix(iris_subset), level = 0.95, npoints = 10, type = "t2mean")
  expect_type(eli, "double")
  expect_equal(nrow(eli), 10)
  expect_equal(ncol(eli), 2)

  eli <- hotelling_ellipse(as.matrix(iris_subset), level = 0.95, npoints = 10, type = "c2data")
  expect_type(eli, "double")
  expect_equal(nrow(eli), 10)
  expect_equal(ncol(eli), 2)

  eli <- hotelling_ellipse(as.matrix(iris_subset), level = 0.95, npoints = 10, type = "c2data", robust = TRUE)
  expect_type(eli, "double")
  expect_equal(nrow(eli), 10)
  expect_equal(ncol(eli), 2)


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

  hp <- outliers(iris_subset)
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), length(cols))
  expect_true(all(cols %in% colnames(hp)))
  expect_equal(sum(hp$is_outlier), 2)

  hp <- outliers(iris_subset, level =.99)
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), length(cols))
  expect_true(all(cols %in% colnames(hp)))
  expect_equal(sum(hp$is_outlier), 0)

  hp <- outliers(iris_subset, level =.90)
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), length(cols))
  expect_true(all(cols %in% colnames(hp)))
  expect_equal(sum(hp$is_outlier), 4)

  hp <- outliers(iris_subset, type = "t2mean")
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), length(cols))
  expect_true(all(cols %in% colnames(hp)))
  expect_equal(sum(hp$is_outlier), 44)

  hp <- outliers(as.matrix(iris_subset), type = "t2data")
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), length(cols))
  expect_true(all(cols %in% colnames(hp)))
  expect_equal(sum(hp$is_outlier), 2)

  hp <- outliers(as.matrix(iris_subset), type = "t2data", robust = TRUE)
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), length(cols))
  expect_true(all(cols %in% colnames(hp)))
  expect_equal(sum(hp$is_outlier), 5)

  hp <- outliers(as.matrix(iris_subset), type = "c2data")
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), length(cols))
  expect_true(all(cols %in% colnames(hp)))
  expect_equal(sum(hp$is_outlier), 2)

  hp <- outliers(as.matrix(iris_subset), type = "c2data", robust = TRUE)
  expect_s3_class(hp, "data.frame")
  expect_equal(ncol(hp), length(cols))
  expect_true(all(cols %in% colnames(hp)))
  expect_equal(sum(hp$is_outlier), 5)


  # checking for p == 2
  expect_error(outliers(iris))

  # checking for n > p
  expect_error(outliers(iris_subset[1:2, ]))

})

test_that(".expanded_range works correctly", {
  # Test the .expanded_range function
  r <- .expanded_range(1:10)
  expect_equal(r, c(-1.25, 12.25))

  r <- .expanded_range(1:100, scale = 0.2)
  expect_equal(r, c(-18.8, 119.8))

})

test_that("boundary cases are tested", {

  x <- matrix(0, ncol = 2, nrow = 10)
  expect_error(outliers(x), "Covariance matrix is singular")
  expect_error(hotelling_ellipse(x), "Covariance matrix is singular")

  x <- matrix(1:2, ncol = 2, nrow = 1)
  expect_error(outliers(x), "Need n > p to compute")
  expect_error(hotelling_ellipse(x), "Need n > p to compute")
})
