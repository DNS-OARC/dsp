# Copyright (c) 2016, OARC, Inc.
# Copyright (c) 2007, The Measurement Factory, Inc.
# Copyright (c) 2007, Internet Systems Consortium, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

AC_PREREQ(2.61)
AC_INIT([DSP], [2.0.0], [dsc@dns-oarc.net], [dsp], [https://github.com/DNS-OARC/dsp/issues])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])
AC_CONFIG_SRCDIR([grapher/dsc-grapher-cli.pl])
AC_CONFIG_MACRO_DIR([m4])

# Checks for programs.
AC_PROG_INSTALL
AC_PATH_PROG([PERL],[perl])

# Checks for Perl version and modules
AX_PROG_PERL_VERSION([5.8.0], ,
    AC_MSG_ERROR(Need Perl))
AX_PROG_PERL_MODULES([
    Cwd
    DSC::extractor
    DSC::extractor::config
    Data::Dumper
    Proc::PID::File
    POSIX
    XML::Simple
    File::Copy
    Digest::MD5
    DSC::putfile
    DSC::grapher
    CGI
    Getopt::Long], ,
    AC_MSG_ERROR(Need some Perl modules))

# data dir
AC_ARG_WITH(data-dir,
    [AS_HELP_STRING([--with-data-dir=DIR],
        [use DIR for DSC data [LOCALSTATEDIR/lib/dsc]])],
    [],
    [with_data_dir=${localstatedir}/lib/dsc])

AC_SUBST([DSC_DATA_DIR], [$with_data_dir])

# cgi bin dir
AC_ARG_WITH(cgi-bin-dir,
    [AS_HELP_STRING([--with-cgi-bin-dir=DIR],
        [use DIR for cgi-bin scripts [LIBDIR/cgi-bin]])],
    [],
    [with_cgi_bin_dir=${libdir}/cgi-bin])

AC_SUBST([DSP_CGI_BIN_DIR], [$with_cgi_bin_dir])

# html dir
AC_ARG_WITH(html-dir,
    [AS_HELP_STRING([--with-html-dir=DIR],
        [use DIR for html content [DATAROOTDIR/dsp/html]])],
    [],
    [with_html_dir=${datarootdir}/dsp/html])

AC_SUBST([DSP_HTML_DIR], [$with_html_dir])

# etc dir
AC_ARG_WITH(etc-dir,
    [AS_HELP_STRING([--with-etc-dir=DIR],
        [use DIR for configuration [SYSCONFDIR/dsp]])],
    [],
    [with_etc_dir=${sysconfdir}/dsp])

AC_SUBST([DSP_ETC_DIR], [$with_etc_dir])

# libexec dir
AC_ARG_WITH(libexec-dir,
    [AS_HELP_STRING([--with-libexec-dir=DIR],
        [use DIR for library executables [LIBEXECDIR/dsp]])],
    [],
    [with_libexec_dir=${libexecdir}/dsp])

AC_SUBST([DSP_LIBEXEC_DIR], [$with_libexec_dir])

# create dirs
AC_ARG_ENABLE(create-dirs,
    [AS_HELP_STRING([--enable-create-dirs],
        [create directories as pre 2.0.0 [PREFIX/(var/log|data|cache)]])],
    [case "${enableval}" in
        yes)
            create_dirs=true
            ;;
        no)
            create_dirs=false
            ;;
        *)
            AC_MSG_ERROR(bad value ${enableval} for --enable-create-dirs)
            ;;
    esac],
    [create_dirs=false])

AM_CONDITIONAL([DSC_CREATE_DIRS], [test "x$create_dirs" = "xtrue"])

# Create Makefiles
AC_CONFIG_FILES([
    Makefile
    cron/Makefile
    extractor/Makefile
    grapher/Makefile
])
AC_OUTPUT
