######################################################################################
## CARD SCRIPT: "Play.Edit_E11"   E11 CAMERA SQUARES  (LIB_EDITOR, 11 18 2026)
## One method: cameras from data (the Tomb Raider Level Editor's camera triggers: fixed,
## target, flyby). The yard's [links] mark camera squares, "10,7 camera @cam1", and its
## [objects] place the cameras. Everywhere else a follow camera rides behind the hero.
##   cam1 FIXED  in the east room's corner, looking over the pool (the three squares south of it)
##   cam2 TARGET high in the west room's corner, turning to watch you (the square at 5,3)
##   cam3 FLYBY  round the yard and back, 120 steps (the square at 3,9), then the hero's camera again
## CONTROLS  Arrows or W A S D: walk
## NEEDS     ../LIB_BIT/editor (lib_cellmap, tags_default.txt), maps/cards_yard.cellmap
## LESSON    Adding: E11.Choose (the hero's square picks a camera) and E11.Camera (each mode)
##           Result: the view cuts as you walk, the way a film does
## FORMAT    ../LIB_BIT/editor/CELLMAP_V2.md section 5: [links] type camera, to @id;
##           [objects] kind camera, col,row, facing (0 north, 90 east), above (hu over the
##           ground there), props mode=fixed;pitch=<degrees down> | mode=target |
##           mode=flyby;path=<col,row col,row ...>;steps=<n>
######################################################################################

global gCameraYaw, gCameraPitch

local sMap, sTags, sHero, sCellWas, sCam, sFly, sError, sTestKeys

constant kSpeed = 3
constant kFall = 6
constant kHeroH = 50
constant kFollowUp = 300         -- the follow camera: this high over the hero's feet
constant kFollowBack = 260       -- and this far north of the hero, looking south
constant kFlyPitch = 35          -- degrees down while flying
constant kColours = "floor #1F4A5A,wall #7FA8FF,pit #FF5040,water #40E0FF,ceiling #9098A8,green #50E070,sky #B8D8FF"

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   put empty into sError
   put empty into sFly
   put E11.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E11: NOT FOUND LIB_BIT/EDITOR" into sError
      HUD.Set "E11.Err", sError, 20, 120, 14
      exit Game.OnStart
   end if
   start using stack tLib
   put CellMap.Read(E11.FindFile("LIB_EDITOR/maps/cards_yard.cellmap")) into sMap
   CellMap.Upgrade sMap
   put CellMap.TagsFromText(CellMap.ReadText(E11.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
   E11.Build
   E11.TestPlace 3, 5
   E11.Choose E11.Cell()
   E11.Camera
   HUD.Set "E11.Help", "ARROWS OR W A S D: WALK   CAMERA SQUARES: BY THE POOL, AT 5,3, AND AT 3,9 (A FLYBY)", 20, 146, 11
end Game.OnStart

on E11.Build
   local tSeg, tE, tMesh, tClass, tPair, tA, tB, n
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
      Mesh.Define "E11." & tClass, tMesh[tClass]
      get Entity.Spawn("E11." & tClass, 0, 0, 0, word 2 of tPair)
   end repeat
   -- a thin square on each camera square, so the player can see where the view will cut
   Mesh.Define "E11.Square", MeshBox(sMap["meta"]["cell"] - 24, 2, sMap["meta"]["cell"] - 24)
   put 1 into n
   repeat while n <= CellMap.Count(sMap["links"])
      if sMap["links"][n]["type"] is "camera" then
         get Entity.Spawn("E11.Square", CellMap.CellX(sMap, item 1 of sMap["links"][n]["from"]), -2, CellMap.CellZ(sMap, item 2 of sMap["links"][n]["from"]), "#FFB040")
      end if
      add 1 to n
   end repeat
   Mesh.Define "E11.Hero", MeshBox(24, kHeroH, 24)
   put Entity.Spawn("E11.Hero", 0, 0, 0, "#40E0FF") into sHero["key"]
end E11.Build

-- the method, part 1: the square the hero has just entered picks the camera. A camera link
-- names an object (@cam1); no link means the follow camera. A flyby, once started, plays to its
-- end whatever squares are crossed meanwhile; pNoFly true (a flyby just ended): the flyby's
-- own square gives the follow camera until it is entered again
on E11.Choose pCell, pNoFly
   local n, tId, tObj
   put empty into tId
   put 1 into n
   repeat while n <= CellMap.Count(sMap["links"])
      if sMap["links"][n]["from"] is pCell and sMap["links"][n]["type"] is "camera" then
         put char 2 to -1 of word 1 of sMap["links"][n]["to"] into tId
         exit repeat
      end if
      add 1 to n
   end repeat
   if sFly["left"] > 0 then exit E11.Choose
   put empty into sCam
   put "follow" into sCam["mode"]
   put "follow" into sCam["id"]
   if tId is empty then exit E11.Choose
   put 1 into n
   repeat while n <= CellMap.Count(sMap["objects"])
      put sMap["objects"][n] into tObj
      add 1 to n
      if tObj["id"] is not tId or tObj["kind"] is not "camera" then next repeat
      if pNoFly is true and E11.Prop(tObj["props"], "mode") is "flyby" then exit repeat
      put tId into sCam["id"]
      put E11.Prop(tObj["props"], "mode") into sCam["mode"]
      put CellMap.CellX(sMap, item 1 of tObj["at"]) into sCam["x"]
      put CellMap.CellZ(sMap, item 2 of tObj["at"]) into sCam["z"]
      put (E11.GroundHU(sCam["x"], sCam["z"]) + tObj["above"]) * CellMap.HU(sMap) into sCam["up"]
      put tObj["facing"] into sCam["facing"]
      put E11.Prop(tObj["props"], "pitch") into sCam["pitch"]
      if sCam["mode"] is "flyby" then E11.StartFly tObj
      exit repeat
   end repeat
end E11.Choose

-- a flyby: the path's cells as points at the camera's height, and steps to fly them all
on E11.StartFly pObj
   local tCell, n
   put empty into sFly
   put 0 into n
   repeat for each word tCell in E11.Prop(pObj["props"], "path")
      add 1 to n
      put CellMap.CellX(sMap, item 1 of tCell) into sFly[n]["x"]
      put CellMap.CellZ(sMap, item 2 of tCell) into sFly[n]["z"]
   end repeat
   put n into sFly["count"]
   put E11.Prop(pObj["props"], "steps") into sFly["steps"]
   if sFly["steps"] is not a number then put 120 into sFly["steps"]
   put sFly["steps"] into sFly["left"]
end E11.StartFly

-- the method, part 2: where the camera is and where it looks, each step
on E11.Camera
   local tX, tZ, tUp, tA, tB, tT, tSeg, tF
   switch sCam["mode"]
      case "fixed"
         put sCam["facing"] * pi / 180 into tF
         E11.Place sCam["x"], sCam["up"], sCam["z"], pi - tF, -sCam["pitch"] * pi / 180
         break
      case "target"
         E11.Aim sCam["x"], sCam["up"], sCam["z"], sHero["x"], sHero["y"] + kHeroH, sHero["z"]
         break
      case "flyby"
         -- along the path's legs, an equal share of the steps each; looking the way it flies
         put sFly["steps"] - sFly["left"] into tT
         put max(1, sFly["count"] - 1) into tSeg
         put min(tSeg - 0.0001, tT * tSeg / sFly["steps"]) into tT
         put trunc(tT) + 1 into tA
         put min(sFly["count"], tA + 1) into tB
         put tT - trunc(tT) into tT
         put sFly[tA]["x"] + (sFly[tB]["x"] - sFly[tA]["x"]) * tT into tX
         put sFly[tA]["z"] + (sFly[tB]["z"] - sFly[tA]["z"]) * tT into tZ
         E11.Place tX, sCam["up"], tZ, atan2(sFly[tB]["x"] - sFly[tA]["x"], sFly[tB]["z"] - sFly[tA]["z"]), -kFlyPitch * pi / 180
         subtract 1 from sFly["left"]
         if sFly["left"] <= 0 then
            put empty into sFly
            E11.Choose E11.Cell(), true
            E11.Camera
         end if
         break
      default
         E11.Aim sHero["x"], sHero["y"] + kFollowUp, sHero["z"] - kFollowBack, sHero["x"], sHero["y"] + kHeroH, sHero["z"]
   end switch
end E11.Camera

-- the camera at pCX, pCUp (engine units up), pCZ looking at pTX, pTUp, pTZ (as E13 aims)
on E11.Aim pCX, pCUp, pCZ, pTX, pTUp, pTZ
   E11.Place pCX, pCUp, pCZ, atan2(pTX - pCX, pTZ - pCZ), -atan2(pCUp - pTUp, sqrt((pTX - pCX) ^ 2 + (pTZ - pCZ) ^ 2))
end E11.Aim

-- yaw 0 looks south (+z), pitch below 0 looks down; Engine.SetCam takes the position turned round
on E11.Place pX, pUp, pZ, pYaw, pPitch
   put pX into sCam["atX"]
   put pUp into sCam["atUp"]
   put pZ into sCam["atZ"]
   put pYaw into gCameraYaw
   put pPitch into gCameraPitch
   Engine.SetCam -pX, pUp, -pZ
end E11.Place

function E11.GroundHU pX, pZ
   local tG
   put CellMap.GroundAt(sMap, sTags, empty, pX, pZ) into tG
   if tG is empty then return 0
   return round(tG / CellMap.HU(sMap))
end E11.GroundHU

function E11.Prop pProps, pKey
   local tPair
   set the itemDel to ";"
   repeat for each item tPair in pProps
      if tPair begins with (pKey & "=") then return char (length(pKey) + 2) to -1 of tPair
   end repeat
   return empty
end E11.Prop

on Game.OnUpdate
   local tCell
   if sError is not empty then exit Game.OnUpdate
   E11.Move E11.Keys()
   put E11.Cell() into tCell
   if tCell is not sCellWas then
      put tCell into sCellWas
      E11.Choose tCell
   end if
   E11.Camera
   E11.ShowHUD
end Game.OnUpdate

on E11.Move pKeys
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
end E11.Move

function E11.Cell
   return CellMap.CellAt(sMap, sHero["x"], sHero["z"])
end E11.Cell

on E11.ShowHUD
   local tMode
   put toUpper(sCam["mode"]) into tMode
   if sCam["id"] is not "follow" then put tMode && "(" & toUpper(sCam["id"]) & ")" into tMode
   if sFly["left"] > 0 then put tMode && sFly["left"] && "STEPS LEFT" into tMode
   HUD.Set "E11.Cell", "E11 CAMERA SQUARES   YOU ARE ON" && E11.Cell() & "   CAMERA:" && tMode, 20, 120, 14
end E11.ShowHUD

on Game.OnStop
   HUD.Clear
end Game.OnStop

on arrowKey
end arrowKey

function E11.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E11.Keys

on E11.TestKeys pKeys
   put pKeys into sTestKeys
end E11.TestKeys

-- tests: the hero on the centre of cell pCol,pRow (the camera is chosen on the next step)
on E11.TestPlace pCol, pRow
   put CellMap.CellX(sMap, pCol) into sHero["x"]
   put CellMap.CellZ(sMap, pRow) into sHero["z"]
   put CellMap.GroundAt(sMap, sTags, empty, sHero["x"], sHero["z"]) into sHero["y"]
   put empty into sCellWas
   SetObjectPosition sHero["key"], sHero["x"], -sHero["y"] - kHeroH / 2, sHero["z"]
end E11.TestPlace

-- hero's cell | camera id and mode | where it is (x, up, z, engine units) | yaw and pitch in degrees | flyby steps left | error
function E11.State
   return E11.Cell() & "|" & sCam["id"] && sCam["mode"] & "|at " & round(sCam["atX"]) & "," & round(sCam["atUp"]) & "," & round(sCam["atZ"]) & \
         "|yaw " & (round(gCameraYaw * 180 / pi) + 720) mod 360 & " pitch " & round(gCameraPitch * 180 / pi) & "|fly " & max(0, sFly["left"]) & "|" & sError
end E11.State

function E11.FindFile pRelPath
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
end E11.FindFile
