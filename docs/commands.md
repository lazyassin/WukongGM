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

## Item IDs

### Currency

| id | item |
|----|------|
| `1002` | Will **(verified)** |

### Formulas

| id | item |
|----|------|
| `1113` | Ascension Powder Formula |
| `1144` | Evil Repelling Medicament Formula |
| `1166` | Enhanced Ginseng Pellets Formula |
| `1168` | Enhanced Tiger Subduing Pellets Formula |

### Wine and brewing

| id | item |
|----|------|
| `1998` | Awaken Wine Worm |
| `1999` | Luojia Fragrant Vine |
| `2001` | Coconut Wine |
| `2012` | Loong Balm |

### Medicine and pellets

| id | item |
|----|------|
| `2204` | Body-Warming Powder |
| `2205` | Antimiasma Powder |
| `2206` | Shock-Quelling Powder |
| `2211` | Life-Saving Pill |
| `2213` | Ascension Powder |
| `2221` | Tonifying Enhancing Medicine |
| `2224` | Amplification Pellets |
| `2227` | Tiger Subduing Pellets |
| `2230` | Longevity Enhancing Medicine |
| `2234` | Fortifying Medicament |
| `2247` | Evil Repelling Medicament |
| `2251` | Enhanced Ginseng Pellets |
| `2253` | Enhanced Tiger Subduing Pellets |
| `2402` | Incense Trail Talisman |

### Soak ingredients

| id | item |
|----|------|
| `2305` | Mount Lingtai Seedlings |
| `2310` | Laurel Buds |
| `2313` | Deathstinger |
| `2314` | Purple-Veined Peach Pit |
| `2315` | Bee Mountain Stone |
| `2319` | Goji Shoots |
| `2320` | Fruit of Dao |
| `2323` | Gall Gem |

### Herbs and ores

| id | item |
|----|------|
| `3201` | Licorice |
| `3202` | Aged Ginseng |
| `3203` | Fragrant Jade Flower |
| `3204` | Purple Lingzhi |
| `3205` | Fire Bellflower |
| `3206` | Gentian |
| `3207` | Tree Pearl |
| `3208` | Celestial Pear |
| `3209` | Withered Silkworm |
| `3214` | Nine-Capped Lingzhi |
| `3215` | Flame Ore |
| `3216` | Jade Lotus |
| `3217` | Snake-Head Mushroom |
| `3219` | Golden Lotus |

### Curios and valuables

| id | item |
|----|------|
| `3003` | Mind Core |
| `3301` | Tadpole |
| `3302` | Gold Ridge Beast |
| `3305` | Buddha's Right Hand |
| `3306` | Tiny Piece of Gold |
| `3307` | Small Piece of Gold |
| `3308` | Large Piece of Gold |
| `3309` | Blood of the Iron Bull |
| `3310` | Knot of Voidness |

### Crafting materials

| id | item |
|----|------|
| `3594` | Celestial Ribbon |
| `3901` | Jade Fang |
| `3902` | Flame Ebongold |
| `3906` | Spider Leg |
| `3916` | Starlit Cloud-Bidden Antler |
| `3921` | Loong Pearl |
| `3925` | Sky-Piercing Horn |
| `3929` | Venomous Hair |
| `3950` | Yarn |
| `3951` | Silk |
| `3952` | Cold Iron Leaves |
| `3953` | Fine Gold Thread |
| `3958` | Stone Spirit |
| `3959` | Yaoguai Core |
| `3960` | Refined Iron Sand |
| `3961` | Gold Tree Core |
| `3962` | Kun Steel |

### Seeds

| id | item |
|----|------|
| `6002` | Nine-Capped Lingzhi Seed |
| `6004` | Fragrant Jade Flower Seed |
| `6005` | Fire Bellflower Seed |

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
