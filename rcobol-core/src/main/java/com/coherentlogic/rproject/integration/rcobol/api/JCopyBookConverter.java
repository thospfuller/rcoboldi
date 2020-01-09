package com.coherentlogic.rproject.integration.rcobol.api;

import java.io.IOException;

import com.coherentlogic.rproject.integration.dataframe.adapters.RemoteAdapter;
import com.coherentlogic.rproject.integration.dataframe.builders.JDataFrameBuilder;
import com.coherentlogic.rproject.integration.dataframe.domain.JDataFrame;

import net.sf.JRecord.Common.Constants;
import net.sf.JRecord.Common.Conversion;
import net.sf.JRecord.Details.AbstractLine;
import net.sf.JRecord.Details.LayoutDetail;
import net.sf.JRecord.Details.RecordDetail;
import net.sf.JRecord.External.CobolCopybookLoader;
import net.sf.JRecord.External.CopybookLoader;
import net.sf.JRecord.External.ExternalRecord;
import net.sf.JRecord.IO.AbstractLineReader;
import net.sf.JRecord.IO.LineIOProvider;
import net.sf.JRecord.Log.TextLog;
import net.sf.JRecord.Numeric.ICopybookDialects;
import net.sf.cb2xml.def.Cb2xmlConstants;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 
 * @see <a href="https://github.com/svn2github/jrecord/blob/master/ReadMe.md">ReadMe.md for JRecord</a>
 * 
 * @author <a href="mailto:thomas.fuller@coherentlogic.com">Thomas P. Fuller</a>
 */
public class JCopyBookConverter {

    private static final Logger log = LoggerFactory.getLogger(JCopyBookConverter.class);

    static class PassThroughUpdateFieldName implements IUpdateFieldName {
        public String updateName(String name) { return name; }
    }

    private final LineIOProvider ioProvider = new LineIOProvider();

    private JDataFrameBuilder<String, String[]> readCopyBookAsJDataFrameBuilder (
        AbstractLineReader reader,
        LayoutDetail layout,
        String font,
        String sep,
        String quote,
        IUpdateFieldName updateFldName
    ) throws IOException {

        JDataFrameBuilder<String, String[]> result =
            new JDataFrameBuilder<String, String[]> (
                new JDataFrame<String, String[]> (),
                new RemoteAdapter<String, String[]> ()
            );

        AbstractLine line;

        RecordDetail rec = layout.getRecord(0);

        for (int ctr = 1; ctr < rec.getFieldCount(); ctr++) {

            var header = (sep + updateFldName.updateName(rec.getField(ctr).getName()));

            log.debug ("(first scan) header: " + header);

            result.getDataFrame().addOrReturnExistingColumn (header);
        }

        int idx;

        while ((line = reader.read()) != null) {

            idx = line.getPreferredLayoutIdx();

            if (0 <= idx) {

                for (int ctr = 1; ctr < layout.getRecord(idx).getFieldCount(); ctr++) {

                    var header = rec.getField(ctr).getName();

                    var value = formatField(line.getFieldValue(idx, ctr).asString(), sep, quote);

                    log.debug("header: " + header + ", value: " + value);

                    result
                        .getDataFrame()
                        .addOrReturnExistingColumn(header)
                        .addValues( new String [] { value.toString() });
                }
            }
        }

        return result;
    }

    /**
     * Invokes the {@link #readCopyBookAsString(String, String, String, String, IUpdateFieldName)} using an instance of
     * PassThroughUpdateFieldName for the updateFldName.
     */
    public String readCopyBookAsString(String copyBookFile, String inFile, String font, String sep, String quote) throws IOException {
        return readCopyBookAsString(copyBookFile, inFile, font, sep, quote, new PassThroughUpdateFieldName());
    }

    public String readCopyBookAsString(
        String copyBookFile,
        String inFile,
        String font,
        String sep,
        String quote,
        IUpdateFieldName updateFldName
    ) throws IOException {

        // #62 https://github.com/svn2github/jrecord/blob/master/Source/JRecord/src/net/sf/JRecord/zExamples/cobol/toCsv/Cobol2CsvAlternative.java

        CobolCopybookLoader conv = new CobolCopybookLoader();

        ExternalRecord schema;

        // #126 https://github.com/bmTas/JRecord/blob/master/Source/JRecord_Project/JRecord/src/net/sf/JRecord/zExamples/cobol/toCsv/ParseArgsCobol2Csv.java
        var binFormat = ICopybookDialects.FMT_MAINFRAME; 

        schema = conv.loadCopyBook(
            copyBookFile,
            CopybookLoader.SPLIT_NONE,
            0,
            font,
            Cb2xmlConstants.USE_STANDARD_COLUMNS,
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
         * ?? Open_Cobol_VB</b>      : Gnu Cobol VB File
         *
         * @see net.sf.JRecord.IO.AbstractLineIOProvider#getStructureName(int)
         */
        var inputFileStructure = Constants.IO_FIXED_LENGTH;// -IFS IO_DEFAULT;

        schema.setFileStructure(inputFileStructure);

        var layout = schema.asLayoutDetail();

        AbstractLineReader reader = ioProvider.getLineReader(layout);

        reader.open(inFile, layout);
//            "/Users/thospfuller/development/projects/rcobol/download/"
//            + "Source/JRecord/src/net/sf/JRecord/zTest/Common/SampleFiles/DTAR020.bin", layout);
//            //+ "Source/JRecord/src/net/sf/JRecord/zTest/Common/SampleFiles/DTAR020.bin", layout);

        var result = readCopyBookAsJDataFrameBuilder (reader, layout, font, sep, quote, updateFldName);

        reader.close();

        return (String) result.serialize();
    }

    private String formatField(Object value, String sep, String quote) {
        String v;
        if (value == null) {
            v = "";
        } else {
            v = value.toString();
            if (quote.length() == 0) {
                v = value.toString();
            } else if (v.indexOf(quote) >= 0) {
                StringBuilder sb = new StringBuilder(v);
                Conversion.replace(sb, quote, quote + quote);
                v = quote + sb.toString() + quote;
            } else if (v.indexOf(sep) >= 0 || v.indexOf('\n') > 0) {
                v = quote + v + quote;
            }
        }

        return v;
    }
}
