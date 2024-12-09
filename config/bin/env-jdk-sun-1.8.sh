#!/bin/bash
# Time-stamp: <2023-07-18 14:22:11 martin>

version=jdk1.8
JAVA_HOME=$(find /opt/java -maxdepth 1 -type d -name "*${version}*" | sort | tail -1)
PATH=${JAVA_HOME}/bin:${JAVA_HOME}/jre/bin:$PATH
export JAVA_HOME PATH

ANT_HOME="/usr/share/ant"
PATH=${ANT_HOME}/bin:$PATH
export ANT_HOME PATH

MAVEN_HOME="/opt/apache/apache-maven-3.9.3"
MAVEN_OPTS="-Xmx2048m -XX:ReservedCodeCacheSize=512m"
PATH=${MAVEN_HOME}/bin:$PATH
export MAVEN_HOME MAVEN_OPTS PATH

jfx_builder_root="/opt/java/JavaFXSceneBuilder2.0"
if test -d "$jfx_builder_root" ; then
    PATH=${jfx_builder_root}:$PATH
    export PATH
fi