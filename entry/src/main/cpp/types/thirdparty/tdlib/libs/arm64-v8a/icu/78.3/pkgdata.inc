GENCCODE_ASSEMBLY_TYPE=-a gcc
SO=so
SOBJ=so
A=a
LIBPREFIX=lib
LIB_EXT_ORDER=.78.3
COMPILE=/home/yuanchu/ohos-sdk/linux/native/llvm/bin/aarch64-unknown-linux-ohos-clang -ffunction-sections -fdata-sections -D_REENTRANT  -DU_HAVE_ELF_H=1  -DU_ALL_IMPLEMENTATION -DU_ATTRIBUTE_DEPRECATED= -target aarch64-linux-ohos -fPIC -D__MUSL__=1 -march=armv8-a+crc+crypto -mtune=cortex-a75 -D__OHOS__ -DNDEBUG -O3 -I/home/yuanchu/ohos-sdk/linux/native/sysroot/usr/include -std=c11 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings   -c
LIBFLAGS=-I/home/yuanchu/tdlib-harmony-builder/install/arm64-v8a/include -DPIC -fPIC
GENLIB=/home/yuanchu/ohos-sdk/linux/native/llvm/bin/aarch64-unknown-linux-ohos-clang -target aarch64-linux-ohos -fPIC -D__MUSL__=1 -march=armv8-a+crc+crypto -mtune=cortex-a75 -D__OHOS__ -DNDEBUG -O3 -I/home/yuanchu/ohos-sdk/linux/native/sysroot/usr/include -std=c11 -Wall -pedantic -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings   -target aarch64-linux-ohos -lc++ -lc++abi -fuse-ld=lld -L/home/yuanchu/ohos-sdk/linux/native/sysroot/usr/lib --sysroot=/home/yuanchu/ohos-sdk/linux/native/sysroot -Wl,--gc-sections  -shared -Wl,-Bsymbolic
LDICUDTFLAGS=-nodefaultlibs -nostdlib
LD_SONAME=-Wl,-soname -Wl,
RPATH_FLAGS=
BIR_LDFLAGS=-Wl,-Bsymbolic
AR=/home/yuanchu/ohos-sdk/linux/native/llvm/bin/llvm-ar
ARFLAGS=r
RANLIB=/home/yuanchu/ohos-sdk/linux/native/llvm/bin/llvm-ranlib
INSTALL_CMD=/usr/bin/install -c
