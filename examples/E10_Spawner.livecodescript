######################################################################################
## CARD SCRIPT: "Play.Edit_E10"   E10 A SPAWNER  (LIB_EDITOR, 11 18 2026)
## One method: spawn rules (Forge's item and monster parameters: initial, minimum, maximum,
## random chance). The yard's [objects] line "sp1 spawner 12,2 ... what=orb;initial=2;
## min=1;max=4;chance=25;every=30;spread=2" puts two orbs near the M in the east room's
## top corner. Walk into an orb to take it. Take them all and one comes straight back
## (min 1); every 30 steps (one second) there is a one-in-four chance of another, never
## more than 4 at once. They appear on dry, empty ground within 2 cells of the spawner.
## CONTROLS  Arrows or W A S D: walk (take an orb by walking into it)
## NEEDS     ../LIB_BIT/editor (lib_cellmap, tags_default.txt), maps/cards_yard.cellmap
## LESSON    Adding: E10.Spawn (the rules each step) and E10.Take
##           Result: things appear, are taken, come back
## FORMAT    ../LIB_BIT/editor/CELLMAP_V2.md section 5 ([objects]: kind spawner, props:
##           what, initial, min, max, chance in %, every in steps, spread in cells)
######################################################################################

global gCameraYaw, gCameraPitch

local sMap, sTags, sHero, sSp, sOrb, sSeed, sStep, sTaken, sMade, sError, sTestKeys

constant kSpeed = 3
constant kFall = 6
constant kHeroH = 50
constant kReach = 30             -- engine units: an orb this near the hero's centre is taken
constant kColours = "floor #1F4A5A,wall #7FA8FF,pit #FF5040,water #40E0FF,ceiling #9098A8,green #50E070,sky #B8D8FF"

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   put empty into sError
   put empty into sOrb
   put 0 into sStep
   put 0 into sTaken
   put 0 into sMade
   if sSeed is not a number then put the seconds mod 100000 + 1 into sSeed
   put E10.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E10: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E10.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   put CellMap.Read(E10.FindFile("LIB_EDITOR/maps/cards_yard.cellmap")) into sMap
   CellMap.Upgrade sMap
   put CellMap.TagsFromText(CellMap.ReadText(E10.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   E10.FindSpawner
   E10.Build
   repeat sSp["initial"] times
      E10.Make
   end repeat
   E10.TestPlace 9, 2
   Engine.SetCam 0, 700, 650
   put 0 into gCameraYaw
   put -atan2(700, 650) into gCameraPitch
   HUD.Set "E10.Help", "ARROWS OR W A S D: WALK   WALK INTO AN ORB TO TAKE IT: WATCH THEM COME BACK", 20, 146, 11
end Game.OnStart

-- the spawner's object line and its props (defaults when a key is missing)
on E10.FindSpawner
   local n, tObj, tPair, tDef
   put "what=orb;initial=1;min=0;max=1;chance=100;every=30;spread=1" into tDef
   put empty into sSp
   set the itemDel to ";"
   repeat for each item tPair in tDef
      set the itemDel to "="
      put item 2 of tPair into sSp[item 1 of tPair]
      set the itemDel to ";"
   end repeat
   set the itemDel to comma
   put 1 into n
   repeat while n <= CellMap.Count(sMap["objects"])
      put sMap["objects"][n] into tObj
      add 1 to n
      if tObj["kind"] is not "spawner" then next repeat
      put round(item 1 of tObj["at"]) into sSp["col"]
      put round(item 2 of tObj["at"]) into sSp["row"]
      set the itemDel to ";"
      repeat for each item tPair in tObj["props"]
         set the itemDel to "="
         put item 2 of tPair into sSp[item 1 of tPair]
         set the itemDel to ";"
      end repeat
      set the itemDel to comma
      exit repeat
   end repeat
end E10.FindSpawner

on E10.Build
   local tSeg, tE, tMesh, tClass, tPair, tA, tB
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
      Mesh.Define "E10." & tClass, tMesh[tClass]
      get Entity.Spawn("E10." & tClass, 0, 0, 0, word 2 of tPair)
   end repeat
   Mesh.Define "E10.Orb", MeshBox(18, 18, 18)
   Mesh.Define "E10.Hero", MeshBox(24, kHeroH, 24)
   put Entity.Spawn("E10.Hero", 0, 0, 0, "#40E0FF") into sHero["key"]
end E10.Build

-- the method, part 1: the rules, once a step. Fewer than min: one at once. Every "every"
-- steps, below max: "chance" in a hundred of one more
on E10.Spawn
   if the number of lines of the keys of sOrb < sSp["min"] then
      E10.Make
      exit E10.Spawn
   end if
   if sStep mod sSp["every"] is not 0 then exit E10.Spawn
   if the number of lines of the keys of sOrb >= sSp["max"] then exit E10.Spawn
   if E10.Random(100) <= sSp["chance"] then E10.Make
end E10.Spawn

-- one orb on a free cell near the spawner: dry, flat (floor 1), no orb on it yet
on E10.Make
   local tFree, r, c, tCell, tKey
   if the number of lines of the keys of sOrb >= sSp["max"] then exit E10.Make
   repeat with r = sSp["row"] - sSp["spread"] to sSp["row"] + sSp["spread"]
      repeat with c = sSp["col"] - sSp["spread"] to sSp["col"] + sSp["spread"]
         if c < 1 or r < 1 or c > sMap["meta"]["cols"] or r > sMap["meta"]["rows"] then next repeat
         if CellMap.Get(sMap, "floor", c, r) is not 1 or CellMap.Get(sMap, "red", c, r) > 0 then next repeat
         if CellMap.IsWater(sMap, sTags, c, r) then next repeat
         put c & comma & r into tCell
         if sOrb[tCell] is not empty then next repeat
         if tCell is E10.Cell() then next repeat
         put tCell & return after tFree
      end repeat
   end repeat
   if tFree is empty then exit E10.Make
   put line E10.Random(the number of lines of tFree) of tFree into tCell
   put Entity.Spawn("E10.Orb", CellMap.CellX(sMap, item 1 of tCell), -24, CellMap.CellZ(sMap, item 2 of tCell), "#FF60FF") into sOrb[tCell]
   add 1 to sMade
end E10.Make

-- the method, part 2: an orb near the hero's centre is taken
on E10.Take
   local tCell, tGone
   repeat for each key tCell in sOrb
      if abs(CellMap.CellX(sMap, item 1 of tCell) - sHero["x"]) < kReach and abs(CellMap.CellZ(sMap, item 2 of tCell) - sHero["z"]) < kReach then
         put tCell & return after tGone
      end if
   end repeat
   repeat for each line tCell in tGone
      Entity.Kill sOrb[tCell]
      delete variable sOrb[tCell]
      add 1 to sTaken
   end repeat
end E10.Take

-- 1 to pN, from a small generator of our own (Park and Miller's), so a test sees the same orbs
function E10.Random pN
   put (sSeed * 16807) mod 2147483647 into sSeed
   return sSeed mod pN + 1
end E10.Random

on Game.OnUpdate
   if sError is not empty then exit Game.OnUpdate
   add 1 to sStep
   E10.Move E10.Keys()
   E10.Take
   E10.Spawn
   E10.ShowHUD
end Game.OnUpdate

on E10.Move pKeys
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
   put CellMap.StandAt(sMap, sTags, empty, sHero["x"], sHero["z"], sHero["y"]) into tGround
   if tGround is empty then put sHero["y"] into tGround
   if tGround >= sHero["y"] then
      put tGround into sHero["y"]
   else
      put max(tGround, sHero["y"] - kFall) into sHero["y"]
   end if
   SetObjectPosition sHero["key"], sHero["x"], -sHero["y"] - kHeroH / 2, sHero["z"]
end E10.Move

function E10.Cell
   return CellMap.CellAt(sMap, sHero["x"], sHero["z"])
end E10.Cell

on E10.ShowHUD
   HUD.Set "E10.Cell", "E10 A SPAWNER   ORBS" && the number of lines of the keys of sOrb && "OF AT MOST" && sSp["max"] && \
         "  TAKEN" && sTaken && "  MADE" && sMade, 20, 120, 14
end E10.ShowHUD

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

function E10.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E10.Keys

on E10.TestKeys pKeys
   put pKeys into sTestKeys
end E10.TestKeys

-- tests: a fixed seed before Game.OnStart, so the orbs fall the same way every run
on E10.TestSeed pSeed
   put pSeed into sSeed
end E10.TestSeed

on E10.TestPlace pCol, pRow
   put CellMap.CellX(sMap, pCol) into sHero["x"]
   put CellMap.CellZ(sMap, pRow) into sHero["z"]
   put CellMap.GroundAt(sMap, sTags, empty, sHero["x"], sHero["z"]) into sHero["y"]
   SetObjectPosition sHero["key"], sHero["x"], -sHero["y"] - kHeroH / 2, sHero["z"]
end E10.TestPlace

-- tests: the cells with an orb, sorted, one a line
function E10.Orbs
   local tK
   put the keys of sOrb into tK
   sort lines of tK
   return tK
end E10.Orbs

-- hero's cell | orbs now | taken | made | the rules | error
function E10.State
   return E10.Cell() & "|orbs " & the number of lines of the keys of sOrb & "|taken " & sTaken & "|made " & sMade & "|min " & sSp["min"] & " max " & sSp["max"] & " chance " & sSp["chance"] & " every " & sSp["every"] & "|" & sError
end E10.State

function E10.FindFile pRelPath
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
end E10.FindFile
