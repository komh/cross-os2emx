# Makefile to build cross-os2emx

PACKAGE := cross-os2emx
VERSION := b1

TAR := tar
TARFLAGS := cvzf
TARBALL := $(PACKAGE)-$(VERSION).tar.gz

# Directory where cross-os2emx will be installed.
# That is, $PREFIXROOT/opt/os2emx.
PREFIXROOT := $(HOME)
PREFIX := $(patsubst %/,%,$(PREFIXROOT))/opt/os2emx
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib

TARGETSPEC := i686-pc-os2-emx
TARGETPREFIX := $(PREFIX)/$(TARGETSPEC)
TARGETBINDIR := $(TARGETPREFIX)/bin
TARGETINCDIR := $(TARGETPREFIX)/include
TARGETLIBDIR := $(TARGETPREFIX)/lib

AR := $(BINDIR)/$(TARGETSPEC)-ar
ARFLAGS := cru

MKDIR_P := mkdir -p
RM := rm -f
INSTALL := install
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

LIBCZIP := libc-0_1_14-1_oc00.zip
LIBCZIPURL := https://rpm.netlabs.org/release/00/zip/$(LIBCZIP)
LIBCZIPDIR := libc-$(TARGETSPEC)

BUILDDIR := build

.PHONY: all all-binutils all-libc all-emxtools all-gcc \
        install install-binutils install-libc install-emxtools install-extras \
		install-gcc \
		clean clean-binutils clean-libc clean-emxtools clean-gcc \
		dist

all: all-binutils all-libc all-emxtools all-gcc

all-binutils:
	$(MKDIR_P) $(BINUTILSDIR)/$(BUILDDIR)
	cd $(BINUTILSDIR); \
	test -f configure || { chmod a+x autogen.sh; ./autogen.sh; } || exit 1; \
	cd $(BUILDDIR); \
	test "$(FORCE_CONFIGURE)" == "" -a -f config.status || \
	  PREFIXROOT=$(PREFIXROOT) ../conf-os2emx-cross;
	$(MAKE) -C $(BINUTILSDIR)/$(BUILDDIR)

all-libc: $(LIBCZIPDIR)/$(LIBCZIP)
	$(UNZIP) $(LIBCZIPDIR)/$(LIBCZIP) -d $(LIBCZIPDIR)

$(LIBCZIPDIR)/$(LIBCZIP):
	$(MKDIR_P) $(LIBCZIPDIR)
	cd $(LIBCZIPDIR); $(WGET) $(LIBCZIPURL)

all-emxtools: all-binutils
	$(MAKE) -C $(EMXDIR) -f Makefile.cross

all-gcc: install-binutils install-libc install-emxtools
	$(MKDIR_P) $(GCCDIR)/$(BUILDDIR)
	cd $(GCCDIR); \
	test -f configure || { chmod a+x autogen.sh; ./autogen.sh; } || exit 1; \
	cd $(BUILDDIR); \
	test "$(FORCE_CONFIGURE)" == "" -a -f config.status || \
	  PREFIXROOT=$(PREFIXROOT) ../conf-os2emx-cross;
	$(MAKE) -C $(GCCDIR)/$(BUILDDIR) all-gcc all-target-libgcc
	# Hack for libdstdc++-v3.
	# This may be removed if building a shared libgcc.
	test -f $(GCCDIR)/$(BUILDDIR)/gcc/libgcc_so_d.a || \
	  $(LN_S) libgcc.a $(GCCDIR)/$(BUILDDIR)/gcc/libgcc_so_d.a
	$(MAKE) -C $(GCCDIR)/$(BUILDDIR) all-target-libstdc++-v3

install: install-binutils install-libc install-emxtools install-extras \
         install-gcc

install-binutils: all-binutils
	$(MAKE) -C $(BINUTILSDIR)/$(BUILDDIR) install DESTDIR=$(DESTDIR)

install-libc: all-libc
	$(INSTALL) -d $(DESTDIR)$(TARGETPREFIX)
	$(CP) -pR "$(LIBCZIPDIR)/@unixroot/usr/include" \
	          "$(DESTDIR)$(TARGETINCDIR)"
	$(CP) -pR "$(LIBCZIPDIR)/@unixroot/usr/lib" \
	          "$(DESTDIR)$(TARGETLIBDIR)"
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
	           install-gcc install-target-libgcc install-target-libstdc++-v3
	# Hack for libgcc_eh.a and libgcc_so_d.a.
	# This may be removed if building a shared libgcc.
	v=$$(sed -e 's/^\([0-9]*\).*/\1/' $(GCCDIR)/gcc/BASE-VER) && \
	  $(AR) $(ARFLAGS) \
	        $(DESTDIR)$(LIBDIR)/gcc/$(TARGETSPEC)/$$v/libgcc_eh.a && \
	  $(LN_S) -f libgcc.a \
	        $(DESTDIR)$(LIBDIR)/gcc/$(TARGETSPEC)/$$v/libgcc_so_d.a

dist:
	destdir=$(CURDIR)/$(PACKAGE)-$(VERSION); \
	prefixroot=$(patsubst %/,%,$(PREFIXROOT)); \
	test -z "$$prefixroot" || \
	  prefixrootfirst=/$$(echo $$prefixroot | cut -d '/' -f 2); \
	prefix=$(PREFIX); \
	test -z "$$prefixroot" || \
	  prefix=$$(echo $$prefix | sed -e "s,$$prefixroot,,"); \
	prefixfirst=/$$(echo $$prefix | cut -d '/' -f 2); \
	$(MAKE) install DESTDIR=$$destdir PREFIXROOT=$(PREFIXROOT) && \
	$(MV) $$destdir$$prefixroot/$$prefixfirst $$destdir$$prefixfirst && \
	$(SED) -e "s/@VER@/$(VERSION)/g" $(PACKAGE).txt \
	 > $$destdir/$(PACKAGE)-$(VERSION).txt && \
	$(CP) README.md $$destdir && \
	{ test -z "$$prefixrootfirst" || $(RM) -r $$destdir$$prefixrootfirst; }; \
	$(RM) $(TARBALL); \
	$(TAR) $(TARFLAGS) $(TARBALL) $(PACKAGE)-$(VERSION); \
	$(RM) -r $(PACKAGE)-$(VERSION)

clean: clean-binutils clean-libc clean-emxtools clean-gcc
	$(RM) $(TARBALL)

clean-binutils:
	$(RM) -r $(BINUTILSDIR)/$(BUILDDIR)

clean-libc:
	$(RM) -r $(LIBCZIPDIR)

clean-emxtools:
	$(MAKE) -C $(EMXDIR) -f Makefile.cross clean

clean-gcc:
	$(RM) -r $(GCCDIR)/$(BUILDDIR)
