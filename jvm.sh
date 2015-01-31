#!/bin/sh

_set-java-path() {
  local version="$1"
  local previous_java_home="$JAVA_HOME"
  if [ -d "/usr/lib/jvm/java-${version}-oracle/" ]; then
    local new_java_home="/usr/lib/jvm/java-${version}-oracle/"
  elif [ -e /usr/libexec/java_home ]; then
    local new_java_home="$(/usr/libexec/java_home -v 1."$version")"
  fi
  if [ "$previous_java_home" != "$new_java_home" ]; then
    export JAVA_HOME="$new_java_home"
    export PATH="$(echo "$PATH" | sed -e 's|'"$previous_java_home"'/bin:||g')"
    export PATH="${JAVA_HOME}/bin:$PATH"
  fi
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
