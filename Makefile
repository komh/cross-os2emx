# Makefile to build cross-os2emx

PACKAGE := cross-os2emx
VERSION := $(shell git describe --abbrev=0)

TAR := tar
TARFLAGS := cvzf
TARBALL := $(PACKAGE)-$(VERSION).tar.gz

# Directory where cross-os2emx will be installed.
# That is, $PREFIXROOT/opt/os2emx.
PREFIXROOT := $(HOME)
PREFIX := $(patsubst %/,%,$(PREFIXROOT))/opt/os2emx
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib
SHAREDIR := $(PREFIX)/share

TARGETSPEC := i686-pc-os2-emx
TARGETCPU := $(firstword $(subst -, ,$(TARGETSPEC)))
TARGETPREFIX := $(PREFIX)/$(TARGETSPEC)
TARGETBINDIR := $(TARGETPREFIX)/bin
TARGETINCDIR := $(TARGETPREFIX)/include
TARGETLIBDIR := $(TARGETPREFIX)/lib

AR := $(BINDIR)/$(TARGETSPEC)-ar
ARFLAGS := cru

MKDIR_P := mkdir -p
RM := rm -f
INSTALL := install
INSTALLDATA := $(INSTALL) -m 644
UNZIP := unzip -u
WGET := wget
CP := cp
LN_S := ln -s
MV := mv
SED := sed

BINUTILSDIR := binutils-os2
LIBCDIR := libc
GCCDIR := gcc-os2
EMXDIR := $(LIBCDIR)/src/emx
EXTRASDIR := extras
CMAKEDIR := cmake-os2
MESONCROSSFILE := meson/$(TARGETSPEC)
CMAKECROSSFILE := cmake/$(TARGETSPEC).cmake

LIBCZIP := libc-0_1_14-1_oc00.zip
LIBCZIPURL := https://rpm.netlabs.org/release/00/zip/$(LIBCZIP)
LIBCZIPDIR := libc-$(TARGETSPEC)

BUILDDIR := build

.PHONY: all all-binutils all-libc all-emxtools all-gcc all-meson all-cmake \
        install install-binutils install-libc install-emxtools install-extras \
		install-gcc install-meson install-cmake \
		clean clean-binutils clean-libc clean-emxtools clean-gcc clean-meson \
		clean-cmake \
		dist

all: all-binutils all-libc all-emxtools all-gcc all-meson all-cmake

all-binutils:
	$(MKDIR_P) $(BINUTILSDIR)/$(BUILDDIR)
	cd $(BINUTILSDIR); \
	test -f configure || { chmod a+x autogen.sh; ./autogen.sh; } || exit 1; \
	cd $(BUILDDIR); \
	test "$(FORCE_CONFIGURE)" = "" -a -f config.status || \
	  PREFIXROOT=$(PREFIXROOT) ../conf-os2emx-cross;
	$(MAKE) -C $(BINUTILSDIR)/$(BUILDDIR)

all-libc: $(LIBCZIPDIR)/$(LIBCZIP)
	$(UNZIP) $(LIBCZIPDIR)/$(LIBCZIP) -d $(LIBCZIPDIR)

$(LIBCZIPDIR)/$(LIBCZIP):
	$(MKDIR_P) $(LIBCZIPDIR)
	cd $(LIBCZIPDIR); $(WGET) $(LIBCZIPURL)

all-emxtools: all-binutils
	$(MAKE) -C $(EMXDIR) -f Makefile.cross

all-gcc: install-binutils install-libc install-emxtools install-extras
	$(MKDIR_P) $(GCCDIR)/$(BUILDDIR)
	cd $(GCCDIR); \
	contrib/download_prerequisites || exit 1; \
	test -f configure || { chmod a+x autogen.sh; ./autogen.sh; } || exit 1; \
	cd $(BUILDDIR); \
	test "$(FORCE_CONFIGURE)" = "" -a -f config.status || \
	  PREFIXROOT=$(PREFIXROOT) ../conf-cross-os2emx;
	export PATH=$(DESTDIR)$(BINDIR):$(PATH); \
	$(MAKE) -C $(GCCDIR)/$(BUILDDIR) \
	  all-gcc all-target-libgcc all-target-libstdc++-v3 all-target-libssp

all-meson: $(MESONCROSSFILE)-aout.txt $(MESONCROSSFILE)-omf.txt

$(MESONCROSSFILE)-aout.txt: $(MESONCROSSFILE)-aout.txt.in
	$(SED) -e 's,@PREFIX@,$(PREFIX),g' -e 's,@TARGETSPEC@,$(TARGETSPEC),g' \
	       -e 's,@TARGETCPU@,$(TARGETCPU),g' < $< > $@

$(MESONCROSSFILE)-omf.txt: $(MESONCROSSFILE)-omf.txt.in
	$(SED) -e 's,@PREFIX@,$(PREFIX),g' -e 's,@TARGETSPEC@,$(TARGETSPEC),g' \
	       -e 's,@TARGETCPU@,$(TARGETCPU),g' < $< > $@

all-cmake: $(CMAKECROSSFILE)
	$(MKDIR_P) $(CMAKEDIR)/$(BUILDDIR)
	cd $(CMAKEDIR)/$(BUILDDIR); \
	test -f Makefile || \
	  ../configure --prefix=$(PREFIX);
	export PATH=$(DESTDIR)$(BINDIR):$(PATH); \
	$(MAKE) -C $(CMAKEDIR)/$(BUILDDIR)

$(CMAKECROSSFILE): $(CMAKECROSSFILE).in
	$(SED) -e 's,@PREFIX@,$(PREFIX),g' -e 's,@TARGETSPEC@,$(TARGETSPEC),g' \
	       -e 's,@TARGETCPU@,$(TARGETCPU),g' < $< > $@

install: install-binutils install-libc install-emxtools install-extras \
         install-gcc install-meson install-cmake

install-binutils: all-binutils
	$(MAKE) -C $(BINUTILSDIR)/$(BUILDDIR) install DESTDIR=$(DESTDIR)

install-libc: all-libc
	$(INSTALL) -d $(DESTDIR)$(TARGETPREFIX)
	$(CP) -a "$(LIBCZIPDIR)/@unixroot/usr/include" \
	         "$(DESTDIR)$(TARGETPREFIX)"
	$(CP) -a "$(LIBCZIPDIR)/@unixroot/usr/lib" \
	         "$(DESTDIR)$(TARGETPREFIX)"
	$(INSTALL) -d $(DESTDIR)$(TARGETPREFIX)/usr
	$(RM) $(DESTDIR)$(TARGETPREFIX)/usr/include
	$(LN_S) ../include $(DESTDIR)$(TARGETPREFIX)/usr/include
	$(RM) $(DESTDIR)$(TARGETPREFIX)/usr/lib
	$(LN_S) ../lib $(DESTDIR)$(TARGETPREFIX)/usr/lib

install-emxtools: all-emxtools
	$(MAKE) -C $(EMXDIR) -f Makefile.cross install \
	  DESTDIR=$(DESTDIR) PREFIXROOT=$(PREFIXROOT)

install-extras:
	$(INSTALL) -d $(DESTDIR)$(TARGETBINDIR)
	$(INSTALL) -d $(DESTDIR)$(BINDIR)
	for f in $(EXTRASDIR)/* ; do \
	  n=$$(basename $$f); \
	  $(INSTALL) $$f $(DESTDIR)$(TARGETBINDIR)/$$n; \
	  if test "$$n" != "ldstub.bin" ; then \
	    $(LN_S) -f ../$(TARGETSPEC)/bin/$$n $(DESTDIR)$(BINDIR); \
	    $(LN_S) -f ../$(TARGETSPEC)/bin/$$n \
	               $(DESTDIR)$(BINDIR)/$(TARGETSPEC)-$$n; \
	  fi; \
	done

install-gcc: all-gcc
	$(MAKE) -C $(GCCDIR)/$(BUILDDIR) DESTDIR=$(DESTDIR) \
	           install-gcc install-target-libgcc install-target-libstdc++-v3 \
	           install-target-libssp

install-meson: all-meson
	$(INSTALLDATA) -D $(MESONCROSSFILE)-aout.txt \
	  $(DESTDIR)$(SHAREDIR)/meson/cross/$(notdir $(MESONCROSSFILE)-aout.txt)
	$(INSTALLDATA) -D $(MESONCROSSFILE)-omf.txt \
	  $(DESTDIR)$(SHAREDIR)/meson/cross/$(notdir $(MESONCROSSFILE)-omf.txt)

install-cmake: all-cmake
	$(INSTALLDATA) -D $(CMAKECROSSFILE) \
	  $(DESTDIR)$(SHAREDIR)/cmake/cross/$(notdir $(CMAKECROSSFILE))
	$(MAKE) -C $(CMAKEDIR)/$(BUILDDIR) install DESTDIR=$(DESTDIR)

dist:
	destdir=$(CURDIR)/$(PACKAGE)-$(VERSION); \
	prefixroot=$(patsubst %/,%,$(PREFIXROOT)); \
	test -z "$$prefixroot" || \
	  prefixrootfirst=/$$(echo $$prefixroot | cut -d '/' -f 2); \
	prefix=$(PREFIX); \
	test -z "$$prefixroot" || \
	  prefix=$$(echo $$prefix | $(SED) -e "s,$$prefixroot,,"); \
	prefixfirst=/$$(echo $$prefix | cut -d '/' -f 2); \
	$(MAKE) install DESTDIR=$$destdir PREFIXROOT=$(PREFIXROOT) && \
	{ \
	  test-z "$$prefixroot" || \
	    $(MV) $$destdir$$prefixroot$$prefixfirst $$destdir$$prefixfirst; \
	} && \
	$(SED) -e "s/@VER@/$(VERSION)/g" $(PACKAGE).txt \
	  > $$destdir/$(PACKAGE)-$(VERSION).txt && \
	$(CP) README.md $$destdir && \
	{ test -z "$$prefixrootfirst" || $(RM) -r $$destdir$$prefixrootfirst; }; \
	$(RM) $(TARBALL); \
	$(TAR) $(TARFLAGS) $(TARBALL) $(PACKAGE)-$(VERSION); \
	$(RM) -r $(PACKAGE)-$(VERSION)

clean: clean-binutils clean-libc clean-emxtools clean-gcc clean-meson \
       clean-cmake
	$(RM) $(TARBALL)

clean-binutils:
	$(RM) -r $(BINUTILSDIR)/$(BUILDDIR)

clean-libc:
	$(RM) -r $(LIBCZIPDIR)

clean-emxtools:
	$(MAKE) -C $(EMXDIR) -f Makefile.cross clean

clean-gcc:
	$(RM) -r $(GCCDIR)/$(BUILDDIR)

clean-meson:
	$(RM) $(MESONCROSSFILE)-aout.txt $(MESONCROSSFILE)-omf.txt

clean-cmake:
	$(RM) $(CMAKECROSSFILE)
	$(RM) -r $(CMAKEDIR)/$(BUILDDIR)
