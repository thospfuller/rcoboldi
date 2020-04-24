#!/bin/bash
pwd
mkdir ~/temp

git clone https://bitbucket.org/CoherentLogic/coherent-logic-enterprise-data-adapter.git ~/temp/eda
git clone https://bitbucket.org/CoherentLogic/jdataframe.git ~/temp/jdataframe

#
# The TLSv1.2 is here to fix a 'peer not authenticated' error which causes the build to fail
# when attempting to download dependencies from FuseSource.
#
cd ~/temp/eda/ && mvn clean install -DskipTests=true -U -Dhttps.protocols=TLSv1.2
cd ~/temp/jdataframe/ && mvn clean install -DskipTests=true -U

wget https://sourceforge.net/projects/coboltocsv/files/CobolToCsv/Version_0.90/Cobol2Csv_0.90.zip -P ~/temp/ -O Cobol2Csv_0.90.zip
wget https://sourceforge.net/projects/jrecord/files/jrecord/Version_0.90.3/JRecord_Version_0.90.3.zip -P ~/temp/ -O JRecord_Version_0.90.3.zip
unzip ~/temp/Cobol2Csv_0.90.zip -d ~/temp/Cobol2Csv/
unzip ~/temp/JRecord_Version_0.90.3.zip -d ~/temp/jrecord

mvn install:install-file -Dfile=~/temp/jrecord/lib/JRecord.jar -DgroupId=net.sf -DartifactId=jrecord -Dversion=0.90.2 -Dpackaging=jar
mvn install:install-file -Dfile=~/temp/jrecord/lib/cb2xml.jar -DgroupId=net.sf -DartifactId=cb2xml -Dversion=0.90.2 -Dpackaging=jar
mvn install:install-file -Dfile=~/temp/Cobol2Csv/lib/Cobol2Csv.jar -DgroupId=net.sf -DartifactId=cb2csv -Dversion=0.90 -Dpackaging=jar
