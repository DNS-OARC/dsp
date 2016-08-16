MAINTAINERCLEANFILES = $(srcdir)/Makefile.in

SUBDIRS = cron extractor grapher

dist_doc_DATA = README.md CHANGES LICENSE

EXTRA_DIST = certs doc m4 autogen.sh

if DSC_CREATE_DIRS
install-data-local:
	mkdir -p "$(DESTDIR)$(DSP_LOG_DIR)" \
      "$(DESTDIR)$(DSC_DATA_DIR)" \
      "$(DESTDIR)$(DSP_CACHE_DIR)"
endif

test:
	@true
