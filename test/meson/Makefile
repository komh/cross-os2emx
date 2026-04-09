.PHONY: all test test-common clean

PREFIXROOT := $(HOME)
PREFIX := $(PREFIXROOT)/opt/os2emx
TARGET := i686-pc-os2-emx

MESONDIR := $(CURDIR)/meson.git
MESON := $(MESONDIR)/meson.py

REPODIR := dav1d-os2.git

all: test

test:
	test -d "$(MESONDIR)" \
	  || git clone --depth 1 -b 1.10 https://github.com/mesonbuild/meson.git $(MESONDIR)
	test -d "$(REPODIR)/.git" \
	  || git clone --depth 1 https://github.com/komh/$(REPODIR) $(REPODIR)
	$(MAKE) test-common BLDTYPE=aout OMF=false
	$(MAKE) test-common BLDTYPE=omf OMF=true

test-common:
	set -e; \
	cd $(REPODIR); \
	test -d build-$(BLDTYPE) || mkdir build-$(BLDTYPE); \
	cd build-$(BLDTYPE); \
	test -f build.ninja \
	  || $(MESON) setup .. \
	              --cross-file $(PREFIX)/share/meson/cross/$(TARGET)-$(BLDTYPE).txt \
	              --default-library=both -Dos2_emxomf=$(OMF); \
	ninja -v

clean:
	rm -rf meson.git meson
	rm -rf $(REPODIR)
