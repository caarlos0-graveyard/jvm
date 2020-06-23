#!/bin/sh
# RegExp used to find the java version in a pom file.
POM_REGEX="<(java.version|maven.compiler.source|source)>1\.[4-9]</.*>"
# RegExp used to find the java version in a build.gradle file.
GRADLE_REGEX="(sourceCompatibility|targetCompatibility) ?= ?1\.[4-9]"

# finds the java home for the given version
__jvm_javahome() {
	# shellcheck disable=SC2039
	local version="$1"

	# custom jdk strategy
	test -f ~/.jvmconfig &&
		new="$(grep "$version"= ~/.jvmconfig | cut -f2 -d'=')"

	# ubuntu/debian jdk strategy
	test -z "$new" -a -d "/usr/lib/jvm/java-${version}-oracle/" &&
		new="/usr/lib/jvm/java-${version}-oracle/"

	# osx jdk strategy
	osx_version="$version"
	test "$version" -le 8 && osx_version="1.$version"
	test -z "$new" -a -e /usr/libexec/java_home &&
		new="$(/usr/libexec/java_home -v "$osx_version" || true)"

	# sanity check: new must be a folder.
	test -n "$new" -a -d "$new" || return 1
	echo "$new"
}

# find the appropriate JAVA_HOME for the given java version and fix PATH.
__jvm_set() {
	# shellcheck disable=SC2039
	local version previous new
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

# tries to find the java version using regex inside a pom.xml file.
__jvm_pomversion() {
	# shellcheck disable=SC2039
	local proj tag pom
	proj="$1"
	pom="$proj/pom.xml"
	test ! -s "$pom" && return 1
	tag="$(grep -Eo "$POM_REGEX" "$pom")"
	test -z "$tag" && return 1
	echo "$tag" |
		cut -f2 -d'>' |
		cut -f2 -d'.' |
		cut -f1 -d'<'
}

# tries to find the java version using regex inside a build.gradle file.
__jvm_gradleversion() {
	# shellcheck disable=SC2039
	local proj property build
	proj="$1"
	build="$proj/build.gradle"
	test ! -s "$build" && return 1
	property="$(grep -Eo "$GRADLE_REGEX" "$build" | head -n1)"
	test -z "$property" && return 1
	echo "$property" | tr -d ' ' | cut -f2 -d '=' | cut -f2 -d'.'
}

# tries to get the version from the local .java-version
__jvm_local_version() {
	# shellcheck disable=SC2039
	local file="$1/.java-version"
	test -s "$file" || return 1
	cat "$file"
}

# tries to get the version from the user .java-version
__jvm_user_version() {
	test -s ~/.java-version || return 1
	cat ~/.java-version
}

# finds out which java version should be used.
__jvm_version() {
	# shellcheck disable=SC2039
	local version parent proj
	proj="$1"
	test -z "$proj" && proj="."

	# try to load from .java-version
	version="$(__jvm_local_version "$proj")"

	# try to extract from pom.xml
	test -z "$version" && version="$(__jvm_pomversion "$proj")"

	# try to extrat from build.gradle
	test -z "$version" && version="$(__jvm_gradleversion "$proj")"

	# go up looking for pom.xmls and .java-versions
	parent="$proj/.."
	test -z "$version" &&
		test -f "$parent/pom.xml" -o -f "$parent/.java-version" &&
		version="$(__jvm_version "$parent")"

	# if still no version found, use the user defined version
	test -z "$version" && version="$(__jvm_user_version)"

	echo "$version"
}

# called when current pwd changes. Find which java version to use and sets
# it to PATH.
__jvm_main() {
	# shellcheck disable=SC2039
	local version
	version="$(__jvm_version)"
	test -n "$version" && __jvm_set "$version"
}

# edit custom java version configurations
__jvm_config() {
	# shellcheck disable=SC2039
	local file="$HOME/.jvmconfig"
	test ! -f "$file" && echo "custom-jdk=/path/to/custom/jdk" >"$file"
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
	# shellcheck disable=SC2039
	local command
	if [ "$#" != 0 ]; then
		command="$1"
		shift
	fi
	case "$command" in
	local)
		test -z "$@" && __jvm_usage && return 1
		echo "$@" >.java-version
		__jvm_main
		;;
	global)
		test -z "$@" && __jvm_usage && return 1
		echo "$@" >~/.java-version
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
	if [ -n "$BASH" ]; then
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
	__jvm_main
}

main || true
