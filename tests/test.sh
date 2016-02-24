#!/bin/bash
set -eo pipefail
find . -name '.java-version' -delete

ROOT="$(pwd)"
TESTS="$(dirname "${BASH_SOURCE[0]}")"

assert_java() {
  version="$1"
  test "$(jvm version)" = "$version" || exit 1
  echo "$JAVA_HOME" | grep "$version" || exit 1
}

test_pom7() {
  cd "$ROOT/$TESTS"/java7
  jvm reload
  assert_java 7
}

test_pom7_grep() {
  cd "$ROOT/$TESTS"/grep
  jvm reload
  assert_java 7
}

test_pom8() {
  cd "$ROOT/$TESTS"/java8
  jvm reload
  assert_java 8
}

# shellcheck disable=SC1091
source jvm.sh

echo "jvm global 8"
jvm global 8
test "$TRAVIS_OS_NAME" != "osx" && assert_java 8

echo "jvm global 7"
jvm local 7
assert_java 7

echo "cdwd java 8 pom"
test "$TRAVIS_OS_NAME" != "osx" && test_pom8

echo "cdwd java 7 pom"
test_pom7

echo "cdwd java 7 grep"
test_pom7_grep
