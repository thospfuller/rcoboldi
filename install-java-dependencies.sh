#!/bin/bash
mkdir ~/temp

git clone https://github.com/thospfuller/rcoboldi.git ~/temp/rcoboldi
git clone https://bitbucket.org/CoherentLogic/coherent-logic-enterprise-data-adapter.git ~/temp/eda
git clone https://bitbucket.org/CoherentLogic/jdataframe.git ~/temp/jdataframe

wget https://sourceforge.net/projects/coboltocsv/files/CobolToCsv/Version_0.90/Cobol2Csv_0.90.zip -P ~/temp/
wget https://sourceforge.net/projects/jrecord/files/jrecord/Version_0.90.3/JRecord_Version_0.90.3.zip -P ~/temp/
unzip ./temp/Cobol2Csv_0.90.zip -d ~/temp/Cobol2Csv/
unzip ./temp/JRecord_Version_0.90.3.zip -d ~/temp/jrecord

cd ~/temp/eda/ && mvn clean install -DskipTests=true -U
cd ~/temp/jdataframe/ && mvn clean install -DskipTests=true -U

mvn install:install-file -Dfile=~/temp/jrecord/lib/JRecord.jar -DgroupId=net.sf -DartifactId=jrecord -Dversion=0.90.2 -Dpackaging=jar
mvn install:install-file -Dfile=~/temp/jrecord/lib/cb2xml.jar -DgroupId=net.sf -DartifactId=cb2xml -Dversion=0.90.2 -Dpackaging=jar
mvn install:install-file -Dfile=~/temp/Cobol2Csv/lib/Cobol2Csv.jar -DgroupId=net.sf -DartifactId=cb2csv -Dversion=0.90 -Dpackaging=jar
