MAINTAINERCLEANFILES = $(srcdir)/Makefile.in

CLEANFILES = put-file.pl

scriptdir = $(DSP_LIBEXEC_DIR)
dist_script_SCRIPTS = dsc-xml-extractor.pl \
    fix-corrupted-dat-files.pl

cgibindir = $(DSP_CGI_BIN_DIR)
cgibin_SCRIPTS = put-file.pl

EXTRA_DIST = put-file.pl.in

put-file.pl: put-file.pl.in Makefile
	sed -e 's,[@]DSC_DATA_DIR[@],$(DSC_DATA_DIR),g' \
        -e 's,[@]DSP_LOG_DIR[@],$(DSP_LOG_DIR),g' \
        < $(srcdir)/put-file.pl.in > put-file.pl
