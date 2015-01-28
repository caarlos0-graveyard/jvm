#!/bin/sh

_set-java-path() {
  local version="$1"
  if [ -d "/usr/lib/jvm/java-${version}-oracle/" ]; then
    export JAVA_HOME="/usr/lib/jvm/java-${version}-oracle/"
  elif [ -e /usr/libexec/java_home ]; then
    export JAVA_HOME="$(/usr/libexec/java_home -v 1."$version")"
  fi
  export PATH="${JAVA_HOME}/bin:$PATH"
}

_discover-and-set() {
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
