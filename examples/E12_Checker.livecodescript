######################################################################################
## CARD SCRIPT: "Play.Edit_E12"   E12 THE CHECKER  (LIB_EDITOR, 11 18 2026)
## One method: the tool checks your work and jumps to the culprit (Forge's errors and Goto,
## the Tomb Raider Level Editor's finders). The card opens a deliberately broken map and
## lists its problems: no start, a cell nobody can reach, a link with no target, a
## teleporter with no partner, bad slopes. N shows the next problem: the camera jumps
## over its cell and a yellow frame sits on it. M opens the next map (two broken ones,
## then the yard, which has no problems).
## CONTROLS  N or Space: next problem   B: back one   M: next map
## NEEDS     ../LIB_BIT/editor (lib_cellmap: CellMap.Check, tags_default.txt),
##           maps/cards_broken.cellmap, maps/cards_lost.cellmap, maps/cards_yard.cellmap
## LESSON    Adding: E12.Problems (CellMap.Check + teleporter partners) and E12.Goto
##           Result: a list of what is wrong, and the camera over each in turn
## FORMAT    ../LIB_BIT/editor/CELLMAP_V3.md section 8 (the checker's lines:
##           kind <tab> map <tab> col,row <tab> words)
######################################################################################

global gCameraYaw, gCameraPitch

local sMap, sTags, sMaps, sMapNo, sProblems, sNo, sMark, sCam, sKeyWas, sError, sTestKeys

constant kMaps = "cards_broken,cards_lost,cards_yard"
constant kColours = "floor #1F4A5A,wall #7FA8FF,pit #FF5040,water #40E0FF,ceiling #9098A8,green #50E070,sky #B8D8FF"

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   put empty into sError
   put empty into sKeyWas
   put E12.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E12: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E12.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   -- the Lean style: a map saved lean draws lean (optional, the level draws without it)
   put E12.FindFile("LIB_BIT/livecode/lib_lean.livecodescript") into tLib
   if tLib is not empty then start using stack tLib
   put CellMap.TagsFromText(CellMap.ReadText(E12.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   E12.Open 1
   HUD.Set "E12.Help", "N OR SPACE: NEXT PROBLEM   B: BACK   M: NEXT MAP", 20, 146, 11
end Game.OnStart

-- open map number pNo of kMaps, check it, show the first problem
on E12.Open pNo
   put pNo into sMapNo
   put CellMap.Read(E12.FindFile("LIB_EDITOR/maps/" & item pNo of kMaps & ".cellmap")) into sMap
   CellMap.Upgrade sMap
   E12.Build
   put E12.Problems() into sProblems
   put 0 into sNo
   if sProblems is not empty then put 1 into sNo
   E12.Goto
end E12.Open

-- the method, part 1: every problem of the map, one line each (kind, map, col,row, words).
-- The library's checker, and one check it does not make yet: a teleporter needs a partner
function E12.Problems
   local tOut, n, tLink, tTo, tBack, m, r, c, tFrom
   put CellMap.Check(sMap, sTags) into tOut
   -- a teleport link whose target has no teleport link back
   put 1 into n
   repeat while n <= CellMap.Count(sMap["links"])
      put sMap["links"][n] into tLink
      add 1 to n
      if tLink["type"] is not "teleport" then next repeat
      put tLink["from"] & return after tFrom
      put word 1 of tLink["to"] into tTo
      if tTo is empty or char 1 of tTo is "@" then next repeat
      put false into tBack
      put 1 into m
      repeat while m <= CellMap.Count(sMap["links"])
         if sMap["links"][m]["type"] is "teleport" and sMap["links"][m]["from"] is tTo then put true into tBack
         add 1 to m
      end repeat
      if not tBack then put "partner" & tab & sMap["meta"]["name"] & tab & tLink["from"] & tab & "a teleporter to" && tTo && "with no way back" & return after tOut
   end repeat
   -- a teleporter tile with no teleport link at all
   put 1 into r
   repeat while r <= sMap["meta"]["rows"]
      put 1 into c
      repeat while c <= sMap["meta"]["cols"]
         if CellMap.TagInfo(sMap, sTags, sMap["tags"][r][c], "effect") is "teleport" and (c & comma & r) is not among the lines of tFrom then
            put "partner" & tab & sMap["meta"]["name"] & tab & c & comma & r & tab & "a teleporter tile with no link" & return after tOut
         end if
         add 1 to c
      end repeat
      add 1 to r
   end repeat
   filter tOut without empty
   return tOut
end E12.Problems

-- the method, part 2: the camera jumps over the problem's cell and the frame sits on it;
-- a problem with no cell (no start) shows the whole map
on E12.Goto
   local tAt, tX, tZ, tY
   set the itemDel to tab
   put item 3 of E12.Line() into tAt
   set the itemDel to comma
   if tAt is empty or sNo is 0 then
      E12.Cam 0, 0, 700, 650
      SetObjectPosition sMark, 0, 5000, 0
   else
      put CellMap.CellX(sMap, item 1 of tAt) into tX
      put CellMap.CellZ(sMap, item 2 of tAt) into tZ
      put CellMap.GroundAt(sMap, sTags, empty, tX, tZ) into tY
      if tY is empty then put 0 into tY
      E12.Cam tX, tZ, 420, 380
      SetObjectPosition sMark, tX, -tY - 3, tZ
   end if
   E12.ShowHUD
end E12.Goto

-- the camera pUp high and pBack north of the point pTX, pTZ, looking south and down at it.
-- (Engine.SetCam takes the camera's position turned round, as E13 does: -x, -y, -z, up is -y)
on E12.Cam pTX, pTZ, pUp, pBack
   put round(pTX) & comma & round(pUp) & comma & round(pTZ - pBack) into sCam
   Engine.SetCam -pTX, pUp, pBack - pTZ
   put 0 into gCameraYaw
   put -atan2(pUp, pBack) into gCameraPitch
end E12.Cam

function E12.Line
   if sNo is 0 then return empty
   return line sNo of sProblems
end E12.Line

-- the level as wires, the yellow frame
on E12.Build
   local tSeg, tE, tMesh, tClass, tPair, tA, tB
   Scene.ClearAll
   repeat for each line tSeg in E12.LevelSegments(sMap)
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
      Mesh.Define "E12." & tClass, tMesh[tClass]
      get Entity.Spawn("E12." & tClass, 0, 0, 0, word 2 of tPair)
   end repeat
   Mesh.Define "E12.Mark", MeshBox(sMap["meta"]["cell"] + 4, 6, sMap["meta"]["cell"] + 4)
   put Entity.Spawn("E12.Mark", 0, 5000, 0, "yellow") into sMark
end E12.Build

on Game.OnUpdate
   local tKeys, tCount
   if sError is not empty then exit Game.OnUpdate
   put E12.Keys() into tKeys
   put the number of lines of sProblems into tCount
   if E12.Pressed(tKeys, "110,78,32", "next") and tCount > 0 then
      put sNo mod tCount + 1 into sNo
      E12.Goto
   end if
   if E12.Pressed(tKeys, "98,66", "back") and tCount > 0 then
      put (sNo + tCount - 2) mod tCount + 1 into sNo
      E12.Goto
   end if
   if E12.Pressed(tKeys, "109,77", "map") then E12.Open sMapNo mod the number of items of kMaps + 1
end Game.OnUpdate

on E12.ShowHUD
   local tLine, tTop
   set the itemDel to tab
   put E12.Line() into tLine
   if sNo is 0 then
      put "NO PROBLEMS: THIS MAP IS READY TO PLAY" into tTop
   else
      put sNo && "OF" && the number of lines of sProblems & ":" && toUpper(item 1 of tLine) && "AT" && item 3 of tLine & ":" && toUpper(item 4 of tLine) into tTop
   end if
   set the itemDel to comma
   HUD.Set "E12.Map", "E12 THE CHECKER   MAP" && toUpper(sMap["meta"]["name"]) & "   " & tTop, 20, 120, 14
end E12.ShowHUD

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

-- true once when any of pCodes goes down
function E12.Pressed pKeys, pCodes, pName
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
end E12.Pressed

function E12.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E12.Keys

on E12.TestKeys pKeys
   put pKeys into sTestKeys
end E12.TestKeys

-- map | problem n of count | kind at col,row | camera x,y,z | error
function E12.State
   local tLine
   set the itemDel to tab
   put E12.Line() into tLine
   return sMap["meta"]["name"] & "|" & sNo && "of" && the number of lines of sProblems & "|" & item 1 of tLine && item 3 of tLine & "|cam " & sCam & "|" & sError
end E12.State

-- tests: every problem line of the map now open
function E12.List
   return sProblems
end E12.List

-- the level's lines: the outline only when the map was saved lean (BitEditor: Scene > Lean Style)
-- and lib_lean is there (LIB_BIT/livecode/lib_lean; meta lean "water=off" leaves the water marks out)
function E12.LevelSegments pMap
   if pMap["meta"]["style"] is "lean" and "lib_lean" is among the lines of the stacksInUse then
      return Lean.MapSegments(pMap, sTags, empty, Lean.Style(pMap["meta"]["lean"]))
   end if
   return CellMap.LevelSegments(pMap, sTags, empty)
end E12.LevelSegments

function E12.FindFile pRelPath
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
end E12.FindFile
