-- v3d_skins.livecodescript: "Replace With Model..." for iGame3D XT (A-86, Opus 15 Nov 2026; procedural
-- first, folders second: the owner, 16 Nov 2026).
-- SOURCE OF TRUTH: this file. Built by code on a new stack each time (the editor's Edit > Replace With
-- Model..., Ig.OpenTool): create invisible stack "V3D_Skins"; set its script to this file;
-- send "Skins.Build <projects>" to it. Needs iGame3D XT's Tools/v3d_buildings, v3d_props, v3d_figures in use.
-- HOW IT WORKS
--   Game: a Vibecode3D game (LIB_GAMES/Vibecode3D_Games/Vibecode3D_Play_<Game>.livecodescript). Its
--   placeholder meshes are the names it gives Mesh.Define ("Fuel.Car" ...), listed on the left.
--   Card 1, MODELS: the models iGame3D XT makes from their names (buildings, houses, 123 props, the
--   characters), group by group, with a wire preview. The default: nothing to install, nothing to find.
--   Card 2, FOLDER (tick "Use Folder"): any folder of .wtf or .obj models; its subfolders are listed to
--   explore, the models in the one picked beside them.
--   Assign puts the model on the mesh. Save writes Skins/<Game>/<skin>.skin.txt (mesh TAB model file TAB
--   where it came from) and each model as a .wtf file in Skins/<Game>/models/, so the skin carries its own
--   models and the Game Player (GL.LoadSkin) and the engine play it as they always have, each model scaled
--   to its placeholder. "Play with this skin" writes Skins/<Game>/ACTIVE.txt. The game's script is never
--   changed.
-- Uses me, never this stack (a stack script's "this stack" is the default stack, which may be another).

local sRoot, sMeshes, sAssign, sCurMesh, sCurModel, sGroupNames, sFolder, sFolders, sFiles, sTestPrefs
local sMakeIn     -- the group new controls go into (the shared one), or empty

on closeStackRequest
   set the destroyStack of me to true
   pass closeStackRequest
end closeStackRequest

command Skins.Build pRoot
   put pRoot into sRoot
   set the defaultStack to the short name of me
   lock screen
   lock messages
   set the title of me to "Replace With Model (iGame3D XT skins)"
   set the width of me to 900
   set the height of me to 560
   set the resizable of me to false
   set the backgroundColor of me to "30,30,34"
   set the foregroundColor of me to "220,220,224"
   set the name of card 1 of me to "Models"
   -- what both cards share: the game, its meshes, the preview, the skin (one group on both cards)
   create group "Shared"
   put "Shared" into sMakeIn
   Skins.Make "label", "GameLabel", "8,8,60,30", "Game"
   Skins.Make "field", "Game", "64,8,260,30", "FuelLine"
   set the script of field "Game" to "on returnInField" & return & "   Skins.LoadGame" & return & "end returnInField" & return & \
         "on enterInField" & return & "   Skins.LoadGame" & return & "end enterInField"
   Skins.Make "button", "LoadGame", "264,8,330,30", "Load"
   set the script of button "LoadGame" to "on mouseUp" & return & "   Skins.LoadGame" & return & "end mouseUp"
   Skins.Make "label", "MeshTitle", "8,38,330,58", "Placeholder meshes (what the game defines)"
   Skins.Make "list", "Meshes", "8,60,330,430", empty
   set the tabStops of field "Meshes" to 130
   set the script of field "Meshes" to "on mouseUp" & return & "   Skins.PickMesh the hilitedLine of me" & return & "end mouseUp"
   Skins.Make "button", "Assign", "8,436,166,460", "Assign the model"
   set the script of button "Assign" to "on mouseUp" & return & "   Skins.Assign" & return & "end mouseUp"
   Skins.Make "button", "Unassign", "172,436,330,460", "Back to placeholder"
   set the script of button "Unassign" to "on mouseUp" & return & "   Skins.Unassign" & return & "end mouseUp"
   create graphic "PreviewBack" in group "Shared"
   set the style of graphic "PreviewBack" to "rectangle"
   set the filled of graphic "PreviewBack" to true
   set the backgroundColor of graphic "PreviewBack" to "16,16,20"
   set the foregroundColor of graphic "PreviewBack" to "70,70,80"
   set the rect of graphic "PreviewBack" to 650, 38, 892, 280
   create graphic "Preview" in group "Shared"
   set the style of graphic "Preview" to "line"
   set the foregroundColor of graphic "Preview" to "64,224,255"
   Skins.Make "label", "ModelInfo", "650,284,892,304", empty
   Skins.Make "label", "SkinLabel", "650,316,720,338", "Skin name"
   Skins.Make "field", "SkinName", "724,316,892,338", "alt1"
   Skins.Make "button", "SaveSkin", "650,344,770,368", "Save skin"
   set the script of button "SaveSkin" to "on mouseUp" & return & "   Skins.Save" & return & "end mouseUp"
   Skins.Make "button", "OpenSkin", "774,344,892,368", "Open skin"
   set the script of button "OpenSkin" to "on mouseUp" & return & "   Skins.Open" & return & "end mouseUp"
   Skins.Make "button", "UseSkin", "650,374,892,398", "Play with this skin"
   set the script of button "UseSkin" to "on mouseUp" & return & "   Skins.SetActive true" & return & "end mouseUp"
   Skins.Make "button", "UsePlace", "650,404,892,428", "Play with placeholders"
   set the script of button "UsePlace" to "on mouseUp" & return & "   Skins.SetActive false" & return & "end mouseUp"
   Skins.Make "note", "Help", "8,468,892,516", "Pick a mesh on the left and a model in the middle, then Assign. Models are made from their names; tick Use Folder for a folder of your own .wtf / .obj models. Save the skin, then 'Play with this skin': the Game Player uses the models in place of those meshes, each scaled to the placeholder's size. The game's script is not changed."
   Skins.Make "label", "Status", "8,528,892,550", empty
   put empty into sMakeIn
   set the backgroundBehavior of group "Shared" of me to true
   -- card 1: the models made from their names
   Skins.Make "check", "UseFolder", "340,8,640,30", "Use Folder (your own .wtf / .obj models)"
   set the script of button "UseFolder" to "on mouseUp" & return & "   Skins.UseFolder the hilite of me" & return & "end mouseUp"
   Skins.Make "label", "GroupTitle", "340,38,470,58", "Made from names"
   Skins.Make "list", "Groups", "340,60,470,460", Skins.GroupList()
   set the script of field "Groups" to "on mouseUp" & return & "   Skins.PickGroup the hilitedLine of me" & return & "end mouseUp"
   Skins.Make "list", "Names", "476,60,640,460", empty
   set the script of field "Names" to "on mouseUp" & return & "   Skins.PickName the hilitedLine of me" & return & "end mouseUp"
   -- card 2: a folder of your own
   create card "Folder"
   Skins.Make "check", "UseFolder", "340,8,640,30", "Use Folder (your own .wtf / .obj models)"
   set the hilite of button "UseFolder" of card "Folder" of me to true
   set the script of button "UseFolder" of card "Folder" of me to "on mouseUp" & return & "   Skins.UseFolder the hilite of me" & return & "end mouseUp"
   Skins.Make "button", "ChooseFolder", "340,34,460,56", "Choose folder..."
   set the script of button "ChooseFolder" of card "Folder" of me to "on mouseUp" & return & "   Skins.ChooseFolder" & return & "end mouseUp"
   Skins.Make "label", "FolderPath", "464,34,640,56", empty
   Skins.Make "list", "Folders", "340,60,490,460", empty
   set the script of field "Folders" of card "Folder" of me to "on mouseUp" & return & "   Skins.PickFolder the hilitedLine of me" & return & "end mouseUp"
   Skins.Make "list", "Files", "496,60,640,460", empty
   set the script of field "Files" of card "Folder" of me to "on mouseUp" & return & "   Skins.PickFile the hilitedLine of me" & return & "end mouseUp"
   go card "Models" of stack (the short name of me)
   unlock messages
   set the loc of me to the screenLoc
   set the visible of me to true
   unlock screen
   put Skins.SavedFolder() into sFolder
   Skins.LoadGame
end Skins.Build

command Skins.Make pKind, pName, pRect, pText
   local tObj
   if pKind is "button" or pKind is "check" then
      if sMakeIn is empty then
         create button pName
      else
         create button pName in group sMakeIn
      end if
      put it into tObj
      set the label of tObj to pText
      if pKind is "check" then
         set the style of tObj to "checkbox"
         set the opaque of tObj to false
      else
         set the backgroundColor of tObj to "42,42,48"
      end if
   else
      if sMakeIn is empty then
         create field pName
      else
         create field pName in group sMakeIn
      end if
      put it into tObj
      -- a shared field shows the same text on both cards
      if sMakeIn is not empty then set the sharedText of tObj to true
      if pKind is among the items of "label,note" then
         set the lockText of tObj to true
         set the traversalOn of tObj to false
         set the showBorder of tObj to false
         set the opaque of tObj to false
         set the dontWrap of tObj to (pKind is "label")
      else
         set the backgroundColor of tObj to "42,42,48"
         if pKind is "list" then
            set the listBehavior of tObj to true
            set the lockText of tObj to true
            set the dontWrap of tObj to true
            set the vScrollbar of tObj to true
         end if
      end if
      set the text of tObj to pText
   end if
   set the rect of tObj to pRect
   set the foregroundColor of tObj to "220,220,224"
   set the borderColor of tObj to "70,70,80"
   set the hiliteColor of tObj to "60,100,160"
end Skins.Make

command Skins.Status pText
   put pText into field "Status" of me
end Skins.Status

-------------------------------------------------------------------- the two cards

command Skins.UseFolder pOn
   if pOn then
      go card "Folder" of stack (the short name of me)
      set the hilite of button "UseFolder" of card "Folder" of me to true
      if sFolder is not empty and field "Folders" of card "Folder" of me is empty then Skins.SetFolder sFolder
      if sFolder is empty then
         Skins.Status "Choose a folder of .wtf or .obj models (its subfolders are listed to explore)"
      end if
   else
      go card "Models" of stack (the short name of me)
      set the hilite of button "UseFolder" of card "Models" of me to false
   end if
end Skins.UseFolder

function Skins.Card
   return the short name of this card of me
end Skins.Card

-------------------------------------------------------------------- the game and its meshes

function Skins.Game
   return word 1 to -1 of field "Game" of me
end Skins.Game

function Skins.GameFile pGame
   return sRoot & "/LIB_GAMES/Vibecode3D_Games/Vibecode3D_Play_" & pGame & ".livecodescript"
end Skins.GameFile

function Skins.Dir pGame
   return sRoot & "/LIB_GAMES/Vibecode3D_Games/Skins/" & pGame
end Skins.Dir

-- the names the game gives Mesh.Define as plain quoted text (names built at run time are not found)
function Skins.MeshNames pScript
   local tLine, tOut, tStart, tName
   repeat for each line tLine in pScript
      put offset("Mesh.Define " & quote, tLine) into tStart
      if tStart is 0 then next repeat
      if char 1 to 2 of word 1 to -1 of tLine is "--" then next repeat
      put char tStart + 13 to -1 of tLine into tName
      put char 1 to offset(quote, tName) - 1 of tName into tName
      if tName is not empty and not (tName is among the lines of tOut) then put tName & return after tOut
   end repeat
   return tOut
end Skins.MeshNames

command Skins.LoadGame
   local tFile, tActive
   put Skins.GameFile(Skins.Game()) into tFile
   if there is not a file tFile then
      Skins.Status "No game script:" && tFile
      exit Skins.LoadGame
   end if
   put Skins.MeshNames(textDecode(url ("binfile:" & tFile), "UTF-8")) into sMeshes
   put empty into sAssign
   put empty into sCurMesh
   put url ("file:" & Skins.Dir(Skins.Game()) & "/ACTIVE.txt") into tActive
   put word 1 to -1 of line 1 of tActive into tActive
   if tActive is not empty then
      put tActive into field "SkinName" of me
      Skins.Open
   end if
   Skins.ShowMeshes
   if tActive is empty then
      Skins.Status Skins.Game() & ":" && the number of lines of sMeshes && "placeholder meshes; playing with placeholders"
   else
      Skins.Status Skins.Game() & ":" && the number of lines of sMeshes && "placeholder meshes; playing with skin" && tActive
   end if
end Skins.LoadGame

command Skins.ShowMeshes
   local tName, tOut
   repeat for each line tName in sMeshes
      put tName & tab & Skins.Short(sAssign[tName]) & return after tOut
   end repeat
   delete the last char of tOut
   put tOut into field "Meshes" of me
end Skins.ShowMeshes

-- a model as shown: "car" for gen:Vehicles/car, "plane.obj" for a file
function Skins.Short pModel
   if pModel is empty then return "(placeholder)"
   set the itemDelimiter to "/"
   return item -1 of pModel
end Skins.Short

command Skins.PickMesh pN
   if pN is empty then exit Skins.PickMesh
   put line pN of sMeshes into sCurMesh
   if sAssign[sCurMesh] is not empty then Skins.Preview sAssign[sCurMesh]
   Skins.Status sCurMesh & ":" && Skins.Short(sAssign[sCurMesh])
end Skins.PickMesh

-------------------------------------------------------------------- card 1: made from their names

function Skins.GroupList
   local tOut, tG
   put "Buildings" & return & "Houses" & return into tOut
   if "v3d_props" is among the lines of the stacksInUse then
      repeat for each item tG in Prop.Groups()
         put tG & return after tOut
      end repeat
   end if
   put "Characters" after tOut
   return tOut
end Skins.GroupList

command Skins.PickGroup pN
   local tG, tNames
   if pN is empty then exit Skins.PickGroup
   put line pN of field "Groups" of me into tG
   switch tG
      case "Buildings"
      case "Houses"
         if "v3d_buildings" is among the lines of the stacksInUse then put Bld.Names(tG) into tNames
         break
      case "Characters"
         if "v3d_figures" is among the lines of the stacksInUse then put Fig.Roles() into tNames
         break
      default
         if "v3d_props" is among the lines of the stacksInUse then put Prop.Names(tG) into tNames
   end switch
   replace comma with return in tNames
   put tG into sGroupNames["group"]
   put tNames into field "Names" of me
   Skins.Status tG & ":" && the number of lines of tNames && "models, made from their names"
end Skins.PickGroup

command Skins.PickName pN
   if pN is empty then exit Skins.PickName
   put "gen:" & sGroupNames["group"] & "/" & line pN of field "Names" of me into sCurModel
   Skins.Preview sCurModel
end Skins.PickName

-- the mesh of a model: gen:<group>/<name> is made; anything else is a .wtf or .obj file
function Skins.ModelMesh pModel
   local tG, tN, tB
   if pModel begins with "gen:" then
      set the itemDelimiter to "/"
      put char 5 to -1 of item 1 of pModel into tG
      put item 2 of pModel into tN
      switch tG
         case "Buildings"
         case "Houses"
            put Bld.Make(tN) into tB
            return tB["mesh"]
         case "Characters"
            return Fig.Make(tN)
         default
            return Prop.Make(tN)
      end switch
   end if
   if pModel ends with ".obj" then return Skins.ReadOBJ(pModel)
   return Skins.ReadWTF(pModel)
end Skins.ModelMesh

-------------------------------------------------------------------- card 2: a folder of your own

function Skins.SavedFolder
   local tF
   if sTestPrefs is true then return empty
   put specialFolderPath("support") & "/Vibecode3D/igame3d_xt_skins_folder.txt" into tF
   if there is not a file tF then return empty
   return line 1 of textDecode(url ("binfile:" & tF), "UTF-8")
end Skins.SavedFolder

command Skins.ChooseFolder
   answer folder "A folder of .wtf or .obj models (its subfolders are listed too):"
   if it is empty then exit Skins.ChooseFolder
   Skins.SetFolder it
end Skins.ChooseFolder

-- explore pFolder: its subfolders (indented by depth, four deep) on the left; remembered
command Skins.SetFolder pFolder
   local tDir
   replace "\" with "/" in pFolder
   if char -1 of pFolder is "/" then delete char -1 of pFolder
   if there is not a folder pFolder then
      Skins.Status "No such folder:" && pFolder
      exit Skins.SetFolder
   end if
   put pFolder into sFolder
   if sTestPrefs is not true then
      put specialFolderPath("support") & "/Vibecode3D" into tDir
      if there is not a folder tDir then create folder tDir
      put textEncode(pFolder, "UTF-8") into url ("binfile:" & tDir & "/igame3d_xt_skins_folder.txt")
   end if
   put empty into sFolders
   Skins.Walk pFolder, ".", 0
   put pFolder into field "FolderPath" of card "Folder" of me
   put Skins.FolderLines() into field "Folders" of card "Folder" of me
   put empty into field "Files" of card "Folder" of me
   Skins.PickFolder 1
end Skins.SetFolder

-- every subfolder as a line "relative path"; at most 400 and four deep
command Skins.Walk pRoot, pRel, pDepth
   local tSub, tPath
   if the number of lines of sFolders >= 400 then exit Skins.Walk
   put pRel & return after sFolders
   if pDepth >= 4 then exit Skins.Walk
   if pRel is "." then
      put pRoot into tPath
   else
      put pRoot & "/" & pRel into tPath
   end if
   repeat for each line tSub in folders(tPath)
      if tSub is "." or tSub is ".." or char 1 of tSub is "." then next repeat
      if pRel is "." then
         Skins.Walk pRoot, tSub, pDepth + 1
      else
         Skins.Walk pRoot, pRel & "/" & tSub, pDepth + 1
      end if
   end repeat
end Skins.Walk

-- the folder list as shown: the folder's own name, indented by its depth
function Skins.FolderLines
   local tLine, tOut, tDepth
   repeat for each line tLine in sFolders
      if tLine is empty then next repeat
      if tLine is "." then
         put "(this folder)" & return after tOut
         next repeat
      end if
      set the itemDelimiter to "/"
      put the number of items of tLine into tDepth
      put char 1 to tDepth * 2 of "                " & item -1 of tLine & return after tOut
   end repeat
   delete the last char of tOut
   return tOut
end Skins.FolderLines

command Skins.PickFolder pN
   local tRel, tPath, tF, tOut
   if pN is empty then exit Skins.PickFolder
   put line pN of sFolders into tRel
   if tRel is "." then
      put sFolder into tPath
   else
      put sFolder & "/" & tRel into tPath
   end if
   repeat for each line tF in files(tPath)
      if tF ends with ".wtf" or tF ends with ".obj" then put tF & return after tOut
   end repeat
   delete the last char of tOut
   put tPath into sFiles["dir"]
   put tOut into field "Files" of card "Folder" of me
   Skins.Status tRel & ":" && the number of lines of tOut && "models (.wtf, .obj)"
end Skins.PickFolder

command Skins.PickFile pN
   if pN is empty then exit Skins.PickFile
   put sFiles["dir"] & "/" & line pN of field "Files" of card "Folder" of me into sCurModel
   Skins.Preview sCurModel
end Skins.PickFile

-------------------------------------------------------------------- the preview

command Skins.Preview pModel
   local tM, tLines
   put Skins.ModelMesh(pModel) into tM
   put the number of lines of tM["lines"] into tLines
   set the points of graphic "Preview" of me to Skins.MeshPoints(tM, 652, 40, 238)
   put Skins.Short(pModel) & ":" && tM["count"] && "vertices," && tLines && "lines" into field "ModelInfo" of me
end Skins.Preview

-- a mesh as line-graphic points inside a square: turned 35 degrees, tipped 20, fitted
function Skins.MeshPoints pM, pLeft, pTop, pSize
   local i, tX, tY, tZ, tSX, tSY, minX, maxX, minY, maxY, k, tOut, tL, a, b, cy, sy, cp, sp
   if pM["count"] < 1 then return empty
   put cos(0.61) into cy
   put sin(0.61) into sy
   put cos(0.35) into cp
   put sin(0.35) into sp
   put 1e9 into minX
   put -1e9 into maxX
   put 1e9 into minY
   put -1e9 into maxY
   repeat with i = 1 to pM["count"]
      put pM["vx"][i] * cy - pM["vz"][i] * sy into tX
      put pM["vx"][i] * sy + pM["vz"][i] * cy into tZ
      put pM["vy"][i] * cp + tZ * sp into tY
      put tX into tSX[i]
      put tY into tSY[i]
      put min(minX, tX) into minX
      put max(maxX, tX) into maxX
      put min(minY, tY) into minY
      put max(maxY, tY) into maxY
   end repeat
   put (pSize - 16) / max(0.001, max(maxX - minX, maxY - minY)) into k
   repeat for each line tL in pM["lines"]
      put word 1 of tL into a
      put word 2 of tL into b
      if tSX[a] is empty or tSX[b] is empty then next repeat
      put round(pLeft + 8 + (tSX[a] - minX) * k) & comma & round(pTop + 8 + (tSY[a] - minY) * k) & return after tOut
      put round(pLeft + 8 + (tSX[b] - minX) * k) & comma & round(pTop + 8 + (tSY[b] - minY) * k) & return & return after tOut
   end repeat
   return tOut
end Skins.MeshPoints

-------------------------------------------------------------------- reading and writing model files

-- an iGame3D .wtf: "#Vertices:", its count, x,y,z,bone lines (y up); "#Edges:", its count, a,b (from 0)
function Skins.ReadWTF pPath
   local tText, n, tCount, i, tLine, tM
   put Skins.NewMesh() into tM
   if there is not a file pPath then return tM
   put url ("file:" & pPath) into tText
   replace numToChar(13) with empty in tText
   put lineOffset("#Vertices:", tText) into n
   if n is 0 then return tM
   put line n + 1 of tText into tCount
   if tCount is not an integer then return tM
   repeat with i = 1 to tCount
      put line n + 1 + i of tText into tLine
      add 1 to tM["count"]
      put item 1 of tLine + 0 into tM["vx"][i]
      put -(item 2 of tLine + 0) into tM["vy"][i]
      put item 3 of tLine + 0 into tM["vz"][i]
   end repeat
   put lineOffset("#Edges:", tText) into n
   if n > 0 then
      put line n + 1 of tText into tCount
      if tCount is an integer then
         repeat with i = 1 to tCount
            put line n + 1 + i of tText into tLine
            put (item 1 of tLine + 1) && (item 2 of tLine + 1) & return after tM["lines"]
         end repeat
      end if
   end if
   delete the last char of tM["lines"]
   return tM
end Skins.ReadWTF

-- an .obj: v x y z (y up); every face's sides and every l line become lines
function Skins.ReadOBJ pPath
   local tText, tLine, tM, tIdx, k, a, b, tSeen, tKey, tWord
   put Skins.NewMesh() into tM
   if there is not a file pPath then return tM
   put url ("file:" & pPath) into tText
   replace numToChar(13) with empty in tText
   repeat for each line tLine in tText
      if word 1 of tLine is "v" then
         add 1 to tM["count"]
         put word 2 of tLine + 0 into tM["vx"][tM["count"]]
         put -(word 3 of tLine + 0) into tM["vy"][tM["count"]]
         put word 4 of tLine + 0 into tM["vz"][tM["count"]]
      end if
   end repeat
   repeat for each line tLine in tText
      if word 1 of tLine is not "f" and word 1 of tLine is not "l" then next repeat
      put empty into tIdx
      repeat with k = 2 to the number of words of tLine
         put word k of tLine into tWord
         set the itemDelimiter to "/"
         put item 1 of tWord into tIdx[k - 1]
         set the itemDelimiter to comma
         if tIdx[k - 1] < 0 then put tM["count"] + 1 + tIdx[k - 1] into tIdx[k - 1]
      end repeat
      repeat with k = 1 to the number of words of tLine - 1
         put tIdx[k] into a
         if k < the number of words of tLine - 1 then
            put tIdx[k + 1] into b
         else if word 1 of tLine is "f" then
            put tIdx[1] into b
         else
            next repeat
         end if
         if a is b or a is empty or b is empty then next repeat
         put min(a, b) & "," & max(a, b) into tKey
         if tSeen[tKey] is true then next repeat
         put true into tSeen[tKey]
         put a && b & return after tM["lines"]
      end repeat
   end repeat
   delete the last char of tM["lines"]
   return tM
end Skins.ReadOBJ

-- a mesh as an iGame3D .wtf file (y up), the form the engine's skins load
command Skins.WriteWTF pM, pPath
   local tOut, i, tL
   put "iGame3D Mdl" & return & "0" & return & "#Author: iGame3D XT" & return & "#Date: " & the date & return & \
         "#Notes: made by Replace With Model" & return & "#PNG: 0" & return & return & "#Bones:" & return & "0" & return & \
         "#Vertices:" & return & pM["count"] & return into tOut
   repeat with i = 1 to pM["count"]
      put pM["vx"][i] & "," & -pM["vy"][i] & "," & pM["vz"][i] & ",0" & return after tOut
   end repeat
   put "#Paths:" & return & "0" & return & "#Groups:" & return & "0" & return & "#BoneOrientations:" & return & "0" & return after tOut
   put "#Edges:" & return & the number of lines of pM["lines"] & return after tOut
   repeat for each line tL in pM["lines"]
      put word 1 of tL - 1 & "," & word 2 of tL - 1 & return after tOut
   end repeat
   put tOut into url ("file:" & pPath)
end Skins.WriteWTF

function Skins.NewMesh
   local tM
   put 0 into tM["count"]
   put empty into tM["faces"]
   put empty into tM["lines"]
   return tM
end Skins.NewMesh

-------------------------------------------------------------------- assign, save, open, play

command Skins.Assign
   if sCurMesh is empty or sCurModel is empty then
      Skins.Status "Pick a mesh on the left and a model in the middle first"
      exit Skins.Assign
   end if
   put sCurModel into sAssign[sCurMesh]
   Skins.ShowMeshes
   Skins.Status sCurMesh && "->" && Skins.Short(sCurModel) && "(not saved yet)"
end Skins.Assign

command Skins.Unassign
   if sCurMesh is empty then exit Skins.Unassign
   delete variable sAssign[sCurMesh]
   Skins.ShowMeshes
   Skins.Status sCurMesh && "back to its placeholder (not saved yet)"
end Skins.Unassign

function Skins.SkinFile
   local tName
   put word 1 to -1 of field "SkinName" of me into tName
   replace "/" with "_" in tName
   replace space with "_" in tName
   if tName is empty then return empty
   return Skins.Dir(Skins.Game()) & "/" & tName & ".skin.txt"
end Skins.SkinFile

-- the skin, and each of its models as a .wtf in Skins/<Game>/models (relative to the projects folder)
command Skins.Save
   local tFile, tOut, tName, tParent, tModel, tWTF, tRel
   put Skins.SkinFile() into tFile
   if tFile is empty then
      Skins.Status "Give the skin a name first"
      exit Skins.Save
   end if
   put sRoot & "/LIB_GAMES/Vibecode3D_Games/Skins" into tParent
   if there is not a folder tParent then create folder tParent
   if there is not a folder Skins.Dir(Skins.Game()) then create folder Skins.Dir(Skins.Game())
   if there is not a folder (Skins.Dir(Skins.Game()) & "/models") then create folder (Skins.Dir(Skins.Game()) & "/models")
   put "# Skin for" && Skins.Game() & ": mesh TAB model file (relative to projects) TAB where it came from. Made by Replace With Model." & return into tOut
   repeat for each line tName in sMeshes
      put sAssign[tName] into tModel
      if tModel is empty then next repeat
      put Skins.FileName(tModel) into tWTF
      Skins.WriteWTF Skins.ModelMesh(tModel), Skins.Dir(Skins.Game()) & "/models/" & tWTF
      put "LIB_GAMES/Vibecode3D_Games/Skins/" & Skins.Game() & "/models/" & tWTF into tRel
      put tName & tab & tRel & tab & tModel & return after tOut
   end repeat
   put textEncode(tOut, "UTF-8") into url ("binfile:" & tFile)
   Skins.Status "Saved" && tFile
end Skins.Save

-- the .wtf name a model is saved under: Vehicles_car.wtf, plane.wtf
function Skins.FileName pModel
   local tN
   if pModel begins with "gen:" then
      put char 5 to -1 of pModel into tN
      replace "/" with "_" in tN
      replace space with "_" in tN
      return tN & ".wtf"
   end if
   set the itemDelimiter to "/"
   put item -1 of pModel into tN
   set the itemDelimiter to "."
   return item 1 to -2 of tN & ".wtf"
end Skins.FileName

command Skins.Open
   local tFile, tLine
   put Skins.SkinFile() into tFile
   if tFile is empty or there is not a file tFile then
      Skins.Status "No skin file:" && tFile
      exit Skins.Open
   end if
   put empty into sAssign
   set the itemDelimiter to tab
   repeat for each line tLine in textDecode(url ("binfile:" & tFile), "UTF-8")
      if tLine is empty or char 1 of tLine is "#" then next repeat
      -- where it came from (gen:..., a file) when the skin says; else the saved model file
      if item 3 of tLine is not empty then
         put item 3 of tLine into sAssign[item 1 of tLine]
      else
         put sRoot & "/" & item 2 of tLine into sAssign[item 1 of tLine]
      end if
   end repeat
   Skins.ShowMeshes
   Skins.Status "Opened" && tFile
end Skins.Open

-- which skin the Game Player uses for this game: this one (saved first) or none
command Skins.SetActive pUse
   local tDir
   put Skins.Dir(Skins.Game()) into tDir
   if pUse then
      Skins.Save
      if Skins.SkinFile() is empty then exit Skins.SetActive
      set the itemDelimiter to "/"
      put char 1 to -10 of item -1 of Skins.SkinFile() into url ("file:" & tDir & "/ACTIVE.txt")
      Skins.Status Skins.Game() && "now plays with the skin" && char 1 to -10 of item -1 of Skins.SkinFile()
   else
      if there is a folder tDir then put empty into url ("file:" & tDir & "/ACTIVE.txt")
      Skins.Status Skins.Game() && "now plays with its placeholders"
   end if
end Skins.SetActive

-- test hooks: no remembered folder; pick a mesh / a model by name
command Skins.TestPrefs pFlag
   put pFlag into sTestPrefs
end Skins.TestPrefs

command Skins.TestPick pMesh, pModel
   put pMesh into sCurMesh
   put pModel into sCurModel
end Skins.TestPick

-- tests: one line
function Skins.State
   local tN, tK
   put 0 into tN
   repeat for each key tK in sAssign
      add 1 to tN
   end repeat
   return Skins.Game() & "|" & the number of lines of sMeshes & "|" & tN & "|" & Skins.Card() & "|" & sCurMesh & "|" & sCurModel & "|" & sFolder
end Skins.State
