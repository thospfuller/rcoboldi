# RCOBOLDI

R COBOL DI (Data Integration) Package: An R package that facilitates the importation of COBOL CopyBook data directly into the R Project for Statistical Computing as properly structured data frames.

Note that not all copybook files can be converted into CSV -- for example single-record type files can be converted to CSV however complicated multi-record type files will NOT map to CSV.

# Examples

## [Example One](SIMPLE_EXAMPLE.md) : Local package installation and then convert a COBOL data files into data frames.

Load the RCOBOLDI package locally and use it to convert COBOL data files into data frames. 

This example also includes a call to ```CobolToCSV```.

## [Docker Example](DOCKER_EXAMPLE.md) : If you just want to try the package on some test data, start here.

All you'll need to run this example is Docker and an Internet connection.

# Logging

The Java API uses Log4J and writes files to the ~/rcoboldi-package-logs/ directory. The Log4J configuration file can be found [here](java/rcoboldi-core/src/main/resources).

# See Also

- [AbsaOSS cobrix: A COBOL parser and Mainframe/EBCDIC data source for Apache Spark](https://github.com/AbsaOSS/cobrix)
- [JRecord: Read Cobol data files in Java on SourceForge](https://sourceforge.net/projects/jrecord/)
- [JRecord: Read Cobol data files in Java on GitHub](https://github.com/bmTas/JRecord)
- [EBCDIC](https://en.wikipedia.org/wiki/EBCDIC)

# Further Examples

![An example of the R COBOL DI (Data Integration) Package loading DTAR107 files (example 2) with the inputFileStructure set to "Fixed Length Binary" and the font set to "cp037".](https://github.com/thospfuller/rcoboldi/blob/master/images/RCOBOLDI_Example2_DTAR107.png "An example of the R COBOL DI (Data Integration) Package loading DTAR107 files (example 2) with the inputFileStructure set to 'Fixed Length Binary' and the font set to 'cp037'.")
![An example of the R COBOL DI (Data Integration) Package loading a file with the inputFileStructure set to "Text" and the font set to "cp1252".](https://github.com/thospfuller/rcoboldi/blob/master/images/RCOBOLDIPackageInActionForTextAndCP1252.png "An example of the R COBOL DI (Data Integration) Package loading a file with the inputFileStructure set to 'Text' and the font set to 'cp1252'.")

## Docker (rcoboldi:rocker-rstudio)

Follow [this link for instructions pertaining to setting up a Docker image and running a container using the R COBOL DI package](images/RCOBOLDI_StepOneBuildDockerImage.png).

result <- RCOBOLDI::ReadCopyBookAsDataFrame("/home/rstudio/rcoboldi/java/rcoboldi-core/src/test/resources/example1/DTAR020.cbl", "/home/rstudio/rcoboldi/java/rcoboldi-core/src/test/resources/example1/DTAR020.bin", "Fixed Length Binary", "cp037")

![An example of the R COBOL DI (Data Integration) Package loading a file with the inputFileStructure set to "Fixed Length Binary" and the font set to "cp037". This should work out-of-the-box with a container built from the rcoboldi:rocker-rstudio image."](https://github.com/thospfuller/rcoboldi/blob/master/images/RCOBOLDI-RockerRStudio.png "An example of the R COBOL DI (Data Integration) Package loading a file with the inputFileStructure set to 'Fixed Length Binary' and the font set to 'cp037'. This should work out-of-the-box with a container built from the rcoboldi:rocker-rstudio image.")
