MAINTAINERCLEANFILES = $(srcdir)/Makefile.in

SUBDIRS = cron extractor grapher

dist_doc_DATA = README.md CHANGES LICENSE

EXTRA_DIST = certs doc m4 autogen.sh

if DSC_CREATE_DIRS
install-data-local:
	mkdir -p "$(DSP_LOG_DIR)" \
      "$(DSC_DATA_DIR)" \
      "$(DSP_CACHE_DIR)"
endif

test:
	@true
