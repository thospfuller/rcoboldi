package com.coherentlogic.rproject.integration.rcoboldi.api;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import net.sf.JRecord.Common.FieldDetail;
import net.sf.JRecord.Details.fieldValue.FieldValueSmallBin;
import net.sf.JRecord.JRecordInterface1;
import net.sf.JRecord.Option.IReformatFieldNames;
import net.sf.JRecord.Types.Type;
import net.sf.JRecord.Types.TypeManager;
import net.sf.JRecord.cbl2csv.args.FieldNameUpdaters;
import net.sf.JRecord.cbl2csv.args.ParseArgsCobol2Csv;
import static net.sf.JRecord.cbl2csv.args.ParseArgsCobol2Csv.Option;
import static net.sf.JRecord.cbl2csv.args.ParseArgsCobol2Csv.RO_CHANGE_MINUS_TO_UNDERSCORE;

import net.sf.JRecord.def.IO.builders.ICobolIOBuilder;
import net.sf.JRecord.def.IO.builders.ICsvIOBuilder;
import net.sf.JRecord.def.IO.builders.IDefineCsvFields;
import net.sf.JRecord.utilityClasses.Copy;
import net.sf.JRecord.Option.ICobolSplitOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.coherentlogic.rproject.integration.dataframe.adapters.RemoteAdapter;
import com.coherentlogic.rproject.integration.dataframe.builders.JDataFrameBuilder;
import com.coherentlogic.rproject.integration.dataframe.domain.JDataFrame;
import com.jamonapi.Monitor;
import com.jamonapi.MonitorFactory;

import net.sf.JRecord.Details.AbstractLine;
import net.sf.JRecord.Details.LayoutDetail;
import net.sf.JRecord.Details.RecordDetail;
import net.sf.JRecord.External.CobolCopybookLoader;
import net.sf.JRecord.External.CopybookLoader;
import net.sf.JRecord.External.ExternalRecord;
import net.sf.JRecord.External.base.ExternalConversion;
import net.sf.JRecord.IO.AbstractLineReader;
import net.sf.JRecord.IO.LineIOProvider;
import net.sf.JRecord.Log.TextLog;
import net.sf.JRecord.Numeric.ICopybookDialects;
import net.sf.cb2xml.def.Cb2xmlConstants;

import net.sf.JRecord.cbl2csv.args.CommonCsv2CblCode;

/**
 * Offers functionality for converting COBOL CopyBook files into either JDataFrame or JSON (String).
 *
 * @author <a href="mailto:thomas.fuller@coherentlogic.com">Thomas P. Fuller</a>
 * @see <a href="https://github.com/svn2github/jrecord/blob/master/ReadMe.md">ReadMe.md for JRecord</a>
 */
public class JCopyBookConverter {

    private static final Logger log = LoggerFactory.getLogger(JCopyBookConverter.class);

    static class PassThroughUpdateFieldName implements IUpdateFieldName {
        public String updateName(String name) {
            return name;
        }
    }

    private final LineIOProvider ioProvider = new LineIOProvider();

    private JDataFrameBuilder<String, String[]> readCopyBookAsJDataFrameBuilder(
            AbstractLineReader reader,
            LayoutDetail layout,
            String font,
            IUpdateFieldName updateFldName
    ) throws IOException {

        final Monitor monitor = MonitorFactory.start("readCopyBookAsJDataFrameBuilder method");

        log.debug("readCopyBookAsJDataFrameBuilder: method begins; font: " + font +
                ", updateFldName: " + updateFldName);

        JDataFrameBuilder<String, String[]> result =
                new JDataFrameBuilder<String, String[]>(
                        new JDataFrame<String, String[]>(),
                        new RemoteAdapter<String, String[]>()
                );

        AbstractLine line;

        RecordDetail rec = layout.getRecord(0);

        for (int ctr = 1; ctr < rec.getFieldCount(); ctr++) {

            var header = (updateFldName.updateName(rec.getField(ctr).getName()));

            log.debug("(first scan) header: " + header);

            result.getDataFrame().addOrReturnExistingColumn(header);
        }

        int idx;

        while ((line = reader.read()) != null) {

            idx = line.getPreferredLayoutIdx();

            if (0 <= idx) {

                for (int ctr = 1; ctr < layout.getRecord(idx).getFieldCount(); ctr++) {

                    var header = rec.getField(ctr).getName();

                    var value = line.getFieldValue(idx, ctr);

                    var formattedValue = (String) null;

                    if (value != null && !(value.isSpaces() || value.isLowValues() || value.isHighValues()) && value.isFieldPresent())
                        formattedValue = value.asString();

                    log.debug("header: " + header + ", value: " + value + ", formattedValue: " + formattedValue);

                    result
                            .getDataFrame()
                            .addOrReturnExistingColumn(header)
                            .addValues(new String[]{formattedValue});
                }
            }
        }

        monitor.stop();

        log.debug("readCopyBookAsJDataFrameBuilder: method ends; performance monitor: " + monitor +
                ", result.statistics: " + result.getDataFrame().getStatistics() + ", result: (set level to trace)");

        if (log.isTraceEnabled()) {
            log.trace("result: " + result);
        }

        return result;
    }

    /**
     * TODO: Add: binFormat, splitCopybookOption, copybookFormat, inputFileStructure
     * <p>
     * https://github.com/svn2github/jrecord/blob/master/Source/JRecord/src/net/sf/JRecord/External/CopybookLoader.java
     *
     * @param copyBookFile
     * @param inFile
     * @param font
     * @param updateFldName
     * @return
     * @throws IOException
     */
    public String readCopyBookAsString(
            String copyBookFile,
            String inFile,
            int inputFileStructure,
            String font,
            int copybookDialect,
            IUpdateFieldName updateFldName
    ) throws IOException {

        final Monitor monitor = MonitorFactory.start("readCopyBookAsJDataFrameBuilder method");

        log.debug("readCopyBookAsString: method begins; copyBookFile: " + copyBookFile + ", inFile: " + inFile +
                ", inputFileStructure (int): " + inputFileStructure + ", font: " + font + ", updateFldName: " +
                updateFldName);

        // #62 https://github.com/svn2github/jrecord/blob/master/Source/JRecord/src/net/sf/JRecord/zExamples/cobol/toCsv/Cobol2CsvAlternative.java

        CobolCopybookLoader conv = new CobolCopybookLoader();

        ExternalRecord schema;

        // #126 https://github.com/bmTas/JRecord/blob/master/Source/JRecord_Project/JRecord/src/net/sf/JRecord/zExamples/cobol/toCsv/ParseArgsCobol2Csv.java
        var binFormat = copybookDialect; // ICopybookDialects.FMT_MAINFRAME; 

        schema = conv.loadCopyBook(
                copyBookFile,
                CopybookLoader.SPLIT_NONE, // splitCopybookOption, see https://github.com/svn2github/jrecord/blob/master/Source/JRecord/src/net/sf/JRecord/External/CopybookLoader.java
                0,
                font,
                Cb2xmlConstants.USE_STANDARD_COLUMNS, // Copybook line format
                binFormat,
                0,
                new TextLog()
        );

        /*
         * int fileStructure = Constants.IO_FIXED_LENGTH;
         *
         * ./Source/JRecord_Common/src/net/sf/JRecord/External/Def/BasicConversion.java
         *
         * https://github.com/svn2github/jrecord/blob/master/Source/JRecord_Common/src/net/sf/JRecord/Common/Constants.java
         * http://jrecord.sourceforge.net/JRecord04.html#Header_10
         * https://github.com/svn2github/jrecord/blob/master/Docs/JRecordIntro.htm
         * http://jrecord.sourceforge.net/JRecord05.html
         *
         * -OFS or -OutputFileStructure -- Output File Structure:
         *
         * 0  Default                : Determine by Copybook
         * 1  Text                   : Use Standard Text IO
         * 4  Fixed_Length           : Fixed record Length binary
         * 7  Mainframe_VB           : Mainframe VB File
         * 8  Mainframe_VB_As_RECFMU : Mainframe VB File including BDW (block descriptor word)
         * 10 FUJITSU_VB             : Fujitsu Cobol VB File
         * ?? Open_Cobol_VB          : Gnu Cobol VB File
         *
         * @see net.sf.JRecord.IO.AbstractLineIOProvider#getStructureName(int)
         */
//        Fixed_Width: Every record is a constant length
//        VB: each record is preceded by its lenngth
//        VB_Dump: variation of VB - less important.
//        Standard_Text: Standard Windows / Unix Text file for when files are converted to ascii
//        (The only advantage JRecord has over standard R is it understands Mainframe Zoned
        //var inputFileStructure = Constants.IO_FIXED_LENGTH;

        schema.setFileStructure(inputFileStructure);

        var layout = schema.asLayoutDetail();

        AbstractLineReader reader = ioProvider.getLineReader(layout);

        reader.open(inFile, layout);

        var result = readCopyBookAsJDataFrameBuilder(reader, layout, font, updateFldName);

        reader.close();

        String serializedResult = (String) result.serialize();

        monitor.stop();

        log.debug("readCopyBookAsString: method returns; performance monitor: " + monitor +
                ", serializedResult: (set level to trace)");

        if (log.isTraceEnabled()) {
            log.trace("serializedResult: " + serializedResult);
        }

        log.info("jDataFrame.statistics: " + result.getDataFrame().getStatistics() +
                ", Java performance statistics are: " + monitor);

        return serializedResult;
    }

    public String readCopyBookAsString(
            String copyBookFile,
            String inFile,
            String inputFileStructure,
            String font,
            int copybookDialect,
            IUpdateFieldName updateFldName
    ) throws IOException {

        log.debug("readCopyBookAsString: method invoked; copyBookFile: " + copyBookFile + ", inFile: " + inFile +
                ", inputFileStructure: " + inputFileStructure + ", font: " + font + ", updateFldName: " + updateFldName);

        int inputFileStructureNumber = getFileStructure(inputFileStructure);

        return readCopyBookAsString(
                copyBookFile,
                inFile,
                inputFileStructureNumber,
                font,
                copybookDialect,
                updateFldName
        );
    }

    static boolean equalsAnyOf(String value, String... anyOfThese) {

        boolean result = false;

        for (String next : anyOfThese)
            if (value != null && value.equals(next)) {
                result = true;
                break;
            }

        return result;
    }

    /**
     * Valid values include:
     * <p>
     * "Default"
     * "Fixed Length Binary"
     * "Line based Binary"
     * "Mainframe VB (rdw based) Binary"
     * "Mainframe VB Dump: includes Block length"
     * "Fujitsu Cobol VB"
     * "GNU Cobol VB"
     *
     * @param inputFileStructure
     * @return
     * @see https://github.com/thethoughtcoder/jrecord/blob/master/JRecord/src/net/sf/JRecord/External/ExternalConversion.java
     * @see https://github.com/svn2github/jrecord/blob/master/Source/JRecord/src/net/sf/JRecord/IO/LineIOProvider.java (435)
     * @see net.sf.JRecord.External.Def.BasicConversion for the list of acceptible string values that can be passed as inputFileStructure.
     * @see ExternalConversion.getFileStructure (#157)
     */
    static int getFileStructure(String inputFileStructure) {

        /*
         * ioFixedLength,                  // 2 -- #62, See Constants #77
         * ioVB,                           // 4 -- #66, See Constants #81
         * ioVBDump,                       // 5 -- #67, See Constants #82
         * ioStandardTextFile              // 1 -- #??, See Constants #74.
         * //What about: ioDefault         // standardText; // 58?
         */

        log.debug("inputFileStructure: " + inputFileStructure);

        if (!equalsAnyOf(
                inputFileStructure,
                "Default",
                "Fixed Length Binary",
                "Line based Binary",
                "Mainframe VB (rdw based) Binary",
                "Mainframe VB Dump: includes Block length",
                "Fujitsu Cobol VB",
                "GNU Cobol VB"
        )
        ) {
            String message = "The inputFileStructure value '" + inputFileStructure + "' is not recognized!" +
                    " A default value will be used instead of the inputFileStructure provided and hence the conversion may " +
                    "or may not complete successfully.";

            log.warn(message);
        }

        /* Takes a db index param or file structure string and returns the file structure.
         *
         * Warning: Insofar as the code for the ExternalConversion.getFileStructure (#157) method goes, the first param
         *          is unused and hence has no impact.
         */
        int UNUSED = -9999;

        int result = ExternalConversion.getFileStructure(UNUSED, inputFileStructure);

        log.debug("getFileStructure: method ends; result: " + result);

        return result;
    }

    /**
     * Invokes the {@link #readCopyBookAsString(String, String, int, String, String, String, IUpdateFieldName)} method
     * using an instance of PassThroughUpdateFieldName for the updateFldName.
     *
     * @param inputFileStructure One of: ioStandardTextFile (1), ioFixedLength (2), ioVB (4), or ioVBDump (5).
     */
    public String readCopyBookAsString(
            String copyBookFile,
            String inFile,
            String inputFileStructure,
            String font,
            String copybookDialect
    ) throws IOException {

        log.debug("readCopyBookAsString: method invoked; copyBookFile: " + copyBookFile + ", inFile: " + inFile +
                ", inputFileStructure: " + inputFileStructure + ", font: " + font +
                ", copybookDialect: " + copybookDialect);

        int inputFileStructureNumber = getFileStructure(inputFileStructure);

        return readCopyBookAsString(
                copyBookFile,
                inFile,
                inputFileStructureNumber,
                font,
                Integer.valueOf(copybookDialect),
                new PassThroughUpdateFieldName()
        );
    }

    /**
     * @see <a href="https://github.com/bmTas/JRecord/blob/master/Source/JRecord_Utilities/JRecord_Cbl2Csv/src/net/sf/JRecord/cbl2csv/Cobol2Csv.java">Cobol2Csv.java (development/temp/Cobol2Csv_0.90/Cobol2Csv)</a>
     */
    public void cobolToCSV(String inputFile, String outputFile, String copybook, String delimiter, String quote, String inputCharacterSet, String outputCharacterSet, String inputFileStructure, String outputFileStructure, String dialect, String rename, String csvParser) {

        log.debug("cobolToCSV: method begins; inputFile: " + inputFile + ", outputFile: " + outputFile + ", copybook: " + copybook + ", delimiter: " + delimiter + ", quote: " + quote + ", inputCharacterSet: " + inputCharacterSet + ", outputCharacterSet: " + outputCharacterSet + "inputFileStructure: " + inputFileStructure + ", outputFileStructure: " + outputFileStructure + ", dialect: " + dialect + ", rename: " + rename + ", csvParser: " + csvParser);

        ICobolIOBuilder iobCbl = JRecordInterface1.COBOL
                .newIOBuilder(copybook)
                .setOptimizeTypes(false);

        iobCbl.setFileOrganization(Integer.parseInt(inputFileStructure))
                .setFont(inputCharacterSet)//inFont)
                .setDialect(Integer.parseInt(dialect));//csvArgs.binFormat);

        ICsvIOBuilder iobCsv = JRecordInterface1.CSV
                .newIOBuilder(delimiter, quote)//csvArgs.sep, csvArgs.quote)
                .setFont(outputCharacterSet)//csvArgs.outFont)
                .setParser(Integer.parseInt(csvParser))//csvArgs.csvParser)
                .setFileOrganization(Integer.parseInt(outputFileStructure));//csvArgs.outputFileStructure);

        IDefineCsvFields defineFields = iobCsv.defineFields();
        LayoutDetail cobolLayout = null;

        try {
            cobolLayout = iobCbl.getLayout();
        } catch (IOException ioException) {
            throw new IORuntimeException("Unable to get the iobCbl layout using the following params: inputFile: " + inputFile
                    + ", outputFile: " + outputFile + ", copybook: " + copybook + ", delimiter: " + delimiter
                    + ", quote: " + quote + ", inputCharacterSet: " + inputCharacterSet + ", outputCharacterSet: "
                    + outputCharacterSet + "inputFileStructure: " + inputFileStructure + ", outputFileStructure: "
                    + outputFileStructure + ", dialect: " + dialect + ", rename: " + rename + ", csvParser: "
                    + csvParser,
                    ioException);
        }

        IUpdateFieldName updateFieldName;

        if (cobolLayout.getRecordCount() != 1) {
            log.error("Expecting exactly one record, not " + cobolLayout.getRecordCount());
        } else {
//            TODO: For now we're not updating CSV names -- we can sort this out later.
//            updateCsvNames(cobolLayout, csvArgs, defineFields);    // Update the field names (change -(,) to _)
            defineFields.endOfRecord();
            try {
                Copy.copyFileByFieldNumber(
                    iobCbl.newReader(inputFile),//new FileInputStream(inputFile)),
                    iobCsv.newWriter(outputFile),//new FileOutputStream(outputFile),
                    iobCsv.getLayout()
                );

            } catch (IOException ioException) {
                throw new IORuntimeException("Unable to get the iobCsv layout using the following params: inputFile: " + inputFile
                        + ", outputFile: " + outputFile + ", copybook: " + copybook + ", delimiter: " + delimiter
                        + ", quote: " + quote + ", inputCharacterSet: " + inputCharacterSet + ", outputCharacterSet: "
                        + outputCharacterSet + "inputFileStructure: " + inputFileStructure + ", outputFileStructure: "
                        + outputFileStructure + ", dialect: " + dialect + ", rename: " + rename + ", csvParser: "
                        + csvParser,
                        ioException);
            }
        }

        log.debug("cobolToCSV: method ends.");
    }

//    private final Option[] SPLIT_OPTS = {
//            SPLIT_NONE,
//            SPLIT_01,
//            SPLIT_REDEFINE,
//            new Option(ICobolSplitOptions.SPLIT_HIGHEST_REPEATING, "Highest", "On Highest Repeating level"),
//    };
//
//    int getOptionCode(String s, Option[] options, int defaultCode) {
//
//        int ret = defaultCode;
//        if (s.length() > 0) {
//            for (int i = 0; i < options.length; i++) {
//                if (options[i].display.equalsIgnoreCase(s)) {
//                    return options[i].code;
//                }
//            }
//
//            try {
//                ret = Integer.parseInt(s);
//            } catch (Exception e) { }
//        }
//
//        return ret;
//    }
//
//    public static final int RO_LEAVE_ASIS = 0;
//    public static final int RO_CHANGE_MINUS_TO_UNDERSCORE = 1;
//    public static final int RO_DROP_MINUS = 2;
//
//    String updateName(String renameOptStr, Option[] renameOptions, String name) {
//
//        net.sf.JRecord.cbl2csv.IUpdateFieldName updateFieldName = FieldNameUpdaters.NO_UPDATE;
//
//        int renameOption = getOptionCode(renameOptStr, renameOptions, RO_CHANGE_MINUS_TO_UNDERSCORE);
//
//        switch (renameOption) {
//            case IReformatFieldNames.RO_UNDERSCORE:
//                updateFieldName = FieldNameUpdaters.TO_UNDERSCORE;
//                break;
//            case IReformatFieldNames.:
//                updateFieldName = FieldNameUpdaters.DROP_MINUS;
//                break;
//            case IReformatFieldNames.RO_CAMEL_CASE:
//                updateFieldName = FieldNameUpdaters.TO_CAMEL_CASE;
//                break;
//
//            case FieldNameUpdaters.RO_LEAVE_ASIS:
//            default:
//                updateFieldName = FieldNameUpdaters.NO_UPDATE;
//        }
//
//        return updateFieldName.updateName(name);
//    }

//    TODO: Need to swap out the CL IUpdateFieldName with the one in net.sf.JRecord.cbl2csv.
//    /**
//     * See <a href="https://github.com/bmTas/JRecord/blob/master/Source/JRecord_Utilities/JRecord_Cbl2Csv/src/net/sf/JRecord/cbl2csv/args/CommonCsv2CblCode.java">CommonCsv2CblCode.updateCsvNames</a>
//     * See <a href="https://github.com/bmTas/JRecord/blob/master/Source/JRecord_Utilities/JRecord_Cbl2Csv/src/net/sf/JRecord/cbl2csv/args/ParseArgsCobol2Csv.java">net.sf.JRecord.cbl2csv.args.ParseArgsCobol2Csv.updateName</a>
//     */
//    static void updateCsvNames(LayoutDetail schema, IDefineCsvFields defineFields) {
//
//        FieldDetail field;
//        int fieldCount = schema.getRecord(0).getFieldCount();
//        for (int i = 0; i < fieldCount; i++) {
//            field = schema.getField(0, i);
//            if (TypeManager.isNumeric(field.getType())) {
//                defineFields.addCsvField(updateName(field.getName()), Type.ftNumAnyDecimal, 0);
//            } else {
//                defineFields.addCsvField(updateName(field.getName()), Type.ftChar, 0);
//            }
//        }
//    }
}
