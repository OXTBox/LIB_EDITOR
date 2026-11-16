######################################################################################
## CARD SCRIPT: "Play.Ig3dEditor"   iGAME3D MAIN UI, REMADE  (11 13 2026)
## The 2007/2026 iGame3D main window's toolbar (ig3d_UI_MAIN, harvested by XTJSON), remade
## in the Vibecode3D engine: every tool in its old left-to-right order, a Unicode symbol in
## place of each missing PNG icon (chosen from the icon's name), the old tooltip kept.
## Wired now: the primitives, camera, colours, light, play, GL controller (orbit).
## EDITOR TOOLS (Opus 15 Nov 2026, the owner's accepted A-84 / A-86 / A-87):
##   Window > Inspector          one page per object kind; Animation = BVH clip preview + In/Out
##                               clipper + the game's Animation List (LIB_ig3d/livecode/v3d_inspector)
##   Edit > Replace With Model... a game's placeholder meshes -> models, saved as a Skin
##                               (LIB_ig3d/livecode/v3d_skins; the Game Player plays it)
##   Library > Models            click: load at the centre; DRAG a name onto the 3D view: it lands
##                               on the floor where you let go (a preview follows the mouse)
## Every other tool says what it did in iGame3D (a list to judge: keep / adapt / junk).
## CONTROLS  click a tool    hover: the old tooltip    W A S D / arrows: move the camera
## AQUARIUS (iGame3D XT, workstream B, 16 Nov 2026): Library > Text lists the 256 Aquarius
##   characters; the first line lays all 256 on the floor, made from ONE bitmap
##   (Data/Text/Aquarius.pbm beside this script, else the copy built in below), timed.
## BUILDINGS (workstream A, 16 Nov 2026): with no 2008 Data folder, Library > Models lists
##   buildings made from their names (Tools/v3d_buildings); its first line builds a street of each
##   kind (warehouse, shop, home, military). Their doors and windows break as uDead's do:
##   Edit > boom breaks the selected building's, a second boom flattens it; boom all, all of them.
## PROPS, CHARACTERS, LEVELS (workstreams A, C, D, F; 16 Nov 2026): Library > Models also lists
##   123 props in 17 groups (Tools/v3d_props) and 14 characters (Tools/v3d_figures, our stick
##   figure by role), and a showcase of every one. Levels are xTalk files anyone can edit:
##   Data/Levels/<name>/load_script.xtalk, lines of Lvl.Camera / Lvl.Object / Lvl.Aquarius ...
##   (the 2008 Lua hooks, in xTalk; Data/Scripts/LEVEL_API.txt); Library > Levels opens one,
##   File > Save writes the scene to one. Library > Set Data Folder... points the editor at a full
##   2008-style Data folder; without one it needs nothing outside its own folder.
## NEEDS     nothing outside the engine. Map: LIB_ig3d/MAIN_UI_REUSE.md, TOOLBAR_MAP below.
######################################################################################

global gObjectTransforms, gSceneObjects
global gCameraYaw, gCameraPitch
global bPaused, bPlaying

local sLib, sLibRoot, sLibList, sMade, sSelected, sColorN, sOrbit, sTicks, sCamX, sCamY, sCamZ, sMsgUntil, sLight
local sAqua          -- the Aquarius bitmap and models: ["bits"], ["from"], ["keys"], the timings
local sBld, sBldN, sBldOf   -- buildings: sBld[n] name/shell/parts; sBldOf[shell key] = n
local sLayout         -- where things are: ["dock"] top/bottom/left/right, ["collapsed"], ["tab"], ["fps"], the free area
local sObj, sLevel, sDataFolder, sTestPrefs   -- what each made thing is (for File > Save), the level, the chosen Data folder

-- TOOLBAR_MAP: name | Unicode code point | 2007 icon | group | tooltip (iGame3D)
constant kTools = "level|2699|console.png|editing mode|Level settings;snapshot|25D9|snapshot.png|camera tools|Snapshot of the 3D view;colors|25D0|colorball16x16.png|camera tools|Colours;light|2600|lights.png|light|Position lights;objects|263A|32x32zombie3.png|actors and effects|Access view settings (actors);particles|2733|particlesicon24x24.png|actors and effects|Particles;camera|25CE|meshView.png|camera tools|Camera / mesh view;GLController|2725|repositiontoolnew2.png|camera tools|Show/hide the GL controller;pathselect|21E2|pathSelectIcon.png|mesh tools|Path selection;path|270E|pathToolIcon.png|mesh tools|Path editing;select_mesh|25A6|tool6.png|vertex tools|Mesh editing;vertex|2022|tool2.png|vertex tools|Create vertex;line|2571|tool3.png|vertex tools|Connect vertices;disconnect|2702|tool5.png|vertex tools|Disconnect mesh line;split|22D4|tool4.png|vertex tools|Split mesh line;quad|25AD|22x22quadtool.png|primitives|Quad;cube|25A3|cube.png|primitives|Cube;dropMesh|2913|dropMeshicon.png|primitives|Drop mesh;Terrain|25B2|quad.png|primitives|Import image to terrain;Play_Game|25B6|playGameButton.png|editing mode|Play (Escape exits);sounds|266A|soundicon22x22.png|actors and effects|Sounds;cylinder|232D|cylinder.png|primitives|Cylinder;cone|25B3|cone.png|primitives|Cone;sphere|25CF|sphere.png|primitives|Sphere;WindowPickPop|2750|windows.png|windows|Open windows;bones|27DF|bone.png|mesh tools|Bones"

constant kMenus = "File=New Level/N;Open Level.../O;Save Level/S;-;Clear Level;-;Mesh;~Save In Level;~Export;~Clear;-;Close Window/W#Edit=Undo/Z;-;(Cut/X;(Copy/C;(Paste/V;(Select All/A;-;Replace With Model...;-;Boom;Boom All#View=Toolbar At Top;Toolbar At Bottom;Toolbar At Left;Toolbar At Right;-;Hide Tools;Show Tools;-;Frame Rate;~15 fps;~30 fps;~60 fps;-;Show Library;Hide Library#Library=Models;Levels;Text;-;Emitters;Images;Materials;Scripts;Sounds;-;Set Data Folder...#Mesh=Focus Mesh/0;Goto Points;Tag Vertices/T;Duplicate Vertices/D;Extrude/E;Select;~All Vertices;~Connected/g;~Invert/i;~Attached To Bone;Face;~Face In/[;~Face Out/];~Invert Faces/*;View;~Hide/h;~Hide Other/f;~Hide All;~Show All/u;Mirror;~X;~Y;~Z;~Double Side;-;Combine Overlaps;Subdivide;-;Delete Vertices#Dev=SAVE;-;Edit F1Script;Edit SGScript;Edit RLScript;StackScript;-;Xternals;-;stopIdle;-;pointer tool/m;-;FindT3D/3;-;scriptHarvester;OpenStacks;CustomPropLengths;RevFunctions;Harvest;-;resetiGame3D;BackUp#Window=Window Snapping;Mode;~Level;~Model;-;Animation Editor;Console;ig3dWTFEDITOR;Inspector;Level Collect;Library;Scene Graph;Snapshot#Help=iGame3D Help/?;Referencer;Script Commands"
constant kInk = "#7CFF7C"

on Game.OnStart
   local tKeep
   focus on nothing          -- arrow keys belong to the game, never to a menu or a field
   Ig.Wake
   Engine.ResetCamera
   Scene.ClearAll
   Particles.Clear
   HUD.Clear
   Collision.ClearRules
   put 0 into sTicks
   put 0 into sColorN
   put false into sOrbit
   put empty into sMade
   put empty into sSelected
   put 0 into sCamX
   put -160 into sCamY
   put -520 into sCamZ
   Ig.Camera
   Mesh.Define "Ig.Floor", MeshGrid(16, 16, 50)
   get Entity.Spawn("Ig.Floor", 0, 0, 0, "#0A280A")
   -- the axes: x red, z blue, up green
   Mesh.Define "Ig.Axes", Ig.AxesMesh()
   get Entity.Spawn("Ig.Axes", 0, -0.5, 0, "#FF5050")
   put sObj["testdata"] into tKeep
   put empty into sObj
   put tKeep into sObj["testdata"]
   if sLevel is empty then put "my_level" into sLevel
   Ig.LoadLayout
   Ig.BuildToolbar
   Ig.BuildMenus
   Ig.Say "iGAME3D MAIN UI, REMADE.  CLICK A TOOL.  HOVER FOR THE OLD TOOLTIP."
end Game.OnStart

on Ig.Camera
   Engine.SetCam -sCamX, -sCamY, -sCamZ
   put atan2(-sCamX, -sCamZ) into gCameraYaw
   put -atan2(-sCamY, sqrt(sCamX ^ 2 + sCamZ ^ 2)) into gCameraPitch
end Ig.Camera

-------------------------------------------------------------------- the toolbar

-- real buttons in a card-sized group "Ig3dTools"; Ig.Layout puts them along one side
on Ig.BuildToolbar
   local tTool, n, x, tName, tGroup
   lock screen
   if there is not a group "Ig3dTools" of this card then
      reset the templateGroup
      create group "Ig3dTools"
      set the lockLoc of group "Ig3dTools" to true
      set the rect of group "Ig3dTools" to the rect of this card
      -- the menu bar's strip first, so it lies under everything else in the group
      reset the templateGraphic
      create graphic "Ig3dMenuBar" in group "Ig3dTools"
   end if
   set the visible of group "Ig3dTools" to true
   put the short id of group "Ig3dTools" into tGroup
   set the itemDel to "|"
   put 0 into n
   repeat for each item tTool in Ig.ToolList()
      add 1 to n
   end repeat
   put 6 into x
   put 0 into n
   repeat for each line tTool in Ig.ToolList()
      add 1 to n
      put item 1 of tTool into tName
      if there is not a button tName of group id tGroup then
         reset the templateButton
         create button tName in group id tGroup
      end if
      set the label of button tName of group id tGroup to numToCodepoint(baseConvert(item 2 of tTool, 16, 10))
      set the textSize of button tName of group id tGroup to 17
      set the textColor of button tName of group id tGroup to Ig.GroupColor(item 4 of tTool)
      set the backgroundColor of button tName of group id tGroup to "#061006"
      set the borderColor of button tName of group id tGroup to "#1C4A2A"
      set the showBorder of button tName of group id tGroup to true
      set the opaque of button tName of group id tGroup to true
      set the toolTip of button tName of group id tGroup to item 5 of tTool & cr & "(iGame3D 2007: " & item 3 of tTool & ", " & item 4 of tTool & ")"
      set the script of button tName of group id tGroup to "on mouseUp" & cr & "   Ig.Tool the short name of me" & cr & "end mouseUp" & cr & \
            "on mouseEnter" & cr & "   Ig.Hover the short name of me" & cr & "end mouseEnter"
   end repeat
   set the itemDel to comma
   Ig.Layout
   unlock screen
end Ig.BuildToolbar

-- the menu bar, Macintosh order: File Edit View Library Mesh Dev Window Help; items as in
-- iGame3D (kMenus: menus split by #, items by ;, ~ = a submenu item, /X = its shortcut letter,
-- ( = not working yet, so dimmed; ... = it opens a window). The View menu ticks what is on.
on Ig.BuildMenus
   local tMenu, tName, tText, tGroup, x
   put the short id of group "Ig3dTools" into tGroup
   put 6 into x
   set the itemDel to "#"
   repeat for each item tMenu in kMenus
      put char 1 to offset("=", tMenu) - 1 of tMenu into tName
      put char offset("=", tMenu) + 1 to -1 of tMenu into tText
      replace ";" with cr in tText
      replace "~" with tab in tText
      if tName is "View" then put Ig.TickView(tText) into tText
      if there is not a button ("menu_" & tName) of group id tGroup then
         reset the templateButton
         create button ("menu_" & tName) in group id tGroup
      end if
      set the style of button ("menu_" & tName) of group id tGroup to "menu"
      set the menuMode of button ("menu_" & tName) of group id tGroup to "pulldown"
      set the label of button ("menu_" & tName) of group id tGroup to tName
      set the text of button ("menu_" & tName) of group id tGroup to tText
      set the textColor of button ("menu_" & tName) of group id tGroup to kInk
      set the showBorder of button ("menu_" & tName) of group id tGroup to false
      set the opaque of button ("menu_" & tName) of group id tGroup to false
      set the traversalOn of button ("menu_" & tName) of group id tGroup to false
      set the textSize of button ("menu_" & tName) of group id tGroup to 12
      set the script of button ("menu_" & tName) of group id tGroup to "on menuPick pItem" & cr & "   Ig.Menu the label of me, pItem" & cr & "end menuPick"
   end repeat
   set the itemDel to comma
   Ig.Layout
end Ig.BuildMenus

-- the menu titles in order
function Ig.MenuNames
   local tMenu, tOut
   set the itemDel to "#"
   repeat for each item tMenu in kMenus
      put char 1 to offset("=", tMenu) - 1 of tMenu & cr after tOut
   end repeat
   set the itemDel to comma
   delete the last char of tOut
   return tOut
end Ig.MenuNames

-- the View menu with a tick (!c) on the toolbar's side and the frame rate
function Ig.TickView pText
   local tOut, tLine, tBare
   repeat for each line tLine in pText
      put tLine into tBare
      replace tab with empty in tBare
      if tBare is ("Toolbar At" && sLayout["dock"]) or tBare is (sLayout["fps"] && "fps") then
         if char 1 of tLine is tab then
            put tab & "!c" & char 2 to -1 of tLine into tLine
         else
            put "!c" & tLine into tLine
         end if
      end if
      put tLine & cr after tOut
   end repeat
   delete the last char of tOut
   return tOut
end Ig.TickView

-------------------------------------------------------------------- the layout (owner 16 Nov)
-- The menu bar is the top row, as on a Macintosh. The tool buttons sit along one side (View >
-- Toolbar At Top, Bottom, Left or Right), after a ]< button that snaps them away; it becomes ]>,
-- which brings them back, and which can be dragged where you like it. The Library is on the
-- right of what is left. Kept in the settings folder: Vibecode3D/igame3d_xt_layout.txt.

constant kBarH = 20
constant kTool = 28

function Ig.LayoutFile
   return specialFolderPath("support") & "/Vibecode3D/igame3d_xt_layout.txt"
end Ig.LayoutFile

on Ig.LoadLayout
   local tLine, tText
   put empty into sLayout
   if sTestPrefs is empty and there is a file Ig.LayoutFile() then
      put textDecode(URL ("binfile:" & Ig.LayoutFile()), "UTF-8") into tText
      set the itemDelimiter to tab
      repeat for each line tLine in tText
         if item 1 of tLine is not empty then put item 2 of tLine into sLayout[item 1 of tLine]
      end repeat
      set the itemDelimiter to comma
   end if
   if sLayout["dock"] is not among the items of "top,bottom,left,right" then put "top" into sLayout["dock"]
   if sLayout["collapsed"] is not true then put false into sLayout["collapsed"]
   if sLayout["fps"] is not among the items of "15,30,60" then put 30 into sLayout["fps"]
   Ig.SetFPS sLayout["fps"]
end Ig.LoadLayout

on Ig.SaveLayout
   local tDir, tOut, tKey, tErr
   if sTestPrefs is not empty then exit Ig.SaveLayout
   repeat for each item tKey in "dock,collapsed,tab,fps"
      put tKey & tab & sLayout[tKey] & cr after tOut
   end repeat
   put specialFolderPath("support") & "/Vibecode3D" into tDir
   try
      if there is not a folder tDir then create folder tDir
      put textEncode(tOut, "UTF-8") into URL ("binfile:" & Ig.LayoutFile())
   catch tErr
   end try
end Ig.SaveLayout

-- the frame rate while anything moves (the player's gV3DTickMS); at rest nothing is drawn
on Ig.SetFPS pFPS
   global gV3DTickMS
   if pFPS is not among the items of "15,30,60" then put 30 into pFPS
   put pFPS into sLayout["fps"]
   put round(1000 / pFPS) into gV3DTickMS
end Ig.SetFPS

-- View > Toolbar At ...: the tools along that side, shown
on Ig.SetDock pSide
   if pSide is not among the items of "top,bottom,left,right" then exit Ig.SetDock
   put pSide into sLayout["dock"]
   put false into sLayout["collapsed"]
   Ig.SaveLayout
   Ig.BuildMenus
   Ig.Say "THE TOOLS ARE ALONG THE" && toUpper(pSide) && "(VIEW > TOOLBAR AT ...)"
end Ig.SetDock

-- everything in its place: the menu bar, the tools, the free area (sLayout pLeft, pTop,
-- pRight, pBottom) where the Library and the messages go
on Ig.Layout
   local tG, tW, tH, x, y, tName, tB, tTools, tN, k, tPer, tRows, tTop, tBottom, tLeft, tRight, tAt
   if there is not a group "Ig3dTools" then exit Ig.Layout
   put the short id of group "Ig3dTools" into tG
   put the width of this card into tW
   put the height of this card into tH
   lock screen
   set the rect of group id tG to the rect of this card
   -- the menu bar: a strip across the top, the titles on it
   if there is not a graphic "Ig3dMenuBar" of group id tG then
      reset the templateGraphic
      create graphic "Ig3dMenuBar" in group id tG
   end if
   if the style of graphic "Ig3dMenuBar" of group id tG is not "rectangle" then
      set the style of graphic "Ig3dMenuBar" of group id tG to "rectangle"
      set the opaque of graphic "Ig3dMenuBar" of group id tG to true
      set the backgroundColor of graphic "Ig3dMenuBar" of group id tG to "#0A1A0E"
      set the foregroundColor of graphic "Ig3dMenuBar" of group id tG to "#1C4A2A"
   end if
   set the rect of graphic "Ig3dMenuBar" of group id tG to -1, -1, tW + 1, kBarH
   put 8 into x
   repeat for each line tName in Ig.MenuNames()
      put "menu_" & tName into tB
      if there is not a button tB of group id tG then next repeat
      put max(the formattedWidth of button tB of group id tG, the number of chars of tName * 7 + 14) into k
      set the rect of button tB of group id tG to x, 1, x + k, kBarH - 1
      add k + 2 to x
   end repeat
   -- the tools: ]< (or ]>) first, then the buttons, in rows or columns along one side
   if there is not a button "Ig3dToolsTab" of group id tG then
      reset the templateButton
      create button "Ig3dToolsTab" in group id tG
      set the textSize of button "Ig3dToolsTab" of group id tG to 12
      set the textStyle of button "Ig3dToolsTab" of group id tG to "bold"
      set the textColor of button "Ig3dToolsTab" of group id tG to kInk
      set the backgroundColor of button "Ig3dToolsTab" of group id tG to "#0A1A0E"
      set the borderColor of button "Ig3dToolsTab" of group id tG to "#1C4A2A"
      set the opaque of button "Ig3dToolsTab" of group id tG to true
      set the traversalOn of button "Ig3dToolsTab" of group id tG to false
      set the script of button "Ig3dToolsTab" of group id tG to "on mouseDown" & cr & "   Ig.TabDown" & cr & "end mouseDown"
   end if
   put kBarH + 2 into tTop
   put tH - 26 into tBottom
   put 2 into tLeft
   put tW - 2 into tRight
   put tLeft into sLayout["pLeft"]
   put tTop into sLayout["pTop"]
   put tRight - 8 into sLayout["pRight"]
   put tBottom - 4 into sLayout["pBottom"]
   put empty into tTools
   set the itemDel to "|"
   repeat for each line tName in Ig.ToolList()
      if there is a button (item 1 of tName) of group id tG then put item 1 of tName & cr after tTools
   end repeat
   set the itemDel to comma
   put the number of lines of tTools into tN
   if sLayout["collapsed"] then
      repeat for each line tName in tTools
         set the visible of button tName of group id tG to false
      end repeat
      set the label of button "Ig3dToolsTab" of group id tG to "]>"
      set the toolTip of button "Ig3dToolsTab" of group id tG to "Bring the tools back (drag me to move me)"
      put sLayout["tab"] into tAt
      if not (tAt is a point and item 1 of tAt >= 0 and item 1 of tAt <= tW - 24 and item 2 of tAt >= kBarH and item 2 of tAt <= tH - kTool) then
         switch sLayout["dock"]
            case "bottom"
               put tLeft & comma & (tBottom - kTool) into tAt
               break
            case "right"
               put (tRight - 24) & comma & tTop into tAt
               break
            default
               put tLeft & comma & tTop into tAt
         end switch
      end if
      set the rect of button "Ig3dToolsTab" of group id tG to item 1 of tAt, item 2 of tAt, item 1 of tAt + 24, item 2 of tAt + kTool - 1
   else
      set the label of button "Ig3dToolsTab" of group id tG to "]<"
      set the toolTip of button "Ig3dToolsTab" of group id tG to "Snap the tools away"
      if sLayout["dock"] is "top" or sLayout["dock"] is "bottom" then
         put max(1, (tRight - tLeft) div kTool) into tPer
      else
         put max(1, (tBottom - tTop) div kTool) into tPer
      end if
      put (tN + tPer) div tPer into tRows
      repeat with k = 0 to tN
         switch sLayout["dock"]
            case "top"
               put tLeft + (k mod tPer) * kTool into x
               put tTop + (k div tPer) * kTool into y
               break
            case "bottom"
               put tLeft + (k mod tPer) * kTool into x
               put tBottom - (k div tPer + 1) * kTool into y
               break
            case "left"
               put tLeft + (k div tPer) * kTool into x
               put tTop + (k mod tPer) * kTool into y
               break
            case "right"
               put tRight - (k div tPer + 1) * kTool into x
               put tTop + (k mod tPer) * kTool into y
               break
         end switch
         if k is 0 then
            set the rect of button "Ig3dToolsTab" of group id tG to x, y, x + kTool - 1, y + kTool - 1
         else
            set the rect of button (line k of tTools) of group id tG to x, y, x + kTool - 1, y + kTool - 1
            set the visible of button (line k of tTools) of group id tG to true
         end if
      end repeat
      switch sLayout["dock"]
         case "top"
            put tTop + tRows * kTool + 4 into sLayout["pTop"]
            break
         case "bottom"
            put tBottom - tRows * kTool - 4 into sLayout["pBottom"]
            break
         case "left"
            put tLeft + tRows * kTool + 4 into sLayout["pLeft"]
            break
         case "right"
            put tRight - tRows * kTool - 8 into sLayout["pRight"]
            break
      end switch
   end if
   set the visible of button "Ig3dToolsTab" of group id tG to true
   put sLayout["pLeft"] + 8 into sLayout["msgX"]
   put sLayout["pBottom"] - 18 into sLayout["msgY"]
   Ig.PlaceLibrary
   unlock screen
end Ig.Layout

-- ]< / ]>: a click snaps the tools away or brings them back; ]> can be dragged anywhere
on Ig.TabDown
   local tG, tStart, tMoved, tOffX, tOffY, tX, tY
   put the short id of group "Ig3dTools" into tG
   put the mouseLoc into tStart
   put item 1 of tStart - the left of button "Ig3dToolsTab" of group id tG into tOffX
   put item 2 of tStart - the top of button "Ig3dToolsTab" of group id tG into tOffY
   put false into tMoved
   repeat while the mouse is down
      if not tMoved and sLayout["collapsed"] and abs(item 1 of the mouseLoc - item 1 of tStart) + abs(item 2 of the mouseLoc - item 2 of tStart) > 4 then put true into tMoved
      if tMoved then
         put max(0, min(the width of this card - 24, item 1 of the mouseLoc - tOffX)) into tX
         put max(kBarH, min(the height of this card - kTool, item 2 of the mouseLoc - tOffY)) into tY
         set the topLeft of button "Ig3dToolsTab" of group id tG to tX, tY
      end if
      wait 10 milliseconds with messages
   end repeat
   Ig.Wake
   if tMoved then
      put the topLeft of button "Ig3dToolsTab" of group id tG into sLayout["tab"]
      Ig.SaveLayout
      exit Ig.TabDown
   end if
   put not sLayout["collapsed"] into sLayout["collapsed"]
   Ig.SaveLayout
   Ig.Layout
end Ig.TabDown

on Ig.Menu pMenu, pItem
   Ig.Wake
   local tKey
   if char -2 of pItem is "/" then delete char -2 to -1 of pItem      -- "Focus Mesh/0": the shortcut letter
   set the itemDel to "|"
   put pMenu & "/" & item -1 of pItem into tKey
   set the itemDel to comma
   switch tKey
      case "File/New Level"
      case "File/Clear Level"
      case "File/New"
      case "File/Reset"
      case "File/Clear"
         repeat for each line tKey in sMade
            Ig.Kill tKey
         end repeat
         put empty into sMade
         put empty into sSelected
         Ig.Say "LEVEL CLEARED"
         break
      case "Edit/Undo"
         if sMade is not empty then
            Ig.Kill line -1 of sMade
            delete line -1 of sMade
            put line -1 of sMade into sSelected
            Ig.Say "UNDONE"
         end if
         break
      case "Edit/boom"
         -- a building: its doors and windows break first; boom again flattens it
         if sSelected is not empty and sBldOf[sSelected] is not empty then
            if Ig.BreakBuilding(sBldOf[sSelected]) > 0 then break
         end if
         if sSelected is not empty then
            FX.Sparks GetObjectPosition(sSelected, "x"), GetObjectPosition(sSelected, "y"), GetObjectPosition(sSelected, "z"), 30, "#FFB000"
            Ig.Menu "Edit", "Undo"
            Ig.Say "BOOM"
         end if
         break
      case "Edit/boom all"
         if Ig.BreakAll() > 0 then break
         repeat for each line tKey in sMade
            FX.Sparks GetObjectPosition(tKey, "x"), GetObjectPosition(tKey, "y"), GetObjectPosition(tKey, "z"), 20, "#FFB000"
            Ig.Kill tKey
         end repeat
         put empty into sMade
         put empty into sSelected
         Ig.Say "BOOM ALL"
         break
      case "Library/Models"
      case "Library/Levels"
      case "Library/Emitters"
      case "Library/Scripts"
      case "Library/Images"
      case "Library/Sounds"
      case "Library/Materials"
      case "Library/Text"
         Ig.Library char offset("/", tKey) + 1 to -1 of tKey
         break
      case "Library/Set Data Folder..."
         answer folder "A full iGame3D Data folder (the one holding WTF, Levels, Scripts...):"
         if it is not empty then
            Ig.SetDataFolder it
            Ig.Say "DATA FOLDER:" && toUpper(it) && (there is a folder (it & "/WTF")) && "(LIBRARY > MODELS USES IT)"
         end if
         break
      case "File/Save Level"
      case "File/Save"
         Ig.SaveLevel sLevel
         break
      case "Help/iGame3D Help"
         Ig.Help
         break
      case "Window/Inspector"
         Ig.OpenTool "V3D_Inspector", "v3d_inspector.livecodescript", "Insp.Build"
         break
      case "File/Open Level..."
         Ig.LevelLibrary
         break
      case "File/Close Window"
         send "Player.Quit" to this stack in 10 milliseconds
         break
      case "View/Toolbar At Top"
      case "View/Toolbar At Bottom"
      case "View/Toolbar At Left"
      case "View/Toolbar At Right"
         Ig.SetDock word -1 of pItem
         break
      case "View/Hide Tools"
      case "View/Show Tools"
         put (pItem is "Hide Tools") into sLayout["collapsed"]
         Ig.SaveLayout
         Ig.Layout
         break
      case "View/15 fps"
      case "View/30 fps"
      case "View/60 fps"
         put char 6 to -1 of tKey into tKey
         Ig.SetFPS word 1 of tKey
         Ig.SaveLayout
         Ig.BuildMenus
         Ig.Say "FRAME RATE:" && sLayout["fps"] && "A SECOND WHILE ANYTHING MOVES (AT REST NOTHING IS DRAWN)"
         break
      case "View/Show Library"
      case "Window/Library"
         Ig.Library "Models"
         break
      case "View/Hide Library"
         Ig.CloseLibrary
         break
      case "Edit/Replace With Model..."
         -- the models it offers first are made from their names
         Ig.UseTool "v3d_buildings"
         Ig.UseTool "v3d_props"
         Ig.UseTool "v3d_figures"
         Ig.OpenTool "V3D_Skins", "v3d_skins.livecodescript", "Skins.Build"
         break
      case "Mesh/Focus Mesh"
         if sSelected is not empty then
            put GetObjectPosition(sSelected, "x") into sCamX
            put GetObjectPosition(sSelected, "z") - 260 into sCamZ
            put -120 into sCamY
            put false into sOrbit
            Ig.Say "FOCUSED ON THE LAST OBJECT"
         end if
         break
      default
         Ig.Say "NOT WIRED YET:" && toUpper(pMenu) && ">" && toUpper(pItem) && "(AN iGAME3D MENU ITEM)"
   end switch
end Ig.Menu

-------------------------------------------------------------------- the library (filesLibrary, remade)

-- the 2008 iGame3D Data folder (LIB_GAMES/igame3D_2008_Texts), found above this stack or in WSL
function Ig.DataRoot
   -- a full 2008-style Data folder, only when one is chosen (Library > Set Data Folder...);
   -- this edition's own things are in Ig.XTData()
   local tF
   if sLibRoot is not empty then return sLibRoot
   put Ig.ChosenFolder() into tF
   if tF is not empty and there is a folder (tF & "/WTF") then put tF into sLibRoot
   return sLibRoot
end Ig.DataRoot

-- the chosen Data folder, remembered in the settings folder (Vibecode3D/igame3d_xt.txt)
function Ig.ChosenFolder
   local tF
   if sTestPrefs is not empty then return sDataFolder
   put specialFolderPath("support") & "/Vibecode3D/igame3d_xt.txt" into tF
   if there is not a file tF then return empty
   return line 1 of textDecode(URL ("binfile:" & tF), "UTF-8")
end Ig.ChosenFolder

on Ig.SetDataFolder pFolder
   local tDir
   replace "\" with "/" in pFolder
   put pFolder into sDataFolder
   put empty into sLibRoot
   if sTestPrefs is not empty then exit Ig.SetDataFolder
   put specialFolderPath("support") & "/Vibecode3D" into tDir
   if there is not a folder tDir then create folder tDir
   put textEncode(pFolder, "UTF-8") into URL ("binfile:" & tDir & "/igame3d_xt.txt")
end Ig.SetDataFolder

-- test hook: use pFolder as this edition's Data folder (levels are saved there)
on Ig.TestXTData pFolder
   put pFolder into sObj["testdata"]
end Ig.TestXTData

-- test hook: keep the chosen folder in this session only
on Ig.TestPrefs pFlag
   put pFlag into sTestPrefs
end Ig.TestPrefs

-- this edition's own Data folder: Data/ beside the script, else LIB_EDITOR/iGame3D_XT/Data above
function Ig.XTData
   local tDir, tErr, tPath
   if sObj["testdata"] is not empty then return sObj["testdata"]
   set the itemDelimiter to "/"
   put empty into tDir
   try
      put the uScriptFile of (the long owner of me) into tDir
   catch tErr
      put empty into tDir
   end try
   replace "\" with "/" in tDir
   if tDir contains "/" and there is a folder (item 1 to -2 of tDir & "/Data") then return item 1 to -2 of tDir & "/Data"
   put the effective filename of this stack into tPath
   replace "\" with "/" in tPath
   repeat 8 times
      delete item -1 of tPath
      if tPath is empty then exit repeat
      if there is a folder (tPath & "/LIB_EDITOR/iGame3D_XT/Data") then return tPath & "/LIB_EDITOR/iGame3D_XT/Data"
   end repeat
   return empty
end Ig.XTData

-- Library > Models / Levels / Emitters / Scripts: the files in a list on the right
on Ig.Library pWhat
   local tRoot, tFolder, tSuffix, tList, tGroup
   if pWhat is "Text" then
      -- the Aquarius characters: made here from one bitmap, no 2008 data needed
      put Ig.AquaList() into sLibList
      put false into sLib["browse"]
      Ig.ShowLibrary
      put "Aqua" into sLib["folder"]
      Ig.Say "LIBRARY > TEXT: THE 256 AQUARIUS CHARACTERS (" & toUpper(sAqua["from"]) & ").  CLICK ONE, OR THE FIRST LINE FOR ALL 256"
      exit Ig.Library
   end if
   put Ig.DataRoot() into tRoot
   if tRoot is empty and pWhat is "Levels" then
      Ig.LevelLibrary
      exit Ig.Library
   end if
   if tRoot is empty and pWhat is "Models" then
      -- no 2008 Data folder: the models are made from their names
      Ig.GenLibrary
      exit Ig.Library
   end if
   if tRoot is empty then
      Ig.Say "LIBRARY >" && toUpper(pWhat) & ": NOT IN THIS EDITION YET (NO 2008 DATA FOLDER)"
      exit Ig.Library
   end if
   switch pWhat
      case "Models"
         put "WTF" into tFolder
         put ".wtf" into tSuffix
         break
      case "Levels"
         put "Levels" into tFolder
         put ".txt,.lua" into tSuffix
         break
      case "Emitters"
         put "Emitters" into tFolder
         put ".emt" into tSuffix
         break
      case "Scripts"
         put "Scripts" into tFolder
         put ".lua" into tSuffix
         break
      default
         Ig.Say "LIBRARY >" && toUpper(pWhat) & ": NOT IN THE 2008 DATA (IMAGES AND SOUNDS ARE LEFT OUT)"
         exit Ig.Library
   end switch
   put Ig.ListFiles(tRoot & "/" & tFolder, empty, tSuffix) into sLib["all"]
   put empty into sLib["path"]
   put true into sLib["browse"]
   put tFolder into sLib["folder"]
   Ig.ShowLibrary
   Ig.Say "LIBRARY >" && toUpper(pWhat) & ":" && the number of lines of sLib["all"] && "FILES IN FOLDERS.  DOUBLE-CLICK A FOLDER (OR RETURN); CLICK A FILE (A MODEL LOADS AS A WIREFRAME)"
end Ig.Library

-- the Library on the right: a preview of the chosen entry over a short list, an X above.
-- In the list a click chooses (the preview shows it), a double-click or Return / Enter opens a
-- folder or places the model where the mouse last was in the 3D view; dragging the preview
-- into the view places it where it is let go.
on Ig.ShowLibrary
   local tGroup, tN
   put the short id of group "Ig3dTools" into tGroup
   if there is not a field "Ig3dLibrary" of group id tGroup then
      reset the templateField
      create field "Ig3dLibrary" in group id tGroup
      set the listBehavior of field "Ig3dLibrary" of group id tGroup to true
      set the lockText of field "Ig3dLibrary" of group id tGroup to true
      set the vScrollbar of field "Ig3dLibrary" of group id tGroup to true
      set the textSize of field "Ig3dLibrary" of group id tGroup to 11
      set the backgroundColor of field "Ig3dLibrary" of group id tGroup to "#061006"
      set the textColor of field "Ig3dLibrary" of group id tGroup to kInk
   end if
   set the traversalOn of field "Ig3dLibrary" of group id tGroup to true
   set the script of field "Ig3dLibrary" of group id tGroup to "on mouseUp" & cr & "   Ig.LibrarySelect the hilitedLine of me" & cr & "end mouseUp" & cr & \
         "on mouseDoubleUp" & cr & "   Ig.LibraryOpen the hilitedLine of me" & cr & "end mouseDoubleUp" & cr & \
         "on rawKeyDown pKey" & cr & "   if pKey is 65293 or pKey is 65421 then Ig.LibraryOpen the hilitedLine of me" & cr & "end rawKeyDown"
   -- the preview: a box, and the model's wire in it; pressing on it drags the model out
   repeat for each item tN in "Ig3dPreview,Ig3dPreviewWire"
      if there is not a graphic tN of group id tGroup then
         reset the templateGraphic
         create graphic tN in group id tGroup
         set the script of graphic tN of group id tGroup to "on mouseDown" & cr & "   Ig.PreviewDrag" & cr & "end mouseDown"
      end if
   end repeat
   set the style of graphic "Ig3dPreview" of group id tGroup to "rectangle"
   set the opaque of graphic "Ig3dPreview" of group id tGroup to true
   set the backgroundColor of graphic "Ig3dPreview" of group id tGroup to "#061006"
   set the foregroundColor of graphic "Ig3dPreview" of group id tGroup to "#1C4A2A"
   set the toolTip of graphic "Ig3dPreview" of group id tGroup to "Drag the model into the 3D view"
   set the style of graphic "Ig3dPreviewWire" of group id tGroup to "line"
   set the foregroundColor of graphic "Ig3dPreviewWire" of group id tGroup to kInk
   -- a little X above the preview's top right corner closes the Library
   if there is not a button "Ig3dLibraryClose" of group id tGroup then
      reset the templateButton
      create button "Ig3dLibraryClose" in group id tGroup
      set the label of button "Ig3dLibraryClose" of group id tGroup to "X"
      set the textSize of button "Ig3dLibraryClose" of group id tGroup to 11
      set the textStyle of button "Ig3dLibraryClose" of group id tGroup to "bold"
      set the traversalOn of button "Ig3dLibraryClose" of group id tGroup to false
      set the opaque of button "Ig3dLibraryClose" of group id tGroup to true
      set the backgroundColor of button "Ig3dLibraryClose" of group id tGroup to "#061006"
      set the textColor of button "Ig3dLibraryClose" of group id tGroup to kInk
      set the tooltip of button "Ig3dLibraryClose" of group id tGroup to "Close the Library"
      set the script of button "Ig3dLibraryClose" of group id tGroup to "on mouseUp" & cr & "   Ig.CloseLibrary" & cr & "end mouseUp"
   end if
   repeat for each item tN in "field Ig3dLibrary,graphic Ig3dPreview,graphic Ig3dPreviewWire,button Ig3dLibraryClose"
      if word 1 of tN is "field" then set the visible of field (word 2 of tN) of group id tGroup to true
      if word 1 of tN is "graphic" then set the visible of graphic (word 2 of tN) of group id tGroup to true
      if word 1 of tN is "button" then set the visible of button (word 2 of tN) of group id tGroup to true
   end repeat
   put empty into sLib["sel"]
   Ig.PlaceLibrary
   Ig.Wake
   if sLib["browse"] is true then
      Ig.Browse
   else
      put sLibList into field "Ig3dLibrary" of group id tGroup
   end if
end Ig.ShowLibrary

-- the Library's place: the right of the free area, the preview 150 high, the list under it
on Ig.PlaceLibrary
   local tG, tL, tR, tT, tB
   if there is not a group "Ig3dTools" then exit Ig.PlaceLibrary
   put the short id of group "Ig3dTools" into tG
   if there is not a field "Ig3dLibrary" of group id tG then exit Ig.PlaceLibrary
   put sLayout["pRight"] into tR
   if tR is not a number then put the width of this card - 10 into tR
   put tR - 220 into tL
   put sLayout["pTop"] into tT
   if tT is not a number then put 26 into tT
   add 20 to tT
   put sLayout["pBottom"] into tB
   if tB is not a number then put the height of this card - 30 into tB
   set the rect of graphic "Ig3dPreview" of group id tG to tL, tT, tR, tT + 150
   set the rect of button "Ig3dLibraryClose" of group id tG to tR - 20, tT - 19, tR, tT - 1
   set the rect of field "Ig3dLibrary" of group id tG to tL, tT + 154, tR, max(tT + 154 + 60, tB)
   Ig.ShowPreview
end Ig.PlaceLibrary

-- the chosen entry's wire in the preview box (empty: nothing chosen, or a folder)
on Ig.ShowPreview
   local tG, tM, tR
   if there is not a graphic "Ig3dPreviewWire" of group "Ig3dTools" then exit Ig.ShowPreview
   put the short id of group "Ig3dTools" into tG
   put the rect of graphic "Ig3dPreview" of group id tG into tR
   if sLib["sel"] is empty then
      set the points of graphic "Ig3dPreviewWire" of group id tG to empty
      exit Ig.ShowPreview
   end if
   put Ig.EntryMesh(sLib["sel"]) into tM
   set the points of graphic "Ig3dPreviewWire" of group id tG to Ig.MeshPoints(tM, item 1 of tR, item 2 of tR, item 3 of tR - item 1 of tR, item 4 of tR - item 2 of tR)
end Ig.ShowPreview

-- a click in the list: choose the entry and show it; nothing is made yet
on Ig.LibrarySelect pLine
   local tLine
   Ig.Wake
   if pLine is not a number then exit Ig.LibrarySelect
   put line pLine of sLibList into tLine
   if sLib["browse"] is true and (tLine is ".." or the last char of tLine is "/") then
      put empty into sLib["sel"]
      Ig.ShowPreview
      Ig.Say "DOUBLE-CLICK (OR RETURN) TO OPEN" && toUpper(tLine)
      exit Ig.LibrarySelect
   end if
   put pLine into sLib["sel"]
   Ig.ShowPreview
   if Ig.CanPlace(pLine) then
      Ig.Say toUpper(tLine) & ": DOUBLE-CLICK OR ENTER PUTS IT WHERE THE MOUSE WAS IN THE VIEW, OR DRAG THE PREVIEW IN"
   else
      Ig.Say toUpper(tLine) & ": DOUBLE-CLICK OR ENTER"
   end if
end Ig.LibrarySelect

-- a model that can be put anywhere: made from its name, or a .wtf file
function Ig.CanPlace pLine
   local tLine
   put line pLine of sLibList into tLine
   if tLine is empty or tLine is ".." or the last char of tLine is "/" then return false
   if sLib["folder"] is "Gen" then return not (tLine begins with "A STREET" or tLine begins with "A SHOWCASE")
   if sLib["folder"] is "WTF" then return char -4 to -1 of tLine is ".wtf"
   return false
end Ig.CanPlace

-- the mesh of a list entry, for the preview: made from its name, read from its .wtf, or an
-- Aquarius character
function Ig.EntryMesh pLine
   local tRel, tG, tN, tB
   put Ig.LibRel(pLine) into tRel
   if sLib["folder"] is "Aqua" then
      if pLine > 1 then return Ig.AquaMesh(pLine - 2, 20, 12)
      return empty
   end if
   if not Ig.CanPlace(pLine) then return empty
   if sLib["folder"] is "WTF" then return Ig.WTFMesh(Ig.DataRoot() & "/WTF/" & tRel)
   set the itemDelimiter to "/"
   put item 1 of tRel into tG
   put item 2 of tRel into tN
   set the itemDelimiter to comma
   switch tG
      case "Buildings"
      case "Houses"
         Ig.UseBuildings
         put Bld.Make(tN) into tB
         return tB["mesh"]
      case "Characters"
         Ig.UseTool "v3d_figures"
         return Fig.Make(tN)
      default
         Ig.UseTool "v3d_props"
         return Prop.Make(tN)
   end switch
end Ig.EntryMesh

-- a mesh as line-graphic points, turned 35 degrees and tipped 20, fitted in the box
function Ig.MeshPoints pM, pLeft, pTop, pW, pH
   local i, tX, tY, tZ, tSX, tSY, minX, maxX, minY, maxY, k, tOut, tL, a, b, cy, sy, cp, sp, tOX, tOY
   if pM["count"] < 1 then return empty
   put cos(0.61) into cy
   put sin(0.61) into sy
   put cos(0.35) into cp
   put sin(0.35) into sp
   put 1e9 into minX
   put -1e9 into maxX
   put 1e9 into minY
   put -1e9 into maxY
   repeat with i = 1 to pM["count"]
      put pM["vx"][i] * cy - pM["vz"][i] * sy into tX
      put pM["vx"][i] * sy + pM["vz"][i] * cy into tZ
      put pM["vy"][i] * cp + tZ * sp into tY
      put tX into tSX[i]
      put tY into tSY[i]
      put min(minX, tX) into minX
      put max(maxX, tX) into maxX
      put min(minY, tY) into minY
      put max(maxY, tY) into maxY
   end repeat
   put min((pW - 16) / max(0.001, maxX - minX), (pH - 16) / max(0.001, maxY - minY)) into k
   put pLeft + (pW - (maxX - minX) * k) / 2 into tOX
   put pTop + (pH - (maxY - minY) * k) / 2 into tOY
   repeat for each line tL in pM["lines"]
      put word 1 of tL into a
      put word 2 of tL into b
      if tSX[a] is empty or tSX[b] is empty then next repeat
      put round(tOX + (tSX[a] - minX) * k) & comma & round(tOY + (tSY[a] - minY) * k) & return after tOut
      put round(tOX + (tSX[b] - minX) * k) & comma & round(tOY + (tSY[b] - minY) * k) & return & return after tOut
   end repeat
   return tOut
end Ig.MeshPoints

-- where the mouse last was over the 3D view (a double-click in the list puts the model there)
on mouseMove pX, pY
   if Ig.InView(pX, pY) then put pX & comma & pY into sLib["mouse"]
   pass mouseMove
end mouseMove

-- a point of the 3D view: not on the menu bar, the tools or the Library
function Ig.InView pX, pY
   local tR
   if pY < sLayout["pTop"] or pY > sLayout["pBottom"] then return false
   if pX < sLayout["pLeft"] or pX > sLayout["pRight"] then return false
   if there is a field "Ig3dLibrary" of group "Ig3dTools" then
      if the visible of field "Ig3dLibrary" of group "Ig3dTools" and pX >= the left of field "Ig3dLibrary" of group "Ig3dTools" - 4 then return false
   end if
   if there is a button "Ig3dToolsTab" of group "Ig3dTools" then
      if (pX & comma & pY) is within the rect of button "Ig3dToolsTab" of group "Ig3dTools" then return false
   end if
   return true
end Ig.InView

-- a model where the mouse last was in the view (the middle when it hasn't been there)
on Ig.PlaceAtMouse pLine
   local tXZ, tErr
   put empty into tXZ
   if sLib["mouse"] is not empty then
      try
         put Engine.ScreenToFloor(item 1 of sLib["mouse"], item 2 of sLib["mouse"], 0) into tXZ
      catch tErr
         put empty into tXZ
      end try
   end if
   if tXZ is empty then put "0 0" into tXZ
   Ig.PlaceAt pLine, word 1 of tXZ, word 2 of tXZ
end Ig.PlaceAtMouse

-- one more of the entry on line pLine at x, z (engine units on the floor)
on Ig.PlaceAt pLine, pX, pZ
   local tRel, tG, tN
   if not Ig.CanPlace(pLine) then exit Ig.PlaceAt
   if sLib["folder"] is "WTF" then
      Ig.SpawnModel pLine, pX, pZ, false
      exit Ig.PlaceAt
   end if
   put Ig.LibRel(pLine) into tRel
   set the itemDelimiter to "/"
   put item 1 of tRel into tG
   put item 2 of tRel into tN
   set the itemDelimiter to comma
   if tG is "Buildings" or tG is "Houses" then
      Ig.UseBuildings
      get Ig.SpawnBuilding(tN, pX / Bld.UnitsPerMetre(), pZ / Bld.UnitsPerMetre(), false, false)
   else if tG is "Characters" then
      get Ig.SpawnThing("figure", tN, pX / 10, pZ / 10, 0, false, empty)
   else
      get Ig.SpawnThing("prop", tN, pX / 10, pZ / 10, 0, false, empty)
   end if
end Ig.PlaceAt

-- pressing on the preview: drag the chosen model into the view; it is made where it is let go
on Ig.PreviewDrag
   local tStart, tMoved, tPrev, tX, tY, tXZ, tWhere, tLine
   put sLib["sel"] into tLine
   if tLine is empty or not Ig.CanPlace(tLine) then
      Ig.Say "CLICK A MODEL IN THE LIST, THEN DRAG ITS PREVIEW INTO THE VIEW"
      exit Ig.PreviewDrag
   end if
   put the screenMouseLoc into tStart
   put false into tMoved
   put "V3D_DragPreview" into tPrev
   repeat while the mouse is down
      if not tMoved and abs(item 1 of the screenMouseLoc - item 1 of tStart) + abs(item 2 of the screenMouseLoc - item 2 of tStart) > 6 then
         put true into tMoved
         Ig.MakeDragPreview tPrev, Ig.MeshPoints(Ig.EntryMesh(tLine), 0, 0, 110, 110)
      end if
      if tMoved and there is a stack tPrev then set the topLeft of stack tPrev to (item 1 of the screenMouseLoc + 14) & comma & (item 2 of the screenMouseLoc + 14)
      wait 15 milliseconds with messages
   end repeat
   if there is a stack tPrev then delete stack tPrev
   if not tMoved then exit Ig.PreviewDrag
   put item 1 of the screenMouseLoc - the left of this stack into tX
   put item 2 of the screenMouseLoc - the top of this stack into tY
   if not Ig.InView(tX, tY) then
      Ig.Say "LET GO OUTSIDE THE 3D VIEW: NOTHING ADDED"
      exit Ig.PreviewDrag
   end if
   try
      put Engine.ScreenToFloor(tX, tY, 0) into tXZ
   catch tWhere
      put empty into tXZ
   end try
   if tXZ is empty then put "0 0" into tXZ
   Ig.PlaceAt tLine, word 1 of tXZ, word 2 of tXZ
end Ig.PreviewDrag

-- the X above the list: the list goes (Library > ... brings it back)
on Ig.CloseLibrary
   if there is a field "Ig3dLibrary" of group "Ig3dTools" then set the visible of field "Ig3dLibrary" of group "Ig3dTools" to false
   if there is a button "Ig3dLibraryClose" of group "Ig3dTools" then set the visible of button "Ig3dLibraryClose" of group "Ig3dTools" to false
   if there is a graphic "Ig3dPreview" of group "Ig3dTools" then set the visible of graphic "Ig3dPreview" of group "Ig3dTools" to false
   if there is a graphic "Ig3dPreviewWire" of group "Ig3dTools" then set the visible of graphic "Ig3dPreviewWire" of group "Ig3dTools" to false
   focus on nothing
   Ig.Say "LIBRARY CLOSED (THE LIBRARY MENU OPENS IT AGAIN)"
end Ig.CloseLibrary

-- the list as folders: sLib["all"] holds every entry (a/b/name), sLib["path"] the folder shown.
-- At the top, the entries with no folder (A STREET OF EACH KIND ...) and then the folders;
-- inside a folder, ".." first, then its folders, then its files.
on Ig.Browse
   local tOut, tTop, tDirs, tFiles, tLine, tRest, tN, tSeen
   put sLib["path"] into tTop
   put the number of chars of tTop into tN
   set the itemDelimiter to "/"
   repeat for each line tLine in sLib["all"]
      if tLine is empty then next repeat
      if tN > 0 then
         if char 1 to tN of tLine is not tTop then next repeat
         put char tN + 1 to -1 of tLine into tRest
      else
         put tLine into tRest
      end if
      if the number of items of tRest > 1 then
         if tSeen[item 1 of tRest] is empty then
            put true into tSeen[item 1 of tRest]
            put item 1 of tRest & "/" & cr after tDirs
         end if
      else
         put tRest & cr after tFiles
      end if
   end repeat
   set the itemDelimiter to comma
   if tN > 0 then
      put ".." & cr & tDirs & tFiles into tOut
   else
      put tFiles & tDirs into tOut
   end if
   if the last char of tOut is cr then delete the last char of tOut
   put tOut into sLibList
   put sLibList into field "Ig3dLibrary" of group "Ig3dTools"
   set the hilitedLine of field "Ig3dLibrary" of group "Ig3dTools" to empty
   set the vScroll of field "Ig3dLibrary" of group "Ig3dTools" to 0
end Ig.Browse

-- a double-click or Return: a folder opens, ".." goes back up, a file loads as a click does
on Ig.LibraryOpen pLine
   local tLine
   if pLine is not a number then exit Ig.LibraryOpen
   put line pLine of sLibList into tLine
   if Ig.CanPlace(pLine) then
      Ig.PlaceAtMouse pLine
      exit Ig.LibraryOpen
   end if
   if sLib["browse"] is not true then
      Ig.LibraryPick pLine
      exit Ig.LibraryOpen
   end if
   set the itemDelimiter to "/"
   if tLine is ".." then
      delete the last char of sLib["path"]
      delete item -1 of sLib["path"]
      if sLib["path"] is not empty then
         put "/" after sLib["path"]
      end if
   else if the last char of tLine is "/" then
      put tLine after sLib["path"]
   else
      set the itemDelimiter to comma
      Ig.LibraryPick pLine
      exit Ig.LibraryOpen
   end if
   set the itemDelimiter to comma
   Ig.Browse
   if sLib["path"] is empty then
      Ig.Say "LIBRARY: THE TOP.  DOUBLE-CLICK A FOLDER (OR RETURN) TO OPEN IT"
   else
      Ig.Say "LIBRARY > " & toUpper(char 1 to -2 of sLib["path"]) & ":" && the number of lines of sLibList - 1 && "ENTRIES.  CLICK ONE; .. (DOUBLE-CLICK OR RETURN) GOES BACK"
   end if
end Ig.LibraryOpen

-- the entry on line pLine, with its folder: Vehicles/car, ships/small/boat.wtf
function Ig.LibRel pLine
   return sLib["path"] & line pLine of sLibList
end Ig.LibRel

-- something changed: draw again (the player stops drawing while nothing moves, bStill)
on Ig.Wake
   global bStill
   put false into bStill
   put 0 into sLib["still"]
end Ig.Wake

function Ig.ListFiles pFolder, pRel, pSuffix
   local tOut, tF, tSub, tSuf
   repeat for each line tF in files(pFolder)
      repeat for each item tSuf in pSuffix
         if char -(the number of chars of tSuf) to -1 of tF is tSuf then
            put pRel & tF & cr after tOut
            exit repeat
         end if
      end repeat
   end repeat
   repeat for each line tSub in folders(pFolder)
      if tSub is "." or tSub is ".." or tSub begins with "_" then next repeat
      put Ig.ListFiles(pFolder & "/" & tSub, pRel & tSub & "/", pSuffix) after tOut
   end repeat
   return tOut
end Ig.ListFiles

-------------------------------------------------------------------- editor tools (A-84, A-86, A-87)

-- the projects folder (the 2008 Data folder is projects/LIB_GAMES/igame3D_2008_Texts)
-- the projects folder (the one holding LIB_GAMES, whose games Replace With Model skins): found
-- above this script or this stack; empty when there is none (an installed copy)
function Ig.Projects
   local tDir, tErr, tPath
   put empty into tDir
   try
      put the uScriptFile of (the long owner of me) into tDir
   catch tErr
      put empty into tDir
   end try
   set the itemDelimiter to "/"
   repeat for each line tPath in (tDir & cr & the effective filename of this stack)
      replace "\" with "/" in tPath
      repeat 8 times
         delete item -1 of tPath
         if tPath is empty then exit repeat
         if there is a folder (tPath & "/LIB_GAMES") then return tPath
      end repeat
   end repeat
   return empty
end Ig.Projects

-- a tool window built by code on a brand-new stack each time (its script: Tools/<pFile> beside
-- this script, else LIB_ig3d/livecode/<pFile>)
on Ig.OpenTool pStack, pFile, pBuild
   local tFile
   if there is a stack pStack then
      go stack pStack
      exit Ig.OpenTool
   end if
   put Ig.ToolFile(pFile) into tFile
   if there is not a file tFile then
      Ig.Say "NOT FOUND:" && tFile
      exit Ig.OpenTool
   end if
   lock messages
   create invisible stack pStack
   unlock messages
   set the script of stack pStack to textDecode(URL ("binfile:" & tFile), "UTF-8")
   if the result is not empty then
      Ig.Say "THE TOOL'S SCRIPT DOES NOT COMPILE:" && line 1 of the result
      delete stack pStack
      exit Ig.OpenTool
   end if
   send pBuild && quote & Ig.Projects() & quote to stack pStack
end Ig.OpenTool

-- A-87: press on a model in the Library and drag: a small window with the model's wire follows the
-- mouse; let go over the 3D view and the model lands on the floor there. A plain click still loads it.

-- a tool window's script: Tools/<pFile> beside this script (iGame3D XT carries its own), else
-- LIB_ig3d/livecode/<pFile> in the projects
function Ig.ToolFile pFile
   local tDir, tErr
   set the itemDelimiter to "/"
   put empty into tDir
   try
      put the uScriptFile of (the long owner of me) into tDir
   catch tErr
      put empty into tDir
   end try
   replace "\" with "/" in tDir
   if tDir contains "/" and there is a file (item 1 to -2 of tDir & "/Tools/" & pFile) then return item 1 to -2 of tDir & "/Tools/" & pFile
   return Ig.Projects() & "/LIB_ig3d/livecode/" & pFile
end Ig.ToolFile

-- the drag preview: a small borderless window with the model's wire (pPoints, Ig.MeshPoints)
on Ig.MakeDragPreview pStack, pPoints
   lock messages
   create invisible stack pStack
   set the decorations of stack pStack to empty
   set the width of stack pStack to 110
   set the height of stack pStack to 110
   set the backgroundColor of stack pStack to "#061006"
   set the blendLevel of stack pStack to 15
   set the defaultStack to pStack
   create graphic "Wire"
   set the style of graphic "Wire" to "line"
   set the foregroundColor of graphic "Wire" to kInk
   set the points of graphic "Wire" to pPoints
   set the defaultStack to the short name of this stack
   unlock messages
   set the topLeft of stack pStack to (item 1 of the screenMouseLoc + 14) & comma & (item 2 of the screenMouseLoc + 14)
   show stack pStack
end Ig.MakeDragPreview

on Ig.LibraryPick pLine
   local tRel, tPath, tName
   if pLine is not a number then exit Ig.LibraryPick
   Ig.Wake
   if sLib["browse"] is true and (line pLine of sLibList is ".." or the last char of line pLine of sLibList is "/") then
      Ig.Say "DOUBLE-CLICK (OR RETURN) TO OPEN" && toUpper(line pLine of sLibList)
      exit Ig.LibraryPick
   end if
   if sLib["folder"] is "Gen" then
      put Ig.LibRel(pLine) into tRel
      if tRel begins with "A STREET" then
         Ig.Streets
      else if tRel begins with "A SHOWCASE" then
         Ig.Showcase
      else
         set the itemDelimiter to "/"
         put item 1 of tRel into tName
         put item 2 of tRel into tRel
         set the itemDelimiter to comma
         if tName is "Buildings" or tName is "Houses" then
            get Ig.SpawnBuilding(tRel, 0, 0, false, true)
         else if tName is "Characters" then
            get Ig.SpawnThing("figure", tRel, 0, 0, 0, true, empty)
         else
            get Ig.SpawnThing("prop", tRel, 0, 0, 0, true, empty)
         end if
      end if
      exit Ig.LibraryPick
   end if
   if sLib["folder"] is "Levels" then
      Ig.RunLevel Ig.XTData() & "/Levels/" & line pLine of sLibList & "/load_script.xtalk"
      exit Ig.LibraryPick
   end if
   if sLib["folder"] is "Aqua" then
      if pLine is 1 then
         Ig.AquariusLevel
      else
         Ig.AquaSpawn pLine - 2
      end if
      exit Ig.LibraryPick
   end if
   put Ig.LibRel(pLine) into tRel
   put Ig.DataRoot() & "/" & sLib["folder"] & "/" & tRel into tPath
   if char -4 to -1 of tRel is ".wtf" then
      Ig.SpawnModel pLine, 0, 0, true
   else
      Ig.Say toUpper(tRel) && "(" & the number of lines of URL ("file:" & tPath) && "LINES; OPENING THESE IS NEXT)"
   end if
end Ig.LibraryPick

-- a Library model into the scene, standing on the floor at x, z; pReplace: a click swaps the last
-- loaded model, a drop adds one more
on Ig.SpawnModel pLine, pX, pZ, pReplace
   local tRel, tPath, tName
   put Ig.LibRel(pLine) into tRel
   put Ig.DataRoot() & "/" & sLib["folder"] & "/" & tRel into tPath
   put "Ig.WTF" & pLine into tName
   Mesh.Define tName, Ig.WTFMesh(tPath)
   if pReplace and sSelected is not empty and gObjectTransforms[sSelected]["mesh"] begins with "Ig.WTF" then Entity.Kill sSelected
   put Entity.Spawn(tName, pX, -90, pZ, Ig.NextColor()) into sSelected
   put sSelected & cr after sMade
   Ig.Say "MODEL:" && toUpper(tRel) && "(" & sLib["v"] && "VERTICES," && sLib["e"] && "EDGES)" && "AT" && round(pX) && round(pZ)
end Ig.SpawnModel

-------------------------------------------------------------------- buildings (workstream A)
-- Made from their names by Tools/v3d_buildings (Bld.*); each door and window is its own
-- entity with hit points, as in uDead (window 10, door 60, heavy door 120, roller door 150).

on Ig.UseBuildings
   Ig.UseTool "v3d_buildings"
end Ig.UseBuildings

on Ig.UseTool pName
   local tLib
   if pName is among the lines of the stacksInUse then exit Ig.UseTool
   put Ig.ToolFile(pName & ".livecodescript") into tLib
   if there is a file tLib then start using stack tLib
end Ig.UseTool

-------------------------------------------------------------------- props and characters (A, C)

-- a prop or a character on the floor at x, z (metres), turned pRot radians; pReplace: it takes the
-- place of the last single one; pInst: a character's name (soldier_001). Returns its entity.
function Ig.SpawnThing pKind, pName, pX, pZ, pRot, pReplace, pInst
   local tMesh, tKey, tColor, tM
   if pKind is "figure" then
      Ig.UseTool "v3d_figures"
      put "Fig." & pName into tMesh
      put Fig.Make(pName) into tM
      if pInst is empty then
         add 1 to sObj["n" & pName]
         put Fig.Instance(pName, sObj["n" & pName]) into pInst
      end if
      put "#FFB060" into tColor
      if pName is "zombie" then put "#80FF80" into tColor
      if pName is "police" or pName is "soldier" then
         put "#80B0FF" into tColor
      end if
   else
      Ig.UseTool "v3d_props"
      put "Prop." & pName into tMesh
      put Prop.Make(pName) into tM
      put Ig.NextColor() into tColor
   end if
   Mesh.Define tMesh, tM
   if pReplace and sSelected is not empty and (sObj[sSelected] begins with "prop|" or sObj[sSelected] begins with "figure|") then
      Ig.Kill sSelected
      filter lines of sMade without sSelected
   end if
   put Entity.Spawn(tMesh, pX * 10, 0, pZ * 10, tColor) into tKey
   if pRot is not 0 then SetObjectRotation tKey, 0, pRot, 0
   put pKind & "|" & pName & "|" & pX & "|" & pZ & "|" & pRot & "|" & pInst into sObj[tKey]
   put tKey into sSelected
   put tKey & cr after sMade
   if pKind is "figure" then
      Ig.Say "CHARACTER" && toUpper(pInst) & ": OUR STICK FIGURE AS A" && toUpper(pName) && "(" & tM["count"] && "VERTICES)"
   else
      Ig.Say "MODEL" && toUpper(pName) && "(" & toUpper(Prop.GroupOf(pName)) & "):" && tM["count"] && "VERTICES, MADE FROM ITS NAME"
   end if
   return tKey
end Ig.SpawnThing

-- one of every prop and character, in rows of twelve, timed (skies and floors left out: too big)
on Ig.Showcase
   local t0, tG, tN, k, tX, tZ, tList
   Ig.UseTool "v3d_props"
   Ig.UseTool "v3d_figures"
   repeat for each item tG in Prop.Groups()
      if tG is "Sky" or tG is "Floors" then next repeat
      repeat for each item tN in Prop.Names(tG)
         put "prop," & tN & cr after tList
      end repeat
   end repeat
   repeat for each item tN in Fig.Roles()
      put "figure," & tN & cr after tList
   end repeat
   put the milliseconds into t0
   lock screen
   put 0 into k
   repeat for each line tN in tList
      put ((k mod 12) - 5.5) * 7 into tX
      put (k div 12) * 7 - 30 into tZ
      get Ig.SpawnThing(item 1 of tN, item 2 of tN, tX, tZ, 0, false, empty)
      add 1 to k
   end repeat
   unlock screen
   put the milliseconds - t0 into sObj["showcase"]
   put k into sObj["showcaseN"]
   put 0 into sCamX
   put -700 into sCamY
   put -1100 into sCamZ
   Ig.Camera
   Ig.Say "SHOWCASE:" && k && "MODELS, EVERY ONE MADE FROM ITS NAME, IN" && sObj["showcase"] && "MS"
end Ig.Showcase

-------------------------------------------------------------------- levels as xTalk files (D)
-- A level is Data/Levels/<name>/load_script.xtalk: lines of Lvl.* commands, the 2008 Lua
-- hooks in xTalk (loadMesh / make + setObjectInfo -> Lvl.Object, setCameraInfo -> Lvl.Camera,
-- setSceneInfo -> Lvl.Scene, setLightInfo -> Lvl.Light). Anyone, or their AI, can edit one in a
-- text editor; only lines that begin with Lvl. are run.

on Ig.LevelLibrary
   local tDir, tOut, tF
   put Ig.XTData() & "/Levels" into tDir
   if there is not a folder tDir then
      Ig.Say "LIBRARY > LEVELS: NO LEVELS FOLDER (" & tDir & ")"
      exit Ig.LevelLibrary
   end if
   repeat for each line tF in folders(tDir)
      if tF is "." or tF is ".." then next repeat
      if there is a file (tDir & "/" & tF & "/load_script.xtalk") then put tF & cr after tOut
   end repeat
   delete the last char of tOut
   sort lines of tOut
   put tOut into sLibList
   put false into sLib["browse"]
   Ig.ShowLibrary
   put "Levels" into sLib["folder"]
   Ig.Say "LIBRARY > LEVELS:" && the number of lines of tOut && "LEVELS (XTALK FILES: Data/Levels/<NAME>/load_script.xtalk).  CLICK ONE"
end Ig.LevelLibrary

-- run a level file; returns nothing, says how many lines ran
on Ig.RunLevel pFile
   local tText, tLine, tRan, tSkip, tErr, tName
   if there is not a file pFile then
      Ig.Say "NO LEVEL FILE:" && pFile
      exit Ig.RunLevel
   end if
   Ig.Menu "File", "Clear"
   set the itemDelimiter to "/"
   put item -2 of pFile into sLevel
   set the itemDelimiter to comma
   put textDecode(URL ("binfile:" & pFile), "UTF-8") into tText
   replace numToChar(13) with empty in tText
   put 0 into tRan
   put 0 into tSkip
   repeat for each line tLine in tText
      put word 1 to -1 of tLine into tLine
      if tLine is empty or tLine begins with "--" or tLine begins with "#" then next repeat
      if not (word 1 of tLine begins with "Lvl.") then
         add 1 to tSkip
         next repeat
      end if
      try
         do tLine
         add 1 to tRan
      catch tErr
         add 1 to tSkip
      end try
   end repeat
   put tRan & "," & tSkip into sObj["ran"]
   Ig.Say "LEVEL" && toUpper(sLevel) & ":" && tRan && "LINES RUN" & (tSkip > 0) && "(" & tSkip && "SKIPPED)"
end Ig.RunLevel

-- write the scene as a level file: the camera, then every thing made, in order
on Ig.SaveLevel pName
   local tDir, tText, tKey, tRec
   put Ig.XTData() & "/Levels" into tDir
   if Ig.XTData() is empty then
      Ig.Say "NO DATA FOLDER TO SAVE INTO"
      exit Ig.SaveLevel
   end if
   if there is not a folder tDir then create folder tDir
   if there is not a folder (tDir & "/" & pName) then create folder (tDir & "/" & pName)
   put "-- iGame3D XT level: " & pName & ", saved " & the long date && the time & cr & \
         "-- Edit freely: one Lvl. command a line (Data/Scripts/LEVEL_API.txt). Lines that do not" & cr & \
         "-- begin with Lvl. are left alone." & cr & \
         "Lvl.Camera " & sCamX & ", " & sCamY & ", " & sCamZ & cr into tText
   if sAqua["keys"] is not empty then put "Lvl.Aquarius" & cr after tText
   set the itemDelimiter to "|"
   repeat for each line tKey in sMade
      put sObj[tKey] into tRec
      if tRec is empty then next repeat
      if item 1 of tRec is "building" then
         put "Lvl.Object " & quote & "building" & quote & ", " & quote & item 2 of tRec & quote & ", " & item 3 of tRec & ", " & item 4 of tRec & ", " & item 5 of tRec & cr after tText
      else
         put "Lvl.Object " & quote & item 1 of tRec & quote & ", " & quote & item 2 of tRec & quote & ", " & item 3 of tRec & ", " & item 4 of tRec & ", " & item 5 of tRec & ", " & quote & item 6 of tRec & quote & cr after tText
      end if
   end repeat
   set the itemDelimiter to comma
   put textEncode(tText, "UTF-8") into URL ("binfile:" & tDir & "/" & pName & "/load_script.xtalk")
   put pName into sLevel
   Ig.Say "SAVED:" && tDir & "/" & pName & "/load_script.xtalk"
end Ig.SaveLevel

-- the level commands (the hooks a level file calls)
on Lvl.Camera pX, pY, pZ
   put pX into sCamX
   put pY into sCamY
   put pZ into sCamZ
   Ig.Camera
end Lvl.Camera

-- kind: building (pRot: true = facing +z), prop, figure (pInst: its name)
on Lvl.Object pKind, pName, pX, pZ, pRot, pInst
   if pKind is "building" then
      get Ig.SpawnBuilding(pName, pX, pZ, pRot is true, false)
   else
      if pRot is empty then put 0 into pRot
      get Ig.SpawnThing(pKind, pName, pX, pZ, pRot, false, pInst)
   end if
end Lvl.Object

on Lvl.Aquarius
   Ig.AquariusLevel
end Lvl.Aquarius

on Lvl.Streets
   Ig.Streets
end Lvl.Streets

on Lvl.Showcase
   Ig.Showcase
end Lvl.Showcase

on Lvl.Scene pKey, pValue
   put pValue into sObj["scene"][pKey]
end Lvl.Scene

on Lvl.Light pN, pKey, pValue
   put pValue into sObj["light"][pN][pKey]
end Lvl.Light

on Lvl.Say pText
   Ig.Say pText
end Lvl.Say

-- Help > iGame3D Help: the 2008 help pages, kept as legacy documentation
on Ig.Help
   local tF
   put Ig.XTData() into tF
   set the itemDelimiter to "/"
   put item 1 to -2 of tF & "/Help_2008/index.html" into tF
   set the itemDelimiter to comma
   if there is not a file tF then
      Ig.Say "NO HELP PAGES (" & tF & ")"
      exit Ig.Help
   end if
   launch url ("file://" & tF)
   Ig.Say "THE 2008 HELP (LEGACY DOCUMENTATION) IN YOUR BROWSER"
end Ig.Help

function Ig.ObjStats
   return the number of lines of sMade & "|" & sObj["showcaseN"] & "|" & sObj["showcase"] & "|" & sObj["ran"] & "|" & sLevel
end Ig.ObjStats

function Ig.AxesMesh
   local tM
   put Mesh.New() into tM
   Mesh.AddVertex tM, 0, 0, 0
   Mesh.AddVertex tM, 120, 0, 0
   Mesh.AddVertex tM, 0, 0, 120
   Mesh.AddVertex tM, 0, -120, 0
   Mesh.AddLine tM, 1, 2
   Mesh.AddLine tM, 1, 3
   Mesh.AddLine tM, 1, 4
   return tM
end Ig.AxesMesh

-- Library > Models without the 2008 data: the 2008 names, made procedurally
on Ig.GenLibrary
   local tOut, tN, tG
   Ig.UseBuildings
   if not ("v3d_buildings" is among the lines of the stacksInUse) then
      Ig.Say "LIBRARY > MODELS: NO BUILDING TOOL (Tools/v3d_buildings.livecodescript) AND NO 2008 DATA"
      exit Ig.GenLibrary
   end if
   put "A STREET OF EACH KIND" & cr & "A SHOWCASE OF EVERY MODEL" & cr into tOut
   repeat for each item tN in Bld.Names("Buildings")
      put "Buildings/" & tN & cr after tOut
   end repeat
   repeat for each item tN in Bld.Names("Houses")
      put "Houses/" & tN & cr after tOut
   end repeat
   Ig.UseTool "v3d_props"
   Ig.UseTool "v3d_figures"
   if "v3d_props" is among the lines of the stacksInUse then
      repeat for each item tG in Prop.Groups()
         repeat for each item tN in Prop.Names(tG)
            put tG & "/" & tN & cr after tOut
         end repeat
      end repeat
   end if
   if "v3d_figures" is among the lines of the stacksInUse then
      repeat for each item tN in Fig.Roles()
         put "Characters/" & tN & cr after tOut
      end repeat
   end if
   delete the last char of tOut
   put tOut into sLib["all"]
   put empty into sLib["path"]
   put true into sLib["browse"]
   put "Gen" into sLib["folder"]
   Ig.ShowLibrary
   Ig.Say "LIBRARY > MODELS: MADE FROM THEIR NAMES.  THE FIRST TWO LINES: A STREET, A SHOWCASE.  DOUBLE-CLICK A FOLDER (OR RETURN) FOR ITS MODELS"
end Ig.GenLibrary

-- a building on the floor at x, z (metres from the middle, the front facing -z; pTurn: facing +z).
-- pReplace: it takes the place of the last single building. Returns its number.
function Ig.SpawnBuilding pName, pX, pZ, pTurn, pReplace
   local tB, tN, tKey, tPart, tColor, tPN, k, tF, tPX, tPZ
   Ig.UseBuildings
   put Bld.Make(pName) into tB
   if pReplace and sSelected is not empty and sBldOf[sSelected] is not empty then
      Ig.Kill sSelected
      filter lines of sMade without sSelected
   end if
   put 1 into tF
   if pTurn then put -1 into tF
   Mesh.Define "Bld." & pName, tB["mesh"]
   switch tB["kind"]
      case "warehouse"
         put "#7FA8C8" into tColor
         break
      case "shop"
         put "#E0C060" into tColor
         break
      case "military"
         put "#D07070" into tColor
         break
      default
         put "#7CFF7C" into tColor
   end switch
   put Entity.Spawn("Bld." & pName, pX * Bld.UnitsPerMetre(), 0, pZ * Bld.UnitsPerMetre(), tColor) into tKey
   if pTurn then SetObjectRotation tKey, 0, 3.14159, 0
   add 1 to sBldN
   put sBldN into tN
   put pName into sBld[tN]["name"]
   put tB["kind"] into sBld[tN]["kind"]
   put tKey into sBld[tN]["shell"]
   put tN into sBldOf[tKey]
   put 0 into tPN
   set the itemDelimiter to "|"
   repeat for each line tPart in tB["parts"]
      if tPart is empty then next repeat
      add 1 to tPN
      Mesh.Define Bld.PartName(item 1 of tPart, item 5 of tPart, item 6 of tPart, item 7 of tPart), Bld.PartMesh(item 1 of tPart, item 5 of tPart, item 6 of tPart, item 7 of tPart)
      put "#9FE8FF" into tColor
      if item 1 of tPart is not "window" then put "#C08A3A" into tColor
      put pX + tF * item 2 of tPart into tPX
      put pZ + tF * item 4 of tPart into tPZ
      put Entity.Spawn(Bld.PartName(item 1 of tPart, item 5 of tPart, item 6 of tPart, item 7 of tPart), tPX * Bld.UnitsPerMetre(), -(item 3 of tPart) * Bld.UnitsPerMetre(), tPZ * Bld.UnitsPerMetre(), tColor) into sBld[tN]["key"][tPN]
      put item 1 of tPart into sBld[tN]["kind"][tPN]
      put item 8 of tPart into sBld[tN]["hp"][tPN]
      put tPX & "," & -(item 3 of tPart) - item 6 of tPart / 2 & "," & tPZ into sBld[tN]["at"][tPN]
   end repeat
   set the itemDelimiter to comma
   put tPN into sBld[tN]["parts"]
   put tKey into sSelected
   put tKey & cr after sMade
   put "building|" & pName & "|" & pX & "|" & pZ & "|" & pTurn into sObj[tKey]
   Ig.Say "BUILDING" && toUpper(pName) & ":" && toUpper(tB["kind"]) & "," && tB["storeys"] && "STOREYS," && round(tB["w"]) & "x" & round(tB["d"]) && "M," && tPN && "DOORS AND WINDOWS (EDIT > BOOM BREAKS THEM)"
   return tN
end Ig.SpawnBuilding

-- a street of each kind: five warehouses, shops, homes and military buildings in four rows, timed
on Ig.Streets
   local t0, tRow, k, tKind, tX, tB, tW, tNames, tN, tParts, tLines
   Ig.UseBuildings
   put the milliseconds into t0
   put 0 into tParts
   put 0 into tLines
   lock screen
   put 0 into tRow
   repeat for each item tKind in "warehouse,shop,home,military"
      add 1 to tRow
      -- the row's width first, so it can be centred
      put empty into tNames
      put 0 into tW
      repeat with k = 1 to 5
         put Bld.Make(tKind & "_" & k) into tB
         put tKind & "_" & k & "," & tB["w"] & cr after tNames
         add tB["w"] + 4 to tW
         add the number of lines of tB["mesh"]["lines"] to tLines
      end repeat
      put -tW / 2 into tX
      repeat for each line tB in tNames
         add (item 2 of tB) / 2 + 2 to tX
         put Ig.SpawnBuilding(item 1 of tB, tX, (2.5 - tRow) * 40, false, false) into tN
         add sBld[tN]["parts"] to tParts
         add (item 2 of tB) / 2 + 2 to tX
      end repeat
   end repeat
   unlock screen
   put the milliseconds - t0 into sBld["make"]
   put tParts into sBld["partsMade"]
   put tLines into sBld["lines"]
   put 0 into sCamX
   put -1100 into sCamY
   put -1500 into sCamZ
   Ig.Camera
   Ig.Say "STREETS: 20 BUILDINGS, ONE OF EACH KIND A ROW," && tParts && "DOORS AND WINDOWS TO BREAK.  MADE AND PLACED IN" && sBld["make"] && "MS"
end Ig.Streets

-- a door or window takes pDamage; at 0 it breaks (sparks, gone), as in uDead. Returns hp left.
function Ig.HitPart pN, pP, pDamage
   local tAt
   if sBld[pN]["hp"][pP] <= 0 then return 0
   subtract pDamage from sBld[pN]["hp"][pP]
   if sBld[pN]["hp"][pP] > 0 then return sBld[pN]["hp"][pP]
   put 0 into sBld[pN]["hp"][pP]
   put sBld[pN]["at"][pP] into tAt
   FX.Sparks item 1 of tAt * Bld.UnitsPerMetre(), item 2 of tAt * Bld.UnitsPerMetre(), item 3 of tAt * Bld.UnitsPerMetre(), 10, "#FFE0A0"
   Entity.Kill sBld[pN]["key"][pP]
   put empty into sBld[pN]["key"][pP]
   return 0
end Ig.HitPart

-- every door and window of building pN breaks; returns how many did
function Ig.BreakBuilding pN
   local k, tBroke
   put 0 into tBroke
   repeat with k = 1 to sBld[pN]["parts"]
      if sBld[pN]["hp"][k] > 0 then
         get Ig.HitPart(pN, k, 1e6)
         add 1 to tBroke
      end if
   end repeat
   if tBroke > 0 then Ig.Say "BOOM:" && tBroke && "DOORS AND WINDOWS OF" && toUpper(sBld[pN]["name"]) && "BROKEN (BOOM AGAIN TO FLATTEN IT)"
   return tBroke
end Ig.BreakBuilding

function Ig.BreakAll
   local tN, tBroke, k
   put 0 into tBroke
   repeat with tN = 1 to sBldN
      if sBld[tN]["shell"] is not empty then
         repeat with k = 1 to sBld[tN]["parts"]
            if sBld[tN]["hp"][k] > 0 then
               get Ig.HitPart(tN, k, 1e6)
               add 1 to tBroke
            end if
         end repeat
      end if
   end repeat
   if tBroke > 0 then Ig.Say "BOOM ALL:" && tBroke && "DOORS AND WINDOWS BROKEN (BOOM ALL AGAIN TO FLATTEN EVERYTHING)"
   return tBroke
end Ig.BreakAll

-- an entity goes; a building takes its doors and windows with it
on Ig.Kill pKey
   local tN, k
   if pKey is empty then exit Ig.Kill
   put sBldOf[pKey] into tN
   if tN is not empty then
      repeat with k = 1 to sBld[tN]["parts"]
         if sBld[tN]["key"][k] is not empty then Entity.Kill sBld[tN]["key"][k]
      end repeat
      put empty into sBld[tN]["shell"]
      delete variable sBldOf[pKey]
   end if
   delete variable sObj[pKey]
   Entity.Kill pKey
end Ig.Kill

-- for the tests: buildings standing | doors and windows | of them unbroken | ms | lines
function Ig.BldStats
   local tN, k, tB, tP, tU
   put 0 into tB
   put 0 into tP
   put 0 into tU
   repeat with tN = 1 to sBldN
      if sBld[tN]["shell"] is empty then next repeat
      add 1 to tB
      repeat with k = 1 to sBld[tN]["parts"]
         add 1 to tP
         if sBld[tN]["hp"][k] > 0 then add 1 to tU
      end repeat
   end repeat
   return tB & "|" & tP & "|" & tU & "|" & sBld["make"] & "|" & sBld["lines"]
end Ig.BldStats

function Ig.BldPart pN, pP
   return sBld[pN]["kind"][pP] & "|" & sBld[pN]["hp"][pP] & "|" & (sBld[pN]["key"][pP] is not empty)
end Ig.BldPart

-------------------------------------------------------------------- Aquarius (workstream B)
-- The Aquarius character set is ONE bitmap, 128 x 128: 16 x 16 glyphs of 8 x 8, glyph n at column
-- n mod 16, row n div 16. Read from Data/Text/Aquarius.pbm beside this script when it
-- is there (edit it and the models change), else from kAquaHex, the copy built in (the same bitmap
-- as 128 rows of 32 hex digits; tools/aquarius_bitmap.py makes both). Each glyph becomes a wire
-- model lying on the floor: the outline of its lit pixels, raised a little.

constant kAquaHex = "3C444464003C000018180F0000F000FC20484828104204203C18070420E03CFC20505050009902405A180F0E70F03C3C782C2C2C7CA1FFFF18181D1C38B800302044545400A1FFFF181838B81D1C7E3060081C1C10990240185A70F00F0EFF30AC1C040400420420183C20E00704FF3000000000003C0000181800F00F00FF30FF7F3C007E007C007C18000F00F0F0003C7F3C3C3C383E383F3C000F00F0F0003C783C3C663C1B3C1F66000F00F0F0003C183C0066001E003B24000F00F0F0003C183C7EE7381C39F3E70F00F0000FFF00183CFFC3781879C3BD0F00F0000FFF00183CBDC37C38DF80990F00F0000FFF00183CDBC37F38DC00DB0F00F0000FFF00102828106020081010100000000000001028283C64500820085410000000040010287C50085010400438100000000800100028381020004004107C007C00100010007C14205400400438101000002000000028784C4800200854101000004000100028100C34001010100020001000000000000000000000000000000000003810387C087C1C7C3838000008002038443044041840200444440000100010444C1004082878400844441010207C08085410181848047810383C000040000410641020047804442044041010207C08104410404408444420440800101000100038387C380838382038700020080020100000000000000000000000000000000038107838787C7C3C4438044440444438442844444440404044100448406C4444544444404440404044100450405464445C447840447878407C10046040545444587C44404440404C4410045040444C444044444444404044441044484044444438447838787C403C443838447C44443800000000000000000000000000000000783878387C44444444447C7C007C0000444444441044444444440460400C0000444444401044444428280860200C1000784478381044445410101060100C2800405450041044445428102060080C4400404848441044286C44104060040C0000403444381038104444107C7C007C007C0000000000000000000000000000000020004000040008004010084030000000200040000400100040000040100000001034581C3438103478300848106C7838004C64204C44384C441008501052444400444420447C10444410087010524444004C64204C40103C44100848105244440034581C3438100444380844385244380000000000000038000030000000000000000000100000000000000C106000FF000000001000000000000010101000FF5834583C7C44445244247C10101004FF644C60401044445228240820000838FF444440381044285210241010101040FF644C400410442852283C2010101000FF58344078103C102C44047C0C106000FF400600000000000000380000000000FF0080003E00A0AA000000183C003EC018FF801C7C00505518000018181CFCF018FF803CD800A0AA3C00FF3CDB3CF8FC3CFF8000780050557E00FFFEFF00DCFF3CFF801C38AAA0AA7E00FFFF7E9CCFFF7EFF801E185550553C00FFDB3C9EC3FC7EFF803E1CAAA0AA18FFFF1818FB01F0FFFF80FE1C55505500FFFF3C183B00C0FF00FE3C3CAA0A3CC0E0F0300C000003FF00FE524A55057EC0E0F0381C66180FFF00FE3C3CAA0AFFC0E0F09C397EFF3F7E00FE80015505FFC0E0F0FFFF42C3FF7E00FEBC3D000AFFC0E0F0FFFFC342FF3C00FEFFFF0005FFC0E0F09C39FF7E3F3C00FE3DBC000A7EC0E0F0381C18660F18FFFE3DBC00053CC0E0F0300C0000031800F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00000000F0F0F0F00F0F0F0FFFFFFFFF00000000F0F0F0F00F0F0F0FFFFFFFFF00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00000000F0F0F0F00F0F0F0FFFFFFFFF00000000F0F0F0F00F0F0F0FFFFFFFF0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F00180FFFC0018000F180001031818001803C0FFFC003C000F180002071818001807E07EFC3C7E00071800040F181800180FF03CFC3CFF1803FF00080FFF1FF81F1FF800FC3CFF1800FFC0100FFF1FF81F3FFC00FC3C7E000018E0200F001818007FFE00FC003C000018F0400700181800FFFF00FC0018000018F0800300181800095200006618180081F080C00018001820440010FF3C180042F040E000180018042D002CFF18180024E020F00018001880C4003AFF42180018C010F0FFF81FF811113C5C7EE71803180008F0FFF81FF840B47E343C421807240004F0181818000823FF041818181F420002E018181800024AFF00183C181F810001C01818180000F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00000000F0F0F0F00F0F0F0FFFFFFFFF0F000000F0F0F0F00F0F0F0FFFFFFFFF0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00F00FFF00000000F0F0F0F00F0F0F0FFFFFFFFF00000000F0F0F0F00F0F0F0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"

-- the bitmap as 128 lines of 128 "0"/"1"
function Ig.AquaBits
   local tBits, tRow, i, j
   if sAqua["bits"] is not empty then return sAqua["bits"]
   put Ig.AquaReadPBM(Ig.AquaFile()) into tBits
   if the number of lines of tBits is 128 then
      put "from Aquarius.pbm" into sAqua["from"]
   else
      put empty into tBits
      repeat with i = 0 to 127
         put empty into tRow
         repeat with j = 1 to 32
            put char -4 to -1 of ("000" & baseConvert(char (i * 32 + j) of kAquaHex, 16, 2)) after tRow
         end repeat
         put tRow & cr after tBits
      end repeat
      delete the last char of tBits
      put "built in" into sAqua["from"]
   end if
   put tBits into sAqua["bits"]
   return tBits
end Ig.AquaBits

-- Data/Text/Aquarius.pbm beside this script, else LIB_EDITOR/iGame3D_XT above this stack; empty: none
function Ig.AquaFile
   local tDir, tErr, tPath, tTry
   if sAqua["testfile"] is not empty then
      if sAqua["testfile"] is "none" then return empty
      return sAqua["testfile"]
   end if
   set the itemDelimiter to "/"
   put empty into tDir
   try
      put the uScriptFile of (the long owner of me) into tDir
   catch tErr
      put empty into tDir
   end try
   replace "\" with "/" in tDir
   if tDir contains "/" then
      put item 1 to -2 of tDir & "/Data/Text/Aquarius.pbm" into tTry
      if there is a file tTry then return tTry
   end if
   put the effective filename of this stack into tPath
   replace "\" with "/" in tPath
   repeat 8 times
      delete item -1 of tPath
      if tPath is empty then exit repeat
      put tPath & "/LIB_EDITOR/iGame3D_XT/Data/Text/Aquarius.pbm" into tTry
      if there is a file tTry then return tTry
   end repeat
   return empty
end Ig.AquaFile

-- a plain (P1) 128 x 128 PBM -> 128 lines of 128 "0"/"1"; empty if it isn't one
function Ig.AquaReadPBM pPath
   local tText, tLine, tWords, tDigits, tOut, i
   if pPath is empty or there is not a file pPath then return empty
   put URL ("file:" & pPath) into tText
   replace numToChar(13) with empty in tText
   repeat for each line tLine in tText
      if char 1 of tLine is "#" then next repeat
      put tLine & space after tWords
   end repeat
   if word 1 of tWords is not "P1" or word 2 of tWords is not 128 or word 3 of tWords is not 128 then return empty
   put word 4 to -1 of tWords into tDigits
   replace space with empty in tDigits
   replace tab with empty in tDigits
   if the number of chars of tDigits is not 16384 then return empty
   repeat with i = 0 to 127
      put char i * 128 + 1 to i * 128 + 128 of tDigits & cr after tOut
   end repeat
   delete the last char of tOut
   return tOut
end Ig.AquaReadPBM

-- glyph pCode as 8 lines of 8 "0"/"1"
function Ig.AquaGlyph pCode
   local tBits, r, tOut, tCol
   put Ig.AquaBits() into tBits
   put (pCode mod 16) * 8 into tCol
   repeat with r = 1 to 8
      put char tCol + 1 to tCol + 8 of line (pCode div 16) * 8 + r of tBits & cr after tOut
   end repeat
   delete the last char of tOut
   return tOut
end Ig.AquaGlyph

-- a glyph as a wire model on the floor (x across, z away, y up is negative): the outline of
-- its lit pixels, pCell units a pixel, raised pHigh (0: flat). Centred on 0,0.
function Ig.AquaMesh pCode, pCell, pHigh
   local tG, tM, tIdx, r, c, tLit
   put Ig.AquaGlyph(pCode) into tG
   repeat with r = 0 to 7
      repeat with c = 0 to 7
         put (char c + 1 of line r + 1 of tG is "1") into tLit[r, c]
      end repeat
   end repeat
   put Mesh.New() into tM
   put 0 into sAqua["n"]          -- lines made (Ig.AquaSide, Ig.AquaPoint count them)
   repeat with r = 0 to 7
      repeat with c = 0 to 7
         if not tLit[r, c] then next repeat
         if r is 0 or not tLit[r - 1, c] then Ig.AquaSide tM, tIdx, c, r, c + 1, r, pCell, pHigh
         if r is 7 or not tLit[r + 1, c] then Ig.AquaSide tM, tIdx, c, r + 1, c + 1, r + 1, pCell, pHigh
         if c is 0 or not tLit[r, c - 1] then Ig.AquaSide tM, tIdx, c, r, c, r + 1, pCell, pHigh
         if c is 7 or not tLit[r, c + 1] then Ig.AquaSide tM, tIdx, c + 1, r, c + 1, r + 1, pCell, pHigh
      end repeat
   end repeat
   return tM
end Ig.AquaMesh

-- one outline side from grid point a to grid point b, on the floor and (raised) on top, and an
-- upright at each grid point the first time it is used
on Ig.AquaSide @pM, @pIdx, pAC, pAR, pBC, pBR, pCell, pHigh
   local tA, tB
   put Ig.AquaPoint(pM, pIdx, pAC, pAR, pCell, pHigh) into tA
   put Ig.AquaPoint(pM, pIdx, pBC, pBR, pCell, pHigh) into tB
   Mesh.AddLine pM, item 1 of tA, item 1 of tB
   add 1 to sAqua["n"]
   if pHigh > 0 then
      Mesh.AddLine pM, item 2 of tA, item 2 of tB
      add 1 to sAqua["n"]
   end if
end Ig.AquaSide

-- the vertex numbers "floor,top" of grid point (column, row), made when first needed
function Ig.AquaPoint @pM, @pIdx, pC, pR, pCell, pHigh
   local tKey, tX, tZ
   put pC & "," & pR into tKey
   if pIdx[tKey] is not empty then return pIdx[tKey]
   put (pC - 4) * pCell into tX
   put (4 - pR) * pCell into tZ
   Mesh.AddVertex pM, tX, 0, tZ
   put pM["count"] into pIdx[tKey]
   if pHigh > 0 then
      Mesh.AddVertex pM, tX, -pHigh, tZ
      put comma & pM["count"] after pIdx[tKey]
      Mesh.AddLine pM, pM["count"] - 1, pM["count"]
      add 1 to sAqua["n"]
   end if
   return pIdx[tKey]
end Ig.AquaPoint

-- the Library list: the whole level first, then each character
function Ig.AquaList
   local tOut, c, tShow
   get Ig.AquaBits()
   put "ALL 256: THE AQUARIUS LEVEL, FROM ONE BITMAP" & cr into tOut
   repeat with c = 0 to 255
      put empty into tShow
      if c >= 33 and c <= 126 then put "  " & numToChar(c) into tShow
      put "chr " & c & tShow & cr after tOut
   end repeat
   delete the last char of tOut
   return tOut
end Ig.AquaList

-- all 256 lying on the floor, 16 x 16 (one floor square each), as the 2008 aquatext level did,
-- timed: making the 256 models, and placing them
on Ig.AquariusLevel
   local t0, c, tKey, tLines, tVerts, tM, tColor
   Ig.AquaClear
   put the milliseconds into t0
   put 0 into tLines
   put 0 into tVerts
   repeat with c = 0 to 255
      put Ig.AquaMesh(c, 5, 4) into tM
      add tM["count"] to tVerts
      add sAqua["n"] to tLines
      Mesh.Define "Ig.Aqua" & c, tM
   end repeat
   put the milliseconds - t0 into sAqua["make"]
   put the milliseconds into t0
   lock screen
   repeat with c = 0 to 255
      put "#7CFF7C" into tColor
      if c >= 128 then put "#40E0FF" into tColor
      put Entity.Spawn("Ig.Aqua" & c, ((c mod 16) - 7.5) * 50, 0, (7.5 - (c div 16)) * 50, tColor) into tKey
      put tKey & cr after sAqua["keys"]
   end repeat
   unlock screen
   put the milliseconds - t0 into sAqua["place"]
   put tVerts into sAqua["verts"]
   put tLines into sAqua["lines"]
   put 256 into sAqua["models"]
   -- the camera up and back, to see the whole floor
   put 0 into sCamX
   put -560 into sCamY
   put -620 into sCamZ
   Ig.Camera
   Ig.Say "AQUARIUS: 256 MODELS FROM ONE BITMAP (" & toUpper(sAqua["from"]) & "), " & tLines && "LINES.  MADE IN" && sAqua["make"] && "MS, PLACED IN" && sAqua["place"] && "MS"
end Ig.AquariusLevel

-- one character, bigger, in the middle of the floor (a click swaps the last one)
on Ig.AquaSpawn pCode
   local tM, tName
   if pCode < 0 or pCode > 255 then exit Ig.AquaSpawn
   put "Ig.AquaBig" & pCode into tName
   put Ig.AquaMesh(pCode, 20, 12) into tM
   Mesh.Define tName, tM
   if sSelected is not empty and gObjectTransforms[sSelected]["mesh"] begins with "Ig.AquaBig" then Entity.Kill sSelected
   put Entity.Spawn(tName, 0, 0, 0, Ig.NextColor()) into sSelected
   put sSelected & cr after sMade
   Ig.Say "AQUARIUS CHARACTER" && pCode & ":" && tM["count"] && "VERTICES," && sAqua["n"] && "LINES"
end Ig.AquaSpawn

on Ig.AquaClear
   local tKey
   repeat for each line tKey in sAqua["keys"]
      if tKey is not empty then Entity.Kill tKey
   end repeat
   put empty into sAqua["keys"]
end Ig.AquaClear

-- for the tests: where the bitmap came from, models, vertices, lines, ms to make, ms to place
function Ig.AquaStats
   return sAqua["from"] & "|" & sAqua["models"] & "|" & sAqua["verts"] & "|" & sAqua["lines"] & "|" & sAqua["make"] & "|" & sAqua["place"]
end Ig.AquaStats

-- test hook: read the bitmap from pPath ("none": use the built-in copy; empty: as normal)
on Ig.TestAquaFile pPath
   put pPath into sAqua["testfile"]
   put empty into sAqua["bits"]
end Ig.TestAquaFile

-- an iGame3D .wtf model -> a wire mesh: its #Vertices (x,y,z,bone) and #Edges (a,b, from 0),
-- centred and scaled to about 180 units; iGame3D's y is up, Vibecode3D's is down
function Ig.WTFMesh pPath
   local tText, n, tCount, i, tV, tM, minX, maxX, minY, maxY, minZ, maxZ, k, cx, cy, cz, tLine
   put URL ("file:" & pPath) into tText
   replace numToChar(13) with empty in tText
   put Mesh.New() into tM
   put lineOffset("#Vertices:", tText) into n
   if n is 0 then return tM
   put line n + 1 of tText into tCount
   put 1e9 into minX
   put -1e9 into maxX
   put 1e9 into minY
   put -1e9 into maxY
   put 1e9 into minZ
   put -1e9 into maxZ
   repeat with i = 1 to tCount
      put line n + 1 + i of tText into tLine
      put item 1 of tLine into tV[i]["x"]
      put item 2 of tLine into tV[i]["y"]
      put item 3 of tLine into tV[i]["z"]
      put min(minX, tV[i]["x"]) into minX
      put max(maxX, tV[i]["x"]) into maxX
      put min(minY, tV[i]["y"]) into minY
      put max(maxY, tV[i]["y"]) into maxY
      put min(minZ, tV[i]["z"]) into minZ
      put max(maxZ, tV[i]["z"]) into maxZ
   end repeat
   put 180 / max(0.001, max(maxX - minX, max(maxY - minY, maxZ - minZ))) into k
   put (minX + maxX) / 2 into cx
   put (minY + maxY) / 2 into cy
   put (minZ + maxZ) / 2 into cz
   repeat with i = 1 to tCount
      Mesh.AddVertex tM, (tV[i]["x"] - cx) * k, -(tV[i]["y"] - cy) * k, (tV[i]["z"] - cz) * k
   end repeat
   put tCount into sLib["v"]
   put lineOffset("#Edges:", tText) into n
   put 0 into sLib["e"]
   if n > 0 then
      put line n + 1 of tText into tCount
      put tCount into sLib["e"]
      repeat with i = 1 to tCount
         put line n + 1 + i of tText into tLine
         Mesh.AddLine tM, item 1 of tLine + 1, item 2 of tLine + 1
      end repeat
   end if
   return tM
end Ig.WTFMesh

function Ig.ToolList
   local t
   put kTools into t
   replace ";" with cr in t
   return t
end Ig.ToolList

function Ig.GroupColor pGroup
   switch pGroup
      case "primitives"
         return "#40E0FF"
      case "camera tools"
         return "#FFB000"
      case "light"
         return "#FFE060"
      case "actors and effects"
         return "#FF60D0"
      case "editing mode"
         return "#FF5050"
      default
         return kInk
   end switch
end Ig.GroupColor

function Ig.ToolInfo pName
   local tTool
   set the itemDel to "|"
   repeat for each line tTool in Ig.ToolList()
      if item 1 of tTool is pName then return tTool
   end repeat
   return empty
end Ig.ToolInfo

on Ig.Hover pName
   local tTool
   put Ig.ToolInfo(pName) into tTool
   set the itemDel to "|"
   if tTool is not empty then Ig.Say toUpper(item 5 of tTool) & "   (" & toUpper(item 4 of tTool) & ")"
end Ig.Hover

-------------------------------------------------------------------- what the tools do

on Ig.Tool pName
   local tTool, tKey, x, z
   Ig.Wake
   put Ig.ToolInfo(pName) into tTool
   put (random(9) - 5) * 50 into x
   put (random(7) - 4) * 50 into z
   switch pName
      case "sphere"
         Ig.Make "Ig.Sphere", MeshSphere(30, 4, 8), x, z
         break
      case "cone"
         Ig.Make "Ig.Cone", MeshPyramid(8, 30, 60), x, z
         break
      case "cylinder"
         Ig.Make "Ig.Cylinder", MeshPrism(8, 28, 60), x, z
         break
      case "cube"
         Ig.Make "Ig.Cube", MeshBox(50, 50, 50), x, z
         break
      case "quad"
         Ig.Make "Ig.Quad", MeshBox(80, 2, 80), x, z
         break
      case "Terrain"
         Ig.Make "Ig.Terrain", MeshGrid(6, 6, 30), x, z
         break
      case "dropMesh"
         if sSelected is not empty then
            SetObjectPosition sSelected, GetObjectPosition(sSelected, "x"), -15, GetObjectPosition(sSelected, "z")
            Ig.Say "DROPPED THE LAST OBJECT TO THE FLOOR"
         end if
         break
      case "colors"
         if sSelected is not empty then Ig.Recolor
         break
      case "camera"
         put 0 into sCamX
         put -160 into sCamY
         put -520 into sCamZ
         Ig.Camera
         Ig.Say "CAMERA RESET"
         break
      case "GLController"
         put not sOrbit into sOrbit
         Ig.Say "ORBIT" && (sOrbit is true)
         break
      case "Play_Game"
         put not sOrbit into sOrbit
         Ig.Say "PLAY" && (sOrbit is true) && " (THE OLD PLAY BUTTON RAN THE LEVEL'S LUA GAME LOOP)"
         break
      case "light"
         if sLight is not empty then Entity.Kill sLight
         Mesh.Define "Ig.Light", MeshPyramid(4, 10, 20)
         put Entity.Spawn("Ig.Light", x, -200, z, "#FFE060") into sLight
         Ig.Say "A LIGHT MARKER PLACED (VIBECODE3D DRAWS LINES: NO LIGHTING YET)"
         break
      default
         set the itemDel to "|"
         Ig.Say "NOT WIRED YET:" && toUpper(item 5 of tTool) && "- IN iGAME3D:" && toUpper(item 4 of tTool)
   end switch
end Ig.Tool

on Ig.Make pMesh, pGeo, pX, pZ
   Mesh.Define pMesh, pGeo
   put Entity.Spawn(pMesh, pX, -30, pZ, Ig.NextColor()) into sSelected
   put sSelected & cr after sMade
   Ig.Say "MADE" && toUpper(char 4 to -1 of pMesh) && "(" & the number of lines of sMade && "OBJECTS)"
end Ig.Make

function Ig.NextColor
   add 1 to sColorN
   return item (sColorN mod 6) + 1 of "#40E0FF,#FF60D0,#FFB000,#7CFF7C,#FF5050,#D0E8FF"
end Ig.NextColor

-- an object's colour is its graphic: respawn it with the next colour
on Ig.Recolor
   local tMesh, x, y, z
   put gObjectTransforms[sSelected]["mesh"] into tMesh
   put GetObjectPosition(sSelected, "x") into x
   put GetObjectPosition(sSelected, "y") into y
   put GetObjectPosition(sSelected, "z") into z
   Entity.Kill sSelected
   put Entity.Spawn(tMesh, x, y, z, Ig.NextColor()) into sSelected
   put sSelected & cr after sMade
   Ig.Say "RECOLOURED"
end Ig.Recolor

on Ig.Say pText
   Ig.Wake
   if sLayout["msgY"] is not a number then put the height of this card - 44 into sLayout["msgY"]
   if sLayout["msgX"] is not a number then put 10 into sLayout["msgX"]
   HUD.Set "Ig.Msg", pText, sLayout["msgX"], sLayout["msgY"], 11
   put sTicks + 150 into sMsgUntil
end Ig.Say

-------------------------------------------------------------------- the loop

on Game.OnUpdate
   local tKeys
   global gV3DSelected, bStill
   put sSelected into gV3DSelected     -- the Inspector's Object page shows it
   add 1 to sTicks
   put the keysDown into tKeys
   local tStep
   put 8 * 30 / max(15, sLayout["fps"]) into tStep
   if 119 is among the items of tKeys or 65362 is among the items of tKeys then add tStep to sCamZ
   if 115 is among the items of tKeys or 65364 is among the items of tKeys then subtract tStep from sCamZ
   if 97 is among the items of tKeys or 65361 is among the items of tKeys then subtract tStep from sCamX
   if 100 is among the items of tKeys or 65363 is among the items of tKeys then add tStep to sCamX
   if sOrbit then
      put 520 * sin(sTicks / 90) into sCamX
      put -520 * cos(sTicks / 90) into sCamZ
   end if
   Ig.Camera
   if sMsgUntil is a number and sTicks > sMsgUntil then
      HUD.Remove "Ig.Msg"
      put empty into sMsgUntil
   end if
   -- nothing moving (no keys, no orbit, no message to take down): after a few frames the
   -- player stops stepping and drawing until a key, the mouse or Ig.Wake (an idle editor
   -- costs next to no CPU)
   if tKeys is empty and not sOrbit and sMsgUntil is empty then
      add 1 to sLib["still"]
      if sLib["still"] >= 3 then
         put true into bStill
      end if
   else
      put 0 into sLib["still"]
   end if
end Game.OnUpdate

on Game.OnClick pX, pY, pButton
end Game.OnClick

on Game.OnKill pKey, pX, pY, pZ
end Game.OnKill

on Game.OnPause
end Game.OnPause

on Game.OnResume
end Game.OnResume

on Game.OnStop
   global gV3DTickMS
   put empty into gV3DTickMS
   HUD.Clear
   if there is a group "Ig3dTools" then set the visible of group "Ig3dTools" to false
end Game.OnStop

on Collision.Hit pA, pB
end Collision.Hit

-- the arrows move you; a focused menu or field must never get them
on arrowKey pKey
end arrowKey
