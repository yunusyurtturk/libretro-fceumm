#!/bin/bash
# The custom core's build tree in tools/corebuild (gitignored) from the official sources and this
# folder: EmulatorJS/RetroArch 5a21e08, EmulatorJS/libretro-fceumm e1630de (twice: ours with
# fceumm-spram2.patch, fceumm-stock as it is), emsdk 5.0.0; then the scripts and the harness.
# Run in WSL: bash core/setup.sh
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
C="$ROOT/tools/corebuild"
mkdir -p "$C"
cd "$C"
[ -d RetroArch ] || { git clone https://github.com/EmulatorJS/RetroArch.git && git -C RetroArch checkout 5a21e08a5de7649cfa6416d6843c0c40de27714e; }
[ -d libretro-fceumm ] || { git clone https://github.com/EmulatorJS/libretro-fceumm.git && git -C libretro-fceumm checkout e1630de02074801eb96f3bc4ff33f69df9554c69 && git -C libretro-fceumm apply "$ROOT/core/fceumm-spram2.patch"; }
[ -d fceumm-stock ] || git -C libretro-fceumm worktree add "$C/fceumm-stock" e1630de02074801eb96f3bc4ff33f69df9554c69
[ -d emsdk ] || { git clone https://github.com/emscripten-core/emsdk.git && ./emsdk/emsdk install 5.0.0 && ./emsdk/emsdk activate 5.0.0; }
cp "$ROOT"/core/build_core.sh "$ROOT"/core/pack_core.sh "$ROOT"/core/build_native.sh .
mkdir -p harness/tests harness/out
cp "$ROOT"/core/harness/*.c "$ROOT"/core/harness/*.sh harness/
cp "$ROOT"/core/harness/tests/*.txt harness/tests/
echo "ready: bash build_core.sh libretro-fceumm legacy out-ours-legacy (and normal), bash build_native.sh, then pack_core.sh in Git Bash"
