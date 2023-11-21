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


	# opensuse(/redhat?) 64 bit jdk strategy
	test -z "$new" -a -d "/usr/lib64/jvm/java-${version}-openjdk-${version}/" &&
		new="/usr/lib64/jvm/java-${version}-openjdk-${version}/"


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
