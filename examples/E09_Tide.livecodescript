######################################################################################
## CARD SCRIPT: "Play.Edit_E09"   E09 WATER WITH A TIDE  (LIB_EDITOR, 11 18 2026)
## One method: an animated level (Forge's liquids, which rise and fall). The yard's pool
## steps down east, 20, 40 and 60 hu deep. An [objects] line "tide1 tide 11,5 ...
## low=-50;high=0;period=240" makes its water breathe: brim-full, then down 50 hu, then
## back, every 240 steps (8 seconds at 30 a second). Walk in: the deeper the water over
## your feet, the slower you go. At low tide the shallow end is dry.
## CONTROLS  Arrows or W A S D: walk
## NEEDS     ../LIB_BIT/editor (lib_cellmap, tags_default.txt), maps/cards_yard.cellmap
## LESSON    Adding: E09.Tide (the level from the clock) and E09.Speed (depth slows you)
##           Result: a pool that fills and empties, and wading that feels like wading
## FORMAT    ../LIB_BIT/editor/CELLMAP_V2.md section 5 ([objects]: id kind col,row facing
##           above props); kind "tide": low / high = the surface in hu from the cell's
##           floor (0 = the brim, -50 = 50 hu down), period = steps for one rise and fall.
##           It acts on the water cells joined to its col,row
######################################################################################

global gCameraYaw, gCameraPitch

local sMap, sTags, sHero, sWater, sTide, sStep, sError, sTestKeys

constant kSpeed = 3              -- engine units a step, dry
constant kWade = 2               -- water up to kWaist hu over the feet
constant kSwim = 1               -- deeper than that
constant kWaist = 40
constant kFall = 6
constant kHeroH = 50
constant kColours = "floor #1F4A5A,wall #7FA8FF,pit #FF5040,ceiling #9098A8,green #50E070,sky #B8D8FF"

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   put empty into sError
   put 0 into sStep
   put E09.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E09: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E09.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   put CellMap.Read(E09.FindFile("LIB_EDITOR/maps/cards_yard.cellmap")) into sMap
   CellMap.Upgrade sMap
   put CellMap.TagsFromText(CellMap.ReadText(E09.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   E09.FindTide
   E09.Build
   E09.TestPlace 9, 5
   E09.Tide
   Engine.SetCam 0, 700, 650
   put 0 into gCameraYaw
   put -atan2(700, 650) into gCameraPitch
   HUD.Set "E09.Help", "ARROWS OR W A S D: WALK INTO THE POOL (EAST ROOM)   DEEPER WATER, SLOWER FEET", 20, 146, 11
end Game.OnStart

-- the tide's object line, its props, and the water cells joined to it (a flood fill)
on E09.FindTide
   local n, tObj, tTodo, tCell, tC, tR, tNext
   put empty into sTide
   put empty into sWater
   put 1 into n
   repeat while n <= CellMap.Count(sMap["objects"])
      put sMap["objects"][n] into tObj
      add 1 to n
      if tObj["kind"] is not "tide" then next repeat
      put E09.Prop(tObj["props"], "low") into sTide["low"]
      put E09.Prop(tObj["props"], "high") into sTide["high"]
      put E09.Prop(tObj["props"], "period") into sTide["period"]
      put round(item 1 of tObj["at"]) & comma & round(item 2 of tObj["at"]) into tTodo
      exit repeat
   end repeat
   repeat while tTodo is not empty
      put line 1 of tTodo into tCell
      delete line 1 of tTodo
      if tCell is among the lines of sWater["cells"] then next repeat
      put item 1 of tCell into tC
      put item 2 of tCell into tR
      if tC < 1 or tR < 1 or tC > sMap["meta"]["cols"] or tR > sMap["meta"]["rows"] then next repeat
      if not CellMap.IsWater(sMap, sTags, tC, tR) then next repeat
      put tCell & return after sWater["cells"]
      repeat for each item tNext in (tC + 1) & ":" & tR & "," & (tC - 1) & ":" & tR & "," & tC & ":" & (tR + 1) & "," & tC & ":" & (tR - 1)
         replace ":" with comma in tNext
         put return & tNext after tTodo
      end repeat
   end repeat
   filter sWater["cells"] without empty
end E09.FindTide

-- one key of a props string "a=1;b=2"
function E09.Prop pProps, pKey
   local tPair
   set the itemDel to ";"
   repeat for each item tPair in pProps
      if tPair begins with (pKey & "=") then return char (length(pKey) + 2) to -1 of tPair
   end repeat
   return empty
end E09.Prop

-- the level as wires (the pool's still water sheet left out: the tide draws its own),
-- a thin sheet over each tide cell, the hero
on E09.Build
   local tSeg, tE, tMesh, tClass, tPair, tA, tB, tCell
   Scene.ClearAll
   repeat for each line tSeg in CellMap.LevelSegments(sMap, sTags, empty)
      put item 7 of tSeg into tClass
      if tClass is "water" then next repeat
      if tMesh[tClass] is not an array then put Mesh.New() into tMesh[tClass]
      put CellMap.SegToEngine(sMap, tSeg) into tE
      Mesh.AddVertex tMesh[tClass], item 1 of tE, -(item 2 of tE), item 3 of tE
      put the result into tA
      Mesh.AddVertex tMesh[tClass], item 4 of tE, -(item 5 of tE), item 6 of tE
      put the result into tB
      Mesh.AddLine tMesh[tClass], tA, tB
   end repeat
   repeat for each item tPair in kColours
      put word 1 of tPair into tClass
      if tMesh[tClass] is not an array then next repeat
      Mesh.Define "E09." & tClass, tMesh[tClass]
      get Entity.Spawn("E09." & tClass, 0, 0, 0, word 2 of tPair)
   end repeat
   Mesh.Define "E09.Sheet", MeshBox(sMap["meta"]["cell"], 1, sMap["meta"]["cell"])
   repeat for each line tCell in sWater["cells"]
      put Entity.Spawn("E09.Sheet", CellMap.CellX(sMap, item 1 of tCell), 0, CellMap.CellZ(sMap, item 2 of tCell), "#40E0FF") into sWater["key"][tCell]
   end repeat
   Mesh.Define "E09.Hero", MeshBox(24, kHeroH, 24)
   put Entity.Spawn("E09.Hero", 0, 0, 0, "#FFD040") into sHero["key"]
end E09.Build

-- the method, part 1: the surface from the clock. Brim-full (high) at step 0, low half a period
-- later, back at high after a whole one; a cosine, so it slows at the top and the bottom
on E09.Tide
   local tF, tCell, tLevel
   if sTide["period"] is not a number or sTide["period"] <= 0 then exit E09.Tide
   put sTide["high"] - (sTide["high"] - sTide["low"]) * (1 - cos(2 * pi * sStep / sTide["period"])) / 2 into tLevel
   put round(tLevel) into sTide["level"]
   repeat for each line tCell in sWater["cells"]
      -- never below the cell's bottom: at low tide the shallow end is dry
      put CellMap.Get(sMap, "floor", item 1 of tCell, item 2 of tCell) into tF
      put max(tF - CellMap.Get(sMap, "red", item 1 of tCell, item 2 of tCell), tF + sTide["level"]) into tF
      put tF into sWater["surface"][tCell]
      SetObjectPosition sWater["key"][tCell], CellMap.CellX(sMap, item 1 of tCell), -tF * CellMap.HU(sMap), CellMap.CellZ(sMap, item 2 of tCell)
   end repeat
end E09.Tide

-- the method, part 2: hu of water over the hero's feet (0 when dry) and the speed it leaves
function E09.Depth
   local tCell, tS
   put E09.Cell() into tCell
   put sWater["surface"][tCell] into tS
   if tS is empty then return 0
   return max(0, round(tS - sHero["y"] / CellMap.HU(sMap)))
end E09.Depth

function E09.Speed
   local tD
   put E09.Depth() into tD
   if tD <= 0 then return kSpeed
   if tD <= kWaist then return kWade
   return kSwim
end E09.Speed

on Game.OnUpdate
   if sError is not empty then exit Game.OnUpdate
   add 1 to sStep
   E09.Tide
   E09.Move E09.Keys()
   E09.ShowHUD
end Game.OnUpdate

on E09.Move pKeys
   local tDX, tDZ, tW, tGround, tV
   put E09.Speed() into tV
   put 0 into tDX
   put 0 into tDZ
   if 65362 is among the items of pKeys or 119 is among the items of pKeys then subtract tV from tDZ
   if 65364 is among the items of pKeys or 115 is among the items of pKeys then add tV to tDZ
   if 65361 is among the items of pKeys or 97 is among the items of pKeys then subtract tV from tDX
   if 65363 is among the items of pKeys or 100 is among the items of pKeys then add tV to tDX
   put CellMap.Walk(sMap, sTags, empty, sHero["x"], sHero["z"], sHero["y"], tDX, tDZ, 12) into tW
   put item 1 of tW into sHero["x"]
   put item 2 of tW into sHero["z"]
   put CellMap.StandAt(sMap, sTags, empty, sHero["x"], sHero["z"], sHero["y"]) into tGround
   if tGround is empty then put sHero["y"] into tGround
   if tGround >= sHero["y"] then
      put tGround into sHero["y"]
   else
      put max(tGround, sHero["y"] - kFall) into sHero["y"]
   end if
   SetObjectPosition sHero["key"], sHero["x"], -sHero["y"] - kHeroH / 2, sHero["z"]
end E09.Move

function E09.Cell
   return CellMap.CellAt(sMap, sHero["x"], sHero["z"])
end E09.Cell

on E09.ShowHUD
   HUD.Set "E09.Cell", "E09 WATER WITH A TIDE   SURFACE" && sTide["level"] && "HU FROM THE BRIM   YOU ARE ON" && E09.Cell() && \
         "  WATER OVER YOUR FEET" && E09.Depth() && "HU   SPEED" && E09.Speed(), 20, 120, 14
end E09.ShowHUD

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

function E09.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E09.Keys

on E09.TestKeys pKeys
   put pKeys into sTestKeys
end E09.TestKeys

-- tests: the hero on the centre of cell pCol,pRow, on its ground
on E09.TestPlace pCol, pRow
   put CellMap.CellX(sMap, pCol) into sHero["x"]
   put CellMap.CellZ(sMap, pRow) into sHero["z"]
   put CellMap.GroundAt(sMap, sTags, empty, sHero["x"], sHero["z"]) into sHero["y"]
   SetObjectPosition sHero["key"], sHero["x"], -sHero["y"] - kHeroH / 2, sHero["z"]
end E09.TestPlace

-- tests: set the tide's clock
on E09.TestClock pStep
   put pStep into sStep
   E09.Tide
end E09.TestClock

-- hero's cell | x in engine units | ground in hu | tide level | water over the feet | speed | tide cells | error
function E09.State
   return E09.Cell() & "|x " & round(sHero["x"]) & "|y " & round(sHero["y"] / CellMap.HU(sMap)) & "|tide " & sTide["level"] & "|depth " & E09.Depth() & "|speed " & E09.Speed() & "|cells " & the number of lines of sWater["cells"] & "|" & sError
end E09.State

function E09.FindFile pRelPath
   local tPath, tTry
   put the effective filename of this stack into tPath
   set the itemDel to "/"
   repeat 6 times
      delete item -1 of tPath
      if tPath is empty then exit repeat
      put tPath & "/" & pRelPath into tTry
      if there is a file tTry then return tTry
   end repeat
   put "//wsl$/Ubuntu/home/igame3d/projects/" & pRelPath into tTry
   if there is a file tTry then return tTry
   return empty
end E09.FindFile
