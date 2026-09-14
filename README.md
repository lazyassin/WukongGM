# WukongGM

Run Black Myth: Wukong's own GM commands from UE4SS — no in-game console, no
C# loader, no version-specific offsets.

Add Will, unlock weapons and spells, grant items, jump chapters. Anything the
game's internal GM system can do.

## Why this exists

Wukong ships a GM command system, but the usual way to reach it (a console mod
plus CSharpLoader) breaks on newer game builds — the hooks are compiled against
engine internals that move with every patch.

WukongGM skips all of that. It resolves the game's own function library by name
at runtime and calls it directly:

```lua
local lib = StaticFindObject("/Script/b1-Managed.Default__BGUFunctionLibraryManaged")
local ctx = FindFirstOf("BGPPlayerController")
lib:RunScriptGM("additem 1002 100000", ctx)
```

Because everything is resolved by name rather than by offset, it keeps working
across game updates.

## Requirements

- [RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) installed for Black Myth: Wukong

Nothing else. No CSharpLoader, no ReShade, no console mod.

## Install

1. Copy the `WukongGM` folder into:

   ```
   <Game>\b1\Binaries\Win64\ue4ss\Mods\
   ```

2. Confirm you end up with `ue4ss\Mods\WukongGM\scripts\main.lua`.
   The mod enables itself via `enabled.txt` — no `mods.txt` edit needed.

3. Launch the game and **load a save**. Commands need a live world; nothing
   works from the main menu.

## Use

### Pick items by name

Open `Mods\WukongGM\items.txt`, put a number next to what you want, save, and
press **F7** in game:

```
# --- Crafting materials ---
Refined Iron Sand                      = 0
Gold Tree Core                         = 50
Kun Steel                              = 0
```

Anything left at `0` is skipped. Names match ignoring case and spacing, so
`gold tree core` works too. Unrecognised names are reported by name in the
log, so a typo is visible rather than silently doing nothing.

Pressing F7 again re-adds everything still above 0, so reset to `0` when done.

### Raw commands

`Mods\WukongGM\commands.txt` takes GM commands directly, one per line, for
anything that is not an item:

```
allweapon
addtalentpoint 50
allmedition 1
```

F7 runs `items.txt` first, then `commands.txt`. Both are re-read on every
press, so no restart between edits. **Nothing is active by default.**

| key | action |
|-----|--------|
| F7  | run `items.txt` and `commands.txt` |
| F8  | diagnostics |
| F9  | unlock-all preset |
| F4  | dump equipment ids |

Rebind in `config.txt`. Output goes to `ue4ss\UE4SS.log`.

## Encoding gotcha

`commands.txt` and `config.txt` must be **ASCII or UTF-8 without a BOM**.

Notepad's default "UTF-8" writes a byte-order mark, and those three invisible
bytes become part of your first command, which then silently does nothing.
Use **Save As → Encoding: ANSI**, or any editor that can save without a BOM.

The parser strips BOMs defensively, but other tools may not.

## Known item IDs

74 ids across 9 categories, listed in `docs/commands.md` and pre-written as
commented lines in `commands.txt` — uncomment what you want and press F7.

Ids cluster by category, which makes finding unknown ones cheap:

| block | contents |
|-------|----------|
| `1xxx` | currency, formulas |
| `2xxx` | medicine, wine, soak ingredients |
| `3xxx` | herbs, curios, crafting materials |
| `6xxx` | seeds |

Only `1002` (Will) is confirmed by this project; the rest are community
reported. A wrong id grants the wrong item — harmless, but check before
trusting one. PRs confirming ids are welcome.

To find unmapped ones, probe a block and see what you end up holding 500 of:

```
additem 3220 500
additem 3221 500
```

## Commands

See [docs/commands.md](docs/commands.md) for the full reference.

Note that `addexp` grants **Sparks** (skill points), not Will. Will is
`additem 1002`.

## Safety

Destructive commands — `clearrolebag`, `clearitem`, `clearcard`,
`gmclearlegacy`, `clearshopdata` — are skipped unless you set
`allow_dangerous = true` in `config.txt`.

`clearrolebag` sets your character to level 0 and empties bag, talents and
spells. There is no undo.

**Back up your saves before using any of this.**

## Troubleshooting

Press **F8** and check `ue4ss\UE4SS.log`.

| symptom | cause |
|---------|-------|
| `world context: NOT FOUND` | you're at the main menu — load a save |
| `managed library: NOT FOUND` | UE4SS loaded but the game build differs; open an issue with your version |
| commands dispatch, nothing happens | the command name is wrong, or that command isn't implemented in your build |
| first command ignored | BOM in `commands.txt` — resave as ANSI |

A dispatched command only means the call was made. An unimplemented command
returns cleanly and does nothing, so always verify in game.


## Why console-based mods fail on this game

If you have tried other Wukong console mods and got `command not recognized`,
the cause is not those mods. **UE4SS's console-command hook is dead on this
game build.**

Verified directly: `ConsoleCommandsMod` ships with UE4SS and registers
`dump_object` through the standard `RegisterConsoleCommandHandler` API. Typing
`dump_object` into the F10 console is rejected. Native engine commands
(`stat fps`, `god`, `fly`) work normally.

So the F10 console reaches the engine but never reaches Lua. Any mod that
registers a console command — including the popular console mods — is
registering a handler that will never be invoked. `RegisterConsoleCommandGlobalHandler`
fails the same way.

This mod avoids the problem entirely by using keybinds, which do work.

## Experimental: overlay and file watcher

The repo also contains an in-game overlay (ModMenu) and a file watcher driven
by `tools/console.ps1`. **Both ship disabled**, because neither works on the
game build this was developed against:

- **Overlay** — the panel builds correctly (all sections register, `IsOpen`
  returns true, the widget tree exists) but never renders. This game's Slate
  structs differ from the ones ModMenu targets: `EditableTextBoxStyle` has no
  `TextStyle`, and `SetInputMode_GameAndUIEx` takes 4 parameters rather than 5.
  Raising the widget's Z order above the game HUD did not help.
- **Watcher** — `ExecuteInGameThreadWithDelay` never invokes the scheduled
  callback on this build, so queued commands are never consumed.

Enable them in `config.txt` (`menu_enabled`, `watch_enabled`) if you want to
experiment. The keybind path does not depend on either.

## License

MIT — see [LICENSE](LICENSE).
