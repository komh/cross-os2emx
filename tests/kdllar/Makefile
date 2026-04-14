.NOTPARALLEL:

.SUFFIXES:
.SUFFIXES: .c .o .obj .a .lib .sym .dll .exe .def .imp

TARGET := i686-pc-os2-emx

CC := $(TARGET)-gcc
CFLAGS :=

CXX := $(TARGET)-g++
CXXFLAGS :=

LDFLAGS :=

AR := $(TARGET)-ar
ARFLAGS := crv

KDLLAR := kdllar -cc $(CC) -noecho
KLD := kld -cc $(CC) -noecho

EMXIMP := emximp

MV := mv
RM := rm -f
CMP := diff -i
SED := sed
SORT := sort
GREP := grep
MKDIR_P := mkdir -p

OUTDIR := .

DLLPATH := ././././././././././
DLLNAMESHORT := dll_long
DLLNAMELONG := $(DLLPATH)$(DLLNAMESHORT)_name

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<

%.imp: %.dll
	$(MKDIR_P) $(dir $@)
	$(EMXIMP) -o $@ $<
	$(SED) /^\;/d $@ | $(SORT) > $@.sort
	$(MV) $@.sort $@
	$(CMP) $@ $(notdir $@).ref

.PHONY: all

all: test-kdllar test-kld

.PHONY: test-kdllar

test-kdllar: OUTDIR=kdllar
test-kdllar:
	$(MKDIR_P) $(OUTDIR)
	$(MAKE) dllexp_imp OUTDIR=$(OUTDIR)
	$(MAKE) dllsym_imp OUTDIR=$(OUTDIR)
	$(MAKE) $(notdir $(DLLNAMELONG))_imp OUTDIR=$(OUTDIR)

.PHONY: dllexp_imp

dllexp_imp: $(OUTDIR)/dllexp.imp

$(OUTDIR)/dllexp.dll: dll1.o dll2.a dll3.a
	$(KDLLAR) -noexport -o $@ dll1.o dll2.a dll3.a

.PHONY: dllsym_imp

dllsym_imp: $(OUTDIR)/dllsym.imp

$(OUTDIR)/dllsym.dll: dll2.a dll3.a dll.sym
	$(KDLLAR) -symprefix -symfile dll.sym -o $@ dll2.a dll3.a

.PHONY: $(notdir $(DLLNAMELONG))_imp

$(notdir $(DLLNAMELONG))_imp: $(OUTDIR)/$(DLLNAMELONG).imp

$(OUTDIR)/$(DLLNAMELONG).imp: $(OUTDIR)/$(DLLNAMESHORT).dll
	$(EMXIMP) -o $@ $<
	$(SED) /^\;/d $@ | $(SORT) > $@.sort
	$(MV) $@.sort $@
	$(CMP) $@ $(notdir $@).ref

$(OUTDIR)/$(DLLNAMESHORT).dll: dll2.a dll3.a
	$(KDLLAR) -o $@ dll1.o dll2.a dll3.a

dll2.a: dll2.o
	$(AR) $(ARFLAGS) $@ $<

dll3.a: dll3.o
	$(AR) $(ARFLAGS) $@ $<

.PHONY: test-kld

test-kld: test-kld-aout test-kld-omf

.PHONY: test-kld-aout

test-kld-aout: test-kld-aout-dll test-kld-aout-exe

.PHONY: test-kld-aout-dll

test-kld-aout-dll: OUTDIR=kld-aout-dll
test-kld-aout-dll:
	$(MKDIR_P) $(OUTDIR)
	$(MAKE) KDLLAR="$(KLD) -Zdll" dllexp_imp OUTDIR=$(OUTDIR) \
	  || echo "Expected failure of dllexp.imp! __declspec(dllexport) is not supported by ld."
	$(MAKE) KDLLAR="$(KLD) -Zdll" dllsym_imp OUTDIR=$(OUTDIR)
	$(MAKE) KDLLAR="$(KLD) -Zdll" $(notdir $(DLLNAMELONG))_imp OUTDIR=$(OUTDIR)

.PHONY: test-kld-aout-exe

test-kld-aout-exe: OUTDIR=kld-aout-exe
test-kld-aout-exe:
	$(MKDIR_P) $(OUTDIR)
	$(MAKE) exe-aout_exe OUTDIR=$(OUTDIR)

.PHONY: exe-aout_exe

exe-aout_exe: $(OUTDIR)/exe-aout.exe

EXE_AOUT_STR := This is emx-aout.exe
$(OUTDIR)/exe-aout.exe: exe.o
	$(KLD) -app WINDOWCOMPAT -d "$(EXE_AOUT_STR)" -o $@ $<
	$(GREP) "NAME $(notdir $(@:.exe=)) WINDOWCOMPAT" $(@:.exe=.def)
	$(GREP) "$(EXE_AOUT_STR)" $@

.PHONY: test-kld-omf

test-kld-omf: test-kld-omf-dll test-kld-omf-exe

.PHONY: test-kld-omf-dll

test-kld-omf-dll: OUTDIR=kld-omf-dll
test-kld-omf-dll:
	$(MKDIR_P) $(OUTDIR)
	$(MAKE) KDLLAR="$(KLD) -Zomf -Zdll" dllexp_imp OUTDIR=$(OUTDIR)
	$(MAKE) KDLLAR="$(KLD) -Zomf -Zdll" dllsym_imp OUTDIR=$(OUTDIR)
	$(MAKE) KDLLAR="$(KLD) -Zomf -Zdll" $(notdir $(DLLNAMELONG))_imp OUTDIR=$(OUTDIR)

.PHONY: test-kld-omf-exe

test-kld-omf-exe: OUTDIR=kld-omf-exe
test-kld-omf-exe:
	$(MKDIR_P) $(OUTDIR)
	$(MAKE) exe-omf_exe OUTDIR=$(OUTDIR)

.PHONY: exe-omf_exe

exe-omf_exe: $(OUTDIR)/exe-omf.exe

EXE_OMF_STR := This is emx-omf.exe
$(OUTDIR)/exe-omf.exe: exe.o
	$(KLD) -app WINDOWCOMPAT -d "$(EXE_OMF_STR)" -Zomf -o $@ $<
	$(GREP) "NAME $(notdir $(@:.exe=)) WINDOWCOMPAT" $(@:.exe=.def)
	$(GREP) "$(EXE_OMF_STR)" $@

.PHONY: clean

clean:
	$(RM) -r kdllar
	$(RM) -r kld-aout-dll
	$(RM) -r kld-aout-exe
	$(RM) -r kld-omf-dll
	$(RM) -r kld-omf-exe
	$(RM) *.o *.a *.def *.exe
