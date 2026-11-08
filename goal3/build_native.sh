#!/bin/bash
# Native (Linux, WSL) builds of the stock fceumm and ours, and the test front end (harness/run.c):
# to compare the two cores frame by frame. bash build_native.sh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"
for pair in "fceumm-stock native-stock" "libretro-fceumm native-ours"; do
  set -- $pair
  rm -rf "$2"
  mkdir -p "$2"
  (cd "$1" && tar cf - --exclude=.git --exclude='*.o' --exclude='*.bc' --exclude='*.so' .) | (cd "$2" && tar xf -)
  (cd "$2" && make -f Makefile.libretro -j"$(nproc)" > "$HERE/$2.log" 2>&1)
  ls -la "$2/fceumm_libretro.so"
done
gcc -O2 -I libretro-fceumm/src/drivers/libretro/libretro-common/include -o harness/run harness/run.c -ldl 2> /dev/null
ls -la harness/run
