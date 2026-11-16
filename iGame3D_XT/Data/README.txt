iGame3D XT: its own Data folder (16 Nov 2026)

Everything here is ours or generated. The editor needs nothing outside its own folder.

  Text/Aquarius.pbm      the Aquarius character set, one 128 x 128 bitmap (edit it: the models change)
  Models/stick_figure.gltf  our stick figure for other engines (Tools/v3d_figures draws it here)
  Levels/<name>/load_script.xtalk   levels as xTalk files (Scripts/LEVEL_API.txt)
  Scripts/LEVEL_API.txt  the level commands, and the 2008 Lua hooks they stand for

Models are made from their names when they are needed (Tools/v3d_buildings, v3d_props,
v3d_figures), not stored. A full 2008-style Data folder (WTF, Levels, Scripts ...) can still be
used: Library > Set Data Folder...
