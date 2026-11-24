######################################################################################
## CARD SCRIPT: "Play.Edit_E06"   E06 A DOOR THAT RISES  (LIB_EDITOR, 11 18 2026)
## One method: effects in play (Forge's platforms). Every door cell (+) of the map is a
## block from its floor to the roof top. When the hero comes within a cell and a half,
## the door's bottom (its ceiling) rises 4 hu a step until there is a hallway of air
## under it; when the hero walks away it comes down again. Nothing else moves the hero:
## CellMap.Walk reads the door's heights every step, so a half-open door still stops you.
## CONTROLS  Arrows or W A S D: walk north, west, south, east
## NEEDS     ../LIB_BIT/editor (lib_cellmap, tags_default.txt), maps/cards_yard.cellmap
## LESSON    Adding: a door's ceiling moved every step  Result: the wall opens as you come
## FORMAT    ../LIB_BIT/editor/CELLMAP_V2.md section 3 (a roof at the ground is solid)
######################################################################################

global gCameraYaw, gCameraPitch

local sMap, sTags, sHero, sDoor, sKeyWas, sError, sTestKeys

constant kSpeed = 3              -- engine units a step
constant kFall = 6               -- engine units a step, dropping
constant kHeroH = 50
constant kNear = 1.5             -- cells: this close, a door opens
constant kDoorSpeed = 4          -- hu a step
constant kShut = 1               -- a door's ceiling when shut (at the floor: solid)
constant kOpen = 100             -- and open (a hallway)
constant kColours = "floor #1F4A5A,wall #7FA8FF,pit #FF5040,water #40E0FF,ceiling #9098A8,green #50E070,sky #B8D8FF"

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   put empty into sError
   put empty into sKeyWas
   put E06.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E06: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E06.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   -- the Lean style: a map saved lean draws lean (optional, the level draws without it)
   put E06.FindFile("LIB_BIT/livecode/lib_lean.livecodescript") into tLib
   if tLib is not empty then start using stack tLib
   put CellMap.Read(E06.FindFile("LIB_EDITOR/maps/cards_yard.cellmap")) into sMap
   CellMap.Upgrade sMap
   put CellMap.TagsFromText(CellMap.ReadText(E06.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   E06.Build
   E06.TestPlace 3, 5
   Engine.SetCam 0, 700, 650
   put 0 into gCameraYaw
   put -atan2(700, 650) into gCameraPitch
   HUD.Set "E06.Help", "ARROWS OR W A S D: WALK   GO TO A DOOR (+) AND IT RISES", 20, 146, 11
end Game.OnStart

-- the level as wires (drawn with every door open: the doorway's frame), a box for each door, the hero
on E06.Build
   local tDraw, r, c, tSeg, tE, tMesh, tClass, tPair, tA, tB, n
   Scene.ClearAll
   put sMap into tDraw
   put 0 into n
   put 1 into r
   repeat while r <= sMap["meta"]["rows"]
      put 1 into c
      repeat while c <= sMap["meta"]["cols"]
         if sMap["tags"][r][c] is "+" then
            add 1 to n
            put c into sDoor[n]["col"]
            put r into sDoor[n]["row"]
            put kShut into sDoor[n]["ceiling"]
            put kOpen into tDraw["ceiling"][r][c]
            put 2 into tDraw["from"][r][c]
         end if
         add 1 to c
      end repeat
      add 1 to r
   end repeat
   put n into sDoor["count"]
   repeat for each line tSeg in E06.LevelSegments(tDraw)
      put item 7 of tSeg into tClass
      if tMesh[tClass] is not an array then put Mesh.New() into tMesh[tClass]
      put CellMap.SegToEngine(tDraw, tSeg) into tE
      Mesh.AddVertex tMesh[tClass], item 1 of tE, -(item 2 of tE), item 3 of tE
      put the result into tA
      Mesh.AddVertex tMesh[tClass], item 4 of tE, -(item 5 of tE), item 6 of tE
      put the result into tB
      Mesh.AddLine tMesh[tClass], tA, tB
   end repeat
   repeat for each item tPair in kColours
      put word 1 of tPair into tClass
      if tMesh[tClass] is not an array then next repeat
      Mesh.Define "E06." & tClass, tMesh[tClass]
      get Entity.Spawn("E06." & tClass, 0, 0, 0, word 2 of tPair)
   end repeat
   Mesh.Define "E06.Door", MeshBox(sMap["meta"]["cell"] - 6, kOpen * CellMap.HU(sMap), sMap["meta"]["cell"] - 6)
   put 1 into n
   repeat while n <= sDoor["count"]
      put Entity.Spawn("E06.Door", CellMap.CellX(sMap, sDoor[n]["col"]), 0, CellMap.CellZ(sMap, sDoor[n]["row"]), "#62D962") into sDoor[n]["key"]
      E06.SetDoor n, kShut
      add 1 to n
   end repeat
   Mesh.Define "E06.Hero", MeshBox(24, kHeroH, 24)
   put Entity.Spawn("E06.Hero", 0, 0, 0, "#40E0FF") into sHero["key"]
end E06.Build

-- the method: each door's bottom goes up while the hero is near (or in it), down when not
on E06.Doors
   local n, tX, tZ, tNear, tWant, tC
   put 1 into n
   repeat while n <= sDoor["count"]
      put CellMap.CellX(sMap, sDoor[n]["col"]) into tX
      put CellMap.CellZ(sMap, sDoor[n]["row"]) into tZ
      put sqrt((sHero["x"] - tX) ^ 2 + (sHero["z"] - tZ) ^ 2) <= kNear * sMap["meta"]["cell"] into tNear
      if tNear then
         put kOpen into tWant
      else
         put kShut into tWant
      end if
      put sDoor[n]["ceiling"] into tC
      if tC < tWant then put min(tWant, tC + kDoorSpeed) into tC
      if tC > tWant then put max(tWant, tC - kDoorSpeed) into tC
      if tC is not sDoor[n]["ceiling"] then E06.SetDoor n, tC
      add 1 to n
   end repeat
end E06.Doors

-- the door's ceiling in the map (From Ceiling: solid from it up to the map's top, 101) and its box on screen
on E06.SetDoor pN, pCeiling
   put pCeiling into sDoor[pN]["ceiling"]
   CellMap.Set sMap, "ceiling", sDoor[pN]["col"], sDoor[pN]["row"], pCeiling
   CellMap.Set sMap, "from", sDoor[pN]["col"], sDoor[pN]["row"], 2       -- From Ceiling: solid from the ceiling up to the map's top (101)
   SetObjectPosition sDoor[pN]["key"], CellMap.CellX(sMap, sDoor[pN]["col"]), -(pCeiling + kOpen / 2) * CellMap.HU(sMap), CellMap.CellZ(sMap, sDoor[pN]["row"])
end E06.SetDoor

on Game.OnUpdate
   if sError is not empty then exit Game.OnUpdate
   E06.Doors
   E06.Move E06.Keys()
   E06.ShowHUD
end Game.OnUpdate

-- the hero: a box the map walks (CellMap.Walk), north / west / south / east
on E06.Move pKeys
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
   -- up a step at once, down by falling
   if tGround >= sHero["y"] then
      put tGround into sHero["y"]
   else
      put max(tGround, sHero["y"] - kFall) into sHero["y"]
   end if
   SetObjectPosition sHero["key"], sHero["x"], -sHero["y"] - kHeroH / 2, sHero["z"]
end E06.Move

function E06.Cell
   return CellMap.CellAt(sMap, sHero["x"], sHero["z"])
end E06.Cell

on E06.ShowHUD
   local n, tText
   put "E06 A DOOR THAT RISES   YOU ARE ON" && E06.Cell() into tText
   put 1 into n
   repeat while n <= sDoor["count"]
      put "   DOOR" && sDoor[n]["col"] & "," & sDoor[n]["row"] && "UP" && sDoor[n]["ceiling"] - kShut after tText
      add 1 to n
   end repeat
   HUD.Set "E06.Cell", tText, 20, 120, 14
end E06.ShowHUD

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

function E06.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E06.Keys

on E06.TestKeys pKeys
   put pKeys into sTestKeys
end E06.TestKeys

-- tests: the hero on the centre of cell pCol,pRow, on its ground
on E06.TestPlace pCol, pRow
   put CellMap.CellX(sMap, pCol) into sHero["x"]
   put CellMap.CellZ(sMap, pRow) into sHero["z"]
   put CellMap.GroundAt(sMap, sTags, empty, sHero["x"], sHero["z"]) into sHero["y"]
   put "path" into sHero["effect"]
   SetObjectPosition sHero["key"], sHero["x"], -sHero["y"] - kHeroH / 2, sHero["z"]
end E06.TestPlace

-- hero's cell | height in hu | effect | each door: col,row ceiling
function E06.State
   local n, tOut
   put E06.Cell() & "|y " & round(sHero["y"] / CellMap.HU(sMap)) & "|" & sHero["effect"] into tOut
   put 1 into n
   repeat while n <= sDoor["count"]
      put "|door " & sDoor[n]["col"] & "," & sDoor[n]["row"] && sDoor[n]["ceiling"] after tOut
      add 1 to n
   end repeat
   return tOut & "|" & sError
end E06.State

-- the level's lines: the outline only when the map was saved lean (BitEditor: Scene > Lean Style)
-- and lib_lean is there (LIB_BIT/livecode/lib_lean; meta lean "water=off" leaves the water marks out)
function E06.LevelSegments pMap
   if pMap["meta"]["style"] is "lean" and "lib_lean" is among the lines of the stacksInUse then
      return Lean.MapSegments(pMap, sTags, empty, Lean.Style(pMap["meta"]["lean"]))
   end if
   return CellMap.LevelSegments(pMap, sTags, empty)
end E06.LevelSegments

function E06.FindFile pRelPath
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
end E06.FindFile
