#!/bin/sh
# find the appropriate JAVA_HOME for the given java version and fix PATH.
__jvm_set() {
  version="$1"
  previous="$JAVA_HOME"

  # custom jdk strategy
  test -f ~/.jvmconfig && \
    new="$(grep "$version"= ~/.jvmconfig || true | cut -f2 -d'=')"

  # ubuntu/debian jdk strategy
  test -z "$new" -a -d "/usr/lib/jvm/java-${version}-oracle/" && \
    new="/usr/lib/jvm/java-${version}-oracle/"

  # osx jdk strategy
  test -z "$new" -a -e /usr/libexec/java_home && \
    new="$(/usr/libexec/java_home -v 1."$version" || true)"

  # sanity check: new must be a folder.
  test ! -z "$new" -a -d "$new" || return 1

  # PATH cleanup
  # shellcheck disable=SC2155
  test ! -z "$previous" -a "$previous" != "$new" && \
    export PATH="$(echo "$PATH" | sed -e 's|'"$previous"'/bin:||g')"

  # finally export new home and path
  export JAVA_HOME="$new"
  export PATH="${JAVA_HOME}/bin:$PATH"
}

# evaluates the 'maven.compiler.source' expression, returning the found java
# version
__jvm_pomversion_evaluate() {
  MAVEN_OPTS="" mvn help:evaluate \
    -Dexpression='maven.compiler.source' |
    grep -e '^1\.[4-9]$' |
    cut -f2 -d'.'
}

# tried to find the java version using regex.
__jvm_pomversion_regex() {
  grep -Eo '<(java.version|maven.compiler.source|source)>1\.[4-9]</.*>' pom.xml |
    cut -f2 -d'>' |
    cut -f2 -d'.' |
    cut -f1 -d'<'
}

# tries multiple strategies to find the java version, and then sets it in a
# .java-version
__jvm_pomversion() {
  test -f pom.xml || return 1
  version="$(__jvm_pomversion_regex)"
  test -z "$version" && version="$(__jvm_pomversion_evaluate)"
  test ! -z "$version" && echo "$version" > .java-version
}

# finds out which java version should be used.
__jvm_version() {
  test ! -f .java-version && __jvm_pomversion
  test -f .java-version && version="$(cat .java-version)"
  test -z "$version" -a -f ~/.java-version && version="$(cat ~/.java-version)"
  echo "$version"
}

# called when a dir changes. Find which java version to use and sets it to PATH.
__jvm_main() {
  version="$(__jvm_version)"
  test ! -z "$version" && __jvm_set "$version"
}

# edit custom java version configurations
__jvm_config() {
  test ! -f ~/.jvmconfig && echo "custom-jdk=/path/to/custom/jdk" > ~/.jvmconfig
  $EDITOR ~/.jvmconfig
}

# shows usage instructions
__jvm_usage() {
  cat <<EOF
NAME:
  jvm - The Java Version Manager

USAGE:
  jvm command [command options]

AUTHOR(S):
  Carlos Alexandro Becker (caarlos0@gmail.com)

COMMANDS:
  local   <version> sets the given version to current folder
  global  <version> sets the given version globally
  version           shows the version being used
  reload            reloads jvm and re-sets the PATH and JAVA_HOME
  config            opens jvm config file in your default editor
  help              displays this help
EOF
}

# utilitary function to user interaction with the jvm configs
# (and further scripting).
jvm() {
  command=""
  if [ "$#" != 0 ]; then
    command="$1"; shift
  fi
  case "$command" in
    local)
      test -z "$@" && __jvm_usage && return 1
      echo "$@" > .java-version
      __jvm_main
      ;;
    global)
      test -z "$@" && __jvm_usage && return 1
      echo "$@" > ~/.java-version
      __jvm_main
      ;;
    version)
      __jvm_version
      ;;
    reload)
      __jvm_main
      ;;
    config)
      __jvm_config
      ;;
    *)
      __jvm_usage
      return 0
      ;;
  esac
}

# main function called when sourced.
main() {
  if [ ! -z "$BASH"  ]; then
    PROMPT_COMMAND=__jvm_main
    # shellcheck disable=SC2039
    complete -W "local global version reload config" jvm
  elif [ ! -z "$ZSH_NAME" ]; then
    chpwd() {
      __jvm_main
    }
    _jvm() {
      _arguments "1: :(local global version reload config)"
    }
    # shellcheck disable=SC2039
    compdef _jvm jvm
  fi
}

main
