MAINTAINERCLEANFILES = $(srcdir)/Makefile.in

SUBDIRS = cron extractor grapher

dist_doc_DATA = README.md CHANGES LICENSE

EXTRA_DIST = certs doc m4 perllib autogen.sh

test:
	@true

all-local:
	cd $(srcdir)/perllib && test -f Makefile || $(PERL) Makefile.PL INSTALL_BASE=$(prefix) && $(MAKE) all

install-data-local:
	cd $(srcdir)/perllib && test -f Makefile && $(MAKE) install

clean-local:
	cd $(srcdir)/perllib && test -f Makefile && $(MAKE) clean || true

maintainer-clean-local:
	cd $(srcdir)/perllib && test -f Makefile && $(MAKE) realclean || true

dist-hook:
	cd $(srcdir)/perllib && test -f Makefile && $(MAKE) realclean || true
