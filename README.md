# jvm [![Build Status](https://travis-ci.org/caarlos0/jvm.svg?branch=master)](https://travis-ci.org/caarlos0/jvm)

> The _"Java Version Manager"_

Automatically change `JAVA_HOME` and `PATH` based on current directory
`.java-version` or `pom.xml` files.

The philosophy behind this project is to simplify and automate the `JAVA_HOME`
changing, much like `rbenv` and `rvm` do for Ruby.

It's pretty common to have to work in Java 6, 7 and 8 projects, and changing
`PATH`s and `JAVA_HOME`s by hand is a very repetitive task.

### Usage

```console
$ git clone https://github.com/caarlos0/jvm.git ~/.jvm
$ echo ".java-version" >> ~/.gitignore

# for bash
$ echo "source ~/.jvm/jvm.sh" >> ~/.bashrc

# for zsh
$ echo "source ~/.jvm/jvm.sh" >> ~/.zshrc
```

Then, just `cd` to a java project folder. `jvm` will look for a `.java-version`
and use whatever version is inside it. If the file don't exist, but a
`pom.xml` do, `jvm` will try to extract the version from the `pom.xml` file
using a regular expression.

`jvm` can also recursively search for `.java-version` and `pom.xml` files, so,
`cd`-ing to project's subfolder should maintain its version set.

You can always change the current folder java version by doing:

```console
$ jvm local 7
```

On OSX, `jvm` will use the `java_home` tool to find the available versions. For
Ubuntu, right now `jvm` has `/usr/lib/jvm/java-${version}-oracle/` hard coded.
This might change soon. If you need custom versions, like `6-openjdk`, for
example, you can run `jvm config` and add a line like this:

```properties
6-openjdk=/path/to/openjdk/6
```

And `jvm` will automagically works.

And, yes, this strategy (based on `jvm config`) can make `jvm` work on Windows
with any `bash` terminal too. Or any other operating system with a POSIX shell
really.

You can also read the [self-document tests][tests] to find out more usages.

[tests]: /tests/test.clitest.md

### Antigen/Antibody

For those using Antigen, Antibody or whatever, just bundle `caarlos0/jvm`, as
in:

```console
$ antibody bundle caarlos0/jvm
```

And it should all work out of the box.

# Honorable mentions

- [@aureliojargas](https://github.com/aureliojargas) for helping review `jvm.sh`
and for rewrite my test suite with
[clitest](https://github.com/aureliojargas/clitest);
- [@velo](https://github.com/velo) for helping me test (on Windows), reporting
bugs and giving some useful suggestions.
