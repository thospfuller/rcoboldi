#!/bin/bash
# pwd = /home/travis/build/thospfuller/rcoboldi

mkdir $HOME/temp

git clone https://bitbucket.org/CoherentLogic/coherent-logic-enterprise-data-adapter.git $HOME/temp/eda
git clone https://bitbucket.org/CoherentLogic/jdataframe.git $HOME/temp/jdataframe

#
# The TLSv1.2 is here to fix a 'peer not authenticated' error which causes the build to fail
# when attempting to download dependencies from FuseSource.
#
cd $HOME/temp/eda/ && mvn clean install -DskipTests=true -U -Dhttps.protocols=TLSv1.2
cd $HOME/temp/jdataframe/ && mvn clean install -DskipTests=true -U

cd /home/travis/build/thospfuller/rcoboldi

wget https://sourceforge.net/projects/coboltocsv/files/CobolToCsv/Version_0.90/Cobol2Csv_0.90.zip -O $HOME/temp/Cobol2Csv_0.90.zip
wget https://sourceforge.net/projects/jrecord/files/jrecord/Version_0.90.3/JRecord_Version_0.90.3.zip -O $HOME/temp/JRecord_Version_0.90.3.zip
unzip $HOME/temp/Cobol2Csv_0.90.zip -d $HOME/temp/Cobol2Csv/
unzip $HOME/temp/JRecord_Version_0.90.3.zip -d $HOME/temp/jrecord

mvn install:install-file -Dfile=$HOME/temp/jrecord/lib/JRecord.jar -DgroupId=net.sf -DartifactId=jrecord -Dversion=0.90.2 -Dpackaging=jar
mvn install:install-file -Dfile=$HOME/temp/jrecord/lib/cb2xml.jar -DgroupId=net.sf -DartifactId=cb2xml -Dversion=0.90.2 -Dpackaging=jar
mvn install:install-file -Dfile=$HOME/temp/Cobol2Csv/lib/Cobol2Csv.jar -DgroupId=net.sf -DartifactId=cb2csv -Dversion=0.90 -Dpackaging=jar
