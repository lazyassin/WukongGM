# Third-party components

## ModMenu

`src/shared/ModMenu/ModMenu.lua`

Authored by the maintainer of this project and licensed under the same MIT
terms as the rest of the repository. It is a generated bundle; the sources
live in a separate project.

Optional. The mod detects whether it loaded and falls back to keybind-only
operation, so a failure here never takes the mod down.

## UEHelpers — not bundled

UEHelpers is part of [RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) (MIT)
and ships with it. This project does **not** redistribute or modify it.

It is worth recording why, because the obvious fix is wrong.

ModMenu calls `UEHelpers.GetGameInstance()`, added in UEHelpers v3. The UE4SS
package commonly distributed for Black Myth: Wukong bundles **v2**, which
lacks it. Dropping v3 in looks like the fix, and it is not — v3 uses the
`CreateInvalidObject()` Lua global, which that UE4SS build does not expose:

```
UEHelpers.lua:35: attempt to call a nil value (global 'CreateInvalidObject')
```

That error fires while the file is being loaded, so it takes down every mod
that requires UEHelpers, not just this one.

Instead, `scripts/compat.lua` adds the single missing function to the loaded
module table at runtime, before ModMenu is required. Lua caches modules in
`package.loaded`, so ModMenu receives the patched table. Nothing on disk is
touched and other mods are unaffected.

If a future UE4SS ships UEHelpers v3 or later, the shim detects the function
already exists and does nothing.
