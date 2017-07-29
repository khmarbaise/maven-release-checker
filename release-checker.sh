#!/bin/bash
#
# Calling: release-test.sh maven-compiler-plugin-3.6.2-source-release.zip maven-compiler-plugin-3.6.2
#
##export MAVEN_OPTS="-Xmx768m -Xms128m -XX:MaxPermSize=512m -Djava.awt.headless=true"
export MAVEN_OPTS="-Xmx768m -Xms128m -Djava.awt.headless=true"
MVNLOG=mvn-1.log
RELEASEAREA=release-test
JDKBASE=/Library/Java/JavaVirtualMachines/
JDKSUPP=/Contents/Home
MAVENBASE=/usr/local
MAVENVERSIONS="apache-maven-3.0.5 \
apache-maven-3.1.1 \
apache-maven-3.2.5 \
apache-maven-3.3.1 \
apache-maven-3.3.9 \
apache-maven-3.5.0"
#
JDKS="jdk1.7.0_79.jdk \
jdk1.8.0_131.jdk \
jdk1.8.0_144.jdk \
jdk1.9.0_ea+180.jdk"
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
  $2 &
  PROC_ID=$!
  while kill -0 "$PROC_ID" >/dev/null 2>&1; do
    echo -n "."
    sleep 0.1
  done
  echo -n "$3"
}

BASE=`pwd`
if [ -e $RELEASEAREA ]; then
  echo -n "Removing existing release test area..."
  ##rm -fr $RELEASEAREA
  $BASE/temp-short.sh >$BASE/r.log 2>&1
  echo "done."
fi
mkdir -p $RELEASEAREA
RELEASEBASE=$BASE/$RELEASEAREA
cd $BASE
for jdk in $JDKS
do
  echo "$jdk";
  mkdir -p $RELEASEBASE/$jdk
  cd $RELEASEBASE/$jdk
  for mvnversion in $MAVENVERSIONS
  do
    #echo "Maven: $mvnversion"
    ### mvnPath=$MAVENBASE/$mvnversion/bin/mvn
    mvnPath=$BASE/temp.sh
    mkdir -p $RELEASEBASE/$jdk/$mvnversion
    cd $RELEASEBASE/$jdk/$mvnversion
    echo -n "  $mvnversion..."
    # Unzip the release package.
    #unzip $BASE/$1 >$RELEASEBASE/$jdk/$mvnversion/unzip.log 2>&1
    waitingForEndOfRunning "Unzipping release package..." "$BASE/temp.sh >$RELEASEBASE/$jdk/$mvnversion/unzip.log 2>&1" "done."
    unset JAVA_HOME
    # Need to think about this.
    cd $2
    JAVA_HOME=$JDKBASE/$jdk/$JDKSUPP $mvnPath -V -Prun-its clean verify > $RELEASEBASE/$jdk/$mvnversion/$MVNLOG 2>&1
    SUCCEED=$(cat $RELEASEBASE/$jdk/$mvnversion/$MVNLOG | grep "^\[INFO\] BUILD SUCCESS")
    if [ $? -ne 0 ]; then
      echo "Failure"
    else
      echo "done."
    fi
    cd $RELEASEBASE/$jdk/$mvnversion
  done;
done;
