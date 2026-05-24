GENCCODE_ASSEMBLY_TYPE=-a gcc
SO=so
SOBJ=so
A=a
LIBPREFIX=lib
LIB_EXT_ORDER=.74.2
COMPILE=C:/Users/28483/AppData/Local/OpenHarmony/Sdk/20/native/llvm/bin/clang.exe -ffunction-sections -fdata-sections -D_REENTRANT  -DU_HAVE_ELF_H=1 -DU_HAVE_STRTOD_L=1 -DU_HAVE_XLOCALE_H=0 -DU_HAVE_STRING_VIEW=1  -DU_ATTRIBUTE_DEPRECATED= -target arm-linux-ohos -fPIC -D__MUSL__=1 -march=armv7-a -mfpu=neon -mfloat-abi=hard -D__OHOS__ -DNDEBUG -O3 -IC:/Users/28483/AppData/Local/OpenHarmony/Sdk/20/native/sysroot/usr/include -std=c11 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings   -c
LIBFLAGS=-I/E/important/tdlib-harmony-builder/install/armeabi-v7a/include -DPIC -fPIC
GENLIB=C:/Users/28483/AppData/Local/OpenHarmony/Sdk/20/native/llvm/bin/clang.exe -target arm-linux-ohos -fPIC -D__MUSL__=1 -march=armv7-a -mfpu=neon -mfloat-abi=hard -D__OHOS__ -DNDEBUG -O3 -IC:/Users/28483/AppData/Local/OpenHarmony/Sdk/20/native/sysroot/usr/include -std=c11 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings   -target arm-linux-ohos -lc++ -lc++abi -fuse-ld=lld -LC:/Users/28483/AppData/Local/OpenHarmony/Sdk/20/native/sysroot/usr/lib --sysroot=C:/Users/28483/AppData/Local/OpenHarmony/Sdk/20/native/sysroot -Wl,--gc-sections  -shared -Wl,-Bsymbolic
LDICUDTFLAGS=-nodefaultlibs -nostdlib
LD_SONAME=-Wl,-soname -Wl,
RPATH_FLAGS=
BIR_LDFLAGS=-Wl,-Bsymbolic
AR=C:/Users/28483/AppData/Local/OpenHarmony/Sdk/20/native/llvm/bin/llvm-ar
ARFLAGS=r
RANLIB=C:/Users/28483/AppData/Local/OpenHarmony/Sdk/20/native/llvm/bin/llvm-ranlib
INSTALL_CMD=/usr/bin/install -c
