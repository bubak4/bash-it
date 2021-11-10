#!/bin/bash
# Time-stamp: <2021-11-10 20:35:03 martin>

version=jdk1.6
JAVA_HOME=$(find /opt/java -maxdepth 1 -type d -name "*${version}*" | sort | tail -1)
PATH=${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin:$PATH
export JAVA_HOME PATH

# no ant support for JDK 1.6
# ANT_HOME="/usr/share/ant"
# PATH=${ANT_HOME}/bin:$PATH
# export ANT_HOME PATH

MAVEN_HOME="/opt/apache/apache-maven-2.2.1"
MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=256m -XX:ReservedCodeCacheSize=128m"
PATH=${MAVEN_HOME}/bin:$PATH
export MAVEN_HOME MAVEN_OPTS PATH
