GENCCODE_ASSEMBLY_TYPE=-a gcc
SO=so
SOBJ=so
A=a
LIBPREFIX=lib
LIB_EXT_ORDER=.78.3
COMPILE=/home/yuanchu/ohos-sdk/linux/native/llvm/bin/clang -ffunction-sections -fdata-sections -D_REENTRANT  -DU_HAVE_ELF_H=1  -DU_ALL_IMPLEMENTATION -DU_ATTRIBUTE_DEPRECATED= -target arm-linux-ohos -fPIC -D__MUSL__=1 -march=armv7-a -mfpu=neon -mfloat-abi=hard -D__OHOS__ -DNDEBUG -O3 -I/home/yuanchu/ohos-sdk/linux/native/sysroot/usr/include -std=c11 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings   -c
LIBFLAGS=-I/home/yuanchu/tdlib-harmony-builder/install/armeabi-v7a/include -DPIC -fPIC
GENLIB=/home/yuanchu/ohos-sdk/linux/native/llvm/bin/clang -target arm-linux-ohos -fPIC -D__MUSL__=1 -march=armv7-a -mfpu=neon -mfloat-abi=hard -D__OHOS__ -DNDEBUG -O3 -I/home/yuanchu/ohos-sdk/linux/native/sysroot/usr/include -std=c11 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings   -target arm-linux-ohos -lc++ -lc++abi -fuse-ld=lld -L/home/yuanchu/ohos-sdk/linux/native/sysroot/usr/lib --sysroot=/home/yuanchu/ohos-sdk/linux/native/sysroot -Wl,--gc-sections  -shared -Wl,-Bsymbolic
LDICUDTFLAGS=-nodefaultlibs -nostdlib
LD_SONAME=-Wl,-soname -Wl,
RPATH_FLAGS=
BIR_LDFLAGS=-Wl,-Bsymbolic
AR=/home/yuanchu/ohos-sdk/linux/native/llvm/bin/llvm-ar
ARFLAGS=r
RANLIB=/home/yuanchu/ohos-sdk/linux/native/llvm/bin/llvm-ranlib
INSTALL_CMD=/usr/bin/install -c
