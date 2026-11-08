#!/bin/bash
# Pack our fceumm builds as EmulatorJS core packs (7z, LZMA2 solid, as the shipped ones), with the shipped
# packs' build.json / core.json / license.txt: run in Git Bash (Windows 7-Zip). bash pack_core.sh
# -> packs/fceumm-legacy-wasm.data (out-ours-legacy), packs/fceumm-wasm.data (out-ours-normal)
set -e
cd "$(dirname "$0")"
Z="/c/Program Files/7-Zip/7z.exe"
mkdir -p packs
for pair in "legacy fceumm-legacy-wasm.data" "normal fceumm-wasm.data"; do
  set -- $pair
  rm -rf "packs/$1"; mkdir -p "packs/$1"
  "$Z" e -y -o"packs/stock-$1" "../../web/emulatorjs/data/cores/$2" > /dev/null 2>&1 || true
  [ -f "stock-packs/$2" ] && "$Z" e -y -o"packs/stock-$1" "stock-packs/$2" > /dev/null
  cp "packs/stock-$1/build.json" "packs/stock-$1/core.json" "packs/stock-$1/license.txt" "packs/$1/"
  cp "out-ours-$1/fceumm_libretro.js" "out-ours-$1/fceumm_libretro.wasm" "packs/$1/"
  rm -f "packs/$2"
  (cd "packs/$1" && "$Z" a -t7z -m0=LZMA2 -mx=9 -ms=on "../$2" fceumm_libretro.js fceumm_libretro.wasm build.json core.json license.txt > /dev/null)
  ls -la "packs/$2"
done
