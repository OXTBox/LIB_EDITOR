######################################################################################
## CARD SCRIPT: "Play.Edit_E08"   E08 TELEPORTER PAIRS  (LIB_EDITOR, 11 18 2026)
## One method: links between cells (Forge's teleporter polygons). The map's [links] say
## "3,2 teleport 13,9" and "13,9 teleport 3,2": step onto the red pad in the west room and
## you stand on its partner in the east room's far corner. Arriving is not entering: you
## can stand on the far pad as long as you like and nothing happens. Step off and back
## on, and it sends you home.
## CONTROLS  Arrows or W A S D: walk
## NEEDS     ../LIB_BIT/editor (lib_cellmap, tags_default.txt), maps/cards_yard.cellmap
## LESSON    Adding: E08.Teleport (a teleport link moves the hero; arriving is not entering)
##           Result: a pad here, its partner over there, and no bouncing between them
## FORMAT    ../LIB_BIT/editor/CELLMAP_V2.md section 5 ([links]: from, type teleport, to)
######################################################################################

global gCameraYaw, gCameraPitch

local sMap, sTags, sHero, sKeyWas, sCellWas, sSaid, sJumps, sError, sTestKeys

constant kSpeed = 3              -- engine units a step
constant kFall = 6               -- engine units a step, dropping
constant kHeroH = 50
constant kColours = "floor #1F4A5A,wall #7FA8FF,pit #FF5040,water #40E0FF,ceiling #9098A8,green #50E070,sky #B8D8FF"

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   put empty into sError
   put empty into sKeyWas
   put empty into sSaid
   put 0 into sJumps
   put E08.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E08: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E08.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   put CellMap.Read(E08.FindFile("LIB_EDITOR/maps/cards_yard.cellmap")) into sMap
   CellMap.Upgrade sMap
   put CellMap.TagsFromText(CellMap.ReadText(E08.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   E08.Build
   E08.TestPlace 3, 5
   Engine.SetCam 0, 700, 650
   put 0 into gCameraYaw
   put -atan2(700, 650) into gCameraPitch
   HUD.Set "E08.Help", "ARROWS OR W A S D: WALK   STEP ON A RED PAD (T): YOU ARRIVE ON ITS PARTNER", 20, 146, 11
end Game.OnStart

-- the level as wires, a flat red pad on each end of a teleport link, the hero
on E08.Build
   local tSeg, tE, tMesh, tClass, tPair, tA, tB, n
   Scene.ClearAll
   repeat for each line tSeg in CellMap.LevelSegments(sMap, sTags, empty)
      put item 7 of tSeg into tClass
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
      Mesh.Define "E08." & tClass, tMesh[tClass]
      get Entity.Spawn("E08." & tClass, 0, 0, 0, word 2 of tPair)
   end repeat
   Mesh.Define "E08.Pad", MeshBox(sMap["meta"]["cell"] - 20, 4, sMap["meta"]["cell"] - 20)
   put 1 into n
   repeat while n <= CellMap.Count(sMap["links"])
      if sMap["links"][n]["type"] is "teleport" then
         E08.Pad sMap["links"][n]["from"]
         if sMap["links"][n]["to"] is not empty then E08.Pad word 1 of sMap["links"][n]["to"]
      end if
      add 1 to n
   end repeat
   Mesh.Define "E08.Hero", MeshBox(24, kHeroH, 24)
   put Entity.Spawn("E08.Hero", 0, 0, 0, "#40E0FF") into sHero["key"]
end E08.Build

on E08.Pad pCell
   local tY
   put CellMap.GroundAt(sMap, sTags, empty, CellMap.CellX(sMap, item 1 of pCell), CellMap.CellZ(sMap, item 2 of pCell)) into tY
   get Entity.Spawn("E08.Pad", CellMap.CellX(sMap, item 1 of pCell), -tY - 2, CellMap.CellZ(sMap, item 2 of pCell), "#B20909")
end E08.Pad

-- the method: the hero has just ENTERED pCell ("col,row") by walking. A teleport link from it
-- puts the hero on the centre of its target, standing on the ground there. The target becomes
-- the cell the hero is "already in", so arriving on the partner pad does not count as entering it
on E08.Teleport pCell
   local n, tTo
   put 1 into n
   repeat while n <= CellMap.Count(sMap["links"])
      if sMap["links"][n]["from"] is pCell and sMap["links"][n]["type"] is "teleport" then
         put word 1 of sMap["links"][n]["to"] into tTo
         if tTo is empty then exit repeat
         put CellMap.CellX(sMap, item 1 of tTo) into sHero["x"]
         put CellMap.CellZ(sMap, item 2 of tTo) into sHero["z"]
         put CellMap.GroundAt(sMap, sTags, empty, sHero["x"], sHero["z"]) into sHero["y"]
         put tTo into sCellWas
         add 1 to sJumps
         put toUpper("teleport:" && sMap["links"][n]["note"]) into sSaid
         SetObjectPosition sHero["key"], sHero["x"], -sHero["y"] - kHeroH / 2, sHero["z"]
         exit repeat
      end if
      add 1 to n
   end repeat
end E08.Teleport

on Game.OnUpdate
   local tKeys, tCell
   if sError is not empty then exit Game.OnUpdate
   put E08.Keys() into tKeys
   E08.Move tKeys
   put E08.Cell() into tCell
   if tCell is not sCellWas then
      put tCell into sCellWas
      E08.Teleport tCell
   end if
   E08.ShowHUD
end Game.OnUpdate

-- the hero: a box the map walks (CellMap.Walk), north / west / south / east
on E08.Move pKeys
   local tDX, tDZ, tW, tGround
   put 0 into tDX
   put 0 into tDZ
   if 65362 is among the items of pKeys or 119 is among the items of pKeys then subtract kSpeed from tDZ
   if 65364 is among the items of pKeys or 115 is among the items of pKeys then add kSpeed to tDZ
   if 65361 is among the items of pKeys or 97 is among the items of pKeys then subtract kSpeed from tDX
   if 65363 is among the items of pKeys or 100 is among the items of pKeys then add kSpeed to tDX
   put CellMap.Walk(sMap, sTags, empty, sHero["x"], sHero["z"], sHero["y"], tDX, tDZ, 12) into tW
   put item 1 of tW into sHero["x"]
   put item 2 of tW into sHero["z"]
   put item 4 of tW into sHero["effect"]
   put CellMap.StandAt(sMap, sTags, empty, sHero["x"], sHero["z"], sHero["y"]) into tGround
   if tGround is empty then put sHero["y"] into tGround
   if tGround >= sHero["y"] then
      put tGround into sHero["y"]
   else
      put max(tGround, sHero["y"] - kFall) into sHero["y"]
   end if
   SetObjectPosition sHero["key"], sHero["x"], -sHero["y"] - kHeroH / 2, sHero["z"]
end E08.Move

function E08.Cell
   return CellMap.CellAt(sMap, sHero["x"], sHero["z"])
end E08.Cell

on E08.ShowHUD
   HUD.Set "E08.Cell", "E08 TELEPORTER PAIRS   YOU ARE ON" && E08.Cell() & "   JUMPS" && sJumps & "   " & sSaid, 20, 120, 14
end E08.ShowHUD

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

function E08.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E08.Keys

on E08.TestKeys pKeys
   put pKeys into sTestKeys
end E08.TestKeys

-- tests: the hero on the centre of cell pCol,pRow, on its ground
on E08.TestPlace pCol, pRow
   put CellMap.CellX(sMap, pCol) into sHero["x"]
   put CellMap.CellZ(sMap, pRow) into sHero["z"]
   put CellMap.GroundAt(sMap, sTags, empty, sHero["x"], sHero["z"]) into sHero["y"]
   put "path" into sHero["effect"]
   put CellMap.CellAt(sMap, sHero["x"], sHero["z"]) into sCellWas
   SetObjectPosition sHero["key"], sHero["x"], -sHero["y"] - kHeroH / 2, sHero["z"]
end E08.TestPlace

-- hero's cell | height in hu | effect | jumps so far | what the last teleport said | error
function E08.State
   return E08.Cell() & "|y " & round(sHero["y"] / CellMap.HU(sMap)) & "|" & sHero["effect"] & "|jumps " & sJumps & "|" & sSaid & "|" & sError
end E08.State

function E08.FindFile pRelPath
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
end E08.FindFile
