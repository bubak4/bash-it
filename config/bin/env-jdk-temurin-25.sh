#!/bin/bash
# Time-stamp: <2025-12-05 19:11:41 martin>

version=temurin-25
JAVA_HOME=$(find /usr/lib/jvm -maxdepth 1 -type d -name "*${version}*" | sort | tail -1)
PATH=${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin:$PATH
export JAVA_HOME PATH

ANT_HOME="/usr/share/ant"
PATH=${ANT_HOME}/bin:$PATH
export ANT_HOME PATH

MAVEN_HOME="/opt/apache/apache-maven-3.9.11"
MAVEN_OPTS="-Xmx2048m -XX:ReservedCodeCacheSize=512m"
PATH=${MAVEN_HOME}/bin:$PATH
export MAVEN_HOME MAVEN_OPTS PATH
