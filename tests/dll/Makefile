.SUFFIXES: .c .o .obj .a .lib .dll .exe .def .map

TARGET := i686-pc-os2-emx

CC := $(TARGET)-gcc
CFLAGS := -g

LD := $(CC)
LDFLAGS :=

EMXEXP := $(TARGET)-emxexp
EMXIMP := $(TARGET)-emximp

RM := rm -f

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.obj: %.c
	$(CC) $(CFLAGS) -DBUILD_OMF -Zomf -c -o $@ $<

.PHONY: all test clean

all: test

test: dllmain-aout.exe dllmain-omf.exe dll-aout.dll dll-omf.dll

dllmain-aout.exe: dllmain.o dllmod.a
	$(LD) $(LDFLAGS) -Zmap -o $@ $^

dllmod.a: dll-aout.dll
	$(EMXIMP) -o $@ $<

dll-aout.dll: dllmod.o dll-aout.def
	$(LD) -Zdll -o $@ $^

dll-aout.def: dllmod.o
	echo "LIBRARY $(basename $@) INITINSTANCE TERMINSTANCE" > $@
	echo "EXPORTS" >> $@
	$(EMXEXP) $^ >> $@

dllmain-omf.exe: dllmain.obj dllmod.lib
	$(LD) $(LDFLAGS) -Zomf -Zmap -o $@ $^

dllmod.lib: dll-omf.dll
	$(EMXIMP) -o $@ $<

dll-omf.dll: dllmod.obj dllmod2.obj dll-omf.def
	$(LD) -Zomf -Zdll -Zmap -o $@ $^

dll-omf.def: dllmod.obj
	echo "LIBRARY $(basename $@) INITINSTANCE TERMINSTANCE" > $@
	echo "EXPORTS" >> $@
	$(EMXEXP) $^ >> $@

clean:
	$(RM) *.o *.obj *.a *.lib *.dll *.exe *.def *.map
