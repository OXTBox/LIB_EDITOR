# iGame3D XT

Monday, November 16, 2026. The iGame3D editor remade in xTalk on the Vibecode3D engine, moved here
from LIB_GAMES on the owner's word (16 Nov): it is a tool, not a game. Shipping title
**iGame3D XT** (xRay on the xt3d core, Box2DXT / xRayBox with Box2D), on itch.io as xAction.
It is not in the game launcher (that one is for games only).

| Edition | Where | |
|---|---|---|
| We know it works | `main` here (= branch `ig3d-editor-works`) | as you ran it on 16 Nov: the 2008 Data folder and the LIB_MOCAP clips found on your PC |
| Standalone | branch `ig3d-editor-standalone` | nothing outside itself: template Data folder, generated models (Aquarius done); plan in `STANDALONE_PLAN.md` there |

- `Vibecode3D_Play_Ig3dEditor.livecodescript`: the editor (a Vibecode3D card script).
- `Tools/`: its tool windows (Inspector, Replace With Model, the drag preview), copied from
  LIB_ig3d branch `v3d-editor-tools`. This edition still opens them from LIB_ig3d; the
  standalone edition opens these copies.
- `_manifest_2008/`: Spark's survey of the 2008 Data folder (WTF index, glossary drafts), moved
  from LIB_GAMES. Its tools read the 2008 folder, which now lives only in git: LIB_GAMES commit
  5a62a5d (branch `ig3d-editor-works` there), `git -C ~/projects/LIB_GAMES archive 5a62a5d
  igame3D_2008_Texts | tar -x` brings it back.

## The Library menu (18 Nov 2026)

- The Library menu now comes from a menu file: `LIB_MENU/Data/Default/Ig3dEditor/Menus/Library.txt`.
- It keeps the old items: Models, Levels, Text, Emitters, Images, Materials, Scripts, Sounds, Set Data Folder...
- It adds two lists filled from your Data folder each time the menu opens:
  **Data** (the folders at the top of the Data folder) and **Games** (the game folders).
  Make a folder in Data, and the menu grows.
- Pick a folder there: the Library list on the right shows what is in it, folders first.
  Double-click a folder to go in; ".." goes back.
- Explorer opens only when you pick **Explore here...** at the bottom of the menu.
  It opens at the folder the list shows (or the file you clicked in it).
- To change the menu, copy `Library.txt` into your Data folder's `Menus/Ig3dEditor/` and edit the copy. Yours wins.
- What a pick does is in `Functions/ig3deditor_functions.livecodescript` beside the menu file (copy it the same way).
- Without LIB_MENU (a copy with no projects folder above it), the Library menu is the old one.
- Test: `OXT-BEYOND/tests/t51_editor_library_menu.txt`.

## The menu bar: green graphics, one popup (18 Nov 2026)

- Your design: "graphic labels, one popup button to rule them all".
- The titles (File, Edit, View, Library ...) are green graphics on the menu bar strip now.
  There are no pulldown menu buttons any more. Their lists came out "extreme green" on Windows.
- A mouse down on a title fills ONE hidden popup button with that menu and pops it under the title.
- That popup is plain black on white. Its colours are set on the template before it is made,
  and again on the button, so it never takes the stack's green.
- With LIB_MENU there, the popup is LIB_MENU's (`Menu.PopFor`). Without it, the editor makes the same
  button itself. Either way there is only one.
- A pick goes to the same place as before (`Ig.Menu`); the Library still goes through LIB_MENU first.
- Ctrl + the letter still picks the items with a shortcut (/N New Level, /S Save Level, /Z Undo ...).
- Not seen on screen yet: the tests run with no window, so they check the colours and the picks,
  not what the popup looks like. Please look at it on Windows.
