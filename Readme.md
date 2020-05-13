# Usage

## Prerequisities

* Get labsJDK from https://github.com/graalvm/labs-openjdk-11/releases/download/jvmci-19.3-b07/labsjdk-ce-11.0.6+9-jvmci-19.3-b07-linux-amd64.tar.gz

* Make JAVA_HOME point to the above JDK

* Build graal components
```bash
git clone https://github.com/oracle/graal.git
pushd graal/substratevm
git co vm-19.3.1
mx --components="Native Image" build
```

## Create patced OpenJDK

```bash
popd
GRAAL_REPO=./graal ./build.sh
```
