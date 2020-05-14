#!/usr/bin/env bash

if [[ "${VERBOSE_GRAALVM_LAUNCHERS}" == "true" ]]; then
    set -x
fi

GRAAL_REPO=${GRAAL_REPO:-../graal}
MANDREL_JDK=${MANDREL_SDK:-./mandrelJDK}

### Copy default JDK
rm -rf ${MANDREL_JDK}
cp -pr ${JAVA_HOME} ${MANDREL_JDK}

### Copy needed jars
mkdir ${MANDREL_JDK}/lib/svm
# cp ${GRAAL_REPO}/substratevm/mxbuild/dists/jdk1.8/library-support.jar ${MANDREL_JDK}/lib/svm

mkdir ${MANDREL_JDK}/lib/svm/builder
# cp ${GRAAL_REPO}/substratevm/mxbuild/dists/jdk11/{svm,pointsto}.jar ${MANDREL_JDK}/lib/svm/builder
cp ~/Downloads/svm-19.3.1.redhat-00011.jar ${MANDREL_JDK}/lib/svm/builder/svm.jar
cp ~/Downloads/pointsto-19.3.1.redhat-00011.jar ${MANDREL_JDK}/lib/svm/builder/pointsto.jar
# cp ${GRAAL_REPO}/substratevm/mxbuild/dists/jdk1.8/objectfile.jar ${MANDREL_JDK}/lib/svm/builder
cp ~/Downloads/objectfile-19.3.1.redhat-00011.jar ${MANDREL_JDK}/lib/svm/builder/objectfile.jar

# mkdir ${MANDREL_JDK}/languages
# cp ${GRAAL_REPO}/truffle/mxbuild/dists/jdk11/truffle-nfi.jar ${MANDREL_JDK}/languages

mkdir ${MANDREL_JDK}/lib/graalvm
# cp ${GRAAL_REPO}/substratevm/mxbuild/dists/jdk1.8/svm-driver.jar ${MANDREL_JDK}/lib/graalvm
cp ~/Downloads/svm-driver-19.3.1.redhat-00011.jar ${MANDREL_JDK}/lib/graalvm/svm-driver.jar

## The following jars are not included in the GraalJDK created by `mx --components="Native Image" build`
mkdir ${MANDREL_JDK}/lib/jvmci
# cp ${GRAAL_REPO}/sdk/mxbuild/dists/jdk11/graal-sdk.jar ${MANDREL_JDK}/lib/jvmci
cp ~/Downloads/graal-sdk-19.3.1.redhat-00011.jar ${MANDREL_JDK}/lib/jvmci/graal-sdk.jar
# cp ${GRAAL_REPO}/compiler/mxbuild/dists/jdk11/graal.jar ${MANDREL_JDK}/lib/jvmci
cp ~/Downloads/compiler-19.3.1.redhat-00011.jar ${MANDREL_JDK}/lib/jvmci/graal.jar

mkdir ${MANDREL_JDK}/lib/truffle
# cp ${GRAAL_REPO}/truffle/mxbuild/dists/jdk11/truffle-api.jar ${MANDREL_JDK}/lib/truffle
cp ~/Downloads/truffle-api-19.3.1.redhat-00011.jar ${MANDREL_JDK}/lib/truffle/truffle-api.jar


### Copy native bits
mkdir -p ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64/include
cp ${GRAAL_REPO}/substratevm/src/com.oracle.svm.native.libchelper/include/cpufeatures.h ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64/include
cp ${GRAAL_REPO}/substratevm/src/com.oracle.svm.libffi/include/svm_libffi.h ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64/include
cp ${GRAAL_REPO}/truffle/src/com.oracle.truffle.nfi.native/include/trufflenfi.h ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64/include
cp ${GRAAL_REPO}/substratevm/mxbuild/linux-amd64/src/com.oracle.svm.native.libchelper/amd64/liblibchelper.a ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64
## FIXME: we probably don't want to use the custom libjvm.a
cp ${GRAAL_REPO}/substratevm/mxbuild/linux-amd64/src/com.oracle.svm.native.jvm.posix/amd64/libjvm.a ${MANDREL_JDK}/lib/svm/clibraries/linux-amd64

### Fix native-image launcher
mkdir ${MANDREL_JDK}/lib/svm/bin
cp ${GRAAL_REPO}/sdk/mx.sdk/vm/launcher_template.sh ${MANDREL_JDK}/lib/svm/bin/native-image

### TODO: Add Red Hat, Inc. copyright?
sed -i -e 's!<year>!'$(date +%Y)'!'\
    -e 's!<classpath>!../../../languages/nfi/truffle-nfi.jar:../builder/svm.jar:../library-support.jar:../builder/pointsto.jar:../../graalvm/svm-driver.jar:../builder/objectfile.jar!' \
    -e 's!<jre_bin>!../../../bin!' \
    -e 's!<extra_jvm_args>!--add-exports=java.base/jdk.internal.module=ALL-UNNAMED -XX:+UnlockExperimentalVMOptions -XX:+EnableJVMCI --upgrade-module-path ${location}/../../jvmci/graal.jar --add-modules "org.graalvm.truffle,org.graalvm.sdk" --module-path ${location}/../../truffle/truffle-api.jar:${location}/../../jvmci/graal-sdk.jar!' \
    -e 's!<main_class>!com.oracle.svm.driver.NativeImage$JDK9Plus!' ${MANDREL_JDK}/lib/svm/bin/native-image
chmod +x ${MANDREL_JDK}/lib/svm/bin/native-image

## Create symbolic link in bin
ln -s ../lib/svm/bin/native-image ${MANDREL_JDK}/bin/native-image
chmod +x ${MANDREL_JDK}/bin/native-image
