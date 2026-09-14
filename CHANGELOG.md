# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [SemVer](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-09-14

Initial release.

### Added
- Direct call into the game's GM executor via
  `/Script/b1-Managed.Default__BGUFunctionLibraryManaged:RunScriptGM`,
  with `RunGMCommand` and `ConsoleCommandCS` as fallbacks.
- `commands.txt` — one command per line, re-read on every keypress, with
  `#` comment support.
- Keybinds: run commands, diagnostics, unlock-all preset. Rebindable via
  `config.txt`.
- `wukonggm <command>` console command for builds where UE4SS hooks the
  in-game console.
- Guard on destructive commands (`clearrolebag` and friends), off by default.
- BOM and control-character stripping on command input.
- Item ID reference with Will (`1002`) verified.
- Full GM command reference in `docs/commands.md`.

### Notes
- Requires only RE-UE4SS. No CSharpLoader, ReShade or console mod.
- Everything resolves by name at runtime, so no per-patch offset updates.

## [1.0.1] — 2026-09-14

### Changed
- Overlay (ModMenu) and the file watcher now ship **disabled by default**.
  Both build without error but do not function on the game build tested:
  the overlay's widget tree exists and reports open yet never renders, and
  `ExecuteInGameThreadWithDelay` never fires the watcher's callback.
  Keybinds remain the supported path and are unaffected.

### Added
- `compat.lua` — adds `UEHelpers.GetGameInstance` at runtime when the
  installed UEHelpers is v2. Patches the loaded module rather than replacing
  the file, so other mods are untouched.
- `tools/console.ps1` — external command console for the watcher (experimental).
- `THIRD-PARTY.md`.

### Fixed
- Overlay root-widget lookup matched on the full object path, which matched
  descendants instead of the shell. Now matches the object's own name.

## [1.1.0] — 2026-09-14

### Added
- Item ID database: 74 ids across 9 categories (currency, formulas, wine,
  medicine, soak ingredients, herbs, curios, crafting materials, seeds), with
  category grouping and lookup helpers in `items.lua`.
- `commands.txt` now ships every known id as a commented line — uncomment and
  press F7 rather than hunting for numbers.
- Full id table in `docs/commands.md`.
- `F4` dumps the game's equipment ids via `GetAllEquipId()` to
  `equip_ids.txt`, for mapping the equipment range.

### Notes
- Only `1002` (Will) is verified by this project. The rest are community
  reported and marked accordingly; ids are facts about the game, not anyone's
  authorship.

## [1.1.1] — 2026-09-14

### Fixed
- Log messages were being truncated at the first non-ASCII character. UE4SS's
  logger stops at that byte, so `WukongGM v1.1.0 loaded — 74 known item id(s)`
  printed as `WukongGM v1.1.0 loaded ` and the next log entry ran onto the same
  line. Em dashes and smart quotes in Lua strings are now plain ASCII.

### Added
- `package.ps1` fails the build on any non-ASCII character in shipped `.lua` or
  `.txt` files, alongside the existing BOM check. Both are silent-failure bugs
  that look fine in an editor.

## [1.2.0] — 2026-09-14

### Added
- `items.txt` — pick items by **name** instead of id. Every known item is
  listed with a quantity; set a number, save, press F7. Names match ignoring
  case and spacing, and unrecognised names are reported so typos are visible.
- `wishlist.lua` resolves names to ids against the item database.

### Changed
- F7 now runs `items.txt` first, then `commands.txt`.
- `commands.txt` ships with **no active lines**. It previously shipped with a
  live `additem 1002 100000`, which ran on every press whether you wanted it
  or not. A default config should do nothing until asked.
- The file watcher is disabled and parked. `RegisterHook` works on this build,
  but hooking a name the game lacks raises an error `pcall` cannot contain,
  which tears down the whole script and takes the keybinds with it. `Start`
  now verifies a UFunction exists before registering, but the feature is not
  needed: editing a file and pressing a key already covers it.
