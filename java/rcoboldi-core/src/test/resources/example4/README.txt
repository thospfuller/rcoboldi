These files have been borrowed from the AbsaOSS / cobrix project located here:

https://github.com/AbsaOSS/cobrix/

example.bin under https://github.com/AbsaOSS/cobrix/tree/master/data/test1_data

and

test1_copybook.cob under https://github.com/AbsaOSS/cobrix/tree/master/data

-----

"Fixed Length Binary" with cp037 is the correct option

12 ACCOUNT-DETAIL OCCURS 80
DEPENDING ON NUMBER-OF-ACCTS.
 
These lines of the Cobol copybook are relevant - not all array elements are used. The NUMBER-OF-ACCTS fields holds the array size. Also programmers will use spaces / low-values / high-values for `NULL`

I'm seeing "Unable to read the copyBook and convert it into JSON; copyBookFile: /Users/thospfuller/development/projects/rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_copybook.cob, inFile: /Users/thospfuller/development/projects/rcoboldi-gh/rcoboldi/java/rcoboldi-core/src/test/resources/example4/absaoss_cobrix_test1_example.bin, inputFileStructure: Fixed Length Binary, font: cp037 -- details follow. Invalid sign in field: ACCOUNT-TYPE-N (1) 0 > 404040"

In this case do
   line.getFieldVavalue("ACCOUNT-TYPE-N (1)").isFieldPresent() to check if it is a valid field. This check
* If the field is long enough
* Any occurs depending
 
There are also methods to check for spaces/low-value/high values. All three should be converted to null.Perhaps some thing like
     fv= line.getFieldVavalue("ACCOUNT-TYPE-N (1)");
    if (fv.isSpaces || fv.iLowValues() || ffv.isHighValues()) {
        result = null;
   } else if (! fv.isPresent()) {
       result = null; //????
  } else {
       ...
  }
