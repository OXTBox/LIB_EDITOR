######################################################################################
## CARD SCRIPT: "Play.Edit_E14"   E14 STACKED MAPS  (LIB_EDITOR, 11 18 2026)
## One method: a room above a room (the Tomb Raider Level Editor's stacked rooms, Forge's
## basements). Two small maps: the ground floor, and a loft whose zero sits 120 hu higher.
## The ground floor's [stack] line lays the loft over it: "cards_upper.cellmap 120 1,1".
## Nothing joins them but geometry: a ramp along the south wall climbs 30 hu a cell to
## 121, under a hole in the loft, and you walk off its top onto the loft's deck. The
## goal (X) is in the loft's far corner. Walk back into the hole and you drop down.
## The ground floor is drawn in teal, the loft in orange.
## CONTROLS  Arrows or W A S D: walk
## NEEDS     ../LIB_BIT/editor (lib_cellmap: ReadPack, PackSegments, PackWalk, PackStandAt,
##           tags_default.txt), maps/cards_lower.cellmap + maps/cards_upper.cellmap
## LESSON    Adding: E14.Load (a map and what is stacked on it, as one place) and
##           E14.Move (every map of the place answers where you can stand)
##           Result: up the ramp, through the hole, and you are upstairs
## FORMAT    ../LIB_BIT/editor/CELLMAP_V2.md section 5 ([stack]: file, base, col,row) and
##           CELLMAP_V3.md section 3 (stacked maps: decks, holes, stairs and ramps)
######################################################################################

global gCameraYaw, gCameraPitch

local sPack, sPlace, sTags, sHero, sError, sTestKeys

constant kSpeed = 3
constant kFall = 6
constant kHeroH = 50
constant kColours = "floor #1F4A5A,wall #7FA8FF,pit #FF5040,water #40E0FF,ceiling #9098A8,green #50E070,sky #B8D8FF"
constant kUpper = "#FFA040"      -- every line of a stacked map (the loft), whatever its class

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   put empty into sError
   put E14.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E14: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E14.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   put CellMap.TagsFromText(CellMap.ReadText(E14.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   E14.Load E14.FindFile("LIB_EDITOR/maps/cards_lower.cellmap")
   if sError is not empty then exit Game.OnStart
   E14.Build
   E14.Start
   Engine.SetCam 0, 760, 620
   put 0 into gCameraYaw
   put -atan2(760, 620) into gCameraPitch
   HUD.Set "E14.Help", "ARROWS OR W A S D: WALK   UP THE RAMP ALONG THE SOUTH WALL TO THE LOFT, THEN THE X", 20, 146, 11
end Game.OnStart

-- the method, part 1: a map and every map its [stack] lays over it, read as one place
-- (CellMap.ReadPack opens a .cellmap as a pack: the map itself, then its stacked maps)
on E14.Load pPath
   put CellMap.ReadPack(pPath) into sPack
   if sPack["problems"] is not empty then
      put "E14: " & toUpper(line 1 of sPack["problems"]) into sError
      HUD.Set "E14.Err", sError, 20, 120, 14
      exit E14.Load
   end if
   put sPack["maps"][1]["place"] into sPlace
end E14.Load

-- the hero on the start (@), as the pack says
on E14.Start
   local tAt
   put CellMap.PackEnter(sPack, sTags, empty, empty) into tAt
   put item 2 of tAt into sHero["x"]
   put item 3 of tAt into sHero["z"]
   put item 4 of tAt into sHero["y"]
   put sPack["maps"][1]["id"] into sHero["map"]
   put "start" into sHero["effect"]
   E14.ShowHero
end E14.Start

-- the place as wires (PackSegments: engine units, the map id as an 8th item), the hero
on E14.Build
   local tSeg, tMesh, tKey, tPair, tA, tB, tColour
   Scene.ClearAll
   repeat for each line tSeg in CellMap.PackSegments(sPack, sPlace, sTags, empty)
      put item 7 of tSeg into tKey
      if item 8 of tSeg is not sPack["maps"][1]["id"] then put "upper" into tKey
      if tMesh[tKey] is not an array then put Mesh.New() into tMesh[tKey]
      Mesh.AddVertex tMesh[tKey], item 1 of tSeg, -(item 2 of tSeg), item 3 of tSeg
      put the result into tA
      Mesh.AddVertex tMesh[tKey], item 4 of tSeg, -(item 5 of tSeg), item 6 of tSeg
      put the result into tB
      Mesh.AddLine tMesh[tKey], tA, tB
   end repeat
   repeat for each item tPair in kColours & ",upper" && kUpper
      put word 1 of tPair into tKey
      if tMesh[tKey] is not an array then next repeat
      Mesh.Define "E14." & tKey, tMesh[tKey]
      get Entity.Spawn("E14." & tKey, 0, 0, 0, word 2 of tPair)
   end repeat
   Mesh.Define "E14.Hero", MeshBox(24, kHeroH, 24)
   put Entity.Spawn("E14.Hero", 0, 0, 0, "#40E0FF") into sHero["key"]
end E14.Build

on Game.OnUpdate
   if sError is not empty then exit Game.OnUpdate
   E14.Move E14.Keys()
   E14.ShowHUD
end Game.OnUpdate

-- the method, part 2: every map of the place answers where the hero can stand (PackWalk):
-- the ramp's top, the loft's deck over the ground floor's air, the hole that drops you
on E14.Move pKeys
   local tDX, tDZ, tW, tGround
   put 0 into tDX
   put 0 into tDZ
   if 65362 is among the items of pKeys or 119 is among the items of pKeys then subtract kSpeed from tDZ
   if 65364 is among the items of pKeys or 115 is among the items of pKeys then add kSpeed to tDZ
   if 65361 is among the items of pKeys or 97 is among the items of pKeys then subtract kSpeed from tDX
   if 65363 is among the items of pKeys or 100 is among the items of pKeys then add kSpeed to tDX
   put CellMap.PackWalk(sPack, sPlace, sTags, empty, sHero["x"], sHero["z"], sHero["y"], tDX, tDZ, 12) into tW
   put item 1 of tW into sHero["x"]
   put item 2 of tW into sHero["z"]
   if item 4 of tW is not empty then put item 4 of tW into sHero["effect"]
   if item 5 of tW is not empty then put item 5 of tW into sHero["map"]
   put item 1 of CellMap.PackStandAt(sPack, sPlace, sTags, empty, sHero["x"], sHero["z"], sHero["y"]) into tGround
   if tGround is empty then put sHero["y"] into tGround
   if tGround >= sHero["y"] then
      put tGround into sHero["y"]
   else
      put max(tGround, sHero["y"] - kFall) into sHero["y"]
   end if
   E14.ShowHero
end E14.Move

on E14.ShowHero
   SetObjectPosition sHero["key"], sHero["x"], -sHero["y"] - kHeroH / 2, sHero["z"]
end E14.ShowHero

-- the cell under the hero, counted on the ground floor (the loft lies over it at 1,1)
function E14.Cell
   return CellMap.CellAt(sPack["maps"][1]["map"], sHero["x"] - sPack["maps"][1]["ox"], sHero["z"] - sPack["maps"][1]["oz"])
end E14.Cell

function E14.HU
   return CellMap.HU(sPack["maps"][1]["map"])
end E14.HU

on E14.ShowHUD
   local tWhere
   put "THE GROUND FLOOR" into tWhere
   if sHero["map"] is not sPack["maps"][1]["id"] then put "THE LOFT" into tWhere
   if sHero["effect"] is "goal" then put tWhere & ": THE GOAL!" into tWhere
   HUD.Set "E14.Cell", "E14 STACKED MAPS   YOU ARE ON" && E14.Cell() && "OF" && tWhere && "  STANDING AT" && round(sHero["y"] / E14.HU()) && "HU", 20, 120, 14
end E14.ShowHUD

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

function E14.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E14.Keys

on E14.TestKeys pKeys
   put pKeys into sTestKeys
end E14.TestKeys

-- tests: the hero on the centre of cell pCol,pRow, on the highest ground it could reach
-- from pY hu (1: the ground floor under the loft; 200: the loft's deck)
on E14.TestPlace pCol, pRow, pY
   local tOn
   put CellMap.CellX(sPack["maps"][1]["map"], pCol) + sPack["maps"][1]["ox"] into sHero["x"]
   put CellMap.CellZ(sPack["maps"][1]["map"], pRow) + sPack["maps"][1]["oz"] into sHero["z"]
   put CellMap.PackStandAt(sPack, sPlace, sTags, empty, sHero["x"], sHero["z"], pY * E14.HU()) into tOn
   put item 1 of tOn into sHero["y"]
   put item 2 of tOn into sHero["map"]
   E14.ShowHero
end E14.TestPlace

-- hero's cell | which map it stands on | height in hu | effect | maps in the place | error
function E14.State
   return E14.Cell() & "|" & sHero["map"] & "|y " & round(sHero["y"] / E14.HU()) & "|" & sHero["effect"] & "|maps " & sPack["count"] & "|" & sError
end E14.State

function E14.FindFile pRelPath
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
end E14.FindFile
