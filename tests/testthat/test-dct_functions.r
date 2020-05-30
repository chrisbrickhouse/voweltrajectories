test_that("dctprediction using all coefficients is identity", {
  data("VowelA")
  pred = dctprediction(10,VowelA)
  expect_equivalent(pred,VowelA)
})

test_that("getdct fills with zeros", {
  data("VowelA")
  coeffs = getdct(VowelA,3)
  expect_true(all(coeffs[,4:10]==0))
})

test_that("getdct throws error when n is too big", {
  data("VowelA")
  expect_error(getdct(VowelA,11),"Value of n must be less than the number of data points.")
})

test_that("dctdistance returns expected values",{
  data("VowelA")
  data("VowelB")
  expected = c(
    18.650274,
    21.042907, 
    32.771344, 
    16.969809, 
    15.202317, 
    24.253656, 
    10.180853, 
    22.553967, 
    7.1015920, 
    14.686821
    ) * 100000
  coeffA = getdct(VowelA,3)
  coeffB = getdct(VowelB,3)
  dist = dctdistance(coeffA,coeffB)
  expect_equal(floor(expected),floor(dist*100000))
})
