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
#' This package uses the open-source JRecord API, which is written in Java.
#'
#' More information about JRecord can be found here:
#'
#' https://github.com/bmTas/JRecord/
#'
#' \dontrun{
#' library(RCOBOLDI)
#' RCOBOLDI::Initialize()
#' RCOBOLDI::ReadCopyBookAsDataFrame("/Users/thospfuller/development/projects/rcobol/download/Examples/SchemaCompare/cobol_copybooks/DTAR020.cbl", "/Users/thospfuller/development/projects/rcobol/download/Source/JRecord/src/net/sf/JRecord/zTest/Common/SampleFiles/DTAR020.bin", "cp037", ",", "\"")
#' }
#'
#' See also: https://github.com/s-u/rJava/issues/151
#'
#' sudo R CMD javareconf
#'
#' @import RJSONIO
#' @import rJava
#'
#' @docType package
#'
#' @name RCOBOLDI
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

#' This function must be called *exactly one time* before the package can be used.
#'
#' @param disableAbout When true the function will not print the about message (default: false).
#'
#' @export
#'
Initialize <- function (disableAbout = FALSE) {

    if(!disableAbout) {
        About()
    }

    jCopyBookConverter <- .jnew('com/coherentlogic/rproject/integration/rcoboldi/api/JCopyBookConverter')
        #J("com.coherentlogic.rproject.integration.rcoboldi.api.JCopyBookConverter")
    
    assign("jCopyBookConverter", jCopyBookConverter, envir = .rcobol.env)
}

#' This function delegates to the R COBOL Java API and returns the results as a data frame. 
#'
#' Note below that "cp1252" = Conversion.DEFAULT_ASCII_CHARSET.
#'
#' \dontrun{
#' result <- RCOBOLDI::ReadCopyBookAsDataFrame("../java/rcoboldi-core/src/test/resources/example1/DTAR020.cbl", "../java/rcoboldi-core/src/test/resources/example1/DTAR020.bin", "Fixed Length Binary", "cp037")
#' result <- RCOBOLDI::ReadCopyBookAsDataFrame("../java/rcoboldi-core/src/test/resources/example2/DTAR107.cbl", "../java/rcoboldi-core/src/test/resources/example2/DTAR107.bin", "Fixed Length Binary", "cp037")
#' result <- RCOBOLDI::ReadCopyBookAsDataFrame("../java/rcoboldi-core/src/test/resources/example3/AmsLocation.cbl", "../java/rcoboldi-core/src/test/resources/example3/Ams_LocDownload_20041228.txt", "Text", "cp1252")
#' result <- RCOBOLDI::ReadCopyBookAsDataFrame("/Users/thospfuller/development/projects/rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_copybook.cob", "/Users/thospfuller/development/projects/rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_example.bin", "Fixed Length Binary", "cp037")
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
#' @export
#'
ReadCopyBookAsDataFrame <- function (copyBookFile, inFile, inputFileStructure, font, copybookDialect="1") {

    jCopyBookConverter <- .rcobol.env$jCopyBookConverter

    if (is.null(jCopyBookConverter)) {
        stop ("The Initialize function must be called exactly once prior to calling this function and it looks like this was not done.")
    }

    tryCatch(
        result <- jCopyBookConverter$readCopyBookAsString (copyBookFile, inFile, inputFileStructure, font, copybookDialect), Throwable = function (e) {
            stop(
                paste ("Unable to read the copyBook and convert it into JSON; copyBookFile: ", copyBookFile, ", inFile: ", inFile, ", inputFileStructure: ", inputFileStructure,", font: ", font, " -- details follow. ", e$getMessage(), sep="")
            )
        }
    )

    resultAsJson <- RJSONIO::fromJSON(result)

    uncoercedResultDF <- as.data.frame(do.call("rbind", resultAsJson))

    coercedResultDF <- t(uncoercedResultDF)

    return( as.data.frame( coercedResultDF ) )
}

#' Function delegates to the Cobol2Csv.runCobol2Csv method.
#'
#' [See net.sf.JRecord.cbl2csv.Cobol2Csv.runCobol2Csv on GitHub.](https://github.com/bmTas/JRecord/blob/master/Source/JRecord_Utilities/JRecord_Cbl2Csv/src/net/sf/JRecord/cbl2csv/Cobol2Csv.java)
#'
#' @param inputFile 	: Input file
#' @param outputFile	: Output file
#' @param copybook 	: Cobol Copybook file
#' @param delimiter 	: Field Separator (space, tab or value)
#' @param quote 	: Quote, you can use DoubleQuote SingleQuote as well
#' @param inputCharacterSet  	: Input font or character set
#' @param outputCharacterSet  	: Output font or character set
#'
#' @param inputFileStructure	: Input File Structure:
#' @param outputFileStructure	: Output File Structure:
#'  Default	: Determine by
#'  Text	: Use Standard Text IO
#'  Fixed_Length	: Fixed record Length binary
#'  Binary	: Binary File, length based on record
#'  Mainframe_VB	: Mainframe VB File
#'  Mainframe_VB_As_RECFMU	: Mainframe VB File including BDW (block descriptor word)
#'  FUJITSU_VB	: Fujitsu Cobol VB File
#'  Gnu_Cobol_VB	: Gnu Cobol VB File
#'  UNICODE_CSV_NAME_1ST_LINE	Standard Csv file with colum names on the first line
#'  Text_Unicode	Csv file with out colum names on the first line
#' @param dialect	: Cobol Dialect
#'  0  or Intel	: Intel little endian
#'  1  or Mainframe	: Mainframe big endian (Default)
#'  4  or GNU_Cobol_Little_Endian_(Intel)	: Gnu:Cobol
#'  2 or Fujitsu	: Fujitsu Cobol
#' @param rename  : How to update cobol variable names
#'  0 or Asis	: Use the COBOL name
#'  0 or Leave_Asis	: Use the COBOL name
#'  1 or _	: Change '-(),' to '_'
#'  1 or Change_Minus_To_Underscore	: Change '-(),' to '_'
#'  2 or No-	: Drop minus ('-') from the name
#'  2 or Drop_Minus	: Drop minus ('-') from the name
#'  3 or camelCase	: Camel Case
#' @param csvParser  : Controls how Csv fields are parsed
#'  14 or Basic_Parser	: Parse Csv - when a field starts with " look for "<FieldSeparator> or "<eol>
#'   1 or Standard_Parser	: Parse CSV matching Quotes
#'   2 or Standard_Parse_Quote_4_Char_Fields	: Standard Parser, add Quotes to all Char fields
#'   3 or Basic_Parser_Column_names_in_quotes	: Basic Parser, Field (Column) names in Quotes
#'   4 or Standard_Parser_Column_names_in_quotes	: Standard Parser, Field (Column) names in Quotes
#'   5 or Standard_Parser_Quote_4_Char_Fields_Column_names_in_quotes	: Standard Parser, Char fields in Quotes,  Field (Column) names in Quotes
#'   6 or Basic_Parser_Delimiter_all_fields	: Basic Parser, Field Separator for all fields
#'   7 or Basic_Parser_Delimiter_all_fields+1	: Basic Parser, Field Separator for all fields + extra Separator at the End-of-Line
#'
CobolToCSV <- function (inputFile, outputFile, copybook, delimiter, quote, inputCharacterSet, outputCharacterSet, inputFileStructure, outputFileStructure, dialect, rename, csvParser) {
  
  jCopyBookConverter <- .rcobol.env$jCopyBookConverter
  
  if (is.null(jCopyBookConverter)) {
    stop ("The Initialize function must be called exactly once prior to calling this function and it looks like this was not done.")
  }
  
  tryCatch(
    result <- jCopyBookConverter$cobolToCSV (inputFile, outputFile, copybook, delimiter, quote, inputCharacterSet, outputCharacterSet, inputFileStructure, outputFileStructure, dialect, rename, csvParser), Throwable = function (e) {
      stop(
        paste ("The call to cobolToCSV failed; inputFile: ", inputFile, ", outputFile: ", outputFile, ", copybook: ", copybook, ", delimiter: ", delimiter, ", quote: ", quote, ", inputCharacterSet: ", inputCharacterSet, ", outputCharacterSet: ", outputCharacterSet, "inputFileStructure: ", inputFileStructure, ", outputFileStructure: ", outputFileStructure, ", dialect: ", dialect, ", rename: ", rename, ", csvParser: ", csvParser, " -- details follow. ", e$getMessage(), sep="")
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
    cat (
        "                                                                               \n",
        "    ______      __                         __     __               _           \n",
        "   / ____/___  / /_  ___  ________  ____  / /_   / /  ____  ____ _(_)____      \n",
        "  / /   / __ \\/ __ \\/ _ \\/ ___/ _ \\/ __ \\/ __/  / /  / __ \\/ __ `/ / ___/\n",
        " / /___/ /_/ / / / /  __/ /  /  __/ / / / /_   / /__/ /_/ / /_/ / / /__        \n",
        " \\____/\\____/_/ /_/\\___/_/   \\___/_/ /_/\\__/  /_____|____/\\__, /_/\\___/ \n",
        "                                                         /____/                \n",
        " RCOBOLDI (R COBOL Data Integration) Package 1.0.0-RELEASE                     \n",
        "                                                                               \n",
        " Brought to you by: https://coherentlogic.com                                  \n",
        "                                                                               \n",
        " Software Engineering and Data Analytics                                       \n",
        " McLean, VA USA                                                                \n",
        "                                                                               \n",
        "  Follow : https://www.linkedin.com/company/229316/                            \n",
        " Connect : https://www.linkedin.com/in/thomasfuller/                           \n",
        "    Like : https://github.com/thospfuller/rcoboldi/                            \n",
        "           https://github.com/bmTas/JRecord/                                   \n",
        "                                                                               \n"
    )
}

