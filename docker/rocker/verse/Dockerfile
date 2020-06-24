#
# This script sets up rocker/verse with the RCOBOLDI project.
#
# ----- Testing begins -----
#
# docker stop $(docker ps -aq) && docker rm $(docker ps -aq) && docker rmi $(docker images -q)
#
# docker stop $(docker ps -aq)
# docker rm $(docker ps -aq)
# docker rmi $(docker images -q)
# docker build ./docker
#
# -----
#
# docker run -d -p 8787:8787 -e PASSWORD=password --name rstudio -i -t [id]
# docker exec -it clrstudio /bin/bash
#
FROM rocker/verse:latest

RUN su -
RUN apt-get update
RUN sudo apt-get -y install apt-utils
RUN sudo apt-get -y install openjdk-11-jre openjdk-11-jdk

RUN R CMD javareconf

RUN chown rstudio:rstudio /usr/local/lib/R/
RUN chown -R rstudio:rstudio /usr/local/lib/R/

RUN R -e 'install.packages("rJava")'
RUN R -e 'install.packages("drat")'

RUN sudo apt-get update

RUN sudo apt-get install -y git
RUN sudo apt-get install -y maven
RUN sudo apt-get install -y nano

RUN git clone https://github.com/thospfuller/rcoboldi.git /home/rstudio/rcoboldi
RUN git clone https://bitbucket.org/CoherentLogic/coherent-logic-enterprise-data-adapter.git /home/rstudio/eda
RUN git clone https://bitbucket.org/CoherentLogic/jdataframe.git /home/rstudio/jdataframe
#
# RUN git clone https://github.com/bmTas/JRecord.git /home/rstudio/jrecord
# https://sourceforge.net/projects/coboltocsv/
# RUN wget https://sourceforge.net/projects/coboltocsv/files/CobolToCsv/Version_0.90/Cobol2Csv_0.90.zip
# RUN unzip Cobol2Csv_0.90.zip
# https://sourceforge.net/projects/jrecord/files/jrecord/Version_0.90.3/
#
# RUN git clone https://git.code.sf.net/p/coboltocsv/code /home/rstudio/coboltocsv-code
#
RUN wget https://sourceforge.net/projects/coboltocsv/files/CobolToCsv/Version_0.90/Cobol2Csv_0.90.zip
RUN wget https://sourceforge.net/projects/jrecord/files/jrecord/Version_0.90.3/JRecord_Version_0.90.3.zip

RUN unzip Cobol2Csv_0.90.zip -d /home/rstudio/
RUN unzip JRecord_Version_0.90.3.zip -d /home/rstudio/jrecord

RUN sudo chown -R rstudio:rstudio /home/rstudio/Cobol2Csv/
RUN sudo chown -R rstudio:rstudio /home/rstudio/Cobol2Csv/*
RUN sudo chown -R rstudio:rstudio /home/rstudio/jrecord/*
RUN sudo chown -R rstudio:rstudio /home/rstudio/eda/*
RUN sudo chown -R rstudio:rstudio /home/rstudio/eda/.git/
RUN sudo chown -R rstudio:rstudio /home/rstudio/eda/.git/*
RUN sudo chown -R rstudio:rstudio /home/rstudio/jdataframe/*
RUN sudo chown -R rstudio:rstudio /home/rstudio/jdataframe/.git/
RUN sudo chown -R rstudio:rstudio /home/rstudio/jdataframe/.git/*
RUN sudo chown -R rstudio:rstudio /home/rstudio/rcoboldi/*
RUN sudo chown -R rstudio:rstudio /home/rstudio/rcoboldi/.git/
RUN sudo chown -R rstudio:rstudio /home/rstudio/rcoboldi/.git/*

RUN cd /home/rstudio/eda/ && mvn clean install -DskipTests=true -U
RUN cd /home/rstudio/jdataframe/ && mvn clean install -DskipTests=true -U

RUN mvn install:install-file -Dfile=/home/rstudio/jrecord/lib/JRecord.jar -DgroupId=net.sf -DartifactId=jrecord -Dversion=0.90.2 -Dpackaging=jar
RUN mvn install:install-file -Dfile=/home/rstudio/jrecord/lib/cb2xml.jar -DgroupId=net.sf -DartifactId=cb2xml -Dversion=0.90.2 -Dpackaging=jar
RUN mvn install:install-file -Dfile=/home/rstudio/Cobol2Csv/lib/Cobol2Csv.jar -DgroupId=net.sf -DartifactId=cb2csv -Dversion=0.90 -Dpackaging=jar

RUN mkdir /home/rstudio/rcoboldi/r-package/inst/java

RUN sudo chown -R rstudio:rstudio /home/rstudio/rcoboldi/r-package/*

RUN cd /home/rstudio/rcoboldi/java && mvn clean package && cp rcoboldi-assembly/target/rcoboldi-assembly-1.0.3-RELEASE.jar /home/rstudio/rcoboldi/r-package/inst/java

RUN R -e 'install.packages("RJSONIO")'
RUN R -e 'install.packages("logging")'
RUN R -e 'roxygen2::roxygenize("/home/rstudio/rcoboldi/r-package/", roclets = c("rd", "collate", "namespace", "vignette"))'
RUN cd /home/rstudio/rcoboldi/ && R CMD INSTALL --preclean --no-multiarch --with-keep.source r-package

RUN cd /home/rstudio/

#RUN R -e 'drat::addRepo("thospfuller")'
#RUN R -e 'install.packages("RCOBOLDI", type="source")'
