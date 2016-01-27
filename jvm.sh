#!/bin/sh
# shellcheck disable=SC2039
_jvm_set-java-path() {
  version="$1"
  previous_java_home="$JAVA_HOME"
  new_java_home=""
  if [ -f ~/.jvmconfig ]; then
    new_java_home="$(grep "${version}"= ~/.jvmconfig | cut -f2 -d'=')"
  elif [ -d "/usr/lib/jvm/java-${version}-oracle/" ]; then
    new_java_home="/usr/lib/jvm/java-${version}-oracle/"
  elif [ -e /usr/libexec/java_home ]; then
    new_java_home="$(/usr/libexec/java_home -v 1."$version" 2> /dev/null)"
  fi
  if [ "$new_java_home" != "" ]; then
    if [ "$previous_java_home" != "" ] && [ "$previous_java_home" != "$new_java_home" ]; then
      export PATH="$(echo "$PATH" | sed -e 's|'"$previous_java_home"'/bin:||g')"
    fi
    export JAVA_HOME="$new_java_home"
    export PATH="${JAVA_HOME}/bin:$PATH"
  fi
}

# shellcheck disable=SC2039
_jvm-discover-version() {
  version=""
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

# shellcheck disable=SC2039
_jvm-discover-and-set-version() {
  version="$(_jvm-discover-version)"
  [ ! -z "$version" ] && _jvm_set-java-path "$version"
}

# shellcheck disable=SC2039
_jvm-edit-config() {
  if [ ! -f ~/.jvmconfig ]; then
    cat > ~/.jvmconfig <<EOF
custom-jdk-7=Path to custom jdk 7
custom-jdk-8=Path to custom jdk 8
EOF
  fi
  $EDITOR ~/.jvmconfig
}

# shellcheck disable=SC2039
_jvm-command-list() {
  echo "local global version reload config"
}

jvm() {
  command=""
  if [ "$#" != 0 ]; then
    command="$1"; shift
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
    # shellcheck disable=SC2039
    _jvm-completions() {
      # shellcheck disable=SC2039,SC2034
      IFS=' ' read -r -A reply <<< "$(_jvm-command-list)"
    }
    compctl -K _jvm-completions jvm
  fi
}

main || true
