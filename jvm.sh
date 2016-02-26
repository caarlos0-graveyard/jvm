#!/bin/sh
# finds the java home for the given version
__jvm_javahome() {
  version="$1"

  # custom jdk strategy
  test -f ~/.jvmconfig &&
    new="$(grep "$version"= ~/.jvmconfig | cut -f2 -d'=')"

  # ubuntu/debian jdk strategy
  test -z "$new" -a -d "/usr/lib/jvm/java-${version}-oracle/" &&
    new="/usr/lib/jvm/java-${version}-oracle/"

  # osx jdk strategy
  test -z "$new" -a -e /usr/libexec/java_home &&
    new="$(/usr/libexec/java_home -v 1."$version" || true)"

  # sanity check: new must be a folder.
  test -n "$new" -a -d "$new" || return 1
  echo "$new"
}

# find the appropriate JAVA_HOME for the given java version and fix PATH.
__jvm_set() {
  version="$1"
  previous="$JAVA_HOME"

  new="$(__jvm_javahome "$version")"

  # PATH cleanup
  # shellcheck disable=SC2155
  test -n "$previous" -a "$previous" != "$new" &&
    export PATH="$(echo "$PATH" | sed -e "s|$previous/bin:||g")"

  # finally export new home and path
  export JAVA_HOME="$new"
  export PATH="${JAVA_HOME}/bin:$PATH"
}

# tried to find the java version using regex.
__jvm_pomversion_regex() {
  regex="<(java.version|maven.compiler.source|source)>1\.[4-9]</.*>"
  version="$(grep -Eo "$regex" pom.xml)"
  test -z "$version" && return 1
  echo "$version" |
    cut -f2 -d'>' |
    cut -f2 -d'.' |
    cut -f1 -d'<'
}

# tries multiple strategies to find the java version, and then sets it in a
# .java-version
__jvm_pomversion() {
  version="$(__jvm_pomversion_regex)"
  touch .java-version
  test -n "$version" && echo "$version" > .java-version
}

# tries to get the version from the local .java-version
__jvm_local_version() {
  test -s .java-version || return 1
  cat .java-version
}

# tries to get the version from the user .java-version
__jvm_user_version() {
  test -s ~/.java-version || return 1
  cat ~/.java-version
}

# finds out which java version should be used.
__jvm_version() {
  test ! -f .java-version -a -f pom.xml && __jvm_pomversion
  __jvm_local_version || __jvm_user_version
}

# called when a dir changes. Find which java version to use and sets it to PATH.
__jvm_main() {
  version="$(__jvm_version)"
  test -n "$version" && __jvm_set "$version"
}

# edit custom java version configurations
__jvm_config() {
  file="$HOME/.jvmconfig"
  test ! -f "$file" && echo "custom-jdk=/path/to/custom/jdk" > "$file"
  $EDITOR "$file"
}

# shows usage instructions
__jvm_usage() {
  cat <<EOF
NAME:
  jvm - The Java Version Manager

USAGE:
  jvm command [command-options]

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
  if [ -n "$BASH"  ]; then
    PROMPT_COMMAND="__jvm_main; $PROMPT_COMMAND"
    # shellcheck disable=SC2039
    complete -W "local global version reload config" jvm
  elif [ -n "$ZSH_NAME" ]; then
    chpwd() {
      __jvm_main
    }
    # shellcheck disable=SC2039
    compctl -k "(local global version reload config)" jvm
  fi
}

main
