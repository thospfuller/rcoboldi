context ("Test RCOBOLDI package")

test_that (
    "Calling Finalize twice does not raise an error.",
    {
        skip_on_cran()
        
        RCOBOLDI::Finalize ()
        RCOBOLDI::Finalize ()
    }
)

test_that (
    "Calling Initialize twice does not raise an error.",
    {
        # This test also acts as a precondition for the following tests since it calls the
        # Initialize function.
        #
        # There's still some issue with these tests in that when they're executed via test()
        # they all pass, whereas when they're executing via check() we see two failures.

        skip_on_cran()

        RCOBOLDI::Initialize ()

        expect_warning (RCOBOLDI::Initialize ())

        RCOBOLDI::Finalize()
    }
)

test_that (
    "Calling ReadCopyBookAsDataFrame stops when not initialized.",
    {
        skip_on_cran()

        copyBookFile <- paste(getwd(), "/../../../java/rcoboldi-core/src/test/resources/example1/DTAR020.cbl", sep="")
        inFile       <- paste(getwd(), "/../../../java/rcoboldi-core/src/test/resources/example1/DTAR020.bin", sep="")
                
        expect_error(RCOBOLDI::ReadCopyBookAsDataFrame(copyBookFile, inFile, "Fixed Length Binary", "cp037"))
    }
)

test_that (
    "Calling ReadCopyBookAsDataFrame with valid params returns a valid data frame.",
    {
        skip_on_cran()

        RCOBOLDI::Initialize()

        copyBookFile <- paste(getwd(), "/../../../java/rcoboldi-core/src/test/resources/example1/DTAR020.cbl", sep="")
        inFile       <- paste(getwd(), "/../../../java/rcoboldi-core/src/test/resources/example1/DTAR020.bin", sep="")

        result <- RCOBOLDI::ReadCopyBookAsDataFrame(copyBookFile, inFile, "Fixed Length Binary", "cp037")

        expect_that(nrow(result), equals(379))

        RCOBOLDI::Finalize()
    }
)