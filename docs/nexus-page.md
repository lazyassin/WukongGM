# Nexus page copy

Paste each block into the matching field on the upload form.

---

## Description

Black Myth: Wukong ships with a full GM command system built in — the
developers' own tools for granting items, unlocking weapons and spells, adding
Will, and jumping chapters. It is all still in the shipping game.

The usual way to reach it is a console mod plus CSharpLoader. That stack hooks
engine internals by offset, and those offsets move every time the game is
patched, so on current builds it fails silently: the console opens, you type
`additem`, and the game answers "command not recognized".

WukongGM takes a different route. It looks up the game's own GM function by
name at runtime and calls it directly:

    /Script/b1-Managed.Default__BGUFunctionLibraryManaged:RunScriptGM

No console. No C# loader. No hardcoded addresses. Because everything is
resolved by name rather than by offset, it is not tied to a specific game
version the way the older mods are.

You write commands in a text file and press a key. That is the whole thing.

Tested on the current retail build as of September 2026.

---

## Installation instructions

1. Install RE-UE4SS for Black Myth: Wukong (link under Requirements).
   Confirm it works — press F10 in game and type `stat fps`. If the framerate
   counter appears, UE4SS is running and you are ready.

2. Extract this mod's archive into:

       <Game>\b1\Binaries\Win64\ue4ss\Mods\

   You should end up with:

       ue4ss\Mods\WukongGM\scripts\main.lua

   The mod enables itself. You do NOT need to edit mods.txt.

3. Launch the game and LOAD A SAVE. Commands need a live game world — nothing
   works from the main menu.

4. Open `ue4ss\Mods\WukongGM\commands.txt`, put your commands in, one per
   line, and press F7 in game.

IMPORTANT — file encoding. Save commands.txt as ANSI, not UTF-8.
Notepad's default UTF-8 adds a hidden byte-order mark, which becomes part of
your first command and makes it silently do nothing. In Notepad:
Save As -> Encoding -> ANSI.

---

## Main features

Runs the game's own GM commands — around 50 of them. Add items, grant every
weapon, spell, talent or gourd, unlock all shrines and map fragments, set your
chapter, add Will and talent points.

No keypress-per-command. Put as many commands as you like in commands.txt and
run the lot with one key. The file is re-read every press, so you can edit it
without restarting the game.

Only needs UE4SS. No CSharpLoader, no ReShade, no separate console mod.

Not offset-dependent. Everything is looked up by name when the game is
running, so a patch that shifts engine internals does not break it.

Safety guard. Commands that wipe progress — clearrolebag and friends — are
refused unless you deliberately switch them on in config.txt. clearrolebag
sets your character to level 0 and empties your bag, talents and spells, with
no undo, and it is very easy to type by accident.

Rebindable keys, in config.txt. Defaults:

    F7   run everything in commands.txt
    F8   diagnostics — tells you exactly what resolved and what didn't
    F9   unlock-all preset

Documented. A full translated command reference ships in docs/commands.md,
along with the verified item IDs.

---

## Requirements

RE-UE4SS — required.
https://www.nexusmods.com/blackmythwukong/mods/19

Nothing else. Specifically NOT required:
  - CSharpLoader
  - ReShade
  - any console-enabling mod

You must be in gameplay, not at the main menu, for commands to work.

Single-player only. Do not use this online.

Back up your saves before using any mod that writes to your game state.
They live in: %LOCALAPPDATA%\b1\

---

## Shout outs

SealHoo and 仿生人K2, authors of the Black Myth Wukong Console Mod, whose
archive includes the GM command reference this mod's documentation is
translated from. Their mod is what pointed me at the command set in the first
place, even though its console did not work on my build — which is the reason
this one exists.

The RE-UE4SS team. None of this is possible without it, and UEHelpers ships
with it under MIT.

Everyone who posted a "command not recognized" comment on the older console
mods. Those threads are what told me the problem was the game version rather
than my install, and saved me a lot of pointless reinstalling.

---

## Credits

(Nexus warns that crediting is not the same as permission. Nothing in this
release redistributes anyone else's files — see THIRD-PARTY.md.)

SealHoo / 仿生人K2 — Black Myth Wukong Console Mod
https://www.nexusmods.com/blackmythwukong/mods/979
Their archive documents the game's GM command set, which is how I knew these
commands existed. None of their files are included here, and none of their
text is reproduced: this mod reaches the commands by a different route and the
documentation is written from scratch. Credit for compiling the list is theirs.

RE-UE4SS team — https://github.com/UE4SS-RE/RE-UE4SS
Required to run this mod. Not bundled; users install it themselves.

Game Science — for leaving the GM system in the shipping build.

Everything else in this release is my own work, MIT licensed.
Source: https://github.com/lazyassin/WukongGM
