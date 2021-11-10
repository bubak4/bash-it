#!/bin/sh
# Time-stamp: <2021-03-12 23:05:41 martin>

# sets environment for j2sdk development
# no maven and ant support for JDK 1.4

# j2sdk
j2sdk_root="/opt/java/j2sdk1.4.2_12"
PATH=${j2sdk_root}/bin:${j2sdk_root}/jre/javaws:$PATH
export PATH

JAVA_HOME=${j2sdk_root}
JDK_HOME=$JAVA_HOME
export JAVA_HOME JDK_HOME
