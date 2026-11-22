# The console: a note to start from (owner, 22 Nov 2026)

The owner's words: "we should have a terminal/command-line type chat box ... like Blender has for its
python console. It should open in the lower left of the window, the input line should be able to
accept "Entity." and then tab key offers a menu of suggested words ... or it responds by input
filtering "Entity.Po" would autofill "Entity.Position" ... Try the autofill and also popup menu on
"Entity." + tab key etc first. ... the ig3dEditor seems the best place to test this, console was
always integral to it, or intended to be."

## What to build first
1. A console box in the iGame3D XT editor (`Vibecode3D_Play_Ig3dEditor.livecodescript`), opening in
   the **lower left** of the window: an output area above, one input line below (Blender's Python
   console as the model). The editor's Window menu already has a "Console" item to open it.
2. **Autofill while typing:** `Entity.Po` fills in the rest (`Entity.Position`), the added part
   selected so typing on replaces it.
3. **Tab after a dot:** `Entity.` + Tab pops up a menu of that group's words; picking one puts it in
   the line. Not cycling through the list one by one with each Tab (the owner finds that annoying).
4. Enter runs the line (an engine call) and shows the answer in the output area.

## What already exists (use it, don't redo it)
- `LIB_ig3d/livecode/lib_suggest.livecodescript`: `Suggest.Load`, `Suggest.Groups`, `Suggest.For(typed)`,
  `Suggest.Pick`, `Suggest.Meaning(name)` (the one-line meaning, could show beside the menu).
- `LIB_ig3d/Data/contract_words.txt`: the words, made from ENGINE_CONTRACT.md by `tools/make_names.py`
  (never typed by hand). The plan behind it: `LIB_ig3d/RENAME_DAY.md` section 4.
- House rules: menus pop on mouseUp (here: on the Tab key); colour the templates before creating
  controls; a test with no window (OXT-BEYOND/tests) beside it.

## Questions for later (not blockers)
- Whether comments to Claude also go through the console one day (today they go through the boards'
  right-click "Leave comment", into LIB_LLMIN/LIB_DEV/BOARD_COMMENTS.txt).
- The same console in the Game Player and the xRay windows after it works in the editor.
