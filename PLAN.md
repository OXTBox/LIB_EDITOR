# LIB_EDITOR: the plan (draft 1, 2026-11-14)

The owner's brief (`README.md`): practise the art of editing tools; maybe not one app; form
follows function first. Sources read and then filed away (LIB_LLMOUT/Read/LIB_EDITOR):
Bungie's **Forge** manual (Marathon map editor, 1996), Bungie's **Anvil** manual (shapes, sounds
and physics editor), Core Design's **Tomb Raider Level Editor** manual (TRLE, 2000). Only what
they teach and how they teach it is kept here, in our words.

## 1. How the three manuals teach (the presentation we copy)

- **A tiny vocabulary first.** Forge defines level, map, polygon, line, vertex, platform, draw
  mode, visual mode before anything else. TRLE: blocks, squares and clicks. We do the same:
  cell, design byte, tag, effect, height, map (see 3).
- **Units explained with the player's body.** Forge: a World Unit is about 2 m; corridors 1 WU;
  the player 0.8 WU tall; the highest step 0.2 WU. TRLE: 4 clicks = 1 block; Lara is 3 clicks
  tall. Ours: a cell is 76 units (about 2.5 m), a full wall 58 (height 9), a hero about 52.
- **One map built up tutorial by tutorial.** Forge: two-polygon room, then windows and doors,
  liquids and lights, sounds, switches, objects, network, merging, tricks. TRLE: one room, then
  features, textures, light, doors, slopes, objects, triggers, traps, stacked rooms, water,
  climbing, cameras, the end of the level. Each tutorial saves a map the next one opens.
- **Two views of the same thing.** Forge: 2D draw mode and 3D visual mode. TRLE: plan view,
  editor window and a fly-through preview. Heights shown as colours in 2D (Forge's elevation view;
  TRLE colours rooms red/blue/grey by elevation).
- **Create a type, then paint it.** Forge's lights, liquids and sounds: double-click an empty
  palette square to define one, then click polygons to apply it. That's our tag table + painting.
- **Links, not code.** Forge "tags": a switch and every door, light and liquid listening to the
  same tag change together. TRLE: select an object, select squares, press Trigger; trigger types
  (pad, heavy = set off by anything but the player, antitrigger, switch, key, pickup).
- **The tool checks your work.** Forge refuses concave polygons and zero-length lines and jumps
  to the culprit (Goto); TRLE finds untextured faces and illegal slopes. Limits are published.
- **Safety.** Work on copies (Anvil); autosave on preview, versioned saves a, b, c (TRLE).
- **Design advice beside the tools** (TRLE's designer): no instant death, warn first,
  foreshadow (show the end early), show the structure so players can reason, secrets that are
  places rather than pixel hunts.
- **Separate tools for separate data** (Anvil next to Forge): map editing apart from shapes,
  animation sequences, sounds and physics, with an "Easy Edit" screen of the most-used values.
  This matches the owner's "we may not want to house them all in one app".

## 2. What we have and what we need

| Feature (source) | Ours today | Need |
|---|---|---|
| Grid of squares, raise/lower floor by clicks (TRLE) | cellmap heights 0-35, BitEditor paints them | raise/lower one click with keys (E02) |
| Walls by painting squares (TRLE wall button) | `#` tag, height 9 | - |
| Elevation view in colour (Forge) | heights view in greys | colour ramp (E03) |
| Ceilings, tunnels (TRLE ceiling squares) | `~` tag only | a ceiling layer (E04) |
| Slopes: raise one edge of a square (TRLE arrows) | - | corner heights per cell (E05) |
| Doors and platforms that move (Forge platforms) | `+` open / `D` locked effects | a door that rises when the hero comes (E06) |
| Triggers linked to targets (Forge tags, TRLE pink squares) | effects only, no links | a [links] section: cell -> target, trigger type (E07) |
| Teleporters (Forge polygon type) | `T` effect | pairs of destinations (E08) |
| Liquids with tides (Forge) | `w` `}` tags | level that rises and falls (E09) |
| Item/monster spawning: initial, min, max, appearance % (Forge) | `M` spawner tag | a [spawns] section (E10) |
| Cameras: basic, fixed, target, flyby (TRLE) | game code only | camera squares (E11) |
| Validation with Goto (Forge, TRLE) | round-trip tests only | CellMap.Check: no start, unreachable cells, link without target (E12) |
| 3D preview / walk-through (Forge visual mode, TRLE preview) | Vibe/xt3D tabs say "not yet" | walk a cellmap with Amazing Couple's hero (E13) |
| Stacked rooms / floors above floors (TRLE, Forge basements) | one grid | maps with a base height, stacked (E14) |
| Undo (both) | - | undo stack for painting (E15) |
| Objects with facing and height above floor (Forge object tool) | tag letters | an [objects] section later |
| Lights, ambient per room (both) | - | later: per-cell brightness (wire colours) |
| Sounds: ambient per area, random, objects (Forge) | Sound.Play by type | later: sound tags |
| Terminals / text (Forge terminal scripts) | `?` text tag | later: text per cell |
| Merge levels into one map file (Forge) | one .cellmap a level | later: a map pack |
| Shapes, frames, sequences with views, key and loop frames (Anvil) | glyph font, stick clips, .seq | later: an Anvil-like data tool apart from the map tool |
| Autosave, versioned saves (TRLE) | - | autosave before preview; name_a, name_b |

## 3. Vocabulary (draft)
cell (one square of the grid) · design byte (which glyph builds it) · tag (what it is) · effect
(what it does) · height (how far it is raised, 9 = a full wall) · ceiling (how low the roof
comes, later) · link (a trigger cell pointing at a target) · map (a .cellmap) · map pack (later).

## 4. The examples: one method each, small, testable, and a lesson for the engine
Each is a Vibecode3D game card (runs in the xt3d bench too), reads and writes .cellmap files
through `LIB_BIT/editor/livecode/lib_cellmap`, has a State function and a headless test, and
gets a LIB_HOWTO-style outline (Adding / Result). Only after each works alone does it move into
an editor GUI (BitEditor, or a separate tool where the data is different, like Anvil).

| # | Example | Teaches (engine) | From |
|---|---|---|---|
| E01 | Blocks from a cellmap: every cell with height becomes a box, coloured by its tag | reading data into a scene | TRLE rooms |
| E02 | Raise and lower: a cursor square, arrows move it, Q / A raise or lower one click | editing live, one click at a time | TRLE Q/A keys |
| E03 | Elevation colours: the same map coloured by height | data as colour | Forge elevation view |
| E04 | Ceilings: W / S lower a roof; a `~` tunnel | a second height layer | TRLE ceilings |
| E05 | Slopes: raise one edge of a square | corner heights, sloped meshes | TRLE arrows |
| E06 | A door that rises when the hero is near | effects in play | Forge platforms |
| E07 | A pad that opens a door elsewhere (DONE 18 Nov: `tests/e07_headless.txt`, 13 checks) | links: trigger -> target | Forge tags, TRLE triggers |
| E08 | Teleporter pairs (DONE 18 Nov: `examples/E08_Teleporters`, `tests/e08_headless.txt`, 9 checks; arriving is not entering, so no bounce) | links between cells | Forge teleporter |
| E09 | Water with a tide | animated levels | Forge liquids |
| E10 | A spawner with initial / min / max / % | spawn rules | Forge item parameters |
| E11 | Camera squares | cameras from data | TRLE cameras |
| E12 | The checker: list problems, jump to each | validation | Forge errors, TRLE finders |
| E13 | Walk the map with Amazing Couple's hero (DONE 2026-11-14: a version 2 cellmap as a level, `CellMap.LevelSegments` + `CellMap.Walk`; `tests/e13_test.sh`) | preview | Forge visual mode, TRLE preview |
| E14 | Stacked maps: a room above a room | base heights | TRLE stacked rooms |
| E15 | Undo | an undo stack | both |

## 5. Then the GUIs
- The map tool (BitEditor, grown with E02-E15 as tools) - Forge/TRLE-like.
- A data tool for glyphs, clips and sounds - Anvil-like, separate (owner: maybe not one app).
- Each tool's manual written the way these were: vocabulary, units, tutorials that build one map.

## 5b. Version 2 of the map data (2026-11-14)
`LIB_BIT/editor/CELLMAP_V2.md` settles questions 2 and 3 below: ceilings are a layer (with floor,
red, green, blue: five heights a cell), links and objects are sections, stacked maps have a base.
E04 (ceilings), E07/E08 (links), E14 (stacks) now build on that format; E01/E02 read heights
through `CellMap.Get(map, "heights", col, row)` so they take either version.

## 6. Open questions (with defaults)
1. Examples as Vibecode3D game cards (Play.Edit_E01 ...) installed like the games? Default: yes,
   files in `LIB_EDITOR/examples/`, installed by LIB_TEST's installer later.
2. Ceilings in the same .cellmap as a fourth layer `[ceilings]`? Default: yes.
3. Links as a `[links]` section: `col,row <tab> type <tab> target col,row`? Default: yes.
