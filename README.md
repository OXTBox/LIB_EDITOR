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

Data: the `.cellmap` format and its library live in `../LIB_BIT/editor` (the BitEditor).
