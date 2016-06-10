MAINTAINERCLEANFILES = $(srcdir)/Makefile.in

CLEANFILES = update-dat-file-locations.sh

scriptdir = $(DSP_LIBEXEC_DIR)
dist_script_SCRIPTS = dsc-grapher-cli.pl

cgibindir = $(DSP_CGI_BIN_DIR)
dist_cgibin_SCRIPTS = dsc-grapher.pl

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

script_SCRIPTS = update-dat-file-locations.sh

EXTRA_DIST = update-dat-file-locations.sh.in

update-dat-file-locations.sh: update-dat-file-locations.sh.in Makefile
	sed -e 's,[@]DSC_DATA_DIR[@],$(DSC_DATA_DIR),g' \
        < $(srcdir)/update-dat-file-locations.sh.in > update-dat-file-locations.sh
