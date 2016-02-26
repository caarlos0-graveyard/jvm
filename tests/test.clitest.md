# jvm test suite

This is the self-document test suite for JVM.

# Initial setup

Just cleanup, variable setting and source what needs to be sourced.

```console
$ ROOT="$(pwd)"
$ TESTS="tests"
$ find . -name '.java-version' -delete
$ source jvm.sh
$ export MAVEN_OPTS=""
$ echo "8=$(__jvm_javahome 7)" > ~/.jvmconfig
$
```

# jvm global

Test setting a global version.

```console
$ jvm global 7
$ jvm version
7
$
```

# jvm local

Test setting a version to the current folder.

```console
$ jvm local 7
$ jvm version
7
$
```

# maven.compiler.source

Test a pom with a `maven.compiler.source` property set to Java 8.

```console
$ cd "$ROOT/$TESTS/java8"
$ jvm reload
$ jvm version
8
$
```

# java.version

Test a pom with a `java.version` property set to Java 7.

```console
$ cd "$ROOT/$TESTS/java7"
$ jvm reload
$ jvm version
7
$
```

# maven-compiler-plugin

Test reading the `source` tag from `maven-compiler-plugin`, which in this
example is set to Java 7.

```console
$ cd "$ROOT/$TESTS/grep"
$ jvm reload
$ jvm version
7
$
```

# parent pom

Test a pom with no java config at all, the config is at its parent pom,
therefore, this will run `mvn help:evaluate` and find out that the parent
is using Java 8.

```console
$ cd "$ROOT/$TESTS/java8/empty"
$ jvm reload
$ jvm version
8
$
```

# jvmconfig

Test that `jvm` respects a custom java version in `~/.jvmconfig`, in this case,
pointing out Java 6 to use Java 7 home.

```console
$ cd "$ROOT/$TESTS/grep"
$ echo "6=$(__jvm_javahome 7)" >> ~/.jvmconfig
$ jvm local 6
$ jvm reload
$ jvm version
6
$
```

# nonjava

Test that a folder with a `pom.xml`, but which is not being used to compile
java projects, will get an empty `.java-version` to avoid running `mvn`
evaluate every time.

```console
$ jvm global 8
$ cd "$ROOT/$TESTS/nonjava"
$ jvm reload
$ jvm version
8
$
```

# Cleanup

Remove unneeded files after all tests ran.

```console
$ cd "$ROOT"
$ find . -name '.java-version' -delete
$ echo "6=$(__jvm_javahome 7)" > ~/.jvmconfig
$ jvm global 8
$
```
