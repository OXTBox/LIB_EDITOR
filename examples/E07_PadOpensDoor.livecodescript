######################################################################################
## CARD SCRIPT: "Play.Edit_E07"   E07 A PAD THAT OPENS A DOOR  (LIB_EDITOR, 11 18 2026)
## One method: links, trigger -> target (Forge's tags, the Tomb Raider Level Editor's
## triggers). The map's [links] section says "4,8 pad 8,8": stepping onto the pressure
## plate at 4,8 opens the door at 8,8, far across the room. "10,8 anti 8,8": the plate on
## the other side shuts it again. "6,2 switch 8,5": a switch waits for E, and opens or
## shuts the middle door. A door that no link names stays as it is.
## CONTROLS  Arrows or W A S D: walk   E: use a switch you stand on
## NEEDS     ../LIB_BIT/editor (lib_cellmap, tags_default.txt), maps/cards_yard.cellmap
## LESSON    Adding: E07.Trigger (links read when the hero enters a cell)
##           Result: a plate here, a door there
## FORMAT    ../LIB_BIT/editor/CELLMAP_V2.md section 5 ([links]: from, type, to, note)
######################################################################################

global gCameraYaw, gCameraPitch

local sMap, sTags, sHero, sDoor, sKeyWas, sCellWas, sSaid, sError, sTestKeys

constant kSpeed = 3              -- engine units a step
constant kFall = 6               -- engine units a step, dropping
constant kHeroH = 50
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
   put empty into sSaid
   put E07.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E07: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E07.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   put CellMap.Read(E07.FindFile("LIB_EDITOR/maps/cards_yard.cellmap")) into sMap
   CellMap.Upgrade sMap
   put CellMap.TagsFromText(CellMap.ReadText(E07.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   E07.Build
   E07.TestPlace 3, 5
   Engine.SetCam 0, 700, 650
   put 0 into gCameraYaw
   put -atan2(700, 650) into gCameraPitch
   HUD.Set "E07.Help", "ARROWS OR W A S D: WALK   STEP ON THE PLATE (P) AT 4,8   E: A SWITCH", 20, 146, 11
end Game.OnStart

-- the level as wires (drawn with every door open: the doorway's frame), a box for each door, the hero
on E07.Build
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
            put kShut into sDoor[n]["want"]
            put kOpen into tDraw["ceiling"][r][c]
            put 2 into tDraw["from"][r][c]
         end if
         add 1 to c
      end repeat
      add 1 to r
   end repeat
   put n into sDoor["count"]
   repeat for each line tSeg in CellMap.LevelSegments(tDraw, sTags, empty)
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
      Mesh.Define "E07." & tClass, tMesh[tClass]
      get Entity.Spawn("E07." & tClass, 0, 0, 0, word 2 of tPair)
   end repeat
   Mesh.Define "E07.Door", MeshBox(sMap["meta"]["cell"] - 6, kOpen * CellMap.HU(sMap), sMap["meta"]["cell"] - 6)
   put 1 into n
   repeat while n <= sDoor["count"]
      put Entity.Spawn("E07.Door", CellMap.CellX(sMap, sDoor[n]["col"]), 0, CellMap.CellZ(sMap, sDoor[n]["row"]), "#62D962") into sDoor[n]["key"]
      E07.SetDoor n, kShut
      add 1 to n
   end repeat
   Mesh.Define "E07.Hero", MeshBox(24, kHeroH, 24)
   put Entity.Spawn("E07.Hero", 0, 0, 0, "#40E0FF") into sHero["key"]
end E07.Build

-- the method: the hero has just entered pCell ("col,row"); every link from it acts on its targets.
-- pUse true: E was pressed (a switch); a pad or an anti plate acts by being stepped on
on E07.Trigger pCell, pUse
   local n, tLink, tTo, tWant
   put 1 into n
   repeat while n <= CellMap.Count(sMap["links"])
      put sMap["links"][n] into tLink
      add 1 to n
      if tLink["from"] is not pCell then next repeat
      put empty into tWant
      if tLink["type"] is "pad" and not pUse then put "open" into tWant
      if tLink["type"] is "anti" and not pUse then put "shut" into tWant
      if tLink["type"] is "switch" and pUse then put "toggle" into tWant
      if tWant is empty then next repeat
      repeat for each word tTo in tLink["to"]
         E07.Want tTo, tWant
      end repeat
      put toUpper(tLink["type"] & ":" && tLink["note"]) into sSaid
   end repeat
end E07.Trigger

-- the door on cell pTo ("col,row") will open, shut, or toggle
on E07.Want pTo, pWant
   local n
   put 1 into n
   repeat while n <= sDoor["count"]
      if sDoor[n]["col"] & comma & sDoor[n]["row"] is pTo then
         if pWant is "toggle" then
            if sDoor[n]["want"] is kOpen then
               put "shut" into pWant
            else
               put "open" into pWant
            end if
         end if
         if pWant is "open" then
            put kOpen into sDoor[n]["want"]
         else
            put kShut into sDoor[n]["want"]
         end if
      end if
      add 1 to n
   end repeat
end E07.Want

-- every door moves 4 hu a step toward what it was told
on E07.Doors
   local n, tC, tWant
   put 1 into n
   repeat while n <= sDoor["count"]
      put sDoor[n]["want"] into tWant
      put sDoor[n]["ceiling"] into tC
      if tC < tWant then put min(tWant, tC + kDoorSpeed) into tC
      if tC > tWant then put max(tWant, tC - kDoorSpeed) into tC
      if tC is not sDoor[n]["ceiling"] then E07.SetDoor n, tC
      add 1 to n
   end repeat
end E07.Doors

-- the door's ceiling in the map (From Ceiling: solid from it up to the map's top, 101) and its box on screen
on E07.SetDoor pN, pCeiling
   put pCeiling into sDoor[pN]["ceiling"]
   CellMap.Set sMap, "ceiling", sDoor[pN]["col"], sDoor[pN]["row"], pCeiling
   CellMap.Set sMap, "from", sDoor[pN]["col"], sDoor[pN]["row"], 2       -- From Ceiling: solid from the ceiling up to the map's top (101)
   SetObjectPosition sDoor[pN]["key"], CellMap.CellX(sMap, sDoor[pN]["col"]), -(pCeiling + kOpen / 2) * CellMap.HU(sMap), CellMap.CellZ(sMap, sDoor[pN]["row"])
end E07.SetDoor

on Game.OnUpdate
   local tKeys, tCell
   if sError is not empty then exit Game.OnUpdate
   put E07.Keys() into tKeys
   E07.Doors
   E07.Move tKeys
   put E07.Cell() into tCell
   if tCell is not sCellWas then
      put tCell into sCellWas
      E07.Trigger tCell, false
   end if
   if E07.Pressed(tKeys, "101,69", "use") then E07.Trigger tCell, true
   E07.ShowHUD
end Game.OnUpdate

-- the hero: a box the map walks (CellMap.Walk), north / west / south / east
on E07.Move pKeys
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
end E07.Move

function E07.Cell
   return CellMap.CellAt(sMap, sHero["x"], sHero["z"])
end E07.Cell

on E07.ShowHUD
   local n, tText
   put "E07 A PAD THAT OPENS A DOOR   YOU ARE ON" && E07.Cell() & "   " & sSaid into tText
   put 1 into n
   repeat while n <= sDoor["count"]
      put "   DOOR" && sDoor[n]["col"] & "," & sDoor[n]["row"] && "UP" && sDoor[n]["ceiling"] - kShut after tText
      add 1 to n
   end repeat
   HUD.Set "E07.Cell", tText, 20, 120, 14
end E07.ShowHUD

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

-- true once when any of pCodes goes down
function E07.Pressed pKeys, pCodes, pName
   local tCode, tDown
   put false into tDown
   repeat for each item tCode in pCodes
      if tCode is among the items of pKeys then put true into tDown
   end repeat
   if tDown and sKeyWas[pName] is not true then
      put true into sKeyWas[pName]
      return true
   end if
   put tDown into sKeyWas[pName]
   return false
end E07.Pressed

function E07.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E07.Keys

on E07.TestKeys pKeys
   put pKeys into sTestKeys
end E07.TestKeys

-- tests: the hero on the centre of cell pCol,pRow, on its ground
on E07.TestPlace pCol, pRow
   put CellMap.CellX(sMap, pCol) into sHero["x"]
   put CellMap.CellZ(sMap, pRow) into sHero["z"]
   put CellMap.GroundAt(sMap, sTags, empty, sHero["x"], sHero["z"]) into sHero["y"]
   put "path" into sHero["effect"]
   put CellMap.CellAt(sMap, sHero["x"], sHero["z"]) into sCellWas
   SetObjectPosition sHero["key"], sHero["x"], -sHero["y"] - kHeroH / 2, sHero["z"]
end E07.TestPlace

-- hero's cell | height in hu | effect | each door: col,row ceiling | what the last link did | error
function E07.State
   local n, tOut
   put E07.Cell() & "|y " & round(sHero["y"] / CellMap.HU(sMap)) & "|" & sHero["effect"] into tOut
   put 1 into n
   repeat while n <= sDoor["count"]
      put "|door " & sDoor[n]["col"] & "," & sDoor[n]["row"] && sDoor[n]["ceiling"] after tOut
      add 1 to n
   end repeat
   return tOut & "|" & sSaid & "|" & sError
end E07.State

function E07.FindFile pRelPath
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
end E07.FindFile
