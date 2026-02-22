# Cross-os2emx

This is a cross compilation toolchain for i686-pc-os2-emx target.

This consists of binutils, gcc and LIBCn.

* binutils is v2.33 from https://github.com/bitwiseworks/binutils-os2.
* gcc is v9.2.0 from https://github.com/bitwiseworks/gcc-os2.
* LIBCn is v0.1.14 from https://github.com/bitwiseworks/libc.

Tested hosts:
* x86_64-unknown-linux-gnu

# History

* os2emx-cross-toolchain-b1 (20206/02/23)
    * Released at github

* os2emx-cross-toolchain-test2 (2026/02/19)
    * Added emxomf, emxomfar, emxomfld, emxomfstrip, listomf and stripomf
        * emxomfld supports only WLINK
    * Added -Zomf option with watcom tools such as wlink and wrc
    * Fixed symbolic link problems

* os2emx-cross-toolchain-test1 (2026/02/15)
    * Added binutils 2.33.1
    * Added emxexp, emximp, emxbind and OS/2 ld
    * Added gcc v9.2.0
        * Always link to libgcc.a

# How to build

1. Clone the sources from github:
    `git clone https://github.com/komh/cross-os2emx.git`

2. Bootstrap:
    `./bootstrap`

3. Build:
    `make`

4. Install:
    `make install`

    This will installs the built files into `$HOME/opt/os2emx`.

* **NOTE**: `autoconf v2.69` is required by binutils and gcc.
* **NOTE 2**: `wget` and `unzip` is required to download and to extract LIBCn binaries.
* **NOTE 3**: Unless you set `PREFIXROOT`, `PREFIXROOT` is set to `$HOME` by default. If you want to set PREFIXROOT to other directory than **$HOME**. then you should set **PREFIXROOT** to the same value **WHENEVER** calling **make**. For example,

```
    make PREFIXROOT=/
    make install PREFIXROOT=/
```
This will installs into `$PREFIXROOT/opt/os2emx`.

# Known problems

* Some .so files are missing in pre-built binaries such as libiconv.so.2 and libmpfr.so.4 and so on. For this, see https://github.com/komh/cross-os2emx/issues/2.
* Additional data sections such as `___eh_frame___` are embedded into an object file. As a result, conversion from OMF objects to a.out objects with `emxaout` fails. However, there are any practical problems, yet.
* Shared libgcc and libstdc++-v3 are not provided.
* `-Zsym` does not generate .sym file at all. `mapsym.cmd` should be ported.

# Donation

If you are satisfied with this program and want to donate to me, please visit
the following URL.

https://www.os2.kr/komh/os2factory/

Or, please click the Ads in the following blog.

https://lvzuufx.blogspot.com/

# Contact

Please use the issue tracker of github:

https://github.com/komh/cross-os2emx/issues

KO Myung-Hun
