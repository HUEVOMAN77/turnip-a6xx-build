#!/usr/bin/env bash
# Empaqueta el driver compilado en el formato que entiende AdrenoTools:
# meta.json + la libreria .so
set -euo pipefail

TOOLCHAIN="${NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64"
SO="mesa/build/src/freedreno/vulkan/libvulkan_freedreno.so"

if [ ! -f "${SO}" ]; then
  echo "No se genero ${SO}" >&2
  exit 1
fi

mkdir -p dist
cp "${SO}" dist/vulkan.ad07XX.so
"${TOOLCHAIN}/bin/llvm-strip" --strip-unneeded dist/vulkan.ad07XX.so

VERSION_VULKAN="$(strings -a dist/vulkan.ad07XX.so | grep -m1 -o 'Vulkan 1\.[0-9]\+\.[0-9]\+' || true)"
if [ -z "${VERSION_VULKAN}" ]; then
  VERSION_VULKAN="Vulkan 1.3.280"
fi

cat > dist/meta.json <<EOF
{
  "schemaVersion": 1,
  "name": "Turnip a6xx para Nova 10 - Mesa ${MESA_VERSION}",
  "description": "Compilado desde el codigo de Mesa para el Adreno 642L (a6xx) del Nova 10.",
  "author": "HUEVOMAN77",
  "packageVersion": "${MESA_VERSION}",
  "vendor": "Mesa",
  "driverVersion": "${VERSION_VULKAN}",
  "minApi": 27,
  "libraryName": "vulkan.ad07XX.so"
}
EOF

ZIP="dist/Turnip-a6xx-${MESA_VERSION}.zip"
rm -f "${ZIP}"
(cd dist && zip -q "../${ZIP}" meta.json vulkan.ad07XX.so)

echo "Paquete listo: ${ZIP}"
cat dist/meta.json
ls -la dist
