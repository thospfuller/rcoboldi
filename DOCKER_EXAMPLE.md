# Docker Examples

## Use the RCOBOLDI RStudio image on DockerHub

[The RCOBOLDI Rocker/RStudio image is available on DockerHub here.](https://hub.docker.com/repository/docker/thospfuller/rcoboldi-rocker-rstudio/general)

The following is a fully working example.

## From the command line:

```docker pull thospfuller/rcoboldi-rocker-rstudio:latest```

or

```docker pull thospfuller/rcoboldi-rocker-rstudio:1.0.2```

then

```docker image ls```

should show something like this:

> REPOSITORY                            TAG                 IMAGE ID            CREATED             SIZE
> thospfuller/rcoboldi-rocker-rstudio   1.0.2               3f8c1c269940        37 minutes ago      2.42GB

then

```docker run -d -p 8787:8787 -e PASSWORD=password --name rstudio -i -t 3f8c1c269940```

## From the browser:

The next step is to test this in R so point your browser to [http://localhost:8787](http://localhost:8787) and use "rstudio" and "password" to login and then execute the following:

```
library(RCOBOLDI)
RCOBOLDI::Initialize()
result <- RCOBOLDI::ReadCopyBookAsDataFrame("/home/rstudio/rcoboldi/java/rcoboldi-core/src/test/resources/example1/DTAR020.cbl", "/home/rstudio/rcoboldi/java/rcoboldi-core/src/test/resources/example1/DTAR020.bin", "Fixed Length Binary", "cp037")
head(result)
```

## Build the RCOBOLDI RStudio Docker Image Locally

Step 1.) Build the image (this can take up to 20 minutes).

```
docker build -t rcoboldi/rocker-rstudio:1.0.1 https://raw.githubusercontent.com/thospfuller/rcoboldi/master/docker/rocker/rstudio/Dockerfile
[some image id]
```

![Build the Docker image from the R COBOL Data Integration package Dockerfile."](https://github.com/thospfuller/rcoboldi/tree/master/images/RCOBOLDI_StepOneBuildDockerImage.png "Build the Docker image from the R COBOL Data Integration package Dockerfile.")

Step 2.) Launch a container based on this image.

```
docker run -d -p 8787:8787 -e PASSWORD=password --name rstudio -i -t [some image id]
[some container id]
```

Step 3.) Browse to http://localhost:8787 and enter the username & password combination rstudio & password.

The next three steps appear in the video.

Steps 4-7.) From the R CLI execute:
```
# Step 4.)
library(RCOBOLDI)

# Step 5.)
RCOBOLDI::Initialize()

# Step 6.)
result <- RCOBOLDI::ReadCopyBookAsDataFrame("DTAR020.cbl", "DTAR020.bin", "Fixed Length Binary", "cp037")

# Step 7.)
head(result)
```

![An example of the R COBOL Data Integration Package loading a file with the inputFileStructure set to "Fixed Length Binary" and the font set to "cp037". This should work out-of-the-box with a container built from the rcoboldi:rocker-rstudio image."](images/RCOBOLDI-RockerRStudio.png "An example of the R COBOL Data Integration Package loading a file with the inputFileStructure set to 'Fixed Length Binary' and the font set to 'cp037'. This should work out-of-the-box with a container built from the rcoboldi:rocker-rstudio image.")

## YouTube

If you're looking to load COBOL data files into the R Project for Statistical Computing then you came to the right place.

The Dockerfile in this example is based on Rocker / RStudio and will be running locally on port 8787.

Below is a video which demonstrates the R COBOL Data Integration package running in Docker.

<a href="http://www.youtube.com/watch?feature=player_embedded&v=rBIrvUA788M" target="_blank"><img src="images/Introduction_To_RCOBOLDI_Data_Integration_Package_Static_Movie_Image.png" alt="Introduction To RCOBOLDI Data Integration Package" width="240" height="180" border="10" /></a>
