######################################################################################
## CARD SCRIPT: "Play.Edit_E01"   E01 BLOCKS FROM A CELLMAP  (LIB_EDITOR, 11 14 2026)
## One method: read a .cellmap and build it. Every cell with a height becomes a box as tall
## as its height (9 = a full wall), coloured by its tag. The Tomb Raider Level Editor's
## "rooms are squares raised from the floor", done with data.
## CONTROLS  Left / Right (or A / D): turn around the map
## NEEDS     ../LIB_BIT/editor (lib_cellmap, tags_default.txt, maps/amazing_couple.cellmap)
## LESSON    Adding: CellMap.Read + one MeshBox per height  Result: the maze stands on screen
######################################################################################

global gCameraYaw, gCameraPitch

local sMap, sTags, sBlocks, sError, sTestKeys

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   Scene.ClearAll
   HUD.Clear
   put empty into sError
   put E01.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E01: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E01.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   put CellMap.Read(E01.FindFile("LIB_BIT/editor/maps/amazing_couple.cellmap")) into sMap
   put CellMap.TagsFromText(CellMap.ReadText(E01.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   E01.Build
   -- look down on the whole map from one side
   Engine.SetCam 0, 700, 650
   put 0 into gCameraYaw
   put -atan2(700, 650) into gCameraPitch
   HUD.Set "E01.Title", "E01 BLOCKS FROM A CELLMAP:" && sMap["meta"]["name"] && "(" & sBlocks && "BLOCKS)", 20, 120, 14
   HUD.Set "E01.Help", "LEFT / RIGHT: TURN AROUND THE MAP", 20, 146, 11
end Game.OnStart

-- the method: one box per raised cell, centred on its cell, standing on the floor (up is -Y)
on E01.Build
   local tCell, tWall, tCols, tRows, r, c, tH, tTall, tX, tZ, tTag
   put sMap["meta"]["cell"] into tCell
   put sMap["meta"]["wallH"] into tWall
   put sMap["meta"]["cols"] into tCols
   put sMap["meta"]["rows"] into tRows
   Mesh.Define "E01.Floor", MeshGrid(tCols, tRows, tCell)
   get Entity.Spawn("E01.Floor", 0, 0, 0, "#203040")
   put 0 into sBlocks
   put 1 into r
   repeat while r <= tRows
      put 1 into c
      repeat while c <= tCols
         put CellMap.Get(sMap, "heights", c, r) into tH
         if tH > 0 then
            put tH * tWall / 9 into tTall
            -- one shape per height, made the first time it is needed
            Mesh.Define "E01.Block." & tH, MeshBox(tCell, tTall, tCell)
            put (c - 0.5 - tCols / 2) * tCell into tX
            put (r - 0.5 - tRows / 2) * tCell into tZ
            put sMap["tags"][r][c] into tTag
            get Entity.Spawn("E01.Block." & tH, tX, -tTall / 2, tZ, CellMap.TagInfo(sMap, sTags, tTag, "colour"))
            add 1 to sBlocks
         end if
         add 1 to c
      end repeat
      add 1 to r
   end repeat
end E01.Build

on Game.OnUpdate
   local tKeys
   if sError is not empty then exit Game.OnUpdate
   put E01.Keys() into tKeys
   if 65361 is among the items of tKeys or 97 is among the items of tKeys then subtract 0.02 from gCameraYaw
   if 65363 is among the items of tKeys or 100 is among the items of tKeys then add 0.02 to gCameraYaw
end Game.OnUpdate

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

function E01.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E01.Keys

on E01.TestKeys pKeys
   put pKeys into sTestKeys
end E01.TestKeys

function E01.State
   return sMap["meta"]["name"] & "|" & sMap["meta"]["cols"] & "x" & sMap["meta"]["rows"] & "|blocks " & sBlocks & "|yaw " & round(gCameraYaw, 2) & "|" & sError
end E01.State

-- pRelPath in the folders above this stack, then in the WSL projects folder
function E01.FindFile pRelPath
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
end E01.FindFile
