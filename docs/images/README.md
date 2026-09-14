# Screenshots

Save the three shots here with these names. They are referenced by the Nexus
page and the GitHub release.

## 01-will-before.png
Equipment screen, Will counter reading **1,471,655** in the top right.
The "before" half of the pair.

## 02-will-after.png
Same screen after one `additem 1002 100000`, Will reading **1,571,655**, with
the game's own **Will ×100000** pickup popup visible on the right.
This is the single most useful image on the page: it shows the command working,
in the game's own UI, with the game confirming the grant. Lead with it.

## 03-console-output.png
The UE4SS console window showing a clean load and a successful dispatch:

    [WukongGM] F7   run commands.txt
    [WukongGM] F8   diagnostics
    [WukongGM] F9   unlock-all preset
    [WukongGM] overlay disabled in config.txt
    [WukongGM] WukongGM v1.0.1 loaded
    [WukongGM] running 1 command(s) from ue4ss/Mods/WukongGM/commands.txt
    [WukongGM]   additem 1002 100000 -> RunScriptGM
    [WukongGM] dispatched 1/1

Proof the mod loads without errors and that commands route through
`RunScriptGM`. Good second image — it answers "does this actually work on my
build" for anyone who has been burned by the older console mods.

## How to save them

Win+Shift+S copies to the clipboard only. To get files:

- **Win+PrtScn** writes straight to `Pictures\Screenshots`, or
- After Win+Shift+S, paste into Paint and Save As PNG.

PNG, not JPG — text stays legible and Nexus does not recompress it further.

## Suggested order on the Nexus page

1. `02-will-after.png`   — the result, with the game confirming it
2. `03-console-output.png` — proof it runs clean
3. `01-will-before.png`  — context for the pair
