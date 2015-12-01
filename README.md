# stock-analysis

Prerequisites
-----
1. Operating System
  * This program is extensively tested and known to work on,
    *  Red Hat Enterprise Linux Server release 5.10 (Tikanga)
    *  Ubuntu 12.04.3 LTS
    *  Ubuntu 12.10
  * This may work in Windows systems depending on the ability to setup OpenMPI properly, however, this has not been tested and we recommend choosing a Linux based operating system instead.
 
2. Java
  * Download Oracle JDK 8 from http://www.oracle.com/technetwork/java/javase/downloads/index.html
  * Extract the archive to a folder named `jdk1.8.0`
  * Set the following environment variables.
  ```
    JAVA_HOME=<path-to-jdk1.8.0-directory>
    PATH=$JAVA_HOME/bin:$PATH
    export JAVA_HOME PATH
  ```
3. Apache Maven
  * Download latest Maven release from http://maven.apache.org/download.cgi
  * Extract it to some folder and set the following environment variables.
  ```
    MVN_HOME=<path-to-Maven-folder>
    $PATH=$MVN_HOME/bin:$PATH
    export MVN_HOME PATH
  ```

4. OpenMPI
  * We recommend using `OpenMPI 1.8.1` although it works with the previous 1.7 versions. The Java binding is not available in versions prior to 1.7, hence are not recommended. Note, if using a version other than 1.8.1 please remember to set Maven dependency appropriately in the `pom.xml`.
  * Download OpenMPI 1.8.1 from http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.1.tar.gz
  * Extract the archive to a folder named `openmpi-1.8.1`
  * Also create a directory named `build` in some location. We will use this to install OpenMPI
  * Set the following environment variables
  ```
    BUILD=<path-to-build-directory>
    OMPI_181=<path-to-openmpi-1.8.1-directory>
    PATH=$BUILD/bin:$PATH
    LD_LIBRARY_PATH=$BUILD/lib:$LD_LIBRARY_PATH
    export BUILD OMPI_181 PATH LD_LIBRARY_PATH
  ```
  * The instructions to build OpenMPI depend on the platform. Therefore, we highly recommend looking into the `$OMPI_181/INSTALL` file. Platform specific build files are available in `$OMPI_181/contrib/platform` directory.
  * In general, please specify `--prefix=$BUILD` and `--enable-mpi-java` as arguments to `configure` script. If Infiniband is available (highly recommended) specify `--with-verbs=<path-to-verbs-installation>`. In summary, the following commands will build OpenMPI for a Linux system.
  ```
    cd $OMPI_181
    ./configure --prefix=$BUILD --enable-mpi-java
    make;make install
  ```
  * If everything goes well `mpirun --version` will show `mpirun (Open MPI) 1.8.1`. Execute the following command to instal `$OMPI_181/ompi/mpi/java/java/mpi.jar` as a Maven artifact.
  ```
    mvn install:install-file -DcreateChecksum=true -Dpackaging=jar -Dfile=$OMPI_181/ompi/mpi/java/java/mpi.jar -DgroupId=ompi -DartifactId=ompijavabinding -Dversion=1.8.1
  ```
  * Few examples are available in `$OMPI_181/examples`. Please use `mpijavac` with other parameters similar to `javac` command to compile OpenMPI Java programs. Once compiled `mpirun [options] java -cp <classpath> class-name arguments` command with proper values set as arguments will run the program. 


Stock Analysis Project
----
Download the source from https://github.com/iotcloud/stock-analysis and build.

```
git clone https://github.com/iotcloud/stock-analysis.git
cd stock-analysis
mvn clean install
```

DAMDS Project
----
Download the project from https://github.com/DSC-SPIDAL/damds.git and build.

```
git clone https://github.com/DSC-SPIDAL/damds.git
cd damds
mvn clean install
```

MDSasChisq
----
Download the project from https://github.com/DSC-SPIDAL/MDSasChisq.git and switch to the ompi1.8.1 branch

```
git clone git@github.iu.edu:skamburu/MDSasChisq.git
cd MDSasChisq
git fetch
git checkout ompi1.8.1
mvn clean install
```

# Stock Workflow

We first pre-process the data to create distance matrix files that are required by the MDS algorithm. Then we apply the MDS algorithm to these files. After this we do some post processing to create the final output.

## Pre-Processing

### FileBreaker

FileBreaker program is used to break large stock files in to smaller files for processing. For example if we are interested in processing yearly data the stock file can be broken by year to multiple files.

#### Format of stock files

The stock files are obtained from the CRSP database through the Wharton Research Data Services

```
https://wrds-web.wharton.upenn.edu/wrds/
```

```
Trading Symbol,
Price
Number of Shares Outstanding
Factor to adjust price
Factor to adjust shares

In a comma delimited format. (csv)

At the moment we need to take stocks from 2004-01-01 to 2014-Dec-31
```
These stock files are used to create vector files. This step isn't mandatory and vector generator can be used to create vector files directly from the stock file as wel..

### PVectorGenerator

This program creates a file with stocks in a vector format. Each row of the file contains stock identifier, stock cap and day prices as a vector.

```
PermNo,Cap,prices.....
```

### DistanceCalculator

Produces a distance file given the vector files. Various measures like correlation, correlation squared, euclidean are implemented as distance measures.

### WeightCalculator

Produces a weight matrix file given the vector files.

## Algorithm

We use the MPI version of the MDS algorithm given above to map the distances to 3d space.

## Post-Processing

### HistoGram

Create a Histogram from the vector files. This histogram can be used to label the classes

### PointRotation

This program is used to create a common set of points across all the years to rotate the points.

### MDSasChisq

We use this program to transform the point files generated by the MDS to align with a global points.

### LabelApply

Apply labels to the final rotated points.

## How to Run

You need to create a directory with the input data. Right now the script assumes an input file with the name 2004_2014.csv. 
 
```
mkdir STOCK_ANALYSIS
cd STOCK_ANALYSIS
mkdir input
cp [stock_file] input/2004_2014.csv
```

There are files in bin directory that can be used to run the programs.

To run the pre-process steps, use the file preproc.sh. You can change the parameters in this file.

```
sbatch preproc.sh path_to_stocks_base_directory
```

To run the damnds algorithm use the the command.

```
sh mds_weighted.sh path_to_stocks_base_directory
```

To run the post-processing steps, use the postproc_all.sh

```
sh postproc_all.sh path_to_stocks_base_directory
```
