# GM command reference

Commands accepted by `RunScriptGM`. Put them in `commands.txt`, one per line.

## Provenance

The command *names* are the game's own API — they exist in the shipping
executable regardless of who writes them down.

Which commands exist was learned from the reference bundled with SealHoo's
[Black Myth Wukong Console Mod](https://www.nexusmods.com/blackmythwukong/mods/979).
The wording, grouping and English descriptions below are this project's own;
none of their file is reproduced. Credit to them for compiling the list.

## Verification status

Marked **[v]** below means confirmed working in game on the build this was
developed against. Everything else comes from the reference and is untested
here — if one dispatches and nothing happens, that build likely doesn't
implement it.

Verified: `additem 1002`, `addexp`, `allweapon`, `allitem`, `alltaskitem`,
`allattritem`, `allrecipe`.

PRs confirming more are welcome.

## Items

| command | effect |
|---------|--------|
| `additem <id> <n>` **[v]** | add `n` of item `id` |
| `costitem <id> <n>` | consume `n` of item `id` |
| `allitem` **[v]** | all materials and consumables (excludes wine) |
| `alltaskitem` **[v]** | all quest items |
| `allattritem` **[v]** | all attribute items |
| `allwine` | all wine |
| `allseeds` | all seeds |
| `allrecipe` **[v]** | all recipes |

## Equipment

| command | effect |
|---------|--------|
| `allweapon` **[v]** | all weapons |
| `allequip` | all equipment (one per set) |
| `allhulu` | all gourds |
| `armortotop <id>` | max out one armour piece |
| `allarmortotop` | max out all armour |

## Progression

| command | effect |
|---------|--------|
| `addexp <n>` **[v]** | add Sparks — skill points, **not** Will |
| `addtalentpoint <n>` | add talent / cultivation points |
| `addtalent <id>` | grant one talent |
| `alltalent` | all talents |
| `talentlevelup <id> <level>` | raise a talent to a level |
| `addspell <id>` | grant a spell |
| `setspell <id>` | grant and equip a spell |
| `allspell` | all spells |
| `soulskill <id>` | grant one spirit skill |
| `allsoulskill` | all spirit skills |
| `setsoulskill <id>` | equip a spirit skill |

## World

| command | effect |
|---------|--------|
| `setchapter <n>` | set current chapter |
| `map <id>` | unlock one map fragment |
| `allmap` | all map fragments |
| `allmedition <0\|1>` | unlock all shrines; `1` = as if you have the Sage's Ear |
| `unlockmeditation <id>` | unlock one shrine |
| `enablefunc <id>` | unlock an interactive function |
| `refreshshop <id>` | unlock one shop |
| `refreshallshop` | unlock all shops |
| `commdrop <id>` | force a random drop result |

## Collections

| command | effect |
|---------|--------|
| `allcard` | full bestiary |
| `card <id> <stage> <redpoint>` | unlock one bestiary entry |
| `allmuseum` | unlock museum in game |
| `allmuseumcs` | unlock museum in the scroll UI |
| `mv <id>` | unlock an MV |
| `addsurprise <chapter> <id>` | unlock one easter egg |
| `allsurprise` | all easter eggs |
| `alllegacy` | all Great Sage relics |

## Achievements

| command | effect |
|---------|--------|
| `allachievements` | unlock all |
| `unlockachievement <id>` | unlock one |
| `unlockachievementexclude <prefix> <id...>` | all except the listed |
| `printallachievements` | log all |
| `printcompletedachievements` | log completed |
| `printinprogressachievements` | log in progress |

## Misc

| command | effect |
|---------|--------|
| `addplaytime <seconds>` | add play time |
| `reinitroledata <type> <roleId> <name>` | reinitialise character data |

## Destructive

Skipped unless `allow_dangerous = true` in `config.txt`. No undo.

| command | effect |
|---------|--------|
| `clearrolebag` | **level 0, empties bag, talents and spells** |
| `clearitem` | empty inventory |
| `clearcard` | wipe bestiary |
| `gmclearlegacy` | wipe Great Sage relics and talents |
| `clearshopdata` | wipe all shop data |
| `clearmeditation` | wipe all shrines |
| `clearinterfunc` | wipe interactive functions |

## Finding item IDs

IDs are grouped in blocks. Probe a range and see what you end up holding 500 of:

```
additem 1020 500
additem 1021 500
additem 1022 500
```

Weapons in this engine's sibling titles run in blocks of eleven — a base item
followed by +1 through +10 at consecutive IDs — so once you find one variant
you have found the set.

Verified so far:

| id | item |
|----|------|
| 1002 | Will |

`1001` and `1003`–`1012` are real items (Celestial Pill is among them) but
have not been individually identified yet.
