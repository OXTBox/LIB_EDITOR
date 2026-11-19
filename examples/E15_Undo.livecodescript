######################################################################################
## CARD SCRIPT: "Play.Edit_E15"   E15 UNDO  (LIB_EDITOR, 11 18 2026)
## One method: an undo stack (both Bungie's editors and the Tomb Raider Level Editor).
## As in E02, a yellow cursor sits on one cell; the arrows move it, Q raises the floor
## one click (10 hu), A lowers it. U takes the last change back, R puts it again, as far
## back as you like. What is kept is the list of CHANGES (which cell, from what, to what),
## not copies of the map: a hundred changes are a hundred short lines.
## A new change after an undo forgets what could have been redone (as every editor does).
## CONTROLS  Arrows: move the cursor   Q: raise   A: lower   U: undo   R: redo
## NEEDS     ../LIB_BIT/editor (lib_cellmap, tags_default.txt), maps/cards_yard.cellmap
## LESSON    Adding: E15.Change (every edit goes through it), E15.Undo, E15.Redo
##           Result: edit freely, take it all back
## FORMAT    ../LIB_BIT/editor/CELLMAP_V2.md section 5 ([floor], 0-255 hu a cell)
######################################################################################

global gCameraYaw, gCameraPitch

local sMap, sOriginal, sTags, sBlock, sCol, sRow, sCursor, sUndo, sRedo, sSaid, sKeyWas, sError, sTestKeys

constant kClick = 10             -- hu a press
constant kTop = 255

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   Scene.ClearAll
   HUD.Clear
   put empty into sError
   put empty into sBlock
   put empty into sKeyWas
   put empty into sSaid
   put empty into sUndo
   put empty into sRedo
   put E15.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E15: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E15.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   put CellMap.Read(E15.FindFile("LIB_EDITOR/maps/cards_yard.cellmap")) into sMap
   CellMap.Upgrade sMap
   put sMap into sOriginal
   put CellMap.TagsFromText(CellMap.ReadText(E15.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   Mesh.Define "E15.Floor", MeshGrid(sMap["meta"]["cols"], sMap["meta"]["rows"], sMap["meta"]["cell"])
   get Entity.Spawn("E15.Floor", 0, 0, 0, "#203040")
   E15.BuildAll
   Mesh.Define "E15.Cursor", MeshBox(sMap["meta"]["cell"] - 8, 4, sMap["meta"]["cell"] - 8)
   put 2 into sCol
   put 2 into sRow
   put Entity.Spawn("E15.Cursor", 0, 0, 0, "yellow") into sCursor
   E15.PlaceCursor
   Engine.SetCam 0, 700, 650
   put 0 into gCameraYaw
   put -atan2(700, 650) into gCameraPitch
   HUD.Set "E15.Help", "ARROWS MOVE   Q RAISE   A LOWER   U UNDO   R REDO", 20, 146, 11
   E15.ShowHUD
end Game.OnStart

on E15.BuildAll
   local r, c
   put 1 into r
   repeat while r <= sMap["meta"]["rows"]
      put 1 into c
      repeat while c <= sMap["meta"]["cols"]
         E15.BuildCell c, r
         add 1 to c
      end repeat
      add 1 to r
   end repeat
end E15.BuildAll

-- one cell's block from its floor (none at 0 or 1: the grid shows the flat ground)
on E15.BuildCell pC, pR
   local tF, tTall
   if sBlock[pR][pC] is not empty then
      Entity.Kill sBlock[pR][pC]
      put empty into sBlock[pR][pC]
   end if
   put CellMap.Get(sMap, "floor", pC, pR) into tF
   if tF <= 1 then exit E15.BuildCell
   put tF * CellMap.HU(sMap) into tTall
   Mesh.Define "E15.Block." & tF, MeshBox(sMap["meta"]["cell"], tTall, sMap["meta"]["cell"])
   put Entity.Spawn("E15.Block." & tF, CellMap.CellX(sMap, pC), -tTall / 2, CellMap.CellZ(sMap, pR), \
         CellMap.TagInfo(sMap, sTags, sMap["tags"][pR][pC], "colour")) into sBlock[pR][pC]
end E15.BuildCell

on E15.PlaceCursor
   SetObjectPosition sCursor, CellMap.CellX(sMap, sCol), -(CellMap.Get(sMap, "floor", sCol, sRow) * CellMap.HU(sMap)) - 4, CellMap.CellZ(sMap, sRow)
end E15.PlaceCursor

-- the method, part 1: every edit goes through here. It sets the cell and remembers the change
-- as one line (col,row,layer,from,to) on the undo stack; a new change forgets the redo stack
on E15.Change pCol, pRow, pWhich, pTo
   local tFrom
   put CellMap.Get(sMap, pWhich, pCol, pRow) into tFrom
   if tFrom is pTo then exit E15.Change
   put pCol & comma & pRow & comma & pWhich & comma & tFrom & comma & pTo & return after sUndo
   put empty into sRedo
   E15.Apply pCol, pRow, pWhich, pTo
   put toUpper(pWhich) && pCol & "," & pRow && tFrom && "TO" && pTo into sSaid
end E15.Change

-- the method, part 2: U takes the last change off the undo stack, puts the old number back,
-- and keeps the change on the redo stack; R does the opposite
on E15.Undo
   local tC
   if sUndo is empty then
      put "NOTHING TO UNDO" into sSaid
      exit E15.Undo
   end if
   put line -1 of sUndo into tC
   delete line -1 of sUndo
   put tC & return after sRedo
   E15.Apply item 1 of tC, item 2 of tC, item 3 of tC, item 4 of tC
   put "UNDO" && toUpper(item 3 of tC) && item 1 of tC & "," & item 2 of tC && "BACK TO" && item 4 of tC into sSaid
end E15.Undo

on E15.Redo
   local tC
   if sRedo is empty then
      put "NOTHING TO REDO" into sSaid
      exit E15.Redo
   end if
   put line -1 of sRedo into tC
   delete line -1 of sRedo
   put tC & return after sUndo
   E15.Apply item 1 of tC, item 2 of tC, item 3 of tC, item 5 of tC
   put "REDO" && toUpper(item 3 of tC) && item 1 of tC & "," & item 2 of tC && "TO" && item 5 of tC into sSaid
end E15.Redo

-- the cell, its block, and the cursor go where it is now
on E15.Apply pCol, pRow, pWhich, pValue
   CellMap.Set sMap, pWhich, pCol, pRow, pValue
   E15.BuildCell pCol, pRow
   put pCol into sCol
   put pRow into sRow
end E15.Apply

on Game.OnUpdate
   local tKeys, tF
   if sError is not empty then exit Game.OnUpdate
   put E15.Keys() into tKeys
   if E15.Pressed(tKeys, "65361", "left") then put max(1, sCol - 1) into sCol
   if E15.Pressed(tKeys, "65363", "right") then put min(sMap["meta"]["cols"], sCol + 1) into sCol
   if E15.Pressed(tKeys, "65362", "up") then put max(1, sRow - 1) into sRow
   if E15.Pressed(tKeys, "65364", "down") then put min(sMap["meta"]["rows"], sRow + 1) into sRow
   put CellMap.Get(sMap, "floor", sCol, sRow) into tF
   -- a click: up to the next ten; down to the ten below, then 1 (flat ground), then 0 (empty space)
   if E15.Pressed(tKeys, "113,81", "raise") then E15.Change sCol, sRow, "floor", min(kTop, (tF div kClick + 1) * kClick)
   if E15.Pressed(tKeys, "97,65", "lower") then
      if tF > kClick then
         E15.Change sCol, sRow, "floor", ((tF - 1) div kClick) * kClick
      else
         E15.Change sCol, sRow, "floor", max(0, min(tF - 1, 1))
      end if
   end if
   if E15.Pressed(tKeys, "117,85", "undo") then E15.Undo
   if E15.Pressed(tKeys, "114,82", "redo") then E15.Redo
   E15.PlaceCursor
   E15.ShowHUD
end Game.OnUpdate

-- true once when any of pCodes goes down
function E15.Pressed pKeys, pCodes, pName
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
end E15.Pressed

on E15.ShowHUD
   HUD.Set "E15.Cell", "E15 UNDO   CELL" && sCol & "," & sRow && "FLOOR" && CellMap.Get(sMap, "floor", sCol, sRow) && \
         "  UNDO" && the number of lines of sUndo && " REDO" && the number of lines of sRedo & "   " & sSaid, 20, 120, 14
end E15.ShowHUD

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

function E15.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E15.Keys

on E15.TestKeys pKeys
   put pKeys into sTestKeys
end E15.TestKeys

-- tests: how many cells' floors differ from the map as it was opened
function E15.Changed
   local r, c, n
   put 0 into n
   repeat with r = 1 to sMap["meta"]["rows"]
      repeat with c = 1 to sMap["meta"]["cols"]
         if CellMap.Get(sMap, "floor", c, r) is not CellMap.Get(sOriginal, "floor", c, r) then add 1 to n
      end repeat
   end repeat
   return n
end E15.Changed

-- cursor | its floor | undo and redo stack sizes | cells changed | what the last key did | error
function E15.State
   return sCol & "," & sRow & "|floor " & CellMap.Get(sMap, "floor", sCol, sRow) & "|undo " & the number of lines of sUndo & "|redo " & the number of lines of sRedo & "|changed " & E15.Changed() & "|" & sSaid & "|" & sError
end E15.State

function E15.FindFile pRelPath
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
end E15.FindFile
