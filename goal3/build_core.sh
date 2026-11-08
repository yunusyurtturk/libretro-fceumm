#!/bin/bash
# Build EmulatorJS's fceumm core the way EmulatorJS's build (github.com/EmulatorJS/build, build.sh +
# RetroArch/emulatorjs/build-emulatorjs.sh) does for version 2.0.3 / EmulatorJS 4.2.3 (the cores in
# web/emulatorjs/data/cores, built 2026-05-17): EmulatorJS/RetroArch 5a21e08, EmulatorJS/libretro-fceumm
# e1630de, emsdk 5.0.0 (of the releases the closest to the shipped core: its JS differs in 5 small
# places, poll and an exit wrapper; 3.1.74, 5.0.1, 5.0.2 and 5.0.7 differ more). Run in WSL:
#   bash build_core.sh SRC FLAVOUR OUT
#   SRC     the fceumm source tree (libretro-fceumm: ours; fceumm-stock: the original)
#   FLAVOUR normal | legacy   (no threads: the pages don't use them)
#   OUT     a folder for fceumm_libretro.js / .wasm (packed on Windows with 7-Zip: pack_core.sh)
set -e
SRC="$1"; FLAVOUR="$2"; OUT="$3"
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/emsdk/emsdk_env.sh" > /dev/null
LEGACY_ARG=""; GLES3=1
if [ "$FLAVOUR" = "legacy" ]; then LEGACY_ARG="EMULATORJS_LEGACY=1"; GLES3=0; fi

# 1. the core as LLVM bitcode
cd "$HERE/$SRC"
rm -f *.bc
emmake make -f Makefile.libretro clean > /dev/null
emmake make -j"$(nproc)" -f Makefile.libretro platform=emscripten $LEGACY_ARG > "$HERE/build_${SRC}_${FLAVOUR}_core.log" 2>&1
BC=( *.bc )

# 2. linked with the RetroArch web front end (build-emulatorjs.sh's make, its defaults for fceumm)
cd "$HERE/RetroArch"
if [ -f ".last_flavour" ] && [ "$(cat .last_flavour)" != "$FLAVOUR" ]; then
  emmake make -f Makefile.emulatorjs clean > /dev/null
fi
echo "$FLAVOUR" > .last_flavour
cp -f "$HERE/$SRC/$BC" libretro_emscripten.a
emmake make -f Makefile.emulatorjs HAVE_7ZIP=1 HAVE_CHD=1 HAVE_THREADS=0 PTHREAD_POOL_SIZE=0 ASYNC=0 \
  HAVE_OPENGLES3=$GLES3 STACK_SIZE=4194304 INITIAL_HEAP=134217728 HAVE_AL=0 HAVE_RWEBAUDIO=1 LIGHT_DEBUG=0 \
  TARGET=fceumm_libretro.js -j"$(nproc)" > "$HERE/build_${SRC}_${FLAVOUR}_retroarch.log" 2>&1
mkdir -p "$HERE/$OUT"
mv -f fceumm_libretro.wasm fceumm_libretro.js "$HERE/$OUT/"
ls -la "$HERE/$OUT"
