#!/bin/sh
_jvm_set-java-path() {
  local version="$1"
  local previous_java_home="$JAVA_HOME"
  local new_java_home
  if [ -f ~/.jvmconfig ]; then
    new_java_home="$(grep "${version}"= ~/.jvmconfig | cut -f2 -d'=')"
  elif [ -d "/usr/lib/jvm/java-${version}-oracle/" ]; then
    local new_java_home="/usr/lib/jvm/java-${version}-oracle/"
  elif [ -e /usr/libexec/java_home ]; then
    new_java_home="$(/usr/libexec/java_home -v 1."$version" 2> /dev/null)"
  fi
  if [ "$previous_java_home" != "" ] &&
    [ "$previous_java_home" != "$new_java_home" ]; then
    local new_path
    new_path="$(echo "$PATH" | sed -e 's|'"$previous_java_home"'/bin:||g')"
    export PATH="$new_path"
  fi
  export JAVA_HOME="$new_java_home"
  export PATH="${JAVA_HOME}/bin:$PATH"
}

_jvm-discover-version() {
  local version
  if [ -f pom.xml ]; then
    version="$(\
      grep '<java.version>' pom.xml | \
      sed 's/.*<java.version>1.\(.*\)<\/java.version>.*/\1/' \
    )"
  fi
  if [ -z "$version" ] && [ -f .java-version ]; then
    version="$(cat .java-version)"
  fi
  if [ -z "$version" ] && [ -f ~/.java-version ]; then
    version="$(cat ~/.java-version)"
  fi
  echo "$version"
}

_jvm-discover-and-set-version() {
  local version
  version="$(_jvm-discover-version)"
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

_jvm-command-list() {
  echo "local global version reload config"
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
      echo "Usage: jvm (${$(_jvm-command-list)// /|}) <args>"
      return 0
      ;;
  esac
}

main() {
  _jvm-discover-and-set-version
  if [ ! -z "$BASH"  ]; then
    PROMPT_COMMAND=_jvm-discover-and-set-version
    # shellcheck disable=SC2039
    complete -W "$(_jvm-command-list)" jvm
  elif [ ! -z "$ZSH_NAME" ]; then
    chpwd() {
      _jvm-discover-and-set-version
    }
    _jvm-completions() {
      # shellcheck disable=SC2039,SC2034
      IFS=' ' read -r -A reply <<< "$(_jvm-command-list)"
    }
    compctl -K _jvm-completions jvm
  fi
}

main
