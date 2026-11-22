######################################################################################
## CARD SCRIPT: "Play.Edit_E13"   E13 WALK THE MAP  (LIB_EDITOR, 11 14 2026)
## One method: a version 2 cellmap becomes a level you walk. The map's five height
## layers (floor, ceiling, red, green, blue) are turned into wire meshes by
## CellMap.LevelSegments, one mesh a class (floor, wall, pit, water, ceiling, green,
## sky, relief), and Amazing Couple's PROMPT walks it with CellMap.Walk: down the pool
## steps, up the dais, under the clouds, into the wizard's tower, over the glyphs.
## The engine's own collision is not used: the map answers every step.
## CONTROLS  W S or Up Down: walk   A D or Left Right: turn   Shift: run
##           R: glyph relief on / off   M: next map (wizard_pool, amazing_couple, two_rooms)
##           E: take the door or ladder you stand on (a map pack's doors)
##           L: lean style on / off (only the outline you can see; a map saved lean starts lean;
##           LIB_BIT/livecode/lib_lean.livecodescript, 21 Nov 2026)
## PACKS     two_rooms is a map pack (CELLMAP_V3.md): a cellar and a loft stacked in one
##           place, drawn by CellMap.PackSegments, walked by CellMap.PackWalk (stairs up
##           through a hole, a sloped ramp to the goal), a ladder by CellMap.PackDoors
## NEEDS     ../LIB_BIT/editor (lib_cellmap, tags, fonts, maps), ../LIB_MOCAP/library (the clips)
## LESSON    Adding: CellMap.LevelSegments + CellMap.Walk   Result: the drawing is a place
## FORMAT    ../LIB_BIT/editor/CELLMAP_V2.md
######################################################################################

global gObjectTransforms, gSceneObjects
global gCameraYaw, gCameraPitch
global gViewLeft, gViewTop, gViewRight, gViewBottom

constant kM = 30                 -- engine units a metre (the clips are in metres)
constant kTurn = 0.06            -- radians a step
constant kCamBack = 120
constant kCamUp = 95
constant kGravity = 0.9          -- units a step a step, falling
constant kWalk = "Animazoo_gangster_walk"
constant kIdle = "Animazoo_hands_on_hips"
constant kRun = "Animazoo_Running_-_Jog"
constant kMaps = "wizard_pool,amazing_couple,two_rooms"
-- class, colour: what each kind of line means (CELLMAP_V2.md section 6)
constant kColours = "floor #1F4A5A,wall #7FA8FF,pit #FF5040,water #40E0FF,ceiling #9098A8,green #50E070,sky #B8D8FF,relief #FFFFFF"

local sMap, sTags, sFont, sMapNo, sRelief, sSegCount, sStepMS, sLean
local sClip, sHero, sKeyWas, sTestKeys, sError, sMsg, sMsgUntil, sTicks, sTeleWait
local sCamX, sCamY, sCamZ
-- a map pack (empty for a single map): the pack, the place walked, the map stood on and its shift
local sPack, sPlace, sMapId, sOX, sOZ, sBase

-------------------------------------------------------------------- engine hooks

on Game.OnStart
   local tLib
   focus on nothing
   Engine.ResetCamera
   put Engine.Info("stepMS") into sStepMS
   if sStepMS is not a number then put 33 into sStepMS
   put empty into sError
   put empty into sKeyWas
   put 0 into sTicks
   put 1 into sMapNo
   put true into sRelief
   put E13.FindFile("LIB_BIT/editor/livecode/lib_cellmap.livecodescript") into tLib
   if tLib is empty then
      put "E13: NOT FOUND LIB_BIT/EDITOR" into sError
   else
      start using stack tLib
      -- the Lean style (L): optional, the level draws without it
      put E13.FindFile("LIB_BIT/livecode/lib_lean.livecodescript") into tLib
      if tLib is not empty then start using stack tLib
      put CellMap.TagsFromText(CellMap.ReadText(E13.FindFile("LIB_BIT/editor/data/tags_default.txt"))) into sTags
      E13.LoadClips
   end if
   if sError is not empty then
      Scene.ClearAll
      HUD.Clear
      HUD.Set "E13.Err", sError, gViewLeft + 20, gViewTop + 20, 14
      exit Game.OnStart
   end if
   E13.LoadMap
end Game.OnStart

on Game.OnUpdate
   local tKeys
   if sError is not empty then exit Game.OnUpdate
   add 1 to sTicks
   put E13.Keys() into tKeys
   if E13.Pressed(tKeys, "114,82", "relief") then
      put not sRelief into sRelief
      E13.BuildLevel
   end if
   if E13.Pressed(tKeys, "101,69", "door") then E13.TakeDoor
   if E13.Pressed(tKeys, "108,76", "lean") then
      put not sLean into sLean
      E13.BuildLevel
      if sLean then
         E13.Say "LEAN STYLE:" && sSegCount && "LINES", 3000
      else
         E13.Say "CUBES:" && sSegCount && "LINES", 3000
      end if
   end if
   if E13.Pressed(tKeys, "109,77", "map") then
      add 1 to sMapNo
      if sMapNo > the number of items of kMaps then put 1 into sMapNo
      E13.LoadMap
      exit Game.OnUpdate
   end if
   E13.Controls tKeys
   E13.Animate
   E13.Camera false
   E13.ShowHUD
end Game.OnUpdate

on Game.OnClick pX,pY,pButton
end Game.OnClick

on Game.OnKill pKey,pX,pY,pZ
end Game.OnKill

on Game.OnPause
end Game.OnPause

on Game.OnResume
end Game.OnResume

on Game.OnStop
   HUD.Clear
end Game.OnStop

on Collision.Hit pA,pB
end Collision.Hit

on arrowKey
end arrowKey

-------------------------------------------------------------------- the map becomes a level

on E13.LoadMap
   local tFile, r, c, tStart, tName
   put item sMapNo of kMaps into tName
   put empty into sPack
   put 0 into sOX
   put 0 into sOZ
   put 0 into sBase
   put E13.FindFile("LIB_BIT/editor/maps/" & tName & "/" & tName & ".cellpack") into tFile
   if tFile is not empty then
      E13.LoadPack tFile
      exit E13.LoadMap
   end if
   put E13.FindFile("LIB_BIT/editor/maps/" & tName & ".cellmap") into tFile
   if tFile is empty then
      put "E13: NO MAP " & toUpper(item sMapNo of kMaps) into sError
      exit E13.LoadMap
   end if
   put CellMap.Read(tFile) into sMap
   CellMap.Upgrade sMap                      -- version 1 maps walk too
   put (sMap["meta"]["style"] is "lean") into sLean    -- the map's own style (BitEditor: Scene > Lean Style)
   put CellMap.FontFromText(CellMap.ReadText(E13.FindFile("LIB_BIT/editor/fonts/" & sMap["meta"]["font"] & ".font.txt"))) into sFont
   -- the hero starts on the @ tag (else the first cell it can stand on)
   put empty into tStart
   put 1 into r
   repeat while r <= sMap["meta"]["rows"]
      put 1 into c
      repeat while c <= sMap["meta"]["cols"]
         if sMap["tags"][r][c] is "@" then put c & comma & r into tStart
         if tStart is empty and CellMap.StandAt(sMap, sTags, empty, CellMap.CellX(sMap, c), CellMap.CellZ(sMap, r), 1000000) is not empty then put c & comma & r into tStart
         add 1 to c
      end repeat
      add 1 to r
   end repeat
   put CellMap.CellX(sMap, item 1 of tStart) into sHero["x"]
   put CellMap.CellZ(sMap, item 2 of tStart) into sHero["z"]
   put CellMap.GroundAt(sMap, sTags, sFont, sHero["x"], sHero["z"]) into sHero["y"]
   E13.StartHero
   E13.BuildLevel
   E13.Say "MAP" && toUpper(sMap["meta"]["name"]) & ":" && sSegCount && "LINES", 4000
   E13.Camera true
end E13.LoadMap

-- a map pack: its maps stacked in one place, the hero on the start map's @ (CELLMAP_V3.md 4)
on E13.LoadPack pFile
   local tAt
   put CellMap.ReadPack(pFile) into sPack
   if sPack["problems"] is not empty then
      put "E13: PACK PROBLEM " & toUpper(line 1 of sPack["problems"]) into sError
      exit E13.LoadPack
   end if
   put CellMap.PackEnter(sPack, sTags, empty, empty) into tAt
   if tAt is empty then
      put "E13: NOWHERE TO STAND IN " & toUpper(sPack["meta"]["name"]) into sError
      exit E13.LoadPack
   end if
   put item 1 of tAt into sPlace
   E13.OnMap sPack["meta"]["start"]
   put CellMap.FontFromText(CellMap.ReadText(E13.FindFile("LIB_BIT/editor/fonts/" & sMap["meta"]["font"] & ".font.txt"))) into sFont
   put item 2 of tAt into sHero["x"]
   put item 3 of tAt into sHero["z"]
   put item 4 of tAt into sHero["y"]
   E13.StartHero
   E13.BuildLevel
   E13.Say "PACK" && toUpper(sPack["meta"]["name"]) & ":" && sPack["count"] && "MAPS," && sSegCount && "LINES", 4000
   E13.Camera true
end E13.LoadPack

-- the hero now stands on map pId of the pack: sMap is that map, sOX sOZ sBase its place in the pack
on E13.OnMap pId
   local i
   put CellMap.PackIndex(sPack, pId) into i
   if i is 0 then exit E13.OnMap
   put pId into sMapId
   put sPack["maps"][i]["map"] into sMap
   put sPack["maps"][i]["ox"] into sOX
   put sPack["maps"][i]["oz"] into sOZ
   put sPack["maps"][i]["base"] into sBase
end E13.OnMap

on E13.StartHero
   put 0 into sHero["vy"]
   put pi into sHero["yaw"]                  -- facing north, up the map
   put 0 into sHero["speed"]
   put "idle" into sHero["anim"]
   put 1 into sHero["frame"]
   put "path" into sHero["effect"]
   put 0 into sTeleWait
end E13.StartHero

-- E on a door cell of a pack: the game plays no climb, it puts the hero at the far end
on E13.TakeDoor
   local tCell, tDoor, tAt, tTo
   if sPack is not an array then exit E13.TakeDoor
   put E13.Cell() into tCell
   put line 1 of CellMap.PackDoors(sPack, sMapId, item 1 of tCell, item 2 of tCell) into tDoor
   if tDoor is empty then exit E13.TakeDoor
   set the itemDel to tab
   put CellMap.PackEnter(sPack, sTags, sFont, item 2 of tDoor) into tAt
   if tAt is empty then exit E13.TakeDoor
   E13.Say toUpper(item 1 of tDoor) & ":" && toUpper(item 3 of tDoor), 2500
   put item 2 of tDoor into tTo
   set the itemDel to ":"
   E13.OnMap item 1 of tTo
   set the itemDel to comma
   put item 1 of tAt into sPlace
   put item 2 of tAt into sHero["x"]
   put item 3 of tAt into sHero["z"]
   put item 4 of tAt into sHero["y"]
   put 0 into sHero["vy"]
   E13.Camera true
end E13.TakeDoor

-- the cell of the map the hero stands on
function E13.Cell
   return CellMap.CellAt(sMap, sHero["x"] - sOX, sHero["z"] - sOZ)
end E13.Cell

-- the method: every class of segment is one wire mesh, spawned once in its colour
on E13.BuildLevel
   local tSegs, tSeg, tE, tMesh, tIndex, tClass, tPair, tA, tB, tN, tUseFont, tObj, tAt
   Scene.ClearAll
   HUD.Clear
   if sRelief then
      put sFont into tUseFont
   else
      put empty into tUseFont
   end if
   if sPack is an array then
      put CellMap.PackSegments(sPack, sPlace, sTags, tUseFont) into tSegs
   else
      put CellMap.LevelSegments(sMap, sTags, tUseFont) into tSegs
   end if
   if sLean is true then put Lean.Segments(tSegs, empty) into tSegs
   put the number of lines of tSegs into sSegCount
   repeat for each line tSeg in tSegs
      put item 7 of tSeg into tClass
      if tMesh[tClass] is not an array then put Mesh.New() into tMesh[tClass]
      if sPack is an array then
         put tSeg into tE                    -- a pack's lines come in engine units
      else
         put CellMap.SegToEngine(sMap, tSeg) into tE
      end if
      -- map space has y up; the engine has up = -Y
      put E13.Vertex(tMesh[tClass], tIndex[tClass], item 1 of tE, -(item 2 of tE), item 3 of tE) into tA
      put E13.Vertex(tMesh[tClass], tIndex[tClass], item 4 of tE, -(item 5 of tE), item 6 of tE) into tB
      Mesh.AddLine tMesh[tClass], tA, tB
      add 1 to tN[tClass]
   end repeat
   repeat for each item tPair in kColours
      put word 1 of tPair into tClass
      if tMesh[tClass] is not an array then next repeat
      Mesh.Define "E13." & tClass, tMesh[tClass]
      get Entity.Spawn("E13." & tClass, 0, 0, 0, word 2 of tPair)
   end repeat
   -- objects: a beacon stands where the map says
   put 1 into tA
   if sPack is an array then put 1000000 into tA     -- a pack's maps carry no objects yet
   repeat while tA <= CellMap.Count(sMap["objects"])
      put sMap["objects"][tA] into tObj
      if tObj["kind"] is "beacon" then
         put tObj["at"] into tAt
         Mesh.Define "E13.Beacon", E13.BeaconMesh()
         put CellMap.GroundAt(sMap, sTags, empty, CellMap.CellX(sMap, item 1 of tAt), CellMap.CellZ(sMap, item 2 of tAt)) into tB
         put Entity.Spawn("E13.Beacon", CellMap.CellX(sMap, item 1 of tAt), -tB, CellMap.CellZ(sMap, item 2 of tAt), "#FFD040") into tB
         SetObjectRotationSpeed tB, 0, 0.05, 0
      end if
      add 1 to tA
   end repeat
   -- the hero
   put Entity.Spawn("E13." & kIdle & ".1", sHero["x"], -sHero["y"], sHero["z"], "#40E0FF") into sHero["key"]
end E13.BuildLevel

function E13.Vertex @pMesh, @pIndex, pX, pY, pZ
   local tKey
   put pX & "," & pY & "," & pZ into tKey
   if pIndex[tKey] is empty then
      Mesh.AddVertex pMesh, pX, pY, pZ
      put the result into pIndex[tKey]
   end if
   return pIndex[tKey]
end E13.Vertex

-------------------------------------------------------------------- walking: the map answers every step

on E13.Controls pKeys
   local tF, tTurn, tStep, tDX, tDZ, tW, tWas, tGround, tCell, tDoor
   put 0 into tF
   put 0 into tTurn
   if 119 is among the items of pKeys or 87 is among the items of pKeys or 65362 is among the items of pKeys then add 1 to tF
   if 115 is among the items of pKeys or 83 is among the items of pKeys or 65364 is among the items of pKeys then subtract 0.5 from tF
   if 97 is among the items of pKeys or 65 is among the items of pKeys or 65361 is among the items of pKeys then subtract kTurn from tTurn
   if 100 is among the items of pKeys or 68 is among the items of pKeys or 65363 is among the items of pKeys then add kTurn to tTurn
   add tTurn to sHero["yaw"]
   if tF > 0 and (65505 is among the items of pKeys or 65506 is among the items of pKeys) then
      put E13.WalkStep(kRun) * tF into tStep
   else
      put E13.WalkStep(kWalk) * tF into tStep
   end if
   -- water and rough ground slow you down (the tag's effect)
   if sHero["effect"] is "swim" then multiply tStep by 0.5
   if sHero["effect"] is "slow" then multiply tStep by 0.7
   put sin(sHero["yaw"]) * tStep into tDX
   put cos(sHero["yaw"]) * tStep into tDZ
   put sHero["x"] & comma & sHero["z"] into tWas
   if sPack is an array then
      -- every map of the place answers: stairs, holes and the deck above are plain geometry
      put CellMap.PackWalk(sPack, sPlace, sTags, sFont, sHero["x"], sHero["z"], sHero["y"], tDX, tDZ, 12) into tW
      if item 5 of tW is not empty and item 5 of tW is not sMapId then
         E13.OnMap item 5 of tW
      end if
   else
      put CellMap.Walk(sMap, sTags, sFont, sHero["x"], sHero["z"], sHero["y"], tDX, tDZ, 12) into tW
   end if
   put item 1 of tW into sHero["x"]
   put item 2 of tW into sHero["z"]
   put item 3 of tW into tGround
   put item 4 of tW into sHero["effect"]
   put sqrt((sHero["x"] - item 1 of tWas) ^ 2 + (sHero["z"] - item 2 of tWas) ^ 2) into sHero["speed"]
   if tF < 0 then put -sHero["speed"] into sHero["speed"]
   -- up a step at once; down by falling
   if tStep is 0 then
      if sPack is an array then
         put item 1 of CellMap.PackStandAt(sPack, sPlace, sTags, sFont, sHero["x"], sHero["z"], sHero["y"]) into tGround
      else
         put CellMap.StandAt(sMap, sTags, sFont, sHero["x"], sHero["z"], sHero["y"]) into tGround
      end if
   end if
   if tGround is empty then put sHero["y"] into tGround
   if tGround >= sHero["y"] then
      put tGround into sHero["y"]
      put 0 into sHero["vy"]
   else
      add kGravity to sHero["vy"]
      put max(tGround, sHero["y"] - sHero["vy"]) into sHero["y"]
      if sHero["y"] is tGround then put 0 into sHero["vy"]
   end if
   -- what the cell does
   put E13.Cell() into tCell
   if sTeleWait > 0 then subtract 1 from sTeleWait
   switch sHero["effect"]
      case "teleport"
         if sTeleWait is 0 then E13.Teleport tCell
         break
      case "goal"
         E13.Say "THE GOAL: YOU STAND ON IT", 1500
         break
      case "swim"
         E13.Say "SWIMMING", 500
         break
      case "slide"
         E13.Say "TOO STEEP", 500
         break
   end switch
   if sPack is an array then
      put line 1 of CellMap.PackDoors(sPack, sMapId, item 1 of tCell, item 2 of tCell) into tDoor
      set the itemDel to tab
      if tDoor is not empty then E13.Say "E: TAKE THE" && toUpper(item 1 of tDoor), 300
      set the itemDel to comma
   end if
end E13.Controls

-- links: a teleport link from this cell sends the hero to its target, on the highest level there
on E13.Teleport pCell
   local n, tTo
   put 1 into n
   repeat while n <= CellMap.Count(sMap["links"])
      if sMap["links"][n]["from"] is pCell and sMap["links"][n]["type"] is "teleport" then
         put word 1 of sMap["links"][n]["to"] into tTo
         put CellMap.CellX(sMap, item 1 of tTo) into sHero["x"]
         put CellMap.CellZ(sMap, item 2 of tTo) into sHero["z"]
         put CellMap.GroundAt(sMap, sTags, sFont, sHero["x"], sHero["z"]) into sHero["y"]
         put 0 into sHero["vy"]
         put round(2000 / sStepMS) into sTeleWait
         E13.Say "TELEPORTED:" && toUpper(sMap["links"][n]["note"]), 3500
         E13.Camera true
         exit E13.Teleport
      end if
      add 1 to n
   end repeat
end E13.Teleport

function E13.WalkStep pClip
   return sClip[pClip]["travel"] * kM * sStepMS / 1000
end E13.WalkStep

-------------------------------------------------------------------- the hero's clips (as Amazing Couple)

on E13.LoadClips
   local tName, tFile
   put empty into sClip
   repeat for each item tName in kWalk & comma & kIdle & comma & kRun
      put E13.FindFile("LIB_MOCAP/library/" & tName & "/" & tName & "_stick.txt") into tFile
      if tFile is empty then
         put "E13: NO CLIP " & toUpper(tName) & " IN LIB_MOCAP/LIBRARY" into sError
         exit E13.LoadClips
      end if
      E13.LoadClip tName, URL ("file:" & tFile)
   end repeat
end E13.LoadClips

-- a stick clip: only its cycle when it has one (walks, runs), else its first 300 frames
on E13.LoadClip pName, pText
   local tLine, tEdges, tFrame, tKept, tM, tV, i, tJoints, tE, tA, tB, tFrom, tTo
   put 0 into tFrame
   put 0 into tKept
   put 1 into tFrom
   put 300 into tTo
   repeat for each line tLine in pText
      if tLine is empty or char 1 of tLine is "#" then next repeat
      set the itemDel to comma
      switch item 1 of tLine
         case "fps"
            put item 2 of tLine into sClip[pName]["fps"]
            break
         case "travel"
            if sClip[pName]["travel"] is empty then put item 2 of tLine into sClip[pName]["travel"]
            break
         case "cycle"
            put item 2 of tLine into tFrom
            put item 3 of tLine into tTo
            break
         case "cycle_travel"
            put item 2 of tLine into sClip[pName]["travel"]
            break
         case "joints"
            put item 2 of tLine into tJoints
            break
         case "edges"
            put item 2 of tLine into tEdges
            break
         default
            if char 1 of tLine is "-" or char 1 of tLine is a number then
               add 1 to tFrame
               if tFrame < tFrom or tFrame > tTo then next repeat
               add 1 to tKept
               put tLine into tV
               split tV by comma
               put Mesh.New() into tM
               put 0 into i
               repeat while i < tJoints
                  Mesh.AddVertex tM, tV[3 * i + 1] * kM, -tV[3 * i + 2] * kM, tV[3 * i + 3] * kM
                  add 1 to i
               end repeat
               repeat for each word tE in tEdges
                  set the itemDel to "-"
                  put item 1 of tE + 1 into tA
                  put item 2 of tE + 1 into tB
                  set the itemDel to comma
                  Mesh.AddLine tM, tA, tB
               end repeat
               Mesh.Define "E13." & pName & "." & tKept, tM
            end if
      end switch
   end repeat
   put tKept into sClip[pName]["frames"]
   if sClip[pName]["fps"] is not a number then put 30 into sClip[pName]["fps"]
   if sClip[pName]["travel"] is not a number then put 0 into sClip[pName]["travel"]
end E13.LoadClip

on E13.Animate
   local tSpeed, tWhich, tClip, tN, tKey, tE
   put abs(sHero["speed"]) into tSpeed
   if tSpeed <= 0.2 then
      put "idle" into tWhich
      put kIdle into tClip
   else if tSpeed > (E13.WalkStep(kWalk) + E13.WalkStep(kRun)) / 2 then
      put "run" into tWhich
      put kRun into tClip
   else
      put "walk" into tWhich
      put kWalk into tClip
   end if
   if tWhich is not sHero["anim"] then
      put tWhich into sHero["anim"]
      put 1 into sHero["frame"]
   end if
   put sClip[tClip]["frames"] into tN
   if tN < 1 then exit E13.Animate
   if tWhich is "idle" or E13.WalkStep(tClip) is 0 then
      add sClip[tClip]["fps"] * sStepMS / 1000 to sHero["frame"]
   else
      add sHero["speed"] / E13.WalkStep(tClip) * sClip[tClip]["fps"] * sStepMS / 1000 to sHero["frame"]
   end if
   repeat while sHero["frame"] >= tN + 1
      subtract tN from sHero["frame"]
   end repeat
   repeat while sHero["frame"] < 1
      add tN to sHero["frame"]
   end repeat
   put sHero["key"] into tKey
   E13.SetMesh tKey, "E13." & tClip & "." & trunc(sHero["frame"])
   SetObjectPosition tKey, sHero["x"], -sHero["y"], sHero["z"]
   put E13.Euler(sHero["yaw"], 0) into tE
   SetObjectRotation tKey, item 1 of tE, item 2 of tE, item 3 of tE
end E13.Animate

-- swap the mesh an object is drawn with (from Antack)
on E13.SetMesh pKey, pMesh
   local tOut, tLine
   if gObjectTransforms[pKey]["mesh"] is pMesh then exit E13.SetMesh
   repeat for each line tLine in gSceneObjects
      if word 2 of tLine is pKey then put pMesh into word 1 of tLine
      put tLine & cr after tOut
   end repeat
   delete the last char of tOut
   put tOut into gSceneObjects
   put pMesh into gObjectTransforms[pKey]["mesh"]
end E13.SetMesh

function E13.Euler pYaw, pPitch
   local sy, cy, sp, cp
   put sin(pYaw) into sy
   put cos(pYaw) into cy
   put sin(pPitch) into sp
   put cos(pPitch) into cp
   return atan2(sp, cy * cp) & comma & asin(max(-1, min(1, sy * cp))) & comma & atan2(-sy * sp, cy)
end E13.Euler

function E13.BeaconMesh
   local tM, tTop, tBot, tA, tB
   put Mesh.New() into tM
   Mesh.AddVertex tM, 0, -64, 0
   put the result into tTop
   Mesh.AddVertex tM, 0, -4, 0
   put the result into tBot
   Mesh.AddVertex tM, 12, -34, 0
   put the result into tA
   Mesh.AddVertex tM, 0, -34, 12
   Mesh.AddVertex tM, -12, -34, 0
   Mesh.AddVertex tM, 0, -34, -12
   Mesh.AddLine tM, tA, tA + 1
   Mesh.AddLine tM, tA + 1, tA + 2
   Mesh.AddLine tM, tA + 2, tA + 3
   Mesh.AddLine tM, tA + 3, tA
   repeat for each item tB in tA & "," & (tA + 1) & "," & (tA + 2) & "," & (tA + 3)
      Mesh.AddLine tM, tTop, tB
      Mesh.AddLine tM, tBot, tB
   end repeat
   return tM
end E13.BeaconMesh

-------------------------------------------------------------------- camera and HUD

-- behind and above the hero, at the hero's own height; pSnap jumps there at once
on E13.Camera pSnap
   local tH, tX, tZ, tY, tCX, tCY, tCZ, tK, tLY
   put sHero["yaw"] into tH
   put sHero["x"] into tX
   put sHero["z"] into tZ
   put sHero["y"] into tY
   put tX - sin(tH) * kCamBack into tCX
   put -(tY + kCamUp) into tCY
   put tZ - cos(tH) * kCamBack into tCZ
   if pSnap or sCamX is not a number then
      put tCX into sCamX
      put tCY into sCamY
      put tCZ into sCamZ
   else
      put 0.22 into tK
      put sCamX + (tCX - sCamX) * tK into sCamX
      put sCamY + (tCY - sCamY) * tK into sCamY
      put sCamZ + (tCZ - sCamZ) * tK into sCamZ
   end if
   put -(tY + kM) into tLY          -- chest height (up is -Y)
   put atan2(tX - sCamX, tZ - sCamZ) into gCameraYaw
   put -atan2(tLY - sCamY, sqrt((tX - sCamX) ^ 2 + (tZ - sCamZ) ^ 2)) into gCameraPitch
   Engine.SetCam -sCamX, -sCamY, -sCamZ
end E13.Camera

on E13.Say pText, pMS
   put pText into sMsg
   put sTicks + round(pMS / sStepMS) into sMsgUntil
end E13.Say

on E13.ShowHUD
   local tCell, tC, tR
   put E13.Cell() into tCell
   put item 1 of tCell into tC
   put item 2 of tCell into tR
   -- changing text at the top (the owner: not at the bottom)
   HUD.Set "E13.Cell", "CELL" && tC & "," & tR & "   TAG" && sMap["tags"][tR][tC] && "(" & toUpper(CellMap.TagInfo(sMap, sTags, sMap["tags"][tR][tC], "name")) & ")   EFFECT" && toUpper(sHero["effect"]), gViewLeft + 20, gViewTop + 20, 13
   HUD.Set "E13.Heights", "FLOOR" && sMap["floor"][tR][tC] & "  CEILING" && sMap["ceiling"][tR][tC] & "  RED" && sMap["red"][tR][tC] & "  GREEN" && sMap["green"][tR][tC] & "  BLUE" && sMap["blue"][tR][tC] & \
         "     YOU STAND AT" && round(sHero["y"] / CellMap.HU(sMap)) && "(100 = A FULL HALLWAY)", gViewLeft + 20, gViewTop + 42, 11
   if sMsgUntil is a number and sTicks < sMsgUntil then
      HUD.Set "E13.Msg", sMsg, gViewLeft + 20, gViewTop + 70, 16
   else
      HUD.Remove "E13.Msg"
   end if
   HUD.Set "E13.Help", "W S WALK   A D TURN   SHIFT RUN   R RELIEF   L LEAN   M NEXT MAP   E DOOR / LADDER", gViewLeft + 20, gViewBottom - 30, 11
end E13.ShowHUD

-------------------------------------------------------------------- helpers and tests

-- true once when any of pCodes goes down
function E13.Pressed pKeys, pCodes, pName
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
end E13.Pressed

function E13.Keys
   if sTestKeys is not empty then return sTestKeys
   return the keysDown
end E13.Keys

on E13.TestKeys pKeys
   put pKeys into sTestKeys
end E13.TestKeys

-- tests: put the hero in cell pCol,pRow facing pYawDegrees (0 = north, 90 = east), on the
-- ground there (pTop true: on its highest level, a roof or a cloud); pMapId: that map of a pack
on E13.TestPlace pCol, pRow, pYawDegrees, pTop, pMapId
   if sPack is an array and pMapId is not empty then E13.OnMap pMapId
   put CellMap.CellX(sMap, pCol) + sOX into sHero["x"]
   put CellMap.CellZ(sMap, pRow) + sOZ into sHero["z"]
   if pTop is true then
      put CellMap.GroundAt(sMap, sTags, sFont, sHero["x"] - sOX, sHero["z"] - sOZ) + sBase * CellMap.HU(sMap) into sHero["y"]
   else
      put (item 1 of line 1 of CellMap.Levels(sMap, pCol, pRow) + sBase) * CellMap.HU(sMap) into sHero["y"]
   end if
   put 0 into sHero["vy"]
   if pYawDegrees is a number then put pi - pYawDegrees * pi / 180 into sHero["yaw"]
   put 5 into sTeleWait
end E13.TestPlace

-- cell | standing height in hu | effect | animation | step sizes | map, lines, objects in the scene | message | error | ticks
function E13.State
   local tMsg
   if sMsgUntil is a number and sTicks < sMsgUntil then put sMsg into tMsg
   return E13.Cell() & "|y " & round(sHero["y"] / CellMap.HU(sMap)) & "|" & sHero["effect"] & "|" & sHero["anim"] & \
         "|step " & round(E13.WalkStep(kWalk), 2) & "/" & round(E13.WalkStep(kRun), 2) & \
         "|" & sMap["meta"]["name"] && sSegCount && "lines," && the number of lines of gSceneObjects && "objects|" & tMsg & "|" & sError & "|tick " & sTicks
end E13.State

function E13.FindFile pRelPath
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
end E13.FindFile
