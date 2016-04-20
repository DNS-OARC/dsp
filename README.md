# DNS Statistics Presenter

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

# Install

Following dependencies are needed, example for Debian/Ubuntu.

```
sudo apt-get install libcgi-untaint-perl libfile-flock-perl libfile-nfslock-perl libhash-merge-perl libmath-calc-units-perl libtext-template-perl libxml-simple-perl
```

Or you can install them all using `cpanm`.

```
cd perllib && cpanm --quiet --installdeps --notest .
```

The Perl module `IP::Country` is needed also which may not exist as a package
for some distributions, you could install it manually.

```
cpanm --quiet --installdeps --notest IP::Country
```

If you are installing from the GitHub repository you need to generate configure.

```
./autogen.sh
```

Now you can compile with optinal options and install.

```
./configure [options ... ]
make
make install
```
