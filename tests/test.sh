#!/bin/bash
set -xeo pipefail
# shellcheck disable=SC1091
source jvm.sh
jvm local 7
jvm reload
if ! [ "$(jvm version)" -eq 7 ]; then
  echo "jvm version should be 7"
fi
echo "$PATH" | grep 1.7
