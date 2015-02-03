# jvm  [![Build Status](https://travis-ci.org/caarlos0/jvm.svg?branch=master)](https://travis-ci.org/caarlos0/jvm) [![Stories in Ready](https://badge.waffle.io/caarlos0/jvm.png?label=ready&title=Ready)](https://waffle.io/caarlos0/jvm)

> The _"Java Version Manager"_

Automatically change `JAVA_HOME` based on current directory `pom.xml`
or `.java-version` files.

The philosophy behind this project is to simplify and automatize the `JAVA_HOME`
changing, much like `rbenv` and `rvm` do for Ruby.

It's pretty common to have to work in Java 6, 7 and 8 projects, and changing
`PATH`s and `JAVA_HOME`s by hand is annoying.

### Usage

```sh
git clone https://github.com/caarlos0/jvm.git ~/.jvm

# for bash
echo "source ~/.jvm/jvm.sh" >> .bashrc

# for zsh
echo "source ~/.jvm/jvm.sh" >> .zshrc
```

Then, just `cd` to a java project folder. If the `pom.xml`  has a
`<java.version>1.7</java.version>`, for example, jvm will try to
set JDK7 to your PATH.

If you don't have and don't want to have this in your project's pom,
you can also do this:

```sh
echo 7 > .java-version
```

On OSX, jvm will use the `java_home` tool to find the available versions. For
Ubuntu, right now jvm has `/usr/lib/jvm/java-${version}-oracle/` hard coded.
This might change soon.

### Antigen

For those using Antigen, just hit

```sh
antigen bundle caarlos0/jvm
```

And it should all work out of the box.
