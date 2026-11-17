# iGame3D XT: the release checklist

Monday, November 16, 2026. Draft 1 (Claude, Fable 5.2). Every step from today to a build
someone can download from itch.io under the owner's handle **xAction**. It rests on
`STANDALONE_PLAN.md` (the owner's decisions per group), `ASSET_CHECKLIST.tsv`, `INVENTORY.md`,
`LIB_PUBLIC/install/` (the installer and the persona simulation) and tests t19, t20, t33-t38.
The owner decides; nothing here ships anything.

Names: **iGame3D XT** (this one). Later: iGame3D xRay, iGame3D Box2DXT, iGame3D xRayBox.

## 0. Only you can clear these (the release waits on each)

1. **Look at it on a screen.** Nothing in this edition has been seen on a screen yet; every
   test ran with no window. Open it (Vibecode3D Library > Tools > iGame3D XT on V:), walk the
   menus, and say what must change before strangers see it. (step D1)
2. **Say what the download is.** iGame3D XT alone (one zip, one program, opens straight into the
   editor), or the whole Vibecode3D Library with XT under Tools. This checklist assumes
   **alone** until you say otherwise. (step C1)
3. **The licence you publish under.** The program the build is made with is under the GNU
   GPL, version 3, so the build must be offered under the GPL v3 too, with its licence text and
   a way to get the source. Our scripts ship as readable text, which covers our side. Say yes
   to "GPL v3" (or stop the release here). (step B1)
4. **Three things that came from somewhere else: yes or no for each.**
   - the **2008 Help pages**: text by the iGame3D team of 2008, not only you. May you publish
     your co-authors' words? (step A4)
   - the **Aquarius character set** (`Data/Text/Aquarius.pbm`, 256 glyphs from your 2008
     converter): where did the glyph shapes come from, and may they ship? (step A5)
   - the **motion clips**: iGame3D XT alone ships none today. If you want clips in the 1.0
     download, name them; Animazoo and Carnegie Mellon are credited either way. (step A6)
5. **The credits, by name.** Who is credited, and how each name is written: you, the 2008
   iGame3D team, Animazoo, Carnegie Mellon, Scott Rossi (the shaped-window idea), the makers of
   the engine. A draft is in section 6. (step B3)
6. **The itch.io page.** Only you can make the page under xAction, set the price (free?),
   choose the screenshots, and press Publish. A draft of the text is in section 7. (steps F1-F4)
7. **The version number.** Default: **1.0.0**. Say so, or say "0.9, early access". (step G1)
8. **Windows will warn people.** The program is not signed, so every download shows "Windows
   protected your PC". Buy a signing certificate, or accept the warning and say so on the page
   (the draft does). (step E5)
9. **Let go of the hold.** When all of the above is done, say "ship it": an AI then removes
   `Ig3dEditor` from `HOLD` in `LIB_PUBLIC/install/vibeinstall.py`. (step H1)

## 1. What "done" means for 1.0

iGame3D XT 1.0 is done when **all** of these are true:

1. **It stands alone.** Unzipped on a PC that has never seen the projects folder, it starts,
   and nothing it does reaches outside its own folder and the player's own Data folder.
2. **Everything in the zip is ours, generated, or paid for**, and every file is on the table in
   section 4 with its source and licence. No row says "owner to state".
3. **Every menu item and tool either works or says plainly that it is not in 1.0.** No item
   fails silently, opens an empty window, or looks for the owner's PC.
4. **It shows what it can do with no extra files:** buildings, props and characters made from
   their names, the 256 Aquarius characters from one bitmap, four levels that open, File > Save
   and open again, the Inspector, Replace With Model on generated models.
5. **A newcomer gets from download to a street of buildings in under five minutes** using only
   the itch.io page and Help > iGame3D XT Help (the Dana persona, on a clean PC).
6. **It tells the truth about itself:** an About box with the name, version, date, credits and
   licence; the licence and credits files in the zip; the 2008 Help marked as legacy.
7. **The tests pass on the release files**, not the projects copy: t19, t20, t33-t38 and the
   new release test (step E2).
8. **The owner has played it on a screen and said "ship it".**

Not needed for 1.0 (say so on the page): particles/emitters (held), shaders, fluid, the mesh
editing tools not wired yet, sound, physics, the other three editions.

## 2. Where it stands tonight

| | |
|---|---|
| The edition | on `main` of LIB_EDITOR, folder `iGame3D_XT/`: the script (96 KB), `Tools/` (7 scripts, 148 KB), `Data/` (84 KB), `Help_2008/` (480 KB). No image files in it (0) |
| The edition before | tag `edition/known-works` (619040e): the editor reading the 2008 Data folder and LIB_MOCAP from the owner's PC. Not shippable; kept as the known-good reference |
| Installed on V: | `V:\Program Files (x86)\Vibecode3D\vibeapps\common\iGame3D XT\` (732 KB), put there with `vibeinstall.py install --include-held`; shown under Tools in the Vibecode3D Library |
| Held | `HOLD = {"Ig3dEditor"}` in `LIB_PUBLIC/install/vibeinstall.py`: an ordinary install leaves it out |
| Tests, run 16 Nov evening, headless, on main | **177 checks passed, 0 failed**: t19 skins 19, t20 editor tools 7, t33 Aquarius 19, t34 buildings 24, t35 props and levels 35, t36 DeadDays 19, t37 layout 30, t38 window shape 24 |
| Speeds from that run (real engine from V:, no screen) | Aquarius 256 models made in 429 ms, first frame 503 ms; four streets 180 ms, first frame 78 ms; the 131-model showcase 260 ms; the DeadDays city 147 ms |
| Seen on a screen | no |

Known gaps found while writing this (each is a step below):

- Installed, the **Inspector's Animation page lists no clips**: it looks for
  `<projects>/LIB_MOCAP/library`, and an installed copy has no projects folder (step A6).
- Installed, **Replace With Model cannot find any game to skin** (no `LIB_GAMES` above it) (step C5).
- The editor script's last fallback for a tool window is still `LIB_ig3d/livecode/` (step C5).
- **Help > iGame3D Help opens only the 2008 pages**, which describe the 2008 Lua engine. There
  is no page for iGame3D XT itself (steps D2-D4).
- The 2008 Help links to igame3d.com, igame3d.de and a SourceForge address 79 times; those may
  be dead (step D3).
- There is **no About box, no version number, no licence or credits file** in the folder (B, G).
- `README.md` beside this file still describes two branches; since the merge of 16 Nov main
  *is* iGame3D XT (step H3).
- The Vibecode3D Library's shared folder ships all 41 Animazoo and 19 Carnegie Mellon clips;
  the owner's decision was "only the clips the games use". That matters for the Library's
  release, and for XT only if XT ships inside the Library (step A6).

## 3. The steps

Who: **owner**, **AI** (Claude: Opus for the work, Fable for structure), **Spark** (drafts
only, always reviewed). "Blocks" = the release cannot go out without it.

### A. What ships and what stays out

| # | Step | Who | How to check it is done | Blocks |
|---|---|---|---|---|
| A1 | Freeze the ship list: exactly the folders in section 4, nothing else | AI | `git ls-files iGame3D_XT` minus the stay-out list equals the files in the zip (step E2 compares them) | yes |
| A2 | Keep out of the zip: `_manifest_2008/` (271 files of Spark's survey), `INVENTORY.md/.tsv` (they list 2008 model names, a few of them other people's characters), `ASSET_CHECKLIST.tsv`, `STANDALONE_PLAN.md`, this file, `tools/` (the Python generators) | AI | none of those names appear in the zip listing | yes |
| A3 | Scan the ship list for other people's names. Done tonight for the 2008 character names (Lara, Master Chief, Lego, TRON, Warhammer and the like): **0 found** in the script, Tools, Data and Help. One leftover word, "arbiter", in `Tools/v3d_figures` line 40 (it maps an old model name to "soldier"): remove the word | AI | the scan is a test in E2 and finds nothing | yes |
| A4 | The 2008 Help pages: confirm you may publish your co-authors' text | owner | the Help row in section 4 has its licence filled in | yes |
| A5 | The Aquarius bitmap: say where the glyph shapes came from and that it may ship. If not: an AI draws a replacement set in LIB_BIT and the editor reads that | owner (AI if replaced) | the Aquarius row in section 4 has its source and licence | yes |
| A6 | Motion clips in XT alone: none (default), or the ones you name. If none, the Inspector's Animation page says "no clips in this download: choose a folder" instead of an empty list; if some, they go in `Data/Clips/` with their credits and the page reads them from there | owner decides, AI builds | open the Inspector on V: with no projects folder: the page says or shows the right thing; t17 extended | yes |
| A7 | Emitters (held), Shaders, Fluid, Armor, Bump_mesh, PathSources, Clothing (removed), the 2008 Lua (stays in the earlier edition): confirm none is in the zip and their menu items say "not in 1.0" | AI | E2's file list; walk Library > Emitters / Scripts on V: | yes |
| A8 | DeadDays is a game, not part of this download; it stays a beta in the Library | none | not in the zip | no |

### B. Credits and licence texts

| # | Step | Who | How to check | Blocks |
|---|---|---|---|---|
| B1 | Say yes to publishing under the GPL v3 | owner | a line in this file: "GPL v3: yes, <date>" | yes |
| B2 | Put the licence texts in the zip, unchanged: `LICENSE.txt` (the GPL v3 text), and the engine's own notices as it ships them (`LICENSE-EXCEPTION.md`, `THIRD-PARTY-NOTICES.md`, `Open Source Licenses.txt` from the OXT-Beyond folder) in a `Licences/` folder. These are other people's legal texts: copied whole, never reworded | AI | the four files are in the zip and byte-identical to the engine's copies | yes |
| B3 | `CREDITS.txt`: approve the names and spellings (draft in section 6) | owner approves, AI writes | the file is in the zip; the About box shows the same text | yes |
| B4 | `SOURCE.txt`: where the source is. Ours: the scripts in the zip are the source, readable and editable. The engine's: the address of its public source (owner or AI copies it from the engine's About/README; do not guess it) | AI, owner confirms the address | the file is in the zip and the address opens | yes |
| B5 | An About box in the editor (LIB_ALPHA rule 17): long date, name, title, version, what it is for, how to use it, how to report a problem, credits, licence | AI | Help > About iGame3D XT shows it; a test reads its text | yes |
| B6 | The Tell box (` or F2) writes the player's notes into their own Data folder; say so in the About box and on the page (it sends nothing anywhere) | AI | the sentence is in both | no |

### C. The standalone build

| # | Step | Who | How to check | Blocks |
|---|---|---|---|---|
| C1 | Decide the shape of the download (blocker 2). Default: `iGame3D XT.exe` + `iGame3D XT/` (script, Tools, Data, Help) + `Engine/` (the three engine scripts the Library loads today) + `Licences/`, in one zip | owner | a line here: "download = alone / inside the Library" | yes |
| C2 | A small start-up stack for XT alone, made from the launcher (`LIB_PUBLIC/launcher/vibe_launcher.livecodescript`, which already opens one title with `-game <folder>`): with no arguments it opens the `iGame3D XT` folder beside itself | AI | double-click the exe in a scratch folder: the editor window opens | yes |
| C3 | **Save the stack VISIBLE before building.** A stack opened with `open invisible` and then saved stays hidden, and the program built from it starts with no window (this happened to the launcher on 16 Nov). In one run in OXT-Beyond: lock messages, `set the visible of stack X to true`, `set the fileName of stack X to <its real path>`, `save stack X` | AI | reopen the saved stack headless and read `the visible of stack X`: true. Then the built exe shows a window (owner looks once) | yes |
| C4 | Build in OXT-Beyond: set the stack's standalone settings (name `iGame3D XT`, Windows x86-64, its icon), then `revSaveAsStandalone`. Output under `build/iGame3D XT/Windows x86-64/` | AI (owner allows the run in OXT-Beyond) | the exe exists, is about 16 MB, and starts | yes |
| C5 | Close the last doors to the owner's PC: `Ig.ToolFile` no longer falls back to `LIB_ig3d/livecode/`; Replace With Model, with no games folder, offers "Use Folder" and says why the game list is empty; no `wsl$`, `/home/` or `LIB_` path is opened at run time | AI | a test starts the editor from a copy with no projects folder above it and logs every file it opens: all inside its folder or the player's Data folder | yes |
| C6 | Closing the last window ends the program and frees it (LIB_ALPHA rule 12b): the editor and every tool window set `destroyStack` and close the main stack | AI | after closing, Task Manager shows no `iGame3D XT.exe` (owner looks once); a headless test checks the handlers exist | yes |
| C7 | Settings go where Windows expects (`AppData\Vibecode3D\igame3d_xt.txt`, already so), saves in the player's Data folder; nothing is written beside the exe | AI | run from a read-only folder (the Jordan probe): no error | yes |
| C8 | A program icon. No image file is in the folder today; the owner supplies or approves one | owner | the exe and the itch.io page show it | no |
| C9 | Sign the exe, or accept the Windows warning (blocker 8) | owner | signed: the properties show the signature. Not signed: the page explains "More info > Run anyway" | no (the wording on the page is) |

### D. The Help pages

| # | Step | Who | How to check | Blocks |
|---|---|---|---|---|
| D1 | Walk every menu and tool on a screen; mark each: works / not in 1.0 / remove | owner | a marked list (the AI prints the menu tree from `kMenus` and `kTools` for you to mark) | yes |
| D2 | Write **iGame3D XT Help**, one page per menu, from the script's own header and D1: the first five minutes; Library (Models, Text, Levels, Set Data Folder); Edit (boom, Replace With Model); Window (Inspector); levels as editable xTalk files (`Data/Scripts/LEVEL_API.txt`); the Tell box | Spark drafts from the script, AI checks every sentence against the script, owner reads | every menu item named in the Help exists in `kMenus`, and every item in `kMenus` is in the Help (a test compares the two lists) | yes |
| D3 | Mark the 2008 pages as legacy: a line at the top of `Help_2008/index.html` ("the 2008 engine's help, kept as it was; iGame3D XT's own help is ..."), and a note that its web links (igame3d.com, igame3d.de, SourceForge, 79 in all) may no longer work. The pages themselves are not edited | AI | the line is there; the owner's 2008 text is unchanged below it | yes |
| D4 | Help menu: "iGame3D XT Help" first, "iGame3D 2008 Help (legacy)" second, "About iGame3D XT" | AI | t37 extended: the three items exist and open their files | yes |
| D5 | The 2008 FAQ pages were exported with a third-party tool and carry its banner ("The Scripter's Scrapbook", FlexibleLearning.com): keep as is, or leave the FAQ out | owner | a yes or no here | no |

### E. The first-run test on a clean PC

| # | Step | Who | How to check | Blocks |
|---|---|---|---|---|
| E1 | Make the release zip from the branch with one command (a small `make_release.py` beside this file: copies the ship list, adds Licences and Credits, writes `version.txt`, zips) | AI | running it twice gives the same file list | yes |
| E2 | A release test (t39) run on the **unzipped zip**, not the projects: file list equals the ship list; no stay-out file; no other people's names; every script compiles; t33-t35 and t37 pointed at the unzipped copy pass | AI | the test passes; its log is kept | yes |
| E3 | The personas on V: (`LIB_PUBLIC/install/escape_sim.py`, people in `LIB_USERS/personas/`). For XT these four matter most: **Dana** (unzips, double-clicks, plays), **Taylor** (runs the exe inside the zip; copies the exe to the Desktop), **Jordan** (school PC, not an admin, read-only folders), **Ana / Kenji** (accented and kanji folder names). Add an "xt" scenario to the simulation so each one unzips the XT zip into their simulated PC and starts it | AI | `ESCAPES_RESULTS.md` has an iGame3D XT row per persona: WORKS, or a plain message telling the player what to do | yes |
| E4 | When started inside the zip or copied out of its folder, the program says "Extract all first" / "make a shortcut instead" (LAYOUT.md design point 5; not built yet) | AI | Taylor's and Jordan's rows say so | yes |
| E5 | The Windows warning (unsigned): see C9 | owner | | |
| E6 | A real clean PC, not the simulation: a Windows machine or a fresh Windows account that has never had the projects, WSL or OXT-Beyond. Download the zip from the itch.io draft page, unzip, run, build a street, save a level, quit, start again, open the level | owner (or a friend) | it works with nobody helping; time from download to a street written down | yes |
| E7 | Long paths and odd places: unzip into a deep Documents folder and onto a USB stick | AI in the simulation (Sam), owner once for real | WORKS in both | no |

### F. The itch.io page

| # | Step | Who | How to check | Blocks |
|---|---|---|---|---|
| F1 | Make the project page under xAction: title "iGame3D XT", kind "Tool", Windows, price | owner | the draft page exists (itch.io keeps it private until published) | yes |
| F2 | The page text: start from section 7. Public wording: xTalk, the HyperCard family; never the old runtime's name or edition | AI drafts, owner edits | the owner has read it aloud once and changed what sounds wrong | yes |
| F3 | Screenshots and a short clip, taken by the owner from the running program (AIs do not open image files): a street of each kind, the Aquarius floor, the showcase, the Inspector, a level file open in a text editor beside the editor | owner | 3 to 5 pictures on the page | yes |
| F4 | Upload the zip, tick Windows, set the version in the file name | owner | downloading from the draft page gives the same zip (same size) | yes |
| F5 | What it is not, said on the page: no particles, shaders or sound yet; mesh editing is partly wired; one Windows build; unsigned | AI drafts, owner approves | the paragraph is on the page | yes |
| F6 | Where to send feedback (itch.io comments by default) | owner | on the page | no |

### G. Version numbering

| # | Step | Who | How to check | Blocks |
|---|---|---|---|---|
| G1 | The scheme: **MAJOR.MINOR.PATCH**. 1.0.0 = the first public iGame3D XT. PATCH = fixes only; MINOR = a new tool or group wired (emitters would be 1.1.0); MAJOR = files made with the old one no longer open. Before release: 1.0.0-rc1, rc2 ... for the builds you test. The other editions keep their own numbers (xRay 1.0.0 is its own first release) | owner says yes | a line here | yes |
| G2 | One place holds the number: `version.txt` beside the script (number, date, the commit it was built from). The About box, the window title, `game.txt` (`engine`/`version` lines), the zip name `iGame3D_XT_1.0.0_win64.zip` and the itch.io upload all read or copy it | AI | change the number once, rebuild: all five places agree (a test compares them) | yes |
| G3 | The installer's own number is still `0.1.0-sim` (`vibeinstall.py`); that is the simulation's, leave it until the Library ships | none | | no |
| G4 | Mark the release in LIB_EDITOR: a tag `iGame3D_XT/1.0.0` on the commit the zip was built from, made by an AI on the owner's word | AI | the tag exists and the zip's `version.txt` names the same commit | no |
| G5 | `CHANGES.txt` in the zip: what is in 1.0.0, what is held for later | AI | in the zip | no |

### H. Release day

| # | Step | Who | How to check | Blocks |
|---|---|---|---|---|
| H1 | "Ship it": remove `Ig3dEditor` from `HOLD` in `LIB_PUBLIC/install/vibeinstall.py`; t27 then expects one more tool in an ordinary install | owner says, AI edits | `vibeinstall.py install` (no extra switch) puts iGame3D XT on V: | yes |
| H2 | Every item of section 1 ticked, with the date | owner | section 1 | yes |
| H3 | Bring the notes up to date: `README.md` here (main is XT; the earlier edition is the tag), `STANDALONE_PLAN.md` marked finished, LIB_SYSTEM STATUS and TODO A-89 | AI | the files say what is true | no |
| H4 | Press Publish on itch.io | owner | the public address opens in a private browser window and the download works | yes |
| H5 | A link to it from the public page (`LIB_PUBLIC/index.html`) | AI, owner approves | the link is there | no |
| H6 | Afterwards: read the first players' comments and their Tell notes if they send any; fixes go out as 1.0.1 | owner + AI | | no |

## 4. Every file that ships, its source and its licence

"Ours" = written by the owner or by AI models working for him. "Generated" = made by our own
code, from names or numbers, when the editor runs or by a tool in `tools/`. Where a right is
only the owner's to state, the cell says so; nobody else fills it in.

| What | Files | Size | Source | Licence / right |
|---|---|---|---|---|
| The editor | `Vibecode3D_Play_Ig3dEditor.livecodescript` | 96 KB | ours (2026), remade from the owner's 2007 main window by structure only | ours; published under the GPL v3 with the build |
| Tools | `Tools/v3d_buildings`, `v3d_props`, `v3d_figures`, `v3d_inspector`, `v3d_models`, `v3d_skins` | 7 scripts, 148 KB with the next row | ours (2026) | ours, GPL v3 |
| Shaped windows | `Tools/window_shape` | | ours (2026); the idea credited to Scott Rossi's WindowLab. Written new around one built-in property, not copied | ours, GPL v3; **owner to confirm the credit line** |
| Buildings, houses | none stored: 51 names, made when asked | 0 | generated (`Tools/v3d_buildings`), sizes from each name | ours |
| Props | none stored: 123 plain names in 17 groups | 0 | generated (`Tools/v3d_props`) | ours |
| Characters | none stored: 14 roles, our stick figure | 0 | generated (`Tools/v3d_figures`) | ours |
| Stick figure for other programs | `Data/Models/stick_figure.gltf` | in Data, 84 KB in all | generated (`tools/stick_gltf.py`) | ours |
| Aquarius character set | `Data/Text/Aquarius.pbm` (16.7 KB) and the same bitmap inside the editor script | | the owner's 2008 converter script (glyphs 1-255), glyph 0 from LIB_BIT's font | **owner to state the origin of the glyph shapes** (step A5) |
| Levels | `Data/Levels/aquarius`, `example_corner`, `showcase`, `streets` (`load_script.xtalk` each) | | ours (2026) | ours, GPL v3 |
| Level commands | `Data/Scripts/LEVEL_API.txt`, `Data/README.txt` | | ours (2026) | ours |
| 2008 Help | `Help_2008/`: 18 files (html and txt; no pictures) | 480 KB | the iGame3D team's 2008 help, brought back from the earlier edition | **owner to state** (step A4) |
| The program | `iGame3D XT.exe` and what the build puts beside it | about 16 MB | built with OXT-Beyond | GPL v3, with the engine's own notice files (step B2) |
| Engine scripts | the three scripts the Library loads to play a title (`vibe_engine_xt3d`, `game_player`, `GameNotes`) | 336 KB | ours | ours, GPL v3 |
| Motion clips | none in XT alone | 0 | | Animazoo and Carnegie Mellon credited if any are added (step A6) |
| Pictures, sounds | none | 0 | | |

Stays out (and where it lives): the 2008 Data folder, 1,394 files (LIB_GAMES commit 5a62a5d,
tag `archive/ig3d-editor-works`); its inventory and survey (`INVENTORY.*`, `_manifest_2008/`);
the motion library (LIB_MOCAP: 41 Animazoo, 19 Carnegie Mellon, 3 iGame3D, 2 ours); the plans
and checklists; the Python tools.

## 5. Things an AI can start on now, without waiting

In this order, each on its own branch of LIB_EDITOR, none of them shipping anything:
C5 (last doors closed) and A3 ("arbiter"); B5 + G2 (About box, version.txt); D3 + D4 (legacy
line, Help menu); E1 + E2 (the zip and its test); C2 (the start-up stack; the build itself, C3
and C4, needs the owner to allow the run in OXT-Beyond); E3 + E4 (the personas). Spark: the
first draft of D2 from the script's header and menus.

## 6. Draft: CREDITS.txt (for the owner to correct)

```
iGame3D XT 1.0.0

Made by xAction.                       [your name here, as you want it written]

iGame3D began in 2002. Its 2008 edition was made by the iGame3D team;
the Help pages under "iGame3D 2008 Help" are theirs, kept as they were.
                                        [names, if you want them listed]

Written in xTalk, the language family that began with HyperCard,
and built with OXT-Beyond. The program is free software under the
GNU General Public License, version 3: see the Licences folder.
Everything in this folder that is ours is plain text you can read and change.

Shaped windows after an idea by Scott Rossi (WindowLab).
Motion capture, where used: Animazoo; the Carnegie Mellon University
Motion Capture Database.               [only if clips ship]

Buildings, props, characters and the Aquarius letters are generated
by the program from their names. No model files were harmed.
Built with AI models as co-workers.     [keep or cut]
```

## 7. Draft: the itch.io page (for the owner to rewrite in his own voice)

**iGame3D XT**
*A 3D game editor that draws in vector lines, written in xTalk, the language of HyperCard.*

iGame3D started in 2002 as a place where all the tools you need are in one window and
everything is a file you can open. iGame3D XT is that idea rebuilt from nothing: a small editor
that makes its whole world from names. Type "warehouse" and get a warehouse, with windows where
a warehouse has them and doors that break. Ask for a street and get four. The whole download is
smaller than a single photograph of the old one.

- **Made from names, not model files.** 51 buildings and houses, 123 props, 14 kinds of
  character, and a 256-character alphabet built from one tiny bitmap you can repaint.
- **Levels are text.** Every level is a short xTalk file. Open it in any text editor, change a
  line, load it again. Hand it to your own AI and ask for a town.
- **Everything is readable.** The editor and its tools are plain scripts in the folder. Read
  them, change them, break them, put them back.
- **Tell it what you think.** Press ` or F2 to leave a note; it is saved as a text file in
  your own Data folder, for you or your AI to read. Nothing is sent anywhere.
- **The 2008 manual is in the box**, kept as it was, for the curious.

What it is not, yet: there are no particles, shaders or sound in 1.0, and some of the mesh
tools in the toolbar only say what they will do. This is the first of four editions; xRay,
Box2DXT and xRayBox follow.

Windows 10 or 11, 64-bit. Unzip the whole folder first ("Extract all"), then run
`iGame3D XT.exe`. Windows may say it protected your PC, because the program is not signed:
choose "More info", then "Run anyway".

Free software under the GNU GPL, version 3. The source is in the folder you download.
