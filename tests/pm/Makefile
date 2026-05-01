.SUFFIXES: .c .h .rc .o .obj .res .exe .map

PREFIXROOT := $(HOME)
PREFIX := $(PREFIXROOT)/opt/os2emx
TARGET := i686-pc-os2-emx

CC := $(TARGET)-gcc
CFLAGS := -g

LD := $(CC)
LDFLAGS :=

RC := $(TARGET)-wrc
RCFLAGS := -q -bt=os2 -r -i=$(PREFIX)/$(TARGET)/include

RM := rm -f

# Do not remove temporary files
.SECONDARY:

%.o: %.c %.h
	$(CC) $(CFLAGS) -c -o $@ $<

%.obj: %.c %.h
	$(CC) $(CFLAGS) -Zomf -c -o $@ $<

%-aout.res: %.rc
	$(RC) $(RCFLAGS) -zm -fo=$@ $<

%-omf.res: %.rc
	$(RC) $(RCFLAGS) -fo=$@ $<

%-aout.exe: %.o %-aout.res
	echo "NAME $(basename $@) WINDOWAPI" > $@.def
	$(LD) $(LDFLAGS) -Zmap -o $@ $^ $@.def

%-omf.exe: %.obj %-omf.res
	echo "NAME $(basename $@) WINDOWAPI" > $@.def
	$(LD) $(LDFLAGS) -Zomf -Zmap -Zsym -o $@ $^ $@.def

.PHONY: all test clean

all: test

test: pmtest2-aout.exe pmtest2-omf.exe

clean:
	$(RM) *.o *.obj *.res *.def *.exe *.map *.sym
