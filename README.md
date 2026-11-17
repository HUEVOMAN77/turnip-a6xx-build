# Turnip a6xx para el Nova 10

Compila el driver grafico **Mesa Turnip** (freedreno) desde el codigo fuente para el
**Adreno 642L** del Huawei Nova 10 (NCO-LX3, chip a6xx, id `0x6030500`).

El driver se compila para `aarch64-linux-android` con el NDK de Android y se empaqueta
en el formato que usa AdrenoTools (`meta.json` + `vulkan.ad07XX.so`), que es el que
reconoce el port de Super Mario Odyssey en la opcion **Advanced -> Graphics driver ->
Install a driver package (.zip)**.

## Que se compila

- Mesa `26.2.7` (rama estable), codigo fuente oficial de `archive.mesa3d.org`.
- Solo el driver Vulkan `freedreno` (Turnip). Sin gallium, sin herramientas, sin LLVM
  (el compilador de shaders de freedreno ya no depende de LLVM desde Mesa 22).
- API de Android 31 (Android 12, que es lo que corre el Nova 10 con EMUI 13).

## Como se usa

1. Lanzar el workflow en **Actions** (o hacer `git tag vX.Y.Z` para dispararlo).
2. Al terminar, descargar el artefacto `turnip-a6xx-<version>`.
3. En el port: **Advanced -> Graphics driver -> Install a driver package (.zip)** y
   elegir el `.zip`.
4. En `graphics.ini` dejar `driver = custom` y `renderer = vulkan`.

El paquete tambien se puede instalar a mano copiando `meta.json` y
`vulkan.ad07XX.so` a:

```
/storage/emulated/0/Android/data/com.mobileodyssey.game/files/driver/
```

## Archivos

- `.github/workflows/build-turnip.yml` - el workflow de compilacion.
- `scripts/preparar.sh` - arma el `zlib.pc` del sysroot y el cross file de meson.
- `scripts/empacar.sh` - empaqueta el `.so` con su `meta.json`.
