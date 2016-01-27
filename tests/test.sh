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
