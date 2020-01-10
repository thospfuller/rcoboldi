#'
#' @title The RCOBOL Package for the R Project for Statistical Computing.
#'
#' @details Provides functions for reading COBOL CopyBook files into R as a data frame.
#'
#' @description The RCOBOL Package provides functions for reading COBOL CopyBook files into R as a data frame.
#' COBOL files must be structured such that they could be convertable into CSV formatted file. For example,
#' single record type files can be converted to CSV however complicated multi-record files will not map to
#' CSV.
#'
#' This package uses the open-source JRecord API, which is written in Java.
#'
#' More information about JRecord can be found here:
#'
#' https://github.com/bmTas/JRecord/
#'
#' \dontrun{
#' library(RCOBOL)
#' RCOBOL::Initialize()
#' RCOBOL::ReadCopyBookAsDataFrame("/Users/thospfuller/development/projects/rcobol/download/Examples/SchemaCompare/cobol_copybooks/DTAR020.cbl", "/Users/thospfuller/development/projects/rcobol/download/Source/JRecord/src/net/sf/JRecord/zTest/Common/SampleFiles/DTAR020.bin", "cp037", ",", "\"")
#' }
#'
#' \dontrun{
#' library(rJava)
#' library(RJSONIO)
#' .jinit()
#' .jaddClassPath("/Users/thospfuller/development/projects/rcobol/rcobol-api/rcobol-assembly/target/rcobol-assembly-1.0.0-RELEASE.jar")
#' jCopyBookConverter <- .jnew('com/coherentlogic/rproject/integration/rcobol/api/JCopyBookConverter')
#' copyBookFile <- "/Users/thospfuller/development/projects/rcobol/download/Examples/SchemaCompare/cobol_copybooks/DTAR020.cbl"
#' inFile <- "/Users/thospfuller/development/projects/rcobol/download/Source/JRecord/src/net/sf/JRecord/zTest/Common/SampleFiles/DTAR020.bin"
#' inFont <- "cp037"
#' result <- jCopyBookConverter$readCopyBookAsString (copyBookFile, inFile, inFont, ",", "\"")
#' resultAsJson <- RJSONIO::fromJSON(result)
#' uncoercedResultDF <- as.data.frame(do.call("rbind", resultAsJson))
#' coercedResultDF <- t(uncoercedResultDF)
#' resultAsDF <- as.data.frame(coercedResultDF)
#' head(resultAsDF)
#' }
#'
#' See also: https://github.com/s-u/rJava/issues/151
#'
#' sudo R CMD javareconf
#'
#' @import RJSONIO
#' @import rJava
#' @import rGroovy
#'
#' @docType package
#'
#' @name RCOBOL
#'
NULL

#'
#' An environment which is used by this package when managing package-scope variables.
#'
.rcobol.env <- new.env()

#' Function instantiates the client which is used to bridge the gap between the
#' R script and the underlying API.
#'
#' @param libname The library name.
#'
#' @param pkgname The package name.
#'
.onLoad <- function (libname, pkgname) {

    targetDir = paste ("-Djava.util.logging.config.file=", tempdir (), sep="")

    packageDir = paste ("-DrpackagePath=", system.file(package="rcobol"), sep="")

    rcobolJars = getOption ("RCOBOL_JARS")

    if (is.null(rcobolJars)) {
        rcobol <- list()
        message (
            paste (
                "The RCOBOL_JARS option is NULL so no additional dependencies have been added. You can add additional dependencies by setting the RCOBOL_JARS as follows: options(RCOBOL_JARS=list(\"C:/Temp/some.jar\")) prior to using this package (that means *before* executing library (\"RCOBOL\").", sep="\n"))
    } else {
        message (
            paste (
                "Additional jars have been added to the rJava classpath.", sep="\n"))

        packageStartupMessage("rcobolJars: ", rcobolJars, sep="")
    }

    .jpackage(pkgname, lib.loc = libname, morePaths=rcobolJars)
}

#' This function must be called *exactly one time* before the package can be used.
#'
#' @export
#'
Initialize <- function () {

    About()

    jCopyBookConverter <- .jnew('com/coherentlogic/rproject/integration/rcobol/api/JCopyBookConverter')
        #J("com.coherentlogic.rproject.integration.rcobol.api.JCopyBookConverter")

    #print (
    #    paste (
    #        "11111 jCopyBookConverter: ", jCopyBookConverter, sep="\n"))
    
    assign("jCopyBookConverter", jCopyBookConverter, envir = .rcobol.env)
}

#' This function delegates to the R COBOL Java API and returns the results as a data frame. 
#'
#' \dontrun{
#' RCOBOL::ReadCopyBookAsDataFrame("/Users/thospfuller/development/projects/rcobol/download/Examples/SchemaCompare/cobol_copybooks/DTAR020.cbl", "/Users/thospfuller/development/projects/rcobol/download/Source/JRecord/src/net/sf/JRecord/zTest/Common/SampleFiles/DTAR020.bin", "Fixed Length Binary", cp037", ",", "\"")
#' }
#'
#' Valid inputFileStructure values are as follows:
#'
#' "Default"
#' "Fixed Length Binary"
#' "Line based Binary"
#' "Mainframe VB (rdw based) Binary"
#' "Mainframe VB Dump: includes Block length"
#' "Fujitsu Cobol VB"
#' "GNU Cobol VB"
#'
#' @param copyBookFile The CopyBook file.
#' @param inFile The binary file.
#' @param inputFileStructure The input file structure, see above for possible values.
#' @param font The font.
#' @param sep The line separator.
#' @param quote The quote character. 
#'
#' @export
#'
ReadCopyBookAsDataFrame <- function (copyBookFile, inFile, inputFileStructure, font, sep, quote) {

    jCopyBookConverter <- .rcobol.env$jCopyBookConverter

    if (is.null(jCopyBookConverter)) {
        stop ("The Initialize function must be called exactly once prior to calling this function and it looks like this was not done.")
    }

    tryCatch(
        result <- jCopyBookConverter$readCopyBookAsString (copyBookFile, inFile, inputFileStructure, font, sep, quote), Throwable = function (e) {
            stop(
                paste ("Unable to read the copyBook and convert it into JSON; copyBookFile: ", copyBookFile, ", inFile: ", inFile, ", inputFileStructure: ", inputFileStructure,", font: ", font, ", sep: ", sep, ", quote: ", quote, " -- details follow. ", e$getMessage(), sep="")
            )
        }
    )
    
    resultAsJson <- RJSONIO::fromJSON(result)
    
    uncoercedResultDF <- as.data.frame(do.call("rbind", resultAsJson))

    coercedResultDF <- t(uncoercedResultDF)

    return( as.data.frame( coercedResultDF ) )
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
    cat (
        " Welcome to the RCOBOLDI (R COBOL Data Integration) Package, brought  \n",
        "to you by Coherent Logic Ltd.                                         \n",
        "                                                                      \n",
        "Follow Coherent Logic on LinkedIn here:                               \n",
        "                                                                      \n",
        "https://www.linkedin.com/company/229316/                              \n",
        "                                                                      \n",
        "And connect with the author of this package here:                     \n",
        "                                                                      \n",
        "https://www.linkedin.com/in/thomasfuller/                             \n",
        "                                                                      \n",
        "This package embeds the open-source JRecord API, which is written in  \n",
        "Java.                                                                 \n",
        "                                                                      \n",
        "More information about JRecord can be found here:                     \n",
        "                                                                      \n",
        "https://github.com/bmTas/JRecord/                                     \n",
        "                                                                      \n"
    )
}
