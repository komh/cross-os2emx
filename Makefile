# Makefile to build cross-os2emx

PACKAGE := cross-os2emx
VERSION := $(shell git describe --abbrev=0)

TARC := tar cvzf
TARX := tar xvzf
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
TOUCH := touch
PATCH := patch

AUTOTOOLSDIR := autotools
AUTOCONFTGZ := autoconf-2.69.tar.gz
AUTOCONFTGZURL := https://ftp.gnu.org/gnu/autoconf/$(AUTOCONFTGZ)
AUTOMAKETGZ := automake-1.18.1.tar.gz
AUTOMAKETGZURL := https://ftp.gnu.org/gnu/automake/$(AUTOMAKETGZ)
LIBTOOLTGZ := 2.5.4-os2-r2.tar.gz
LIBTOOLTGZURL := https://github.com/komh/libtool-os2/archive/refs/tags/$(LIBTOOLTGZ)
LIBTOOLDIR := $(AUTOTOOLSDIR)/libtool-os2-$(LIBTOOLTGZ:.tar.gz=)

BINUTILSDIR := binutils-os2-ps
LIBCDIR := libc
GCCDIR := gcc-os2-ps
EMXDIR := $(LIBCDIR)/src/emx
EXTRASDIR := extras
CMAKEDIR := cmake-os2
MESONCROSSFILE := meson/$(TARGETSPEC)
CMAKECROSSFILE := cmake/$(TARGETSPEC).cmake

LIBCZIP := libc-0_1_14-1_oc00.zip
LIBCZIPURL := https://rpm.netlabs.org/release/00/zip/$(LIBCZIP)
LIBCZIPDIR := libc-$(TARGETSPEC)
LIBCFENVHDIFF := patches/libc/fenv.h.diff

BUILDDIR := build

.PHONY: all
all:

.PHONY: all-autotools
all: all-autotools
all-autotools:

.PHONY: all-autotools-autoconf
all-autotools: all-autotools-autoconf
all-autotools-autoconf: $(AUTOTOOLSDIR)/autoconf.done
$(AUTOTOOLSDIR)/autoconf.done: $(AUTOTOOLSDIR)/$(AUTOCONFTGZ)
	cd $(AUTOTOOLSDIR); \
	$(TARX) $(AUTOCONFTGZ) || exit 1; \
	cd $(AUTOCONFTGZ:.tar.gz=); \
	./configure --prefix=$$(dirname $$PWD) && $(MAKE) && $(MAKE) install
	$(TOUCH) $@

$(AUTOTOOLSDIR)/$(AUTOCONFTGZ):
	$(MKDIR_P) $(AUTOTOOLSDIR)
	cd $(AUTOTOOLSDIR); $(WGET) $(AUTOCONFTGZURL)

.PHONY: all-autotools-automake
all-autotools: all-autotools-automake
all-autotools-automake: $(AUTOTOOLSDIR)/automake.done
$(AUTOTOOLSDIR)/automake.done: $(AUTOTOOLSDIR)/$(AUTOMAKETGZ)
	cd $(AUTOTOOLSDIR); \
	$(TARX) $(AUTOMAKETGZ) || exit 1; \
	cd $(AUTOMAKETGZ:.tar.gz=); \
	./configure --prefix=$$(dirname $$PWD) && $(MAKE) && $(MAKE) install
	$(TOUCH) $@

$(AUTOTOOLSDIR)/$(AUTOMAKETGZ):
	$(MKDIR_P) $(AUTOTOOLSDIR)
	cd $(AUTOTOOLSDIR); $(WGET) $(AUTOMAKETGZURL)

.PHONY: all-autotools-libtool
all-autotools: all-autotools-libtool
all-autotools-libtool: $(AUTOTOOLSDIR)/libtool.done
$(AUTOTOOLSDIR)/libtool.done: $(AUTOTOOLSDIR)/$(LIBTOOLTGZ)
	test -f $(LIBTOOLDIR)/configure \
	  || ( cd $(AUTOTOOLSDIR); $(TARX) $(LIBTOOLTGZ); ) \
	  || exit 1;
	$(MKDIR_P) $(LIBTOOLDIR)/$(BUILDDIR)
	cd $(LIBTOOLDIR)/$(BUILDDIR); \
	../configure --prefix=$$(dirname $$(realpath ..)) \
	  && $(MAKE) && $(MAKE) install
	$(TOUCH) $@

$(AUTOTOOLSDIR)/$(LIBTOOLTGZ):
	$(MKDIR_P) $(AUTOTOOLSDIR)
	cd $(AUTOTOOLSDIR); $(WGET) $(LIBTOOLTGZURL)

.PHONY: all-binutils
all: all-binutils
all-binutils: all-autotools
	$(MKDIR_P) $(BINUTILSDIR)/$(BUILDDIR)
	export PATH=$$PWD/$(AUTOTOOLSDIR)/bin:$$PATH; \
    cd $(BINUTILSDIR)/$(BUILDDIR); \
	test "$(FORCE_CONFIGURE)" = "" -a -f config.status || \
	  PREFIXROOT=$(PREFIXROOT) ../conf-cross-os2emx || exit 1; \
	$(MAKE)

.PHONY: all-libc
all: all-libc
all-libc: $(LIBCZIPDIR)/libc.done
$(LIBCZIPDIR)/libc.done: $(LIBCZIPDIR)/$(LIBCZIP)
	$(UNZIP) $(LIBCZIPDIR)/$(LIBCZIP) -d $(LIBCZIPDIR)
	fenvhdiff=$$(realpath $(LIBCFENVHDIFF)); \
	cd $(LIBCZIPDIR); $(PATCH) --binary -p0 -N < $$fenvhdiff
	$(TOUCH) $@

$(LIBCZIPDIR)/$(LIBCZIP):
	$(MKDIR_P) $(LIBCZIPDIR)
	cd $(LIBCZIPDIR); $(WGET) $(LIBCZIPURL)

.PHONY: all-emxtools
all: all-emxtools
all-emxtools: all-binutils
	$(MAKE) -C $(EMXDIR) -f Makefile.cross

.PHONY: all-gcc
all: all-gcc
all-gcc: all-autotools install-binutils install-libc install-emxtools \
         install-extras
	$(MKDIR_P) $(GCCDIR)/$(BUILDDIR)
	export PATH=$$PWD/$(AUTOTOOLSDIR)/bin:$$PATH; \
	cd $(GCCDIR); \
	contrib/download_prerequisites || exit 1; \
	cd $(BUILDDIR); \
	test "$(FORCE_CONFIGURE)" = "" -a -f config.status || \
	  PREFIXROOT=$(PREFIXROOT) ../conf-cross-os2emx || exit 1; \
	export PATH=$(DESTDIR)$(BINDIR):$$PATH; \
	$(MAKE) all-gcc all-target-libgcc all-target-libstdc++-v3 all-target-libssp

.PHONY: all-meson
all: all-meson
all-meson: $(MESONCROSSFILE)-aout.txt $(MESONCROSSFILE)-omf.txt

$(MESONCROSSFILE)-aout.txt: $(MESONCROSSFILE)-aout.txt.in
	$(SED) -e 's,@PREFIX@,$(PREFIX),g' -e 's,@TARGETSPEC@,$(TARGETSPEC),g' \
	       -e 's,@TARGETCPU@,$(TARGETCPU),g' < $< > $@

$(MESONCROSSFILE)-omf.txt: $(MESONCROSSFILE)-omf.txt.in
	$(SED) -e 's,@PREFIX@,$(PREFIX),g' -e 's,@TARGETSPEC@,$(TARGETSPEC),g' \
	       -e 's,@TARGETCPU@,$(TARGETCPU),g' < $< > $@

.PHONY: all-cmake
all: all-cmake
all-cmake: $(CMAKECROSSFILE)
	$(MKDIR_P) $(CMAKEDIR)/$(BUILDDIR)
	cd $(CMAKEDIR)/$(BUILDDIR); \
	test -f Makefile || \
	  ../configure --prefix=$(PREFIX) || exit 1;
	export PATH=$(DESTDIR)$(BINDIR):$(PATH); \
	$(MAKE) -C $(CMAKEDIR)/$(BUILDDIR)

$(CMAKECROSSFILE): $(CMAKECROSSFILE).in
	$(SED) -e 's,@PREFIX@,$(PREFIX),g' -e 's,@TARGETSPEC@,$(TARGETSPEC),g' \
	       -e 's,@TARGETCPU@,$(TARGETCPU),g' < $< > $@

.PHONY: all-libtool
all: all-libtool
all-libtool: $(AUTOTOOLSDIR)/all-libtool.done
$(AUTOTOOLSDIR)/all-libtool.done: $(AUTOTOOLSDIR)/$(LIBTOOLTGZ)
	test -f $(LIBTOOLDIR)/configure \
	  || ( cd $(AUTOTOOLSDIR); $(TARX) $(LIBTOOLTGZ); ) \
	  || exit 1;
	$(MKDIR_P) $(LIBTOOLDIR)/$(BUILDDIR).all-libtool
	cd $(LIBTOOLDIR)/$(BUILDDIR).all-libtool; \
	../configure --prefix=$(PREFIX) --disable-ltdl-install \
	  && $(MAKE)
	$(TOUCH) $@

.PHONY: install
install:

.PHONY: install-binutils
install: install-binutils
install-binutils: all-binutils
	$(MAKE) -C $(BINUTILSDIR)/$(BUILDDIR) install DESTDIR=$(DESTDIR)

.PHONY: install-libc
install: install-libc
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

.PHONY: install-emxtools
install: install-emxtools
install-emxtools: all-emxtools
	$(MAKE) -C $(EMXDIR) -f Makefile.cross install \
	  DESTDIR=$(DESTDIR) PREFIXROOT=$(PREFIXROOT)

.PHONY: install-extras
install: install-extras
install-extras:
	if test "$(shell uname -s)" = "Darwin" ; then \
		tar xvfz extras_macos.tar.gz; \
		cp /usr/bin/nm $(EXTRASDIR); \
	fi
	$(INSTALL) -d $(DESTDIR)$(TARGETBINDIR)
	$(INSTALL) -d $(DESTDIR)$(BINDIR)
	for f in $(EXTRASDIR)/* ; do \
	  n=$$(basename $$f); \
	  if test -L $$f ; then \
	    $(CP) -a $$f $(DESTDIR)$(TARGETBINDIR)/$$n; \
	  else \
	    $(INSTALL) $$f $(DESTDIR)$(TARGETBINDIR)/$$n; \
	  fi; \
	  if test "$$n" != "ldstub.bin" ; then \
	    $(LN_S) -f ../$(TARGETSPEC)/bin/$$n $(DESTDIR)$(BINDIR); \
	    $(LN_S) -f ../$(TARGETSPEC)/bin/$$n \
	               $(DESTDIR)$(BINDIR)/$(TARGETSPEC)-$$n; \
	  fi; \
	done

.PHONY: install-gcc
install: install-gcc
install-gcc: all-gcc
	$(MAKE) -C $(GCCDIR)/$(BUILDDIR) DESTDIR=$(DESTDIR) \
	           install-gcc install-target-libgcc install-target-libstdc++-v3 \
	           install-target-libssp

.PHONY: install-meson
install: install-meson
install-meson: all-meson
	$(INSTALLDATA) -D $(MESONCROSSFILE)-aout.txt \
	  $(DESTDIR)$(SHAREDIR)/meson/cross/$(notdir $(MESONCROSSFILE)-aout.txt)
	$(INSTALLDATA) -D $(MESONCROSSFILE)-omf.txt \
	  $(DESTDIR)$(SHAREDIR)/meson/cross/$(notdir $(MESONCROSSFILE)-omf.txt)

.PHONY: install-cmake
install: install-cmake
install-cmake: all-cmake
	$(INSTALLDATA) -D $(CMAKECROSSFILE) \
	  $(DESTDIR)$(SHAREDIR)/cmake/cross/$(notdir $(CMAKECROSSFILE))
	$(MAKE) -C $(CMAKEDIR)/$(BUILDDIR) install DESTDIR=$(DESTDIR)

.PHONY: install-libtool
install: install-libtool
install-libtool: all-libtool
	$(MAKE) -C $(LIBTOOLDIR)/$(BUILDDIR).all-libtool install DESTDIR=$(DESTDIR)

.PHONY: test
test: install
	$(MAKE) -C tests

.PHONY: dist
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
	  test -z "$$prefixroot" || \
	    $(MV) $$destdir$$prefixroot$$prefixfirst $$destdir$$prefixfirst; \
	} && \
	$(SED) -e "s/@VER@/$(VERSION)/g" $(PACKAGE).txt \
	  > $$destdir/$(PACKAGE)-$(VERSION).txt && \
	$(CP) README.md $$destdir && \
	{ test -z "$$prefixrootfirst" || $(RM) -r $$destdir$$prefixrootfirst; }; \
	$(RM) $(TARBALL); \
	$(TARC) $(TARBALL) $(PACKAGE)-$(VERSION); \
	$(RM) -r $(PACKAGE)-$(VERSION)

.PHONY: clean
clean:
	$(RM) $(TARBALL)

.PHONY: clean-autotools
clean: clean-autotools
clean-autotools:
	$(RM) -r $(AUTOTOOLSDIR)

.PHONY: clean-binutils
clean: clean-binutils
clean-binutils:
	$(RM) -r $(BINUTILSDIR)/$(BUILDDIR)

.PHONY: clean-libc
clean: clean-libc
clean-libc:
	$(RM) -r $(LIBCZIPDIR)

.PHONY: clean-emxtools
clean: clean-emxtools
clean-emxtools:
	$(MAKE) -C $(EMXDIR) -f Makefile.cross clean

.PHONY: clean-gcc
clean: clean-gcc
clean-gcc:
	$(RM) -r $(GCCDIR)/$(BUILDDIR)

.PHONY: clean-meson
clean: clean-meson
clean-meson:
	$(RM) $(MESONCROSSFILE)-aout.txt $(MESONCROSSFILE)-omf.txt

.PHONY: clean-cmake
clean: clean-cmake
clean-cmake:
	$(RM) $(CMAKECROSSFILE)
	$(RM) -r $(CMAKEDIR)/$(BUILDDIR)

.PHONY: clean-libtool
clean: clean-libtool
clean-libtool:
	$(RM) -r $(LIBTOOLDIR)/build.all-libtool
	$(RM) $(AUTOTOOLSDIR)/all-libtool.done

.PHONY: clean-test
clean: clean-test
clean-test:
	$(MAKE) -C tests clean
