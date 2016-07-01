# DNS Statistics Presenter

[![Build Status](https://travis-ci.org/DNS-OARC/dsp.svg?branch=develop)](https://travis-ci.org/DNS-OARC/dsp)

DNS Statistics Presenter (DSP) is a tool used for exploring statistics from
busy DNS servers collected by DNS Statistics Collector (DSC).

DNS Statistics Collector can be found here:
- https://github.com/DNS-OARC/dsc

More information about DSP/DSC may be found here:
- https://www.dns-oarc.net/tools/dsc
- https://www.dns-oarc.net/oarc/data/dsc

Issues should be reported here:
- https://github.com/DNS-OARC/dsp/issues

Mailinglist:
- https://lists.dns-oarc.net/mailman/listinfo/dsc

# Dependencies

Following dependencies are needed, example for Debian/Ubuntu. Check
`./configure` for a full list of dependencies.

```
sudo apt-get install libproc-pid-file-perl libxml-simple-perl
```

Or you can install them all using `cpanm`.

```
cpanm --quiet --notest Proc::PID::File XML::Simple
```

The DSC Perl library needs to be installed also, if you can't find it in your
distribution or on CPAN you can clone the repository, this example installs the
latest development version using cpanminus.

```
git clone https://github.com/DNS-OARC/p5-DSC.git
cd p5-DSC
cpanm --quiet --notest .
```

# Prepare

If you are installing from the GitHub repository you need to generate configure.

```
./autogen.sh
```

# Install as pre 2.0.0

As of version 2.0.0 most of the paths has been changed and if your
upgrading an older installation and want to keep the paths as they were
this is how you can do it.

Asuming the old prefix of `/usr/local/dsc`, see `configure --help` for more
information.

```
prefix=/usr/local/dsc
./configure --prefix=$prefix \
    --with-data-dir=$prefix/data \
    --with-cgi-bin-dir=$prefix/libexec \
    --with-html-dir=$prefix/share/html \
    --with-etc-dir=$prefix/etc \
    --with-libexec-dir=$prefix/libexec \
    --with-cache-dir=$prefix/cache \
    --with-log-dir=$prefix/var/log \
    --enable-create-dirs
make
make install
```

# Install

Run `configure` with optional options and then install, see `configure --help`
for more information.

```
./configure [options ... ]
make
make install
```

You can use `--enable-create-dirs` to create the necessary directories upon
installation.
