#!/bin/bash
set -eo pipefail
echo 8 > .java-version
# shellcheck disable=SC1091
source jvm.sh
jvm local 7
jvm reload
test "$(jvm version)" = "7" || echo "jvm version should be 7"
echo "$JAVA_HOME" | grep 7
