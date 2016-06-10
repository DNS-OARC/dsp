MAINTAINERCLEANFILES = $(srcdir)/Makefile.in

SUBDIRS = cron extractor grapher

dist_doc_DATA = README.md CHANGES LICENSE

EXTRA_DIST = certs doc m4 autogen.sh

if DSC_CREATE_DIRS
install-data-local:
	mkdir -p "$(prefix)/var/log" \
      "$(prefix)/data" \
      "$(prefix)/cache"
endif

test:
	@true
