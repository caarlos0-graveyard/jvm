#!/bin/sh

_jvm_set-java-path() {
  local version="$1"
  local previous_java_home="$JAVA_HOME"
  if [ -d "/usr/lib/jvm/java-${version}-oracle/" ]; then
    local new_java_home="/usr/lib/jvm/java-${version}-oracle/"
  elif [ -e /usr/libexec/java_home ]; then
    local new_java_home="$(/usr/libexec/java_home -v 1."$version")"
  fi
  if [ "$previous_java_home" != "" ] &&
    [ "$previous_java_home" != "$new_java_home" ]; then
    export PATH="$(echo "$PATH" | sed -e 's|'"$previous_java_home"'/bin:||g')"
  fi
  export JAVA_HOME="$new_java_home"
  export PATH="${JAVA_HOME}/bin:$PATH"
}

_jvm-discover-and-set() {
  if [ -f pom.xml ]; then
    local version="$(\
      grep '<java.version>' pom.xml | \
      sed 's/.*<java.version>1.\(.*\)<\/java.version>.*/\1/' \
    )"
  fi
  if [ -z "$version" ] && [ -f .java-version ]; then
    local version="$(cat .java-version)"
  fi
  [ ! -z "$version" ] && _jvm_set-java-path "$version"
}

if [ ! -z "$BASH"  ]; then
  PROMPT_COMMAND=_jvm-discover-and-set
elif [ ! -z "$ZSH_NAME" ]; then
  chpwd() {
    _jvm-discover-and-set
  }
fi
