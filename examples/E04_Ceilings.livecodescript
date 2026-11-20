######################################################################################
## CARD SCRIPT: "Play.Edit_E04"   E04 CEILINGS  (LIB_EDITOR, 11 18 2026)
## One method: a second height layer, the roof (the Tomb Raider Level Editor's ceiling
## squares). A yellow cursor sits on one cell; W brings its roof down 10 hu, S lifts it
## 10 hu; lifted past 255 the roof is gone (open sky); T roofs the whole ~ tunnel one
## hallway (100 hu) above its floor. The HUD says how much air is under the roof: a hero
## needs 83 hu. Return saves a copy as maps/cards_yard_e04.cellmap.
## CONTROLS  Arrows: move the cursor   W: roof down   S: roof up   T: roof the tunnel
##           Return: save a copy
## NEEDS     ../LIB_BIT/editor (lib_cellmap, tags_default.txt), maps/cards_yard.cellmap
## LESSON    Adding: the ceiling layer + one roof slab a cell  Result: a hallway you walk under
## FORMAT    ../LIB_BIT/editor/CELLMAP_V2.md section 3 (ceiling = the underside of a roof)
######################################################################################

global gCameraYaw, gCameraPitch

local sMap, sTags, sBlock, sRoof, sCol, sRow, sCursor, sKeyWas, sSaved, sError, sTestKeys

constant kStep = 10              -- hu a press
constant kHallway = 100          -- T puts the tunnel's roof this far above its floor

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   Scene.ClearAll
   HUD.Clear
   put empty into sError
   put empty into sBlock
   put empty into sRoof
   put empty into sKeyWas
   put empty into sSaved
   put E04.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E04: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E04.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   put CellMap.Read(E04.FindFile("LIB_EDITOR/maps/cards_yard.cellmap")) into sMap
   CellMap.Upgrade sMap
   put CellMap.TagsFromText(CellMap.ReadText(E04.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   E04.BuildAll
   Mesh.Define "E04.Cursor", MeshBox(sMap["meta"]["cell"] - 8, 4, sMap["meta"]["cell"] - 8)
   put 3 into sCol
   put 9 into sRow
   put Entity.Spawn("E04.Cursor", 0, 0, 0, "yellow") into sCursor
   E04.PlaceCursor
   Engine.SetCam 0, 700, 650
   put 0 into gCameraYaw
   put -atan2(700, 650) into gCameraPitch
   HUD.Set "E04.Help", "ARROWS MOVE   W ROOF DOWN   S ROOF UP   T ROOF THE TUNNEL   RETURN SAVES A COPY", 20, 146, 11
   E04.ShowHUD
end Game.OnStart

on E04.BuildAll
   local r, c
   put 1 into r
   repeat while r <= sMap["meta"]["rows"]
      put 1 into c
      repeat while c <= sMap["meta"]["cols"]
         E04.BuildCell c, r
         add 1 to c
      end repeat
      add 1 to r
   end repeat
end E04.BuildAll

-- one cell: its ground block, and its roof (a grey slab from the ceiling up to its top: thick when
-- the cell is From Ceiling; at least 4 units)
on E04.BuildCell pC, pR
   local tC, tHU, tCell, tTall, tThick
   if sBlock[pR][pC] is not empty then Entity.Kill sBlock[pR][pC]
   if sRoof[pR][pC] is not empty then Entity.Kill sRoof[pR][pC]
   put empty into sBlock[pR][pC]
   put empty into sRoof[pR][pC]
   put CellMap.Column(sMap, pC, pR) into tC
   if tC is empty then exit E04.BuildCell
   put CellMap.HU(sMap) into tHU
   put sMap["meta"]["cell"] into tCell
   put max(2, item 1 of tC * tHU) into tTall
   Mesh.Define "E04.Block." & round(tTall), MeshBox(tCell, tTall, tCell)
   put Entity.Spawn("E04.Block." & round(tTall), CellMap.CellX(sMap, pC), -tTall / 2, CellMap.CellZ(sMap, pR), \
         CellMap.TagInfo(sMap, sTags, sMap["tags"][pR][pC], "colour")) into sBlock[pR][pC]
   if item 2 of tC is empty then exit E04.BuildCell
   put max(4, (item 3 of tC - item 2 of tC) * tHU) into tThick
   Mesh.Define "E04.Roof." & round(tThick), MeshBox(tCell, tThick, tCell)
   put Entity.Spawn("E04.Roof." & round(tThick), CellMap.CellX(sMap, pC), -(item 2 of tC * tHU) - tThick / 2, \
         CellMap.CellZ(sMap, pR), "#9098A8") into sRoof[pR][pC]
end E04.BuildCell

-- the method: the roof of one cell moves by pBy hu; never below the ground (a roof there is
-- solid: a wall inside a building); lifted past 255 it is gone; from no roof, W starts it a hallway up
on E04.MoveRoof pC, pR, pBy
   local tGround, tCeil
   if sMap["floor"][pR][pC] <= 0 then exit E04.MoveRoof
   put sMap["floor"][pR][pC] - sMap["red"][pR][pC] into tGround
   put sMap["ceiling"][pR][pC] into tCeil
   if tCeil is 0 then
      if pBy > 0 then exit E04.MoveRoof
      put min(255, max(1, tGround) + kHallway) into tCeil
   else
      add pBy to tCeil
   end if
   if tCeil > 255 then put 0 into tCeil
   if tCeil is not 0 then put max(max(1, tGround), tCeil) into tCeil
   CellMap.Set sMap, "ceiling", pC, pR, tCeil
   E04.BuildCell pC, pR
end E04.MoveRoof

-- T: every tunnel cell (~) gets a roof one hallway above its ground
on E04.RoofTunnel
   local r, c
   put 1 into r
   repeat while r <= sMap["meta"]["rows"]
      put 1 into c
      repeat while c <= sMap["meta"]["cols"]
         if sMap["tags"][r][c] is "~" then
            CellMap.Set sMap, "ceiling", c, r, min(255, max(1, sMap["floor"][r][c] - sMap["red"][r][c]) + kHallway)
            E04.BuildCell c, r
         end if
         add 1 to c
      end repeat
      add 1 to r
   end repeat
end E04.RoofTunnel

-- the cursor floats just above the cell's ground
on E04.PlaceCursor
   SetObjectPosition sCursor, CellMap.CellX(sMap, sCol), -(max(1, sMap["floor"][sRow][sCol] - sMap["red"][sRow][sCol]) * CellMap.HU(sMap)) - 4, CellMap.CellZ(sMap, sRow)
end E04.PlaceCursor

on Game.OnUpdate
   local tKeys
   if sError is not empty then exit Game.OnUpdate
   put E04.Keys() into tKeys
   if E04.Pressed(tKeys, "65361", "left") then put max(1, sCol - 1) into sCol
   if E04.Pressed(tKeys, "65363", "right") then put min(sMap["meta"]["cols"], sCol + 1) into sCol
   if E04.Pressed(tKeys, "65362", "up") then put max(1, sRow - 1) into sRow
   if E04.Pressed(tKeys, "65364", "down") then put min(sMap["meta"]["rows"], sRow + 1) into sRow
   if E04.Pressed(tKeys, "119,87", "lower") then E04.MoveRoof sCol, sRow, -kStep
   if E04.Pressed(tKeys, "115,83", "raise") then E04.MoveRoof sCol, sRow, kStep
   if E04.Pressed(tKeys, "116,84", "tunnel") then E04.RoofTunnel
   if E04.Pressed(tKeys, "65293,65421", "save") then E04.Save
   E04.PlaceCursor
   E04.ShowHUD
end Game.OnUpdate

on E04.Save
   local tPath
   put E04.FindFile("LIB_EDITOR/maps/cards_yard.cellmap") into tPath
   replace "cards_yard.cellmap" with "cards_yard_e04.cellmap" in tPath
   CellMap.Write sMap, tPath
   put "SAVED CARDS_YARD_E04.CELLMAP" into sSaved
end E04.Save

-- air under the roof where you stand, and whether a hero (83 hu) fits
function E04.Air
   local tLevel
   put line 1 of CellMap.Levels(sMap, sCol, sRow) into tLevel
   if tLevel is empty then return "solid"
   if item 2 of tLevel >= 5000 then return "open sky"
   if item 2 of tLevel < CellMap.Opt(sMap, "head") then return item 2 of tLevel && "too low"
   return item 2 of tLevel && "fits"
end E04.Air

on E04.ShowHUD
   local tCeil
   put sMap["ceiling"][sRow][sCol] into tCeil
   if tCeil is 0 then put "NONE" into tCeil
   HUD.Set "E04.Cell", "CELL" && sCol & "," & sRow & "   TAG" && sMap["tags"][sRow][sCol] && "   FLOOR" && sMap["floor"][sRow][sCol] && \
         "  ROOF" && tCeil && "  AIR" && toUpper(E04.Air()) && "(A HERO NEEDS 83)   " & sSaved, 20, 120, 14
end E04.ShowHUD

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

function E04.Pressed pKeys, pCodes, pName
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
end E04.Pressed

function E04.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E04.Keys

on E04.TestKeys pKeys
   put pKeys into sTestKeys
end E04.TestKeys

-- cell | floor | ceiling | air | saved | error
function E04.State
   return sCol & "," & sRow & "|floor " & sMap["floor"][sRow][sCol] & "|ceiling " & sMap["ceiling"][sRow][sCol] & "|air " & E04.Air() & "|" & sSaved & "|" & sError
end E04.State

function E04.FindFile pRelPath
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
end E04.FindFile
