#!/usr/bin/env bash
# Prepara el sysroot del NDK y el archivo cross de meson para aarch64-android.
set -euo pipefail

API="${ANDROID_API:-31}"
ARCH=aarch64-linux-android
TOOLCHAIN="${NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64"
SYSROOT="${TOOLCHAIN}/sysroot"

if [ ! -d "${SYSROOT}" ]; then
  echo "No encuentro el sysroot del NDK en ${SYSROOT}" >&2
  exit 1
fi

# El NDK no trae zlib.pc, y meson lo necesita para encontrar libz.
mkdir -p "${SYSROOT}/usr/lib/${ARCH}/pkgconfig"
cat > "${SYSROOT}/usr/lib/${ARCH}/pkgconfig/zlib.pc" <<EOF
prefix=${SYSROOT}
exec_prefix=${SYSROOT}
libdir=${SYSROOT}/usr/lib/${ARCH}/${API}
sharedlibdir=${SYSROOT}/usr/lib/${ARCH}
includedir=${SYSROOT}/usr/include

Name: zlib
Description: zlib compression library
Version: 1.2.3

Requires:
Libs: -L${SYSROOT}/usr/lib/${ARCH}/${API} -lz
Cflags: -I${SYSROOT}/usr/include
EOF

cat > android-aarch64.txt <<EOF
[binaries]
ar = '${TOOLCHAIN}/bin/llvm-ar'
c = ['${TOOLCHAIN}/bin/${ARCH}${API}-clang', '-fno-exceptions', '-fno-unwind-tables', '-fno-asynchronous-unwind-tables']
cpp = ['${TOOLCHAIN}/bin/${ARCH}${API}-clang++', '-fno-exceptions', '-fno-unwind-tables', '-fno-asynchronous-unwind-tables', '--start-no-unused-arguments', '-static-libstdc++', '--end-no-unused-arguments']
strip = '${TOOLCHAIN}/bin/llvm-strip'
pkg-config = 'pkgconf'
cmake = 'cmake'

[host_machine]
system = 'android'
cpu_family = 'aarch64'
cpu = 'armv8'
endian = 'little'

[properties]
needs_exe_wrapper = true
sys_root = '${SYSROOT}'
pkg_config_libdir = '${SYSROOT}/usr/lib/${ARCH}/pkgconfig:${SYSROOT}/usr/lib/${ARCH}/${API}/pkgconfig'
EOF

echo "Cross file listo para ${ARCH}${API}"
