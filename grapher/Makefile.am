MAINTAINERCLEANFILES = $(srcdir)/Makefile.in

CLEANFILES = update-dat-file-locations.sh \
    dsc-grapher-cli.pl \
    dsc-grapher.pl

scriptdir = $(DSP_LIBEXEC_DIR)
script_SCRIPTS = dsc-grapher-cli.pl

cgibindir = $(DSP_CGI_BIN_DIR)
cgibin_SCRIPTS = dsc-grapher.pl

etcdir = $(DSP_ETC_DIR)
dist_etc_DATA = dsc-grapher.cfg.sample

htmldir = $(DSP_HTML_DIR)
dist_html_DATA = plot.page \
    icons/1downarrow.png \
    icons/1leftarrow.png \
    icons/1rightarrow.png \
    icons/1uparrow.png \
    icons/2downarrow.png \
    icons/2leftarrow.png \
    icons/2rightarrow.png \
    icons/2uparrow.png

script_SCRIPTS += update-dat-file-locations.sh

EXTRA_DIST = update-dat-file-locations.sh.in \
    dsc-grapher-cli.pl.in \
    dsc-grapher.pl.in

update-dat-file-locations.sh: update-dat-file-locations.sh.in Makefile
	sed -e 's,[@]DSC_DATA_DIR[@],$(DSC_DATA_DIR),g' \
        < $(srcdir)/update-dat-file-locations.sh.in > update-dat-file-locations.sh

dsc-grapher-cli.pl: dsc-grapher-cli.pl.in Makefile
	sed -e 's,[@]DSC_DATA_DIR[@],$(DSC_DATA_DIR),g' \
        -e 's,[@]DSP_ETC_DIR[@],$(DSP_ETC_DIR),g' \
        -e 's,[@]DSP_CACHE_DIR[@],$(DSP_CACHE_DIR),g' \
        -e 's,[@]DSP_HTML_DIR[@],$(DSP_HTML_DIR),g' \
        < $(srcdir)/dsc-grapher-cli.pl.in > dsc-grapher-cli.pl

dsc-grapher.pl: dsc-grapher.pl.in Makefile
	sed -e 's,[@]DSC_DATA_DIR[@],$(DSC_DATA_DIR),g' \
        -e 's,[@]DSP_ETC_DIR[@],$(DSP_ETC_DIR),g' \
        -e 's,[@]DSP_CACHE_DIR[@],$(DSP_CACHE_DIR),g' \
        -e 's,[@]DSP_HTML_DIR[@],$(DSP_HTML_DIR),g' \
        < $(srcdir)/dsc-grapher.pl.in > dsc-grapher.pl
