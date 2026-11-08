#!/bin/bash
# Our core again after a change: both web flavours and the native one (WSL). bash rebuild_ours.sh
set -e
cd "$(dirname "$0")"
bash build_core.sh libretro-fceumm legacy out-ours-legacy | tail -2
bash build_core.sh libretro-fceumm normal out-ours-normal | tail -2
rm -rf native-ours && mkdir native-ours
(cd libretro-fceumm && tar cf - --exclude=.git --exclude='*.o' --exclude='*.bc' --exclude='*.so' .) | (cd native-ours && tar xf -)
(cd native-ours && make -f Makefile.libretro -j"$(nproc)" > ../native-ours.log 2>&1)
cmp native-ours/src/ppu.c libretro-fceumm/src/ppu.c && ls -la native-ours/fceumm_libretro.so
