#!/bin/sh
OSX_JDKS="/Library/Java/JavaVirtualMachines/"

_set-java-path() {
  local version="$1"
  if [ -d "/usr/lib/jvm/java-${version}-oracle/" ]; then
    export JAVA_HOME="/usr/lib/jvm/java-${version}-oracle/"
  elif [ -d "$OSX_JDKS" ]; then
    # shellcheck disable=SC2010
    local latest="$(ls -t1 "$OSX_JDKS" | grep "1.$version" | head -1)"
    if [ ! -z "$latest" ]; then
      export JAVA_HOME="${OSX_JDKS}${latest}Contents/Home"
    fi
  fi
  export PATH="${JAVA_HOME}/bin:$PATH"
}

_discover-and-set() {
  set -x
  if [ -f pom.xml ]; then
    local version="$(\
      grep '<java.version>' pom.xml | \
      sed 's/.*<java.version>1.\(.*\)<\/java.version>.*/\1/' \
    )"
  fi
  if [ -z "$version" ] && [ -f .java-version ]; then
    local version="$(cat .java-version)"
  fi
  _set-java-path "$version"
}

if [ ! -z "$BASH"  ]; then
  PROMPT_COMMAND=_discover-and-set
elif [ ! -z "$ZSH_NAME" ]; then
  chpwd() {
    _discover-and-set
  }
fi
