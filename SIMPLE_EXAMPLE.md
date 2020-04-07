# Simple Example

In this simple example the R COBOL Data Integration package has been installed locally and several data files are
converted into data frames using the ReadCopyBookAsDataFrame function; the CobolToCSV function is also demonstrated.

## Preconditions

The following should be executed prior to attempting to run the R script, below.

- [R version 3.6.3](https://cran.r-project.org/bin/)
- Java 11
- install.packages(c("drat", "RJSONIO", "rJava"))

If you have trouble with rJava and Java 11 then you might need to execute the following:

```R CMD javareconf```

## R Script Example

The following example should work with the only change needed being the path to the files.

Test files can be found [here](java/rcoboldi-core/src/test/resources).

```
library(drat)

drat::addRepo("thospfuller")

# The following should work for Mac OSX (El Capitan) and on Linux.
install.packages("RCOBOLDI")

# Or install via source (for Windows users, specifically).
install.packages("RCOBOLDI", type = "source")

library("RCOBOLDI")
RCOBOLDI::Initialize()

#
# Substitute the directory path below with one which points to the test files being used.
# 
# The test files below can be found here:
# 
# https://github.com/thospfuller/rcoboldi/tree/master/java/rcoboldi-core/src/test/resources 
#
result <- RCOBOLDI::ReadCopyBookAsDataFrame(".../rcoboldi/java/rcoboldi-core/src/test/resources/example1/DTAR020.cbl", "/Users/thospfuller/development/projects/rcoboldi/java/rcoboldi-core/src/test/resources/example1/DTAR020.bin", "Fixed Length Binary", "cp037")
head(result)
result <- RCOBOLDI::ReadCopyBookAsDataFrame(".../rcoboldi/java/rcoboldi-core/src/test/resources/example2/DTAR107.cbl", "/Users/thospfuller/development/projects/rcoboldi/java/rcoboldi-core/src/test/resources/example2/DTAR107.bin", "Fixed Length Binary", "cp037")
head(result)
result <- RCOBOLDI::ReadCopyBookAsDataFrame(".../rcoboldi/java/rcoboldi-core/src/test/resources/example3/AmsLocation.cbl", "/Users/thospfuller/development/projects/rcoboldi/java/rcoboldi-core/src/test/resources/example3/Ams_LocDownload_20041228.txt", "Text", "cp1252")
cobrix_test1_result <- RCOBOLDI::ReadCopyBookAsDataFrame(".../rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_copybook.cob", "/Users/thospfuller/development/projects/rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_example.bin", "**TBD**", "**TBD**")
head(cobrix_test1_result)
result <- RCOBOLDI::ReadCopyBookAsDataFrame(".../rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_copybook.cob", "/Users/thospfuller/development/projects/rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_example.bin", "Fixed Length Binary", "cp037")

#
# The following line will convert the absaoss_cobrix_test1 data file into a CSV file.
#
RCOBOLDI::CobolToCSV("-I .../rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_example.bin -C .../rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_copybook.cob -FS Fixed_Length -IC cp037 -O .../temp/absaoss_cobrix_test1.csv")
```

## Example Output

![An example of the R COBOL DI (Data Integration) Package in use.](images/RCOBOLDIPackageInAction.png "An example of the R COBOL DI (Data Integration) Package in use.")