######################################################################################
## CARD SCRIPT: "Play.Edit_E03"   E03 ELEVATION COLOURS  (LIB_EDITOR, 11 18 2026)
## One method: the same map coloured by HEIGHT instead of by tag (Forge's elevation view).
## Every cell with a floor becomes a block as tall as its ground (pits go down), and its
## colour comes from one ramp: deep pits dark blue, the floor blue, a step cyan, a full
## wall green, two walls yellow, then red, then white at the top (255 hu).
## C flips between colour by height and colour by tag, so you can see both at a glance.
## CONTROLS  Left / Right: turn around the map   C: height colours / tag colours
## NEEDS     ../LIB_BIT/editor (lib_cellmap, tags_default.txt, maps/wizard_pool.cellmap)
## LESSON    Adding: E03.Ramp (a height becomes a colour)  Result: high and low at a glance
## FORMAT    ../LIB_BIT/editor/CELLMAP_V2.md (heights in hu, 100 = a full hallway)
######################################################################################

global gCameraYaw, gCameraPitch

local sMap, sTags, sByTag, sBlocks, sColours, sKeyWas, sError, sTestKeys

-- hu and colour, low to high: the ramp E03.Ramp blends along
constant kRamp = "-60 #102060,0 #2040FF,30 #00C0FF,100 #20E040,200 #F0E020,230 #FF4020,255 #FFFFFF"

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   put empty into sError
   put empty into sKeyWas
   put false into sByTag
   put E03.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E03: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E03.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   put CellMap.Read(E03.FindFile("LIB_BIT/editor/maps/wizard_pool.cellmap")) into sMap
   CellMap.Upgrade sMap                      -- a version 1 map shows its heights too
   put CellMap.TagsFromText(CellMap.ReadText(E03.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   E03.Build
   Engine.SetCam 0, 900, 900
   put 0 into gCameraYaw
   put -atan2(900, 900) into gCameraPitch
   HUD.Set "E03.Help", "LEFT / RIGHT: TURN   C: HEIGHT COLOURS / TAG COLOURS", 20, 146, 11
end Game.OnStart

-- every cell with a floor: a block from 0 to its ground (down for a pit), in its ramp colour
on E03.Build
   local tCell, tHU, r, c, tC, tG, tTall, tColour
   Scene.ClearAll
   put sMap["meta"]["cell"] into tCell
   put CellMap.HU(sMap) into tHU
   put 0 into sBlocks
   put empty into sColours
   put 1 into r
   repeat while r <= sMap["meta"]["rows"]
      put 1 into c
      repeat while c <= sMap["meta"]["cols"]
         put CellMap.Column(sMap, c, r) into tC
         if tC is not empty then
            -- the highest thing in the column: a roof top or a tower counts, a cloud does not
            put item 1 of tC into tG
            if item 3 of tC is a number then put max(tG, item 3 of tC) into tG
            put max(2, abs(tG) * tHU) into tTall
            Mesh.Define "E03.Block." & round(tTall), MeshBox(tCell, tTall, tCell)
            if sByTag then
               put CellMap.TagInfo(sMap, sTags, sMap["tags"][r][c], "colour") into tColour
            else
               put E03.Ramp(tG) into tColour
            end if
            if tG >= 0 then
               get Entity.Spawn("E03.Block." & round(tTall), CellMap.CellX(sMap, c), -tTall / 2, CellMap.CellZ(sMap, r), tColour)
            else
               get Entity.Spawn("E03.Block." & round(tTall), CellMap.CellX(sMap, c), tTall / 2, CellMap.CellZ(sMap, r), tColour)
            end if
            add 1 to sBlocks
            add 1 to sColours[tColour]
         end if
         add 1 to c
      end repeat
      add 1 to r
   end repeat
   E03.ShowHUD
end E03.Build

-- the method: a height in hu as a colour, blended between the two ramp stops around it
function E03.Ramp pHU
   local tStop, tLastH, tLastC, tH, tCol, tK, tOut, i
   put empty into tLastH
   repeat for each item tStop in kRamp
      put word 1 of tStop into tH
      put word 2 of tStop into tCol
      if pHU <= tH then
         if tLastH is empty then return tCol
         put (pHU - tLastH) / (tH - tLastH) into tK
         put "#" into tOut
         put 2 into i
         repeat while i <= 6
            put E03.Hex2(round(E03.Byte(char i to i + 1 of tLastC) * (1 - tK) + E03.Byte(char i to i + 1 of tCol) * tK)) after tOut
            add 2 to i
         end repeat
         return tOut
      end if
      put tH into tLastH
      put tCol into tLastC
   end repeat
   return tLastC
end E03.Ramp

function E03.Byte pHex
   return baseConvert(pHex, 16, 10)
end E03.Byte

function E03.Hex2 pN
   local tH
   put baseConvert(pN, 10, 16) into tH
   if the number of chars of tH < 2 then put "0" before tH
   return tH
end E03.Hex2

on Game.OnUpdate
   local tKeys
   if sError is not empty then exit Game.OnUpdate
   put E03.Keys() into tKeys
   if 65361 is among the items of tKeys then subtract 0.02 from gCameraYaw
   if 65363 is among the items of tKeys then add 0.02 to gCameraYaw
   if E03.Pressed(tKeys, "99,67", "colours") then
      put not sByTag into sByTag
      E03.Build
   end if
end Game.OnUpdate

on E03.ShowHUD
   local tMode
   if sByTag then
      put "COLOURED BY TAG" into tMode
   else
      put "COLOURED BY HEIGHT: DARK BLUE PIT, BLUE FLOOR, GREEN WALL (100), YELLOW 200, WHITE 255" into tMode
   end if
   HUD.Set "E03.Title", "E03 ELEVATION COLOURS:" && toUpper(sMap["meta"]["name"]) && "(" & sBlocks && "BLOCKS)", 20, 100, 14
   HUD.Set "E03.Mode", tMode, 20, 122, 11
end E03.ShowHUD

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

-- true once when any of pCodes goes down
function E03.Pressed pKeys, pCodes, pName
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
end E03.Pressed

function E03.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E03.Keys

on E03.TestKeys pKeys
   put pKeys into sTestKeys
end E03.TestKeys

-- name | blocks | height or tag | how many different colours
function E03.State
   local tMode
   if sByTag then
      put "tag" into tMode
   else
      put "height" into tMode
   end if
   return sMap["meta"]["name"] & "|blocks " & sBlocks & "|" & tMode & "|colours " & CellMap.Count(sColours) & "|" & sError
end E03.State

-- pRelPath in the folders above this stack, then in the WSL projects folder
function E03.FindFile pRelPath
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
end E03.FindFile
