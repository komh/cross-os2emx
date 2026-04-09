.PHONY: all test clean

PREFIXROOT := $(HOME)
PREFIX := $(PREFIXROOT)/opt/os2emx
TARGET := i686-pc-os2-emx

REPODIR := liba52-os2.git

all: test

test:
	set -e; \
	if test ! -d "$(REPODIR)/.git" ; then \
	  git clone --depth 1 -b 0.7.4-os2 https://github.com/komh/$(REPODIR) $(REPODIR); \
      ( cd "$(REPODIR)"; autoreconf -fi -I "$(PREFIX)/share/aclocal"; ) \
	fi; \
	cd $(REPODIR); \
	chmod a+x configure; \
	test -d build || mkdir build; \
    cd build; \
    test -f config.status \
      || ../configure --host=$(TARGET) --enable-shared --enable-static \
                      CFLAGS="-O2 -std=c99"; \
	$(MAKE); \
	test -f "liba52/.libs/a520.dll"

clean:
	rm -rf $(REPODIR)
