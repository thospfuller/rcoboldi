# RCOBOLDI

R COBOL DI (Data Integration) Package: An R package that facilitates the importation of COBOL CopyBook data directly into the R Project for Statistical Computing as properly structured data frames.

## Releases in Progress:
- Docker (based on Rocker)
- Linux

## Preconditions:
- Java 11
- The drat package has been installed.

# Example:

```library(drat)
drat::addRepo("thospfuller")

// The following should work for Mac OSX El Capitan.
install.packages("RCOBOLDI")

// Or install via source.
install.packages("RCOBOLDI", type = "source")

library("RCOBOLDI")
RCOBOLDI::Initialize()

/*
 * Substitute the directory path below with one which points to the test files being used.
 *
 * The test files below can be found here:
 *
 * https://github.com/thospfuller/rcoboldi/tree/master/java/rcoboldi-core/src/test/resources 
 */
result <- RCOBOLDI::ReadCopyBookAsDataFrame("/Users/thospfuller/development/projects/rcoboldi/java/rcoboldi-core/src/test/resources/example1/DTAR020.cbl", "/Users/thospfuller/development/projects/rcoboldi/java/rcoboldi-core/src/test/resources/example1/DTAR020.bin", "Fixed Length Binary", "cp037")
head(result)
result <- RCOBOLDI::ReadCopyBookAsDataFrame("/Users/thospfuller/development/projects/rcoboldi/java/rcoboldi-core/src/test/resources/example2/DTAR107.cbl", "/Users/thospfuller/development/projects/rcoboldi/java/rcoboldi-core/src/test/resources/example2/DTAR107.bin", "Fixed Length Binary", "cp037")
head(result)
result <- RCOBOLDI::ReadCopyBookAsDataFrame("/Users/thospfuller/development/projects/rcoboldi/java/rcoboldi-core/src/test/resources/example3/AmsLocation.cbl", "/Users/thospfuller/development/projects/rcoboldi/java/rcoboldi-core/src/test/resources/example3/Ams_LocDownload_20041228.txt", "Text", "cp1252")
```
