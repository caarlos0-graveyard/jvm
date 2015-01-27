#!/bin/zsh

chpwd() {
  if [[ -f pom.xml ]]; then
    local java_version="$(\
      cat pom.xml | \
      grep '<java.version>' | \
      sed 's/.*<java.version>1.\(.*\)<\/java.version>.*/\1/' \
    )"
    export JAVA_HOME="/usr/lib/jvm/java-${java_version}-oracle/"
    export PATH="$JAVA_HOME/bin:$PATH"
  fi
}

