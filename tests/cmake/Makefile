.PHONY: all test test-make test-ninja clean

PREFIXROOT := $(HOME)
PREFIX := $(PREFIXROOT)/opt/os2emx
TARGET := i686-pc-os2-emx
TARGETINCDIR := $(PREFIX)/$(TARGET)/include

REPODIR := fluidsynth-os2.git

CMAKEOPTS := -DCMAKE_C_FLAGS="-idirafter $(TARGETINCDIR)/os2tk45" \
	         -DCMAKE_CXX_FLAGS="-idirafter $(TARGETINCDIR)/os2tk45" \
	         -Dosal=cpp11 \
			 -Denable-libinstpatch=0 \
			 -DCMAKE_TOOLCHAIN_FILE=$(PREFIX)/share/cmake/cross/$(TARGET).cmake

all: test

test:
	test -d "$(REPODIR)/.git" \
	  || git clone --depth 1 https://github.com/komh/$(REPODIR) $(REPODIR)
	$(MAKE) test-make
	$(MAKE) test-ninja

test-make:
	set -e; \
	cd $(REPODIR); \
	test -d build.make || mkdir build.make; \
	cd build.make; \
	test -f Makefile \
	  || cmake .. $(CMAKEOPTS) -G "Unix Makefiles"; \
    $(MAKE)

test-ninja:
	set -e; \
	cd $(REPODIR); \
	test -d build.ninja || mkdir build.ninja; \
	cd build.ninja; \
    test -f build.ninja \
	  || cmake .. $(CMAKEOPTS) -G Ninja; \
    ninja

clean:
	rm -rf $(REPODIR)
