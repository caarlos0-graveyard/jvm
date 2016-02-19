#!/bin/bash
set -xeo pipefail
echo 8 > .java-version
# shellcheck disable=SC1091
source jvm.sh
jvm local 7
jvm reload
if ! [ "$(jvm version)" -eq 7 ]; then
  echo "jvm version should be 7"
fi
echo "$JAVA_HOME" | grep 7

rm .java-version
echo "<java.version>7</java.version>" > pom.xml
jvm reload
echo "$JAVA_HOME" | grep 7

rm .java-version
echo "<maven.compiler.source>7</maven.compiler.source>" > pom.xml
jvm reload
echo "$JAVA_HOME" | grep 7
