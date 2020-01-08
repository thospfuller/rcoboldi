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
        warning (
            paste (
                "The RCOBOL_JARS option is NULL so no additional dependencies have been added. You can add additional dependencies by setting",
                "the RCOBOL_JARS as follows: options(RCOBOL_JARS=list(\"C:/Temp/some.jar\")) prior to using this package (that means ",
                "*before* executing library (\"RCOBOL\").", sep="\n"))
    } else {
        info (
            paste (
                "Additional jars have been added to the rJava classpath.", sep="\n"))

        packageStartupMessage("rcobolJars: ", rcobolJars, sep="")
    }

    .jpackage(pkgname, lib.loc = libname, morePaths=rcobolJars)
}

#' This function must be called exactly one time before the package can be used.
#'
#' @export
#'
Initialize <- function () {

    .PrintWelcomeMessage()

    jCopyBookConverter <- J("com.coherentlogic.rproject.integration.rcobol.api.JCopyBookConverter")

    assign("jCopyBookConverter", jCopyBookConverter, envir = .rcobol.env)
}

#' This function delegates to the R COBOL Java API and returns the results as a data frame. 
#'
#' 
#'
#' @export
#'
ReadCopyBookAsDataFrame <- function (copyBookFile, inFile, String font, String sep, quote) {

    jCopyBookConverter <- .rcobol.env$jCopyBookConverter

    tryCatch(
        result <- jCopyBookConverter$readCopyBookAsString (copyBookFile, inFile, font, sep, quote), Throwable = function (e) {
            stop(
                paste ("Unable to read the copyBook and convert it into JSON; copyBookFile: ", copyBookFile, ", inFile: ", inFile, ", font: ", font, ", sep: ", sep, ", quote: ", quote, " -- details follow. ", e$getMessage(), sep="")
            )
        }
    )

    uncoercedResultDF <- as.data.frame(do.call("rbind", json_file))

    coercedResultDF <- t(uncoercedResultDF)

    retun as.data.frame(coercedResultDF)
}
