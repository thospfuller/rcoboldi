# RCOBOLDI

R COBOL DI (Data Integration) Package: An R package that facilitates the importation of COBOL CopyBook data directly into the R Project for Statistical Computing as properly structured data frames.

Note that not all copybook files can be converted into CSV -- for example single-record type files can be converted to CSV however complicated multi-record type files will NOT map to CSV.

# Example

The following example is running in R version 3.6.3 with Java version "11.0.2".

![An example of the R COBOL DI (Data Integration) Package in use.](https://github.com/thospfuller/rcoboldi/blob/master/images/RCOBOLDIPackageInAction.png "An example of the R COBOL DI (Data Integration) Package in use.")

## Preconditions

The following should be executed prior to attempting to run the R script, below.

- [R version 3.6.3](https://cran.r-project.org/bin/)
- Java 11
- install.packages(c("drat", "RJSONIO", "rJava"))

## R Script

The following example should work with the only change needed being the path to the files.

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
cobrix_test1_result <- RCOBOLDI::ReadCopyBookAsDataFrame("/Users/thospfuller/development/projects/rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_copybook.cob", "/Users/thospfuller/development/projects/rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_example.bin", "**TBD**", "**TBD**")
head(cobrix_test1_result)
result <- RCOBOLDI::ReadCopyBookAsDataFrame("/Users/thospfuller/development/projects/rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_copybook.cob", "/Users/thospfuller/development/projects/rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_example.bin", "Fixed Length Binary", "cp037")
RCOBOLDI::CobolToCSV("-I /Users/thospfuller/development/projects/rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_example.bin -C /Users/thospfuller/development/projects/rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_copybook.cob -FS Fixed_Length -IC cp037 -O /Users/thospfuller/temp/absaoss_cobrix_test1.csv")
```

# Logging

The Java API uses Log4J and writes files to the ~/rcoboldi-package-logs/ directory.

# Work in Progress
- Docker (based on Rocker)

# Development Notes

1.) Install [CobolToCsv](https://sourceforge.net/projects/coboltocsv/files/CobolToCsv/Version_0.90/).
2.) Install [JRecord](https://github.com/svn2github/jrecord).
3.) From rcoboldi/java execute: mvn clean package.

See also:

[JRecord_Utilities](https://sourceforge.net/p/jrecord/code/HEAD/tree/Source/JRecord_Utilities/)

## Linux Only

1. sudo add-apt-repository -y ppa:cran/poppler
2. sudo apt-get update
3. sudo sudo apt-get install -y libpoppler-cpp-dev
4. sudo apt-get install -y libxml2-dev
5. install.packages(c("rversions", "xml2", "roxygen2"))
6. At this point "Configure Build Tools" should show the option to use Roxygen.
7. install.packages("pdftools") // May not be necessary.

# See Also

- [AbsaOSS cobrix: A COBOL parser and Mainframe/EBCDIC data source for Apache Spark](https://github.com/AbsaOSS/cobrix)
- [JRecord: Read Cobol data files in Java on SourceForge](https://sourceforge.net/projects/jrecord/)
- [JRecord: Read Cobol data files in Java on GitHub](https://github.com/bmTas/JRecord)

# Further Examples

![An example of the R COBOL DI (Data Integration) Package loading a file with the inputFileStructure set to "Text" and the font set to "cp1252".](https://github.com/thospfuller/rcoboldi/blob/master/images/RCOBOLDIPackageInActionForTextAndCP1252.png "An example of the R COBOL DI (Data Integration) Package loading a file with the inputFileStructure set to 'Text' and the font set to 'cp1252'.")
