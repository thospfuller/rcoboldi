library("testthat")
library("RCOBOLDI")

Sys.setenv("R_TESTS" = "")
test_check("RCOBOLDI")
