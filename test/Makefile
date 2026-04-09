.SUFFIXES: .c .cpp .h .o .obj .exe .map

PREFIXROOT := $(HOME)
PREFIX := $(PREFIXROOT)/opt/os2emx
TARGET := i686-pc-os2-emx
TARGETINCDIR := $(PREFIX)/$(TARGET)/include

export PATH := $(PREFIX)/bin:$(PATH)

CC := $(TARGET)-gcc
CXX := $(TARGET)-g++
CFLAGS := -g
CXXFLAGS := -g

LD := $(CXX)
LDFLAGS :=

RM := rm -f

# Do not remove temporary files
.SECONDARY:

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.obj: %.c
	$(CC) $(CFLAGS) -Zomf -c -o $@ $<

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

%.obj: %.cpp
	$(CXX) $(CXXFLAGS) -Zomf -c -o $@ $<

%-aout.exe: %.o
	$(LD) $(LDFLAGS) -Zmap -o $@ $<

%-omf.exe: %.obj
	$(LD) $(LDFLAGS) -Zomf -Zmap -o $@ $<

.PHONY: all test test-gcc test-g++ test-dll test-pm test-autotools test-meson \
        test-cmake

all: test

test: test-gcc test-g++ test-dll test-pm test-autotools test-meson test-cmake

test-gcc: hello-aout.exe hello-omf.exe

test-g++: xcpt-aout.exe xcpt-omf.exe fenv-aout.exe fenv-omf.exe

test-dll:
	$(MAKE) -C dll PREFIXROOT=$(PREFIXROOT) PREFIX=$(PREFIX) TARGET=$(TARGET)

test-pm:
	$(MAKE) -C pm PREFIXROOT=$(PREFIXROOT) PREFIX=$(PREFIX) TARGET=$(TARGET)

test-autotools:
	$(MAKE) -C autotools PREFIXROOT=$(PREFIXROOT) PREFIX=$(PREFIX) TARGET=$(TARGET)

test-meson:
	$(MAKE) -C meson PREFIXROOT=$(PREFIXROOT) PREFIX=$(PREFIX) TARGET=$(TARGET)

test-cmake:
	if test ! -f $(TARGETINCDIR)/pthread.h \
	   || test ! -f $(TARGETINCDIR)/os2tk45/os2.h ; then \
	  ./installlib.sh; \
	fi
	$(MAKE) -C cmake PREFIXROOT=$(PREFIXROOT) PREFIX=$(PREFIX) TARGET=$(TARGET)

clean: clean-gcc clean-g++ clean-dll clean-pm clean-autotools clean-meson \
       clean-cmake

clean-gcc:
	$(RM) *.o *.obj *.exe *.map

clean-g++:
	$(RM) *.o *.obj *.exe *.map

clean-dll:
	$(MAKE) -C dll clean PREFIXROOT=$(PREFIXROOT) PREFIX=$(PREFIX) TARGET=$(TARGET)

clean-pm:
	$(MAKE) -C pm clean PREFIXROOT=$(PREFIXROOT) PREFIX=$(PREFIX) TARGET=$(TARGET)

clean-autotools:
	-$(MAKE) -C autotools clean PREFIXROOT=$(PREFIXROOT) PREFIX=$(PREFIX) TARGET=$(TARGET)

clean-meson:
	-$(MAKE) -C meson clean PREFIXROOT=$(PREFIXROOT) PREFIX=$(PREFIX) TARGET=$(TARGET)

clean-cmake:
	-$(MAKE) -C cmake clean PREFIXROOT=$(PREFIXROOT) PREFIX=$(PREFIX) TARGET=$(TARGET)
