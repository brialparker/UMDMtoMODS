UMDMtoMODS
==========

Stylesheet for converting UMDM.xml to MODS.xml

Still working out kinks, but most basic fields transform properly. Need to add some more efficiency to it, but for testing things in Fedora4, it should work.

getsamplerdf
------------

The [getsamplerdf](getsamplerdf) script has several prerequisites.

### Python 3

Easiest way is to manage it with [pyenv](https://github.com/yyuu/pyenv). If you
don't already have it, follow the [installation
instructions](https://github.com/yyuu/pyenv#homebrew-on-mac-os-x). Once you have
it installed, you are ready to install Python 3, and set the local Python for
this directory.

```
$ pyenv install 3.4.2
$ pyenv local 3.4.2
```

### Python LXML library

```
$ pip install lxml
```

### Saxon 9 HE

Download the ZIP file from
[here](http://sourceforge.net/projects/saxon/files/Saxon-HE/). Unzip and copy
the saxon9he.jar to a safe location (e.g., `~/jar`). Make sure it is on your
`$CLASSPATH`; add the following to your `~/.bash_profile`:

```bash
CLASSPATH=$HOME/jar/saxon9he.jar
```

### libxml2

This provides both the `xsltproc` and `xmllint` programs.

```
$ brew install libxml2
```

### Raptor

This provides the `rapper` program.

```
$ brew install raptor
```
