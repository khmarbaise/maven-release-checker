#!/bin/bash
#
# Calling: release-test.sh https://repository.apache.org/content/repositories/maven-1391/org/a.../maven-pmd-plugin/3.9.0/maven-pmd-plugin-3.9.0-source-release.zip
#
##export MAVEN_OPTS="-Xmx768m -Xms128m -XX:MaxPermSize=512m -Djava.awt.headless=true"
export MAVEN_OPTS="-Xmx768m -Xms128m -Djava.awt.headless=true"
MVNLOG=mvn.log
RELEASEAREA=test-area
JDKBASE=/Library/Java/JavaVirtualMachines/
JDKSUPP=/Contents/Home
MAVENBASE=/usr/local
MAVENVERSIONS="apache-maven-3.0.5 \
apache-maven-3.1.1 \
apache-maven-3.2.5 \
apache-maven-3.3.1 \
apache-maven-3.3.9 \
apache-maven-3.5.0 \
apache-maven-3.5.2 \
apache-maven-3.5.3"
#
JDKS="jdk1.7.0_79.jdk \
jdk1.8.0_131.jdk \
jdk1.8.0_144.jdk \
jdk-9.0.4.jdk \
jdk-10.jdk"
#
# Get back 20 backspaces.
# result=$(getNumberOfBackspace 20)
# 
getNumberOfBackspace ()
{
  # This the number of characters you want to produce
  variable=$(printf "%0.s\x08" $(seq 1 $1)) # Fill $variable with $n periods
  echo -n $variable # Output content of $variable to terminal
}
#len=100 ch='#'
#printf '%*s' "$len" | tr ' ' "$ch"
#
# Usage:
#   waitingForEndOfRunning "StartText" "WhatEverYouWouldLikeToCall" "Finshed Text"
#
waitingForEndOfRunning () 
{
  len=$((${#1} + 1))
  backspace=$(getNumberOfBackspace $len)
  #echo "Länge: $len"
  echo -n "$1$backspace"
  # Put the command given as parameter into background and wait until it is
  # finished.
  eval "$2 &"
  PROC_ID=$!
  pos=0
  while kill -0 "$PROC_ID" >/dev/null 2>&1; do
    echo -n "."
    sleep 0.1
    pos=$((pos + 1))
    if [ "$pos" -ge "$len" ]; then
      echo -n "$backspace"
      pos=0
    fi
  done
  leftbackspace=$(getNumberOfBackspace $pos)
  echo -n "$leftbackspace"
  echo -n "$3"
}
##
BASE=`pwd`
if [ -e $RELEASEAREA ]; then
  echo -n "Removing existing release test area..."
  rm -fr $RELEASEAREA >$BASE/remove.log 2>&1
  echo "done."
fi
#
# Downloading release packages including checksum packages sha1/md5
DOWNLOAD_FILENAME=$(basename $1)
DOWNLOAD_BASEURL=$(dirname $1)
echo -n "Downloading release package $DOWNLOAD_FILENAME..."
curl -s $1 -O
if [ $? -ne 0 ]; then
  echo "Failure during download."
  exit $?
fi
echo "done."
#
echo -n "Downloading sha1 package for $DOWNLOAD_FILENAME..."
curl -s $DOWNLOAD_BASEURL/$DOWNLOAD_FILENAME.sha1 -O
if [ $? -ne 0 ]; then
  echo "Failure during download."
  exit $?
fi
echo "done."
#
echo -n "Downloading md5 package $DOWNLOAD_FILENAME..."
curl -s $DOWNLOAD_BASEURL/$DOWNLOAD_FILENAME.md5 -O
if [ $? -ne 0 ]; then
  echo "Failure during download."
  exit $?
fi
echo "done."

./downloadcheck.sh $DOWNLOAD_FILENAME
if [ $? -ne 0 ]; then
  echo "Failure during checksum verification."
  exit $?
fi

# Extract the directory name from zip file:
DIRNAME=$(unzip -Z -1 $DOWNLOAD_FILENAME | sort | head -1)
#
# We need to do this before MAVEN_SKIP_RC 
# to have JAVA_HOME defined for the call.
#
echo "Using the following Maven versions for testing"
for mvnversion in $MAVENVERSIONS; do
    mvnPath=$MAVENBASE/$mvnversion/bin/mvn
    MAVENVERSION=$($mvnPath --version | head -1 )
    echo "${MAVENVERSION}"
done;
echo "Start testing..."
#
# Suppress of the loading of ~/.mavenrc file
# so we can decide which JAVA_HOME etc. should be used.
export MAVEN_SKIP_RC=1
#
mkdir -p $RELEASEAREA
RELEASEBASE=$BASE/$RELEASEAREA
cd $BASE
##
for jdk in $JDKS
do
  echo "$jdk";
  mkdir -p $RELEASEBASE/$jdk
  cd $RELEASEBASE/$jdk
  for mvnversion in $MAVENVERSIONS
  do
    #echo "Maven: $mvnversion"
    mvnPath=$MAVENBASE/$mvnversion/bin/mvn
    #mvnPath=$BASE/temp.sh
    mkdir -p $RELEASEBASE/$jdk/$mvnversion
    cd $RELEASEBASE/$jdk/$mvnversion
    echo -n "  $mvnversion..."
    # Unzip the release package.
    #unzip $BASE/$1 >$RELEASEBASE/$jdk/$mvnversion/unzip.log 2>&1
    waitingForEndOfRunning "Unzipping release package..." "unzip $BASE/$DOWNLOAD_FILENAME >$RELEASEBASE/$jdk/$mvnversion/unzip.log 2>&1" "Unpacking done. "
    unset JAVA_HOME
    # Need to think about this.
    cd $DIRNAME
    waitingForEndOfRunning "Building..." "JAVA_HOME=$JDKBASE/$jdk/$JDKSUPP $mvnPath -V -Prun-its clean verify >$RELEASEBASE/$jdk/$mvnversion/$MVNLOG 2>&1" "Building "
    SUCCEED=$(cat $RELEASEBASE/$jdk/$mvnversion/$MVNLOG | grep "^\[INFO\] BUILD SUCCESS")
    if [ $? -ne 0 ]; then
      printf '\e[0;31mfailed.\e[0m\n'
    else
      printf '\e[0;32mfine.\e[0m\n'
    fi
    cd $RELEASEBASE/$jdk/$mvnversion
  done;
done;
