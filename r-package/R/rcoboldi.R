#'
#' @title The RCOBOLDI (R COBOL Data Integration) Package for the R Project for Statistical Computing.
#'
#' @details Provides functions for reading COBOL CopyBook files into R as a data frame.
#'
#' @description The RCOBOLDI Package provides functions for reading COBOL CopyBook files into R as a data frame.
#' COBOL files must be structured such that they could be convertable into CSV formatted file. For example,
#' single record type files can be converted to CSV however complicated multi-record files will not map to
#' CSV.
#'
#' This package uses the open-source \href{https://github.com/bmTas/JRecord/}{JRecord API}, which is written in Java.
#'
#' See also: \href{https://github.com/s-u/rJava/issues/151}{library(rJava) fails on Mac with JDK 8 or 10} -- if this happens then execute: \emph{sudo R CMD javareconf}
#'
#' @examples{
#'  \dontrun{
#'   library(RCOBOLDI)
#'   RCOBOLDI::Initialize()
#'   RCOBOLDI::ReadCopyBookAsDataFrame("~/temp/cobol_copybooks/DTAR020.cbl", "~/temp/DTAR020.bin", "cp037", ",", "\"")
#'   RCOBOLDI::CobolToCSV("-I ~/absaoss_cobrix_test1_example.bin -C ~/temp/absaoss_cobrix_test1_copybook.cob -FS Fixed_Length -IC cp037 -O ~/temp/absaoss_cobrix_test1.csv")
#'   }
#' }
#'
#' @import RJSONIO
#' @import rJava
#' @import logging
#'
#' @docType package
#'
#' @name RCOBOLDI
#'
NULL

#' An environment which is used by this package when managing package-scope variables.
#'
.rcoboldi.env <- new.env()

#' Function instantiates the client which is used to bridge the gap between the
#' R script and the underlying API.
#'
#' @param libname The library name.
#'
#' @param pkgname The package name.
#'
.onLoad <- function (libname, pkgname) {

    targetDir = paste ("-Djava.util.logging.config.file=", tempdir (), sep="")

    packageDir = paste ("-DrpackagePath=", system.file(package="rcoboldi"), sep="")

    rcobolJars = getOption ("RCOBOLDI_JARS")

    if (is.null(rcobolJars)) {
        rcobol <- list()
        message (
            paste (
                "The RCOBOLDI_JARS option is NULL so no additional dependencies have been added. You can add additional dependencies by setting the RCOBOLDI_JARS as follows: options(RCOBOLDI_JARS=list(\"C:/Temp/some.jar\")) prior to using this package (that means *before* executing 'library (\"RCOBOLDI\")'.", sep="\n"))
    } else {
        message (
            paste (
                "Additional jars have been added to the rJava classpath.", sep="\n"))

        packageStartupMessage("rcobolJars: ", rcobolJars, sep="")
    }

    .jpackage(pkgname, lib.loc = libname, morePaths=rcobolJars)
}

#' This function must be called \emph{exactly one time} before the package can be used.
#'
#' @param disableAbout When true the function will not print the about message (default: false).
#'
#' @examples{
#'  \dontrun{
#'   RCOBOLDI::Initialize()
#'  }
#' }
#'
#' @export
#'
Initialize <- function (disableAbout = FALSE) {

    if(!disableAbout) {
        RCOBOLDI::About()
    }

    if (!is.null (.rcoboldi.env$jCopyBookConverter)) {
        warning ("Initialize only needs to be called once per R session.")
    }

    jCopyBookConverter <- .jnew('com/coherentlogic/rproject/integration/rcoboldi/api/JCopyBookConverter')

    assign("jCopyBookConverter", jCopyBookConverter, envir = .rcoboldi.env)
}

#' This function should be called when the R session is ending and removes the
#' reference to the jCopyBookConverter from the package environment.
#'
#' Note that this function can be called many times and will not have any side
#' effects. We added this function in order to facilitate unit testing and to
#' add balance to the API.
#'
#' @examples{
#'  \dontrun{
#'   RCOBOLDI::Finalize()
#'  }
#' }
#'
#' @export
#'
Finalize <- function () {
  assign("jCopyBookConverter", NULL, envir = .rcoboldi.env)
}

#' This function converts the COBOL file into a data frame and returns this to the user. Note below that "cp1252" = \href{https://github.com/svn2github/jrecord/blob/master/Source/JRecord_Common/src/net/sf/JRecord/Common/Conversion.java}{Conversion.DEFAULT_ASCII_CHARSET}.
#'
#' @param copyBookFile The path to the copybook file, for example: "~/temp/DTAR020.cbl".
#' @param inFile The path to the inFile, for example: "~/temp/DTAR020.bin".
#' @param inputFileStructure The input file structure, for example: "Fixed Length Binary". Valid inputFileStructure values are as follows:
#'  "Default"
#'  "Fixed Length Binary"
#'  "Line based Binary"
#'  "Mainframe VB (rdw based) Binary"
#'  "Mainframe VB Dump: includes Block length"
#'  "Fujitsu Cobol VB"
#'  "GNU Cobol VB"
#' @param font The font, for example: "cp037"; see \href{https://github.com/svn2github/jrecord/blob/master/Source/JRecord_Common/src/net/sf/JRecord/Common/Conversion.java}{net.sf.JRecord.Common.Conversion} For example, "cp037", 
#' @param copybookDialect The copybookDialect defaults to 1 and it's unlikely that this will need to be changed; see \href{https://github.com/svn2github/jrecord/blob/master/Source/JRecord_Common/src/net/sf/JRecord/Numeric/ICopybookDialects.java}{ICopybookDialects.java}.
#'
#' @return The resultant data frame.
#'
#' @examples{
#'  \dontrun{
#'   result <- RCOBOLDI::ReadCopyBookAsDataFrame("../java/rcoboldi-core/src/test/resources/example1/DTAR020.cbl", "../java/rcoboldi-core/src/test/resources/example1/DTAR020.bin", "Fixed Length Binary", "cp037")
#'   result <- RCOBOLDI::ReadCopyBookAsDataFrame("../java/rcoboldi-core/src/test/resources/example2/DTAR107.cbl", "../java/rcoboldi-core/src/test/resources/example2/DTAR107.bin", "Fixed Length Binary", "cp037")
#'   result <- RCOBOLDI::ReadCopyBookAsDataFrame("../java/rcoboldi-core/src/test/resources/example3/AmsLocation.cbl", "../java/rcoboldi-core/src/test/resources/example3/Ams_LocDownload_20041228.txt", "Text", "cp1252")
#'   result <- RCOBOLDI::ReadCopyBookAsDataFrame("../java/rcoboldi-core/src/test/resources/cobrix-data/test1_copybook.cob", "../java/rcoboldi-core/src/test/resources/cobrix-data/test1_data/example.bin", "Fixed Length Binary", "cp037")
#'   result <- RCOBOLDI::ReadCopyBookAsDataFrame("../java/rcoboldi-core/src/test/resources/cobrix-data/test2_copybook.cob", "../java/rcoboldi-core/src/test/resources/cobrix-data/test2_data/example2.bin", "Fixed Length Binary", "cp037")
#'   result <- RCOBOLDI::ReadCopyBookAsDataFrame("../java/rcoboldi-core/src/test/resources/cobrix-data/test3_copybook.cob", "../java/rcoboldi-core/src/test/resources/cobrix-data/test3_data/TRAN2.AUG31.DATA.dat", "Fixed Length Binary", "cp037")
#'  }
#' }
#'
#' @export
#'
ReadCopyBookAsDataFrame <- function (copyBookFile, inFile, inputFileStructure, font, copybookDialect="1") {

    jCopyBookConverter <- .rcoboldi.env$jCopyBookConverter

    if (is.null(jCopyBookConverter)) {
        stop ("The Initialize function must be called exactly once prior to calling this function and it looks like this was not done.")
    }

    tryCatch(
        result <- jCopyBookConverter$readCopyBookAsString (copyBookFile, inFile, inputFileStructure, font, copybookDialect), Throwable = function (e) {
            stop(
                paste ("Unable to read the copyBook and convert it into JSON; copyBookFile: ", copyBookFile, ", inFile: ", inFile, ", inputFileStructure: ", inputFileStructure,", font: ", font, " -- details follow. Keep in mind that single-record type files can be converted to CSV however complicated multi-record type files will NOT map to CSV.", e$getMessage(), sep="")
            )
        }
    )

    resultAsJson <- RJSONIO::fromJSON(result)

    uncoercedResultDF <- as.data.frame(do.call("rbind", resultAsJson))

    coercedResultDF <- t(uncoercedResultDF)

    return( as.data.frame( coercedResultDF ) )
}

#' Function delegates via the JCopyBookConverter to the Cobol2Csv.runCobol2Csv method passing the args as a single string. Note that the args are *exactly* the same as those passed to Cobol2Csv.runCobol2Csv.
#'
#' Documentation for all args can be found here:
#' 
#' SF: \href{https://sourceforge.net/p/jrecord/wiki/Cobol2Csv%2C%20Csv2Cobol/}{Cobol2Csv, Csv2Cobol programs}
#'
#' GH: \href{https://github.com/bmTas/JRecord/blob/master/Source/JRecord_Utilities/JRecord_Cbl2Csv/src/net/sf/JRecord/cbl2csv/Cobol2Csv.java}{See net.sf.JRecord.cbl2csv.Cobol2Csv.runCobol2Csv on GitHub}
#'
#' @param args The same args that would be passed in when executing Cobol2Csv from the command line.
#'
#' @examples{
#'   \dontrun{
#'     RCOBOLDI::CobolToCSV("-I ~/temp/absaoss_cobrix_test1_example.bin -C ~/temp/absaoss_cobrix_test1_copybook.cob -FS Fixed_Length -IC cp037 -O ~/temp/absaoss_cobrix_test1.csv")
#'   }
#' }
#'
#' @export
#'
CobolToCSV <- function (args) {
  
  jCopyBookConverter <- .rcoboldi.env$jCopyBookConverter
  
  if (is.null(jCopyBookConverter)) {
    stop ("The Initialize function must be called exactly once prior to calling this function and it looks like this was not done.")
  }
  
  tryCatch(
    result <- jCopyBookConverter$cobol2Csv (args), Throwable = function (e) {
      stop(
        paste (
          "The call to cobolToCSV failed; args: ",
          args,
          "!! Note that not all copybook files can be converted into CSV. Keep in mind that single-record type files can be converted to CSV however complicated multi-record type files will NOT map to CSV.",
          e$getMessage(), sep="\n"
        )
      )
    }
  )
}

#' Function prints some information about this package.
#'
#' @examples
#'  \dontrun{
#'      About()
#'  }
#'
#' @export
#'
About <- function () {

  packageWelcomeTxtFile <- system.file("extdata/welcome.txt", package="RCOBOLDI", mustWork=TRUE)

  logging::loginfo (cat ("packageWelcomeTxtFile: ", packageWelcomeTxtFile, sep=""))

  welcomeConnection <- NULL

  tryCatch(
    welcomeConnection <- file(packageWelcomeTxtFile), Throwable = function (e) {

      logger::logerror (cat("Unable to read the welcome.txt file; packageWelcomeTxt: ",
        packageWelcomeTxtFile, e$getMessage(), sep=""))
    }
  )

  welcomeText <- readLines(con = welcomeConnection)

  cat(welcomeText, sep='\n')

  if (!is.null(welcomeConnection) && isOpen(welcomeConnection)) {
    close(welcomeConnection)
  }
}