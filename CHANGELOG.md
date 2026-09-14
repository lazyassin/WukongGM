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
