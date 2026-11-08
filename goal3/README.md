# Goal 3 Online's FCEUmm: a second sprite table

This branch is [EmulatorJS/libretro-fceumm](https://github.com/EmulatorJS/libretro-fceumm) at
`e1630de` (the FCEUmm core of EmulatorJS 4.2.3) with one change, in `src/ppu.c`: a **second table of up
to 128 sprites**, drawn behind the NES's 64. [Goal 3 Online](https://ct2online.com/goal3/) runs it in the
browser through EmulatorJS (its `fceumm-wasm.data` and `fceumm-legacy-wasm.data`): its 11 v 11 mode draws
more sprites than the NES's 64 slots hold. This is that core's source, as the GPL asks.

The change alone: [`fceumm-spram2.patch`](fceumm-spram2.patch) (the same as this branch's commit).

## How a ROM uses it

| Register | | |
|---|---|---|
| `$401C` | read | `$58` with this core. Other emulators and a real NES give open bus (`$40`), so a ROM can tell. |
| `$401E` | write | A picture begins. The waiting table is emptied, and OAM DMAs (`$4014`) keep the last whole picture until this one is ready. |
| `$401D` | write | Copies a CPU page into the waiting table, in front of a page sent before (the table holds two: the picture's first 64 sprites, then its next 64). |
| `$401F` | write | The picture is ready. The next OAM DMA takes the page as usual, and the waiting table becomes the second table. |

- The second table is drawn after the 64 of OAM, so behind them.
- With "no sprite limit" on, up to 192 sprites can share a line. With the limit on, there are 8 in all.
- Sprite 0 hit and the overflow flag come from OAM only.
- A reset empties the table. Save states don't include it: they stay exactly the stock core's, the same
  size, so states made with either core load in the other. A loaded state starts with the table empty.
- Nothing else uses `$401C-$401F`, so a ROM that doesn't use them runs exactly as on the stock core.

## How it was built

- EmulatorJS/RetroArch `5a21e08a5de7649cfa6416d6843c0c40de27714e`, unchanged
  ([github.com/EmulatorJS/RetroArch](https://github.com/EmulatorJS/RetroArch)), the web front end the
  core is linked with.
- This branch's tree (EmulatorJS/libretro-fceumm `e1630de02074801eb96f3bc4ff33f69df9554c69` + the patch).
- emsdk 5.0.0.

The scripts here are the ones used, as they sit in the Goal 3 project (its `core/` folder, a build tree in
its `tools/corebuild`):

| Script | |
|---|---|
| `setup.sh` | (Linux / WSL) Clones RetroArch and libretro-fceumm at those commits, applies the patch, a stock tree beside it, emsdk 5.0.0. |
| `build_core.sh SRC normal\|legacy OUT` | The core as EmulatorJS's own build makes it: the fceumm bitcode, then linked with RetroArch's `Makefile.emulatorjs` (no threads). |
| `pack_core.sh` | (Windows, 7-Zip) The `.data` packs: 7z, LZMA2, with the shipped packs' `build.json`, `core.json`, `license.txt`. |
| `build_native.sh`, `rebuild_ours.sh` | Native builds of the stock and changed cores, for comparing them frame by frame in tests. |

## License

GNU General Public License, version 2 or (at your option) any later version, as FCEUmm (`Copying` at the
top of this repository). RetroArch, linked into the web core, is GPL version 3.
