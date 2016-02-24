# jvm test suite

Initial setup

```console
$ ROOT="$(pwd)"
$ TESTS="tests"
$ find . -name '.java-version' -delete
$ source jvm.sh
$
```

Test global

```console
$ jvm global 8
$ jvm version
8
$
```

Test local

```console
$ jvm local 7
$ jvm version
7
$
```

Test POM 8

```console
$ cd "$ROOT/$TESTS/java8"
$ jvm reload
$ jvm version
8
$
```

Test POM 7

```console
$ cd "$ROOT/$TESTS/java7"
$ jvm reload
$ jvm version
7
$
```

Test POM 7 grep

```console
$ cd "$ROOT/$TESTS/grep"
$ jvm reload
$ jvm version
7
$
```

Cleanup

```console
$ cd "$ROOT"
$ find . -name '.java-version' -delete
$
```
