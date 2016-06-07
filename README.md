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
