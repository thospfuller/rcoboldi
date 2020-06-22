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
FROM rockstar/rstudio:latest

RUN su -
RUN apt-get update
RUN sudo apt-get install -y git
RUN sudo apt-get -y install apt-utils

RUN git clone https://github.com/thospfuller/rcoboldi.git /home/rstudio/rcoboldi

RUN sudo chown -R rstudio:rstudio /home/rstudio/*

RUN chown rstudio:rstudio /usr/local/lib/R/
RUN chown -R rstudio:rstudio /usr/local/lib/R/

RUN sudo apt-get update

RUN chown -R rstudio:rstudio /usr/local/lib/R/site-library/*

RUN cd /home/rstudio/

#
# This needs to be done on one line otherwise the R session is lost and the install.packages call will try to get
# RCOBOLDI from CRAN and it won't be available.
#
RUN R -e 'drat::addRepo("thospfuller"); install.packages("RCOBOLDI", type="source")'

RUN chown -R rstudio:rstudio /usr/local/lib/R/site-library/*
