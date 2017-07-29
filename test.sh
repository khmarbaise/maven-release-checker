#!/bin/bash
#
# Calling: release-test.sh maven-compiler-plugin-3.6.2-source-release.zip maven-compiler-plugin-3.6.2
# Maybe we can use less memory.
export MAVEN_OPTS="-Xmx768m -Xms128m -XX:MaxPermSize=512m -Djava.awt.headless=true"
JDKBASE=/Library/Java/JavaVirtualMachines/
JDKSUPP=/Contents/Home
MAVENBASE=/usr/local
MAVENVERSIONS="apache-maven-3.0.5"
#
#MAVENVERSIONS="apache-maven-3.0.5 \
#apache-maven-3.1.1 \
#apache-maven-3.2.5 \
#apache-maven-3.3.1 \
#apache-maven-3.3.9 \
#apache-maven-3.5.0"
#
JDKS="jdk1.7.0_79.jdk \
jdk1.8.0_131.jdk \
jdk1.8.0_144.jdk \
jdk1.9.0_ea+180.jdk"
#MAVENVERSIONS="apache-maven-3.0.5 \
#apache-maven-3.1.1 \
#apache-maven-3.2.5 \
#apache-maven-3.3.1 \
#apache-maven-3.3.9 \
#apache-maven-3.5.0"

BASE=`pwd`
if [ -e release-test ]; then
  echo -n "Removing existing release test area..."
  rm -fr release-test
  echo "done."
fi
mkdir -p release-test
RELEASEBASE=$BASE/release-test
cd $BASE
for jdk in $JDKS
do
  #echo "JDK: $jdk";
  mkdir -p $RELEASEBASE/$jdk
  cd $RELEASEBASE/$jdk
  for mvnversion in $MAVENVERSIONS
  do
    #echo "Maven: $mvnversion"
    mvnPath=$MAVENBASE/$mvnversion/bin/mvn
    mkdir -p $RELEASEBASE/$jdk/$mvnversion
    cd $RELEASEBASE/$jdk/$mvnversion
    echo -n "$mvnversion on $jdk..."
    # Unzip the release package.
    echo -n "Unzipping release package..."
    unzip $BASE/$1 >$RELEASEBASE/$jdk/$mvnversion/unzip.log 2>&1
    echo -n "done..start building..."
    unset JAVA_HOME
    # Need to think about this.
    cd $2
    JAVA_HOME=$JDKBASE/$jdk/$JDKSUPP $mvnPath -V -Prun-its clean verify > $RELEASEBASE/$jdk/$mvnversion/mvn.log 2>&1
    SUCCEED=$(cat $RELEASEBASE/$jdk/$mvnversion/mvn.log | grep "^\[INFO\] BUILD SUCCESS")
    if [ $? -ne 0 ]; then
      echo "Failure"
    else
      echo "done."
    fi
    cd $RELEASEBASE/$jdk/$mvnversion
  done;
done;
