# Nexus page copy

Paste each block into the matching field on the upload form.

---

## Description

Black Myth: Wukong ships with a full GM command system built in - the
developers' own tools for granting items, unlocking weapons and spells, adding
Will, and jumping chapters. It is all still in the shipping game.

The usual way to reach it is a console mod plus CSharpLoader. That stack hooks
engine internals by offset, and those offsets move every time the game is
patched, so on current builds it fails silently: the console opens, you type
additem, and the game answers "command not recognized".

The reason is not those mods. UE4SS's console-command hook is dead on current
builds - even UE4SS's own bundled commands are rejected. Anything registering
a console command is registering a handler that will never be invoked.

WukongGM does not use the console at all. It looks up the game's own GM
function by name at runtime and calls it directly:

    /Script/b1-Managed.Default__BGUFunctionLibraryManaged:RunScriptGM

No console. No C# loader. No hardcoded addresses. Because everything is
resolved by name rather than by offset, it is not tied to a specific game
version the way the older mods are.

### There is no in-game menu, and here is why

You use this by editing a text file, not by opening a panel. That is a
deliberate choice, not a missing feature.

An in-game menu needs the game to draw it, and on current builds it will not.
I built one - it constructs correctly, reports itself open, and renders
nothing, because this game's UI internals differ from what the modding tools
expect. UE4SS's own built-in console window crashes the game at startup here.
Every route to drawing something on screen is blocked by the same thing that
breaks the other console mods.

A text file needs none of that. Nothing to render means nothing to fail.

In practice it is two lines of work. Open items.txt, which already lists every
item by name:

    Gold Tree Core                 = 0
    Refined Iron Sand              = 0

Change a zero to the amount you want, save, and press F7 in game:

    Gold Tree Core                 = 50

That is the whole workflow. No IDs to look up, no console to enable, no
commands to memorise. The file is re-read every time you press the key, so you
can leave it open in Notepad on a second monitor and keep editing while you
play.

Tested on the current retail build as of September 2026.

---

## Installation instructions

1. Install RE-UE4SS for Black Myth: Wukong (link under Requirements).
   Confirm it works - press F10 in game and type "stat fps". If the framerate
   counter appears, UE4SS is running and you are ready.

2. Extract this mod's archive into:

       <Game>\b1\Binaries\Win64\ue4ss\Mods\

   You should end up with:

       ue4ss\Mods\WukongGM\scripts\main.lua

   The mod enables itself. You do NOT need to edit mods.txt.

3. Launch the game and LOAD A SAVE. Commands need a live game world - nothing
   works from the main menu.

4. Open ue4ss\Mods\WukongGM\items.txt, set a number next to what you want,
   save, and press F7 in game.

IMPORTANT - file encoding. Save as ANSI, not UTF-8.
Notepad's default UTF-8 adds a hidden byte-order mark, which becomes part of
the first line and makes it silently do nothing. In Notepad:
Save As -> Encoding -> ANSI.

---

## Main features

Pick items by name, not by ID. items.txt lists every known item with a
quantity. Set a number, save, press F7:

    Gold Tree Core                 = 50
    Refined Iron Sand              = 0
    Will                           = 100000

Anything left at 0 is skipped. Names match ignoring case and spacing, and
anything unrecognised is reported by name so a typo is visible rather than
silently doing nothing.

74 item IDs included, grouped by category:

  Currency               1
  Formulas               4
  Wine and brewing       4
  Medicine and pellets   14
  Soak ingredients       8
  Herbs and ores         14
  Curios and valuables   9
  Crafting materials     17
  Seeds                  3

Raw GM commands too. commands.txt takes the game's own commands directly for
anything that is not an item - allweapon, alltalent, allspell, allhulu,
allmedition, allmap, addtalentpoint, setchapter, and around fifty more.

Nothing is active by default. A fresh install does nothing until you ask it to.

Only needs UE4SS. No CSharpLoader, no ReShade, no separate console mod.

Not offset-dependent. Everything is looked up by name while the game is
running, so a patch that shifts engine internals does not break it.

Safety guard. Commands that wipe progress - clearrolebag and friends - are
refused unless you deliberately switch them on in config.txt. clearrolebag
sets your character to level 0 and empties your bag, talents and spells, with
no undo, and it is very easy to type by accident.

Rebindable keys, in config.txt. Defaults:

    F7   run items.txt, then commands.txt
    F8   diagnostics - reports exactly what resolved and what did not
    F9   unlock-all preset
    F4   dump the game's equipment IDs to a file

Documented. A full translated command reference ships in docs/commands.md,
along with every known item ID and which ones are verified.

---

## How to use

### Your first item, step by step

1. Open this file in Notepad:

       <YourGame>\b1\Binaries\Win64\ue4ss\Mods\WukongGM\items.txt

2. Scroll to the "Crafting materials" section and find this line:

       Gold Tree Core                         = 0

3. Change the 0 to how many you want:

       Gold Tree Core                         = 50

4. Save the file. Ctrl+S.
   (First time only: File -> Save As -> Encoding: ANSI)

5. Alt-tab into the game. You must be playing - loaded into the world, not
   sitting on the main menu.

6. Press F7.

7. Open your inventory. You have 50 Gold Tree Core.

That is it. Same for anything else in the list - Will, medicines, herbs,
curios, seeds. Change a number, save, press F7.

When you are finished, set the numbers back to 0, or they get added again
every time you press F7.

---

Everything happens in two text files in `ue4ss\Mods\WukongGM\`. Edit, save,
press F7 in game. Both files are re-read on every press, so you never need to
restart the game.

You must be IN GAMEPLAY. Nothing works from the main menu - there is no game
world for the commands to act on.

### Items - pick by name

Open items.txt. Every known item is listed with a quantity. Put a number next
to what you want and save:

    Gold Tree Core                 = 50
    Refined Iron Sand              = 0
    Will                           = 100000

Press F7. Anything left at 0 is skipped.

Names are matched ignoring case and spacing, so "gold tree core" works too.
Anything it does not recognise is listed by name in the log, so a typo is
visible rather than silently doing nothing.

Pressing F7 again adds everything still above 0 a second time. Set values back
to 0 when you are done.

### Commands - everything that is not an item

Open commands.txt, one command per line. Lines starting with # are ignored, so
you can keep a library and enable things by uncommenting:

    allweapon
    alltalent
    addtalentpoint 50
    allmedition 1

Press F7. It runs items.txt first, then commands.txt.

Nothing is active by default - a fresh install does nothing until you ask.

### Keys

    F7   run items.txt, then commands.txt
    F8   diagnostics - reports what the mod resolved
    F9   unlock everything preset
    F4   dump the game's equipment IDs to a file

Rebind them in config.txt.

### Checking what happened

Output goes to `ue4ss\UE4SS.log`. A successful run looks like:

    [WukongGM] items.txt: 1 item(s) requested
    [WukongGM]   additem 3961 50 -> RunScriptGM
    [WukongGM] dispatched 1/1 - verify in game

Important: "dispatched" means the call was made, not that the game acted on
it. A command the game does not implement returns cleanly and does nothing.
Always check in game.

### If nothing happens

Press F8 and look at the log.

  "world context: NOT FOUND"     you are at the main menu - load a save
  "managed library: NOT FOUND"   your game build differs - open a bug report
  first line ignored             BOM in the file - resave as ANSI
  dispatches but no effect       that command is not implemented on your build

### File encoding

items.txt and commands.txt must be saved as ANSI, not UTF-8.

Notepad's default UTF-8 writes a hidden byte-order mark, and those invisible
bytes become part of your first line, which then silently does nothing. In
Notepad: Save As -> Encoding -> ANSI.

---

## Requirements

RE-UE4SS - required.
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

## Credits

(Nexus warns that crediting is not the same as permission. Nothing in this
release redistributes anyone else's files - see THIRD-PARTY.md.)

SealHoo / K2 - Black Myth Wukong Console Mod (mod 979).
Their archive documents the game's GM command set, which is how I knew these
commands existed. No files or text of theirs are included here; this mod
reaches the commands a different way and the documentation is written from
scratch. Credit for compiling the list is theirs.

RE-UE4SS team - required to run this. Not bundled.

Item IDs were gathered from community reports, chiefly the FearLess
Revolution forums. IDs are facts about the game rather than anyone's work.

Everything else is my own work, MIT licensed.
Source: https://github.com/lazyassin/WukongGM
