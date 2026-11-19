# LIB_EDITOR

The owner's brief (About_Lib_editor.txt, 2026-11-14):

> Here is where we practice the art of the editing tools. We may not want to house them all in
> one app. It would be great, sure, but it's also bigger download, larger documentation, diverse
> user base with too many different wants and needs. We'll focus editor development on "Form
> follows function" first ethos until to perfect the user experience.

| Where | What |
|---|---|
| `PLAN.md` | what classic level editors (Forge, Anvil, the Tomb Raider Level Editor) teach, what we have, what we need, the examples |
| `examples/` | one method each, as small Vibecode3D game cards (E01, E02 ...): lessons for the engine first, tools later |
| `tests/headless.sh` | run an example with no window: `tests/headless.sh E01_Blocks E01 "0:5"` |

## The cards (each one method, keys in its header)

| Card | What it shows | Test |
|---|---|---|
| E01 Blocks | a cellmap's cells as boxes | `tests/headless.sh E01_Blocks E01 "0:5"` |
| E02 Raise and lower | a cursor; Q / A raise or lower one cell | `tests/headless.sh` |
| E03 Elevation colours | the map coloured by height | `tests/e03_headless.txt` |
| E04 Ceilings | W / S lower a roof | `tests/e04_headless.txt` |
| E05 Slopes | lift one edge of a cell | `tests/e05_headless.txt` |
| E06 A rising door | a door that opens when the hero comes | `tests/e06_headless.txt` |
| E07 A pad opens a door | links: a plate here, a door there | `tests/e07_headless.txt` |
| E08 Teleporter pairs | step on a pad, stand on its partner; no bouncing back | `tests/e08_headless.txt` |
| E12 The checker | lists a map's problems, N jumps the camera to each; M next map | `tests/e12_headless.txt` |
| E13 Walk the map | the whole map as a level, walked | `tests/e13_headless.txt` |
| E15 Undo | Q / A raise or lower a cell; U undoes, R redoes, all the way back | `tests/e15_headless.txt` |

The `.txt` tests run with no window:
`cd ~/projects/OXT-BEYOND/tests && python3 -I oxt_headless.py --engine both ~/projects/LIB_EDITOR/tests/e08_headless.txt`

Data: the `.cellmap` format and its library live in `../LIB_BIT/editor` (the BitEditor).
