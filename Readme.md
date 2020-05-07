# Usage

## Prerequisities

* Get OpenJDK > 11.0.8+1 with static libs
```
JDK: https://api.adoptopenjdk.net/v3/binary/latest/11/ea/linux/x64/jdk/hotspot/normal/openjdk
static-libs: https://api.adoptopenjdk.net/v3/binary/latest/11/ea/linux/x64/staticlibs/hotspot/normal/openjdk
```

* Make JAVA_HOME to point to the above JDK

* Build graal components
```bash
git clone https://github.com/oracle/graal.git
pushd graal/substratevm
mx --components="Native Image" build
```

## Create patced OpenJDK

```bash
popd
GRAAL_REPO=./graal ./build.sh
```
