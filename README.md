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

Edit `Mods\WukongGM\commands.txt`, one command per line, then press **F7**
in game. The file is re-read every press, so no restart between edits.

| key | action |
|-----|--------|
| F7  | run every command in `commands.txt` |
| F8  | diagnostics — reports what resolved |
| F9  | unlock-all preset |

Rebind in `config.txt`.

Output goes to `ue4ss\UE4SS.log`.

### Example

```
additem 1002 100000
allweapon
allspell
```

## Encoding gotcha

`commands.txt` and `config.txt` must be **ASCII or UTF-8 without a BOM**.

Notepad's default "UTF-8" writes a byte-order mark, and those three invisible
bytes become part of your first command, which then silently does nothing.
Use **Save As → Encoding: ANSI**, or any editor that can save without a BOM.

The parser strips BOMs defensively, but other tools may not.

## Known item IDs

| id | item |
|----|------|
| 1002 | Will (levelling and crafting currency) |

Only verified IDs are listed — a wrong ID silently grants the wrong item.
To find more, probe a block and see what you end up holding 500 of:

```
additem 1020 500
additem 1021 500
```

PRs adding verified IDs are very welcome.

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

## License

MIT — see [LICENSE](LICENSE).
