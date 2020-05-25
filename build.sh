#!/usr/bin/env bash

if [[ "${VERBOSE_GRAALVM_LAUNCHERS}" == "true" ]]; then
    set -x
fi

GRAAL_REPO=${GRAAL_REPO:-../graal}
MANDREL_JDK=${MANDREL_SDK:-./mandrelJDK}

### Copy default JDK
rm -rf ${MANDREL_JDK}
cp -r ${JAVA_HOME} ${MANDREL_JDK}

### Copy needed jars
mkdir ${MANDREL_JDK}/lib/svm
cp ${GRAAL_REPO}/substratevm/mxbuild/dists/jdk1.8/library-support.jar ${MANDREL_JDK}/lib/svm

mkdir ${MANDREL_JDK}/lib/svm/builder
cp ${GRAAL_REPO}/substratevm/mxbuild/dists/jdk11/{svm,pointsto}.jar ${MANDREL_JDK}/lib/svm/builder
cp ${GRAAL_REPO}/substratevm/mxbuild/dists/jdk1.8/objectfile.jar ${MANDREL_JDK}/lib/svm/builder

mkdir ${MANDREL_JDK}/languages
cp ${GRAAL_REPO}/truffle/mxbuild/dists/jdk11/truffle-nfi.jar ${MANDREL_JDK}/languages

mkdir ${MANDREL_JDK}/lib/graalvm
cp ${GRAAL_REPO}/substratevm/mxbuild/dists/jdk1.8/svm-driver.jar ${MANDREL_JDK}/lib/graalvm

## The following jars are not included in the GraalJDK created by `mx --components="Native Image" build`
mkdir ${MANDREL_JDK}/lib/jvmci
cp ${GRAAL_REPO}/sdk/mxbuild/dists/jdk11/graal-sdk.jar ${MANDREL_JDK}/lib/jvmci
cp ${GRAAL_REPO}/compiler/mxbuild/dists/jdk11/graal.jar ${MANDREL_JDK}/lib/jvmci

mkdir ${MANDREL_JDK}/lib/truffle
cp ${GRAAL_REPO}/truffle/mxbuild/dists/jdk11/truffle-api.jar ${MANDREL_JDK}/lib/truffle


### Copy native bits
mkdir -p ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64/include
cp ${GRAAL_REPO}/substratevm/src/com.oracle.svm.native.libchelper/include/amd64cpufeatures.h ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64/include
cp ${GRAAL_REPO}/substratevm/src/com.oracle.svm.native.libchelper/include/aarch64cpufeatures.h ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64/include
cp ${GRAAL_REPO}/substratevm/src/com.oracle.svm.libffi/include/svm_libffi.h ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64/include
cp ${GRAAL_REPO}/truffle/src/com.oracle.truffle.nfi.native/include/trufflenfi.h ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64/include
cp ${GRAAL_REPO}/substratevm/mxbuild/linux-amd64/src/com.oracle.svm.native.libchelper/amd64/liblibchelper.a ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64
cp ${GRAAL_REPO}/substratevm/mxbuild/linux-amd64/src/com.oracle.svm.native.jvm.posix/amd64/libjvm.a ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64
## TODO: consider using libm instead of fdlibm/strictmath.a?
cp ${GRAAL_REPO}/substratevm/mxbuild/linux-amd64/src/com.oracle.svm.native.strictmath/amd64/libstrictmath.a ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64

### Fix native-image launcher
mkdir ${MANDREL_JDK}/lib/svm/bin
cp ${GRAAL_REPO}/sdk/mxbuild/linux-amd64/native-image.image-bash/native-image ${MANDREL_JDK}/lib/svm/bin/native-image

## Create symbolic link in bin
ln -s ../lib/svm/bin/native-image ${MANDREL_JDK}/bin/native-image
