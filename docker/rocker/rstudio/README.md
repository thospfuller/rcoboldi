# RCOBOLDI on GitHub

[The R COBOL Data Integration Package can be found on GitHub.](https://github.com/thospfuller/rcoboldi/)

# Example

The following is a fully working example.

## From the command line:

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
