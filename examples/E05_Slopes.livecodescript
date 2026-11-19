######################################################################################
## CARD SCRIPT: "Play.Edit_E05"   E05 SLOPES  (LIB_EDITOR, 11 18 2026)
## One method: raise one EDGE or one CORNER of a square (the Tomb Raider Level Editor's
## arrow keys on a selected square). A cell keeps its five heights; a slope adds four
## corner rises on top of its ground (CELLMAP_V3.md). I J K L lift the north, west, south
## or east edge 10 hu; 1 2 3 4 lift the north-west, north-east, south-east or south-west
## corner; hold Shift to lower instead; 0 flattens. If all four corners end up lifted, the
## card tidies: the corners come down and the floor goes up by the same amount.
## Steeper than 60 hu across the cell, it cannot be walked up: the HUD says STEEP.
## The level is drawn by CellMap.LevelSegments, so the wires show the real slope.
## CONTROLS  Arrows: move the cursor   I J K L: edges   1 2 3 4: corners   Shift: lower
##           0: flatten   Return: save a copy (maps/cards_yard_e05.cellmap)
## NEEDS     ../LIB_BIT/editor (lib_cellmap, tags_default.txt), maps/cards_yard.cellmap
## LESSON    Adding: CellMap.SetSlope + LevelSegments  Result: a ramp you could walk up
## FORMAT    ../LIB_BIT/editor/CELLMAP_V3.md section 2
######################################################################################

global gCameraYaw, gCameraPitch

local sMap, sTags, sCol, sRow, sCursor, sSegs, sKeyWas, sSaved, sError, sTestKeys

constant kStep = 10
-- class, colour: how each kind of line is drawn (CELLMAP_V2.md section 6)
constant kColours = "floor #1F4A5A,wall #7FA8FF,pit #FF5040,water #40E0FF,ceiling #9098A8,green #50E070,sky #B8D8FF,relief #FFFFFF"
-- the key's codes (as typed / with Shift: I and i, 1 and !) and which corners (nw ne se sw) it lifts
constant kKeys = "105/73 1 1 0 0,108/76 0 1 1 0,107/75 0 0 1 1,106/74 1 0 0 1,49/33 1 0 0 0,50/64 0 1 0 0,51/35 0 0 1 0,52/36 0 0 0 1"

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   put empty into sError
   put empty into sKeyWas
   put empty into sSaved
   put E05.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E05: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E05.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   put CellMap.Read(E05.FindFile("LIB_EDITOR/maps/cards_yard.cellmap")) into sMap
   CellMap.Upgrade sMap
   put CellMap.TagsFromText(CellMap.ReadText(E05.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   put 4 into sCol
   put 4 into sRow
   E05.Build
   Engine.SetCam 0, 600, 600
   put 0 into gCameraYaw
   put -atan2(600, 600) into gCameraPitch
   E05.ShowHUD
end Game.OnStart

-- the whole level as wires, one mesh a class, and the cursor (rebuilt after every edit: a small map)
on E05.Build
   local tSeg, tE, tMesh, tClass, tPair, tA, tB, tTop
   Scene.ClearAll
   put 0 into sSegs
   repeat for each line tSeg in CellMap.LevelSegments(sMap, sTags, empty)
      put item 7 of tSeg into tClass
      if tMesh[tClass] is not an array then put Mesh.New() into tMesh[tClass]
      put CellMap.SegToEngine(sMap, tSeg) into tE
      Mesh.AddVertex tMesh[tClass], item 1 of tE, -(item 2 of tE), item 3 of tE
      put the result into tA
      Mesh.AddVertex tMesh[tClass], item 4 of tE, -(item 5 of tE), item 6 of tE
      put the result into tB
      Mesh.AddLine tMesh[tClass], tA, tB
      add 1 to sSegs
   end repeat
   repeat for each item tPair in kColours
      put word 1 of tPair into tClass
      if tMesh[tClass] is not an array then next repeat
      Mesh.Define "E05." & tClass, tMesh[tClass]
      get Entity.Spawn("E05." & tClass, 0, 0, 0, word 2 of tPair)
   end repeat
   -- the cursor: a thin square just over the cell's highest corner, red when steep
   put sMap["floor"][sRow][sCol] - sMap["red"][sRow][sCol] into tTop
   if CellMap.Slope(sMap, sCol, sRow) is not empty then add max(CellMap.Slope(sMap, sCol, sRow)) to tTop
   Mesh.Define "E05.Cursor", MeshBox(sMap["meta"]["cell"] - 8, 3, sMap["meta"]["cell"] - 8)
   if CellMap.Steep(sMap, sCol, sRow) then
      put Entity.Spawn("E05.Cursor", CellMap.CellX(sMap, sCol), -(tTop * CellMap.HU(sMap)) - 6, CellMap.CellZ(sMap, sRow), "red") into sCursor
   else
      put Entity.Spawn("E05.Cursor", CellMap.CellX(sMap, sCol), -(tTop * CellMap.HU(sMap)) - 6, CellMap.CellZ(sMap, sRow), "yellow") into sCursor
   end if
end E05.Build

-- the method: lift (pBy > 0) or lower the corners pMask ("nw ne se sw" as 1 or 0) of one cell;
-- all four lifted: tidy them into the floor
on E05.Lift pC, pR, pMask, pBy
   local tS, i, tMin
   if sMap["floor"][pR][pC] <= 0 then exit E05.Lift
   put CellMap.Slope(sMap, pC, pR) into tS
   if tS is empty then put "0,0,0,0" into tS
   put 1 into i
   repeat while i <= 4
      if word i of pMask is 1 then put min(255, max(0, item i of tS + pBy)) into item i of tS
      add 1 to i
   end repeat
   put min(tS) into tMin
   if tMin > 0 then
      put 1 into i
      repeat while i <= 4
         subtract tMin from item i of tS
         add 1 to i
      end repeat
      CellMap.Set sMap, "floor", pC, pR, min(255, sMap["floor"][pR][pC] + tMin)
   end if
   CellMap.SetSlope sMap, pC, pR, tS
   E05.Build
end E05.Lift

on Game.OnUpdate
   local tKeys, tK, tBy, tMoved, tCodes
   if sError is not empty then exit Game.OnUpdate
   put E05.Keys() into tKeys
   put false into tMoved
   if E05.Pressed(tKeys, "65361", "left") then put max(1, sCol - 1) into sCol
   if E05.Pressed(tKeys, "65363", "right") then put min(sMap["meta"]["cols"], sCol + 1) into sCol
   if E05.Pressed(tKeys, "65362", "up") then put max(1, sRow - 1) into sRow
   if E05.Pressed(tKeys, "65364", "down") then put min(sMap["meta"]["rows"], sRow + 1) into sRow
   put kStep into tBy
   if 65505 is among the items of tKeys or 65506 is among the items of tKeys then put -kStep into tBy
   repeat for each item tK in kKeys
      put word 1 of tK into tCodes
      replace "/" with comma in tCodes
      if E05.Pressed(tKeys, tCodes, "k" & word 1 of tK) then
         E05.Lift sCol, sRow, word 2 to 5 of tK, tBy
         put true into tMoved
      end if
   end repeat
   if E05.Pressed(tKeys, "48", "flat") then
      CellMap.SetSlope sMap, sCol, sRow, empty
      put true into tMoved
   end if
   if E05.Pressed(tKeys, "65293,65421", "save") then E05.Save
   if tMoved or E05.Pressed(tKeys, "65361,65362,65363,65364", "cursor") then E05.Build
   E05.ShowHUD
end Game.OnUpdate

on E05.Save
   local tPath
   put E05.FindFile("LIB_EDITOR/maps/cards_yard.cellmap") into tPath
   replace "cards_yard.cellmap" with "cards_yard_e05.cellmap" in tPath
   CellMap.Write sMap, tPath
   put "SAVED CARDS_YARD_E05.CELLMAP" into sSaved
end E05.Save

on E05.ShowHUD
   local tS, tSteep
   put CellMap.Slope(sMap, sCol, sRow) into tS
   if tS is empty then put "FLAT" into tS
   if CellMap.Steep(sMap, sCol, sRow) then put "   STEEP: CANNOT BE WALKED UP" into tSteep
   HUD.Set "E05.Cell", "CELL" && sCol & "," & sRow && "  FLOOR" && sMap["floor"][sRow][sCol] && "  CORNERS NW,NE,SE,SW" && tS & tSteep && "  " & sSaved, 20, 100, 14
   HUD.Set "E05.Help", "ARROWS MOVE   I J K L EDGES   1 2 3 4 CORNERS   SHIFT LOWERS   0 FLAT   RETURN SAVES A COPY", 20, 124, 11
end E05.ShowHUD

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

function E05.Pressed pKeys, pCodes, pName
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
end E05.Pressed

function E05.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E05.Keys

on E05.TestKeys pKeys
   put pKeys into sTestKeys
end E05.TestKeys

-- cell | floor | slope (flat) | steep | lines drawn | saved | error
function E05.State
   local tS
   put CellMap.Slope(sMap, sCol, sRow) into tS
   if tS is empty then put "flat" into tS
   return sCol & "," & sRow & "|floor " & sMap["floor"][sRow][sCol] & "|slope " & tS & "|steep " & CellMap.Steep(sMap, sCol, sRow) & "|lines " & sSegs & "|" & sSaved & "|" & sError
end E05.State

function E05.FindFile pRelPath
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
end E05.FindFile
