#!/bin/sh
_jvm_set-java-path() {
  local version="$1"
  local previous_java_home="$JAVA_HOME"
  if [ -f ~/.jvmconfig ]; then
    local new_java_home="$(grep "${version}"= ~/.jvmconfig | cut -f2 -d'=')"
  elif [ -d "/usr/lib/jvm/java-${version}-oracle/" ]; then
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

_jvm-discover-version() {
  if [ -f pom.xml ]; then
    local version="$(\
      grep '<java.version>' pom.xml | \
      sed 's/.*<java.version>1.\(.*\)<\/java.version>.*/\1/' \
    )"
  fi
  if [ -z "$version" ] && [ -f .java-version ]; then
    local version="$(cat .java-version)"
  fi
  if [ -z "$version" ] && [ -f ~/.java-version ]; then
    local version="$(cat ~/.java-version)"
  fi
  echo "$version"
}

_jvm-discover-and-set-version() {
  local version="$(_jvm-discover-version)"
  [ ! -z "$version" ] && _jvm_set-java-path "$version"
}

_jvm-edit-config() {
  if [ ! -f ~/.jvmconfig ]; then
    cat > ~/.jvmconfig <<EOF
7=Path to jdk 7
8=Path to jdk 8
EOF
  fi
  $EDITOR ~/.jvmconfig
}

jvm() {
  if [ "$#" != 0 ]; then
    local command="$1"; shift
  fi
  case "$command" in
    local)
      echo "$@" > .java-version
      _jvm-discover-and-set-version
      ;;
    global)
      echo "$@" > ~/.java-version
      _jvm-discover-and-set-version
      ;;
    version)
      _jvm-discover-version
      ;;
    reload)
      _jvm-discover-and-set-version
      ;;
    config)
      _jvm-edit-config
      ;;
    *)
      echo "Usage: jvm (local|global|version|reload|config) <args>"
      return 0
      ;;
  esac
}

main() {
  _jvm-discover-and-set-version
  if [ ! -z "$BASH"  ]; then
    PROMPT_COMMAND=_jvm-discover-and-set-version
    complete -W "local global version reload config" jvm
  elif [ ! -z "$ZSH_NAME" ]; then
    chpwd() {
      _jvm-discover-and-set-version
    }
  fi
}

main
