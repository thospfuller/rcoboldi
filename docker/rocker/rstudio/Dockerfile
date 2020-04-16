#
# This script sets up rocker/verse with the RCOBOLDI project.
#
# See: quay.io
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
FROM rocker/rstudio:latest

RUN su -
RUN apt-get update
RUN sudo apt-get install -y git
RUN sudo apt-get -y install apt-utils
RUN sudo apt-get -y install openjdk-11-jre openjdk-11-jdk

RUN R CMD javareconf

RUN git clone https://github.com/thospfuller/rcoboldi.git /home/rstudio/rcoboldi

RUN sudo chown -R rstudio:rstudio /home/rstudio/*

RUN chown rstudio:rstudio /usr/local/lib/R/
RUN chown -R rstudio:rstudio /usr/local/lib/R/

# Not working:
#
# RUN R -e 'install.packages("rJava")'
#
# So we use apt-get instead.
#
# See: https://stackoverflow.com/questions/3311940/r-rjava-package-install-failing
#
RUN sudo apt-get -y install r-cran-rjava

RUN R -e 'install.packages("drat")'
RUN R -e 'install.packages("RJSONIO")'

RUN sudo apt-get update

RUN chown -R rstudio:rstudio /usr/local/lib/R/site-library/*

RUN cd /home/rstudio/

#
# This needs to be done on one line otherwise the R session is lost and the install.packages call will try to get
# RCOBOLDI from CRAN and it won't be available.
#
RUN R -e 'drat::addRepo("thospfuller"); install.packages("RCOBOLDI", type="source")'

RUN chown -R rstudio:rstudio /usr/local/lib/R/site-library/*

#RUN R -e 'library("RCOBOLDI")'
