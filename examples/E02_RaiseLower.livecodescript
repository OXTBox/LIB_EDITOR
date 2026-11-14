######################################################################################
## CARD SCRIPT: "Play.Edit_E02"   E02 RAISE AND LOWER  (LIB_EDITOR, 11 14 2026)
## One method: edit the map live, one click at a time (the Tomb Raider Level Editor's
## Q / A keys). A yellow cursor sits on one cell; the arrows move it a cell a press;
## Q raises that cell one click, A lowers it; only that one block is rebuilt.
## Return saves the edited map as maps/<name>_e02.cellmap (the original is never touched).
## CONTROLS  Arrows: move the cursor   Q: raise   A: lower   Return: save
##           (arrows only: A is "lower" here, as in the Tomb Raider editor, not WASD left)
## NEEDS     ../LIB_BIT/editor (lib_cellmap, tags_default.txt, maps/amazing_couple.cellmap)
## LESSON    Adding: CellMap.Set + rebuild one block  Result: the floor rises under the cursor
######################################################################################

global gCameraYaw, gCameraPitch

local sMap, sTags, sBlock, sCol, sRow, sCursor, sKeyWas, sSaved, sError, sTestKeys

constant kMaxH = 35

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   Scene.ClearAll
   HUD.Clear
   put empty into sError
   put empty into sBlock
   put empty into sKeyWas
   put empty into sSaved
   put E02.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E02: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E02.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   put CellMap.Read(E02.FindFile("LIB_BIT/editor/maps/amazing_couple.cellmap")) into sMap
   put CellMap.TagsFromText(CellMap.ReadText(E02.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   Mesh.Define "E02.Floor", MeshGrid(sMap["meta"]["cols"], sMap["meta"]["rows"], sMap["meta"]["cell"])
   get Entity.Spawn("E02.Floor", 0, 0, 0, "#203040")
   E02.BuildAll
   Mesh.Define "E02.Cursor", MeshBox(sMap["meta"]["cell"] - 8, 4, sMap["meta"]["cell"] - 8)
   put 2 into sCol
   put 2 into sRow
   put Entity.Spawn("E02.Cursor", 0, 0, 0, "yellow") into sCursor
   E02.PlaceCursor
   Engine.SetCam 0, 700, 650
   put 0 into gCameraYaw
   put -atan2(700, 650) into gCameraPitch
   HUD.Set "E02.Help", "ARROWS MOVE   Q RAISE   A LOWER   RETURN SAVES A COPY", 20, 146, 11
   E02.ShowHUD
end Game.OnStart

on E02.BuildAll
   local r, c
   put 1 into r
   repeat while r <= sMap["meta"]["rows"]
      put 1 into c
      repeat while c <= sMap["meta"]["cols"]
         E02.BuildCell c, r
         add 1 to c
      end repeat
      add 1 to r
   end repeat
end E02.BuildAll

-- the method: one cell's block, rebuilt from its height (none at height 0)
on E02.BuildCell pC, pR
   local tH, tTall, tCell
   if sBlock[pR][pC] is not empty then
      Entity.Kill sBlock[pR][pC]
      put empty into sBlock[pR][pC]
   end if
   put CellMap.Get(sMap, "heights", pC, pR) into tH
   if tH <= 0 then exit E02.BuildCell
   put sMap["meta"]["cell"] into tCell
   put tH * sMap["meta"]["wallH"] / 9 into tTall
   Mesh.Define "E02.Block." & tH, MeshBox(tCell, tTall, tCell)
   put Entity.Spawn("E02.Block." & tH, E02.X(pC), -tTall / 2, E02.Z(pR), \
         CellMap.TagInfo(sMap, sTags, sMap["tags"][pR][pC], "colour")) into sBlock[pR][pC]
end E02.BuildCell

function E02.X pC
   return (pC - 0.5 - sMap["meta"]["cols"] / 2) * sMap["meta"]["cell"]
end E02.X

function E02.Z pR
   return (pR - 0.5 - sMap["meta"]["rows"] / 2) * sMap["meta"]["cell"]
end E02.Z

-- the cursor floats just above whatever height the cell has
on E02.PlaceCursor
   SetObjectPosition sCursor, E02.X(sCol), -(CellMap.Get(sMap, "heights", sCol, sRow) * sMap["meta"]["wallH"] / 9) - 4, E02.Z(sRow)
end E02.PlaceCursor

on Game.OnUpdate
   local tKeys, tH
   if sError is not empty then exit Game.OnUpdate
   put E02.Keys() into tKeys
   -- one cell a press: each key acts when it goes down, not while held
   if E02.Pressed(tKeys, "65361", "left") then put max(1, sCol - 1) into sCol
   if E02.Pressed(tKeys, "65363", "right") then put min(sMap["meta"]["cols"], sCol + 1) into sCol
   if E02.Pressed(tKeys, "65362", "up") then put max(1, sRow - 1) into sRow
   if E02.Pressed(tKeys, "65364", "down") then put min(sMap["meta"]["rows"], sRow + 1) into sRow
   put CellMap.Get(sMap, "heights", sCol, sRow) into tH
   if E02.Pressed(tKeys, "113,81", "raise") then E02.SetHeight min(kMaxH, tH + 1)
   if E02.Pressed(tKeys, "97,65", "lower") then E02.SetHeight max(0, tH - 1)
   if E02.Pressed(tKeys, "65293,65421", "save") then E02.Save
   E02.PlaceCursor
   E02.ShowHUD
end Game.OnUpdate

on E02.SetHeight pH
   CellMap.Set sMap, "heights", sCol, sRow, pH
   E02.BuildCell sCol, sRow
end E02.SetHeight

on E02.Save
   local tPath
   put E02.FindFile("LIB_BIT/editor/maps/amazing_couple.cellmap") into tPath
   replace ".cellmap" with "_e02.cellmap" in tPath
   CellMap.Write sMap, tPath
   put "SAVED" && toUpper(sMap["meta"]["name"]) & "_E02.CELLMAP" into sSaved
end E02.Save

-- true once when any of pCodes goes down; pName remembers it
function E02.Pressed pKeys, pCodes, pName
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
end E02.Pressed

on E02.ShowHUD
   HUD.Set "E02.Cell", "CELL" && sCol & "," & sRow & "   TAG" && sMap["tags"][sRow][sCol] && \
         "(" & CellMap.TagInfo(sMap, sTags, sMap["tags"][sRow][sCol], "name") & ")   HEIGHT" && CellMap.Get(sMap, "heights", sCol, sRow) && "  " & sSaved, 20, 120, 14
end E02.ShowHUD

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

function E02.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E02.Keys

on E02.TestKeys pKeys
   put pKeys into sTestKeys
end E02.TestKeys

function E02.State
   return sCol & "," & sRow & "|h " & CellMap.Get(sMap, "heights", sCol, sRow) & "|tag " & sMap["tags"][sRow][sCol] & "|" & sSaved & "|" & sError
end E02.State

function E02.FindFile pRelPath
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
end E02.FindFile
