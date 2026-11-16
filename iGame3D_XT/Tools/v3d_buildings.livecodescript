script "v3d_buildings"
######################################################################################
## BUILDINGS  (iGame3D XT, workstream A, 16 Nov 2026)
## Wire buildings made from a NAME: the name says the kind and the look ("bunker242" is military,
## "smallchurch" a home with a steeple, "warehouse_3" a warehouse), the name's hash picks the
## sizes, so the same name always makes the same building. Nothing is read from disk and no engine
## call is made: meshes come back in the engine's own array form (count, vx/vy/vz, lines), for the
## caller to Mesh.Define. Games use it too:  start using stack ".../Tools/v3d_buildings.livecodescript"
##
## The owner's rules (16 Nov), in metres from each storey's floor (a person is 1.8 m):
##   warehouse  big windows above head height (2.6 to 4.4)    a roller door and a person door
##   shop       windows from the knee to above the head (0.5 to 2.4) on the ground floor
##   home       windows from the hip to above the head (0.9 to 2.1), some smaller (1.4 to 2.0)
##   military   windows well above head height, no peeking (2.4 to 2.9)
## Every building has uDead's breakable doors and windows: separate parts with hit points
## (window 10, door 60, heavy door 120, roller door 150) on the two lowest storeys.
##
##   Bld.Make(name)        -> array: ["mesh"] the shell, ["parts"] one line per breakable part
##                            "kind|x|y|z|width|height|axis|hp|storey" (x,z from the footprint's
##                            centre, y = the part's foot, negative is up; axis x or z: the wall
##                            it sits in), ["kind"], ["roof"], ["w"], ["d"], ["h"], ["storeys"]
##   Bld.PartMesh(kind, w, h, axis)  a door or window: frame and diagonal (a window: a cross)
##   Bld.PartName(kind, w, h, axis)  a name to Mesh.Define it under (one per size)
##   Bld.Kind(name)  Bld.Roof(name)  Bld.Names(group)  Bld.Rule(kind)  kM: units a metre
######################################################################################

constant kM = 10          -- engine units a metre (the editor's floor square, 50 units, is 5 m)
constant kBuildings = "bfbuilding3,bpbuilding1,bpbuilding2,bunker242,castle240,chapel01,church1357,columnedbuilding1K,empirestatelike,gym2,headless1849,middletower,middletower562,skyscraperA,smallchurch,temple107,toolshedgeneral,tower236,tower316"
constant kHouses = "beachouse,bungalow3k,domicile,estate21K,fwHouse12,fwHouse33,hanshaus1k,hanshouse2k,HauntHouse1062,HausBurk10K,HausBurk2k,house02,house02b,house32poly,house5K,house700,house963x3x3,house96long,houseLR,hovel,lowpolyneighborhood,m12shack,m13shack,m15shack,potionshop,RuinedHouse584,sdhouse,shack99,tenamenthouse,townhouse,villahouse,weaponshop"

local sSeed

-- the names to build from: "Buildings" and "Houses" (the 2008 groups, inventoried 16 Nov)
function Bld.Names pGroup
   if pGroup is "Houses" then return kHouses
   return kBuildings
end Bld.Names

function Bld.UnitsPerMetre
   return kM
end Bld.UnitsPerMetre

-- warehouse, shop, home or military, from the words in the name (else from its hash)
function Bld.Kind pName
   local tN
   put toLower(pName) into tN
   -- first the words that hide inside others ("smallchurch" holds "mall")
   if Bld.Has(tN, "church,chapel,temple") then return "home"
   if Bld.Has(tN, "bunker,castle,fort,military,barrack,police,tower,armory,armoury") then return "military"
   if Bld.Has(tN, "warehouse,shed,gym,factory,barn,hangar,garage,depot,mill") then return "warehouse"
   if Bld.Has(tN, "shop,store,mart,cafe,diner,bank,office,skyscraper,empire,columned,mall,hotel") then return "shop"
   if Bld.Has(tN, "house,haus,home,cottage,hut,cabin,villa,bungalow,shack,hovel,estate,domicile,church,chapel,temple,tenament,tenement") then return "home"
   return item (Bld.Hash(tN) mod 4) + 1 of "warehouse,shop,home,military"
end Bld.Kind

-- the roof: flat, gable, steeple (a church), crenel (a castle), or tall (many storeys, flat)
function Bld.Roof pName
   local tN
   put toLower(pName) into tN
   if Bld.Has(tN, "church,chapel,temple") then return "steeple"
   if Bld.Has(tN, "castle,fort") then return "crenel"
   if Bld.Has(tN, "skyscraper,empire,middletower,tenament,tenement") then return "tall"
   if Bld.Has(tN, "bunker,warehouse,gym,factory,hangar,depot,police") then return "flat"
   if Bld.Kind(pName) is "home" then return "gable"
   if Bld.Kind(pName) is "military" then return "flat"
   if Bld.Hash(tN) mod 3 is 0 then return "gable"
   return "flat"
end Bld.Roof

function Bld.Has pText, pWords
   local tW
   repeat for each item tW in pWords
      if pText contains tW then return true
   end repeat
   return false
end Bld.Has

function Bld.Hash pText
   local tH, i
   put 7 into tH
   repeat with i = 1 to the number of chars of pText
      put (tH * 31 + charToNum(char i of pText)) mod 1000003 into tH
   end repeat
   return tH
end Bld.Hash

-- 0 <= r < 1 from the running seed (Park-Miller)
function Bld.Rand
   put (sSeed * 16807) mod 2147483647 into sSeed
   return sSeed / 2147483647
end Bld.Rand

function Bld.Between pLo, pHi
   return pLo + (pHi - pLo) * Bld.Rand()
end Bld.Between

-- a kind's windows on its ground floor: sill, top, width, gap (metres); and its storey height
function Bld.Rule pKind
   switch pKind
      case "warehouse"
         return "2.6,4.4,3,2.2,7"
      case "shop"
         return "0.5,2.4,2.4,0.6,3.6"
      case "military"
         return "2.4,2.9,1.4,2.6,3.6"
   end switch
   return "0.9,2.1,1.2,1.6,2.8"
end Bld.Rule

-------------------------------------------------------------------- the building

function Bld.Make pName
   local tB, tKind, tRoof, tW, tD, tN, tH, tStoreyH, tM, s, tFloorY, tRule, tUpper, tDoorX
   put Bld.Hash(toLower(pName)) + 1 into sSeed
   get Bld.Rand()
   put Bld.Kind(pName) into tKind
   put Bld.Roof(pName) into tRoof
   put Bld.Rule(tKind) into tRule
   put item 5 of tRule into tStoreyH
   switch tKind
      case "warehouse"
         put round(Bld.Between(18, 28)) into tW
         put round(Bld.Between(12, 18)) into tD
         put 1 into tN
         break
      case "shop"
         put round(Bld.Between(8, 14)) into tW
         put round(Bld.Between(8, 12)) into tD
         put 1 + trunc(Bld.Between(0, 3)) into tN
         break
      case "military"
         put round(Bld.Between(10, 18)) into tW
         put round(Bld.Between(8, 14)) into tD
         put 1 + trunc(Bld.Between(0, 2)) into tN
         break
      default
         put round(Bld.Between(7, 11)) into tW
         put round(Bld.Between(7, 10)) into tD
         put 1 + trunc(Bld.Between(0, 2)) into tN
   end switch
   if tRoof is "tall" then
      put round(Bld.Between(10, 16)) into tW
      put round(Bld.Between(10, 14)) into tD
      put 6 + trunc(Bld.Between(0, 14)) into tN
   end if
   if tRoof is "steeple" then put 1 into tN
   if tRoof is "crenel" then put 2 into tN
   -- the shell: corners, a ring at every floor, the roof
   put Bld.NewMesh() into tM
   put tStoreyH + (tN - 1) * Bld.UpperH(tKind) into tH
   repeat with s = 0 to tN
      put s * Bld.UpperH(tKind) into tFloorY
      if s > 0 then put tStoreyH + (s - 1) * Bld.UpperH(tKind) into tFloorY
      Bld.Rect tM, tW, tD, tFloorY
   end repeat
   Bld.Line tM, -tW / 2, 0, -tD / 2, -tW / 2, tH, -tD / 2
   Bld.Line tM, tW / 2, 0, -tD / 2, tW / 2, tH, -tD / 2
   Bld.Line tM, tW / 2, 0, tD / 2, tW / 2, tH, tD / 2
   Bld.Line tM, -tW / 2, 0, tD / 2, -tW / 2, tH, tD / 2
   Bld.RoofLines tM, tRoof, tW, tD, tH
   put empty into tB["parts"]
   -- doors on the front (the -z side), then the windows of every storey on all four walls
   put Bld.Doors(tB, tM, tKind, tW, tD) into tDoorX
   repeat with s = 1 to tN
      if s is 1 then
         put 0 into tFloorY
         put tRule into tUpper
      else
         put tStoreyH + (s - 2) * Bld.UpperH(tKind) into tFloorY
         put Bld.UpperRule(tKind, tRoof) into tUpper
      end if
      Bld.Windows tB, tM, tUpper, tW, tD, tFloorY, s, tDoorX, tKind
   end repeat
   delete variable tM["at"]          -- the vertex lookup is ours, not the engine's
   put tM into tB["mesh"]
   put tKind into tB["kind"]
   put tRoof into tB["roof"]
   put tW into tB["w"]
   put tD into tB["d"]
   put tH into tB["h"]
   put tN into tB["storeys"]
   return tB
end Bld.Make

-- an upper storey's height, and its windows (offices in tall buildings, homes elsewhere)
function Bld.UpperH pKind
   if pKind is "warehouse" then return 4.5
   return 3
end Bld.UpperH

function Bld.UpperRule pKind, pRoof
   if pKind is "military" then return Bld.Rule("military")
   if pKind is "warehouse" then return "2.6,4.0,3,2.2,4.5"
   if pRoof is "tall" then return "0.8,2.6,1.6,0.8,3"
   return Bld.Rule("home")
end Bld.UpperRule

-- the front door(s); returns "x1,x2" ranges kept clear of windows, one per line
function Bld.Doors @pB, @pM, pKind, pW, pD
   local tOut, tX
   switch pKind
      case "warehouse"
         put round(Bld.Between(-pW / 4, pW / 4)) into tX
         Bld.Part pB, pM, "roller", tX, 0, -pD / 2, 4, 4, "x", 150, 1
         put tX - 2.5 & comma & tX + 2.5 & cr after tOut
         Bld.Part pB, pM, "door", tX + 4, 0, -pD / 2, 1, 2.1, "x", 60, 1
         put tX + 3 & comma & tX + 5 & cr after tOut
         break
      case "military"
         Bld.Part pB, pM, "heavydoor", 0, 0, -pD / 2, 1.3, 2.3, "x", 120, 1
         put -1.4 & comma & 1.4 & cr after tOut
         break
      case "shop"
         Bld.Part pB, pM, "door", 0, 0, -pD / 2, 1.4, 2.3, "x", 60, 1
         put -1.3 & comma & 1.3 & cr after tOut
         break
      default
         put round(Bld.Between(-pW / 5, pW / 5) * 2) / 2 into tX
         Bld.Part pB, pM, "door", tX, 0, -pD / 2, 1, 2.1, "x", 60, 1
         put tX - 1 & comma & tX + 1 & cr after tOut
   end switch
   return tOut
end Bld.Doors

-- a storey's windows on all four walls, spaced along each; clear of the doors on the front
on Bld.Windows @pB, @pM, pRule, pW, pD, pFloorY, pStorey, pDoorX, pKind
   local tSill, tTop, tWide, tGap, tFace, tLen, n, k, tC, tX, tZ, tAxis, tClear, tR, tSmall, tS2, tT2, tW2
   put item 1 of pRule into tSill
   put item 2 of pRule into tTop
   put item 3 of pRule into tWide
   put item 4 of pRule into tGap
   repeat for each item tFace in "front,back,left,right"
      if tFace is "front" or tFace is "back" then
         put pW into tLen
         put "x" into tAxis
      else
         put pD into tLen
         put "z" into tAxis
      end if
      put trunc((tLen - tGap) / (tWide + tGap)) into n
      if n < 1 then next repeat
      repeat with k = 1 to n
         put -tLen / 2 + tGap + (k - 1) * (tWide + tGap) + tWide / 2 + (tLen - tGap - n * (tWide + tGap)) / 2 into tC
         if tFace is "front" and pStorey is 1 then
            put true into tClear
            repeat for each line tR in pDoorX
               if tC + tWide / 2 > item 1 of tR - 0.3 and tC - tWide / 2 < item 2 of tR + 0.3 then put false into tClear
            end repeat
            if not tClear then next repeat
         end if
         switch tFace
            case "front"
               put tC into tX
               put -pD / 2 into tZ
               break
            case "back"
               put tC into tX
               put pD / 2 into tZ
               break
            case "left"
               put -pW / 2 into tX
               put tC into tZ
               break
            case "right"
               put pW / 2 into tX
               put tC into tZ
               break
         end switch
         put tSill into tS2
         put tTop into tT2
         put tWide into tW2
         -- some home windows are smaller (a bathroom, a landing)
         if pKind is "home" and tFace is not "front" and Bld.Rand() < 0.25 then
            put 1.4 into tS2
            put 2.0 into tT2
            put 0.6 into tW2
         end if
         if pStorey <= 2 then
            Bld.Part pB, pM, "window", tX, pFloorY + tS2, tZ, tW2, tT2 - tS2, tAxis, 10, pStorey
         else
            Bld.Opening pM, tX, pFloorY + tS2, tZ, tW2, tT2 - tS2, tAxis, true
         end if
      end repeat
   end repeat
end Bld.Windows

-- a breakable part: its opening in the shell, and a line in pB["parts"]
on Bld.Part @pB, @pM, pKind, pX, pY, pZ, pW, pH, pAxis, pHP, pStorey
   Bld.Opening pM, pX, pY, pZ, pW, pH, pAxis, (pKind is "window")
   put pKind & "|" & pX & "|" & pY & "|" & pZ & "|" & pW & "|" & pH & "|" & pAxis & "|" & pHP & "|" & pStorey & cr after pB["parts"]
end Bld.Part

-- an opening's outline in the wall: four sides for a window, three (no sill) for a door
on Bld.Opening @pM, pX, pY, pZ, pW, pH, pAxis, pSill
   local tA, tB
   if pAxis is "x" then
      put pX - pW / 2 into tA
      put pX + pW / 2 into tB
      Bld.Line pM, tA, pY, pZ, tA, pY + pH, pZ
      Bld.Line pM, tB, pY, pZ, tB, pY + pH, pZ
      Bld.Line pM, tA, pY + pH, pZ, tB, pY + pH, pZ
      if pSill then
         Bld.Line pM, tA, pY, pZ, tB, pY, pZ
      end if
   else
      put pZ - pW / 2 into tA
      put pZ + pW / 2 into tB
      Bld.Line pM, pX, pY, tA, pX, pY + pH, tA
      Bld.Line pM, pX, pY, tB, pX, pY + pH, tB
      Bld.Line pM, pX, pY + pH, tA, pX, pY + pH, tB
      if pSill then Bld.Line pM, pX, pY, tA, pX, pY, tB
   end if
end Bld.Opening

on Bld.RoofLines @pM, pRoof, pW, pD, pH
   local tRise, x, tS
   switch pRoof
      case "gable"
         put min(pW, pD) * 0.35 into tRise
         Bld.Line pM, -pW / 2, pH + tRise, 0, pW / 2, pH + tRise, 0
         Bld.Line pM, -pW / 2, pH, -pD / 2, -pW / 2, pH + tRise, 0
         Bld.Line pM, -pW / 2, pH, pD / 2, -pW / 2, pH + tRise, 0
         Bld.Line pM, pW / 2, pH, -pD / 2, pW / 2, pH + tRise, 0
         Bld.Line pM, pW / 2, pH, pD / 2, pW / 2, pH + tRise, 0
         break
      case "steeple"
         -- a gable, and a square tower at the front with a spire
         put min(pW, pD) * 0.4 into tRise
         Bld.Line pM, -pW / 2, pH + tRise, 0, pW / 2, pH + tRise, 0
         Bld.Line pM, -pW / 2, pH, -pD / 2, -pW / 2, pH + tRise, 0
         Bld.Line pM, -pW / 2, pH, pD / 2, -pW / 2, pH + tRise, 0
         Bld.Line pM, pW / 2, pH, -pD / 2, pW / 2, pH + tRise, 0
         Bld.Line pM, pW / 2, pH, pD / 2, pW / 2, pH + tRise, 0
         put 1.5 into tS
         Bld.Box pM, -tS, pH, -pD / 2 - 0.01, tS, pH + 6, -pD / 2 + 2 * tS
         Bld.Line pM, -tS, pH + 6, -pD / 2, 0, pH + 13, -pD / 2 + tS
         Bld.Line pM, tS, pH + 6, -pD / 2, 0, pH + 13, -pD / 2 + tS
         Bld.Line pM, -tS, pH + 6, -pD / 2 + 2 * tS, 0, pH + 13, -pD / 2 + tS
         Bld.Line pM, tS, pH + 6, -pD / 2 + 2 * tS, 0, pH + 13, -pD / 2 + tS
         break
      case "crenel"
         -- merlons along the front and back tops
         repeat with x = -pW / 2 to pW / 2 - 1 step 2
            Bld.Line pM, x, pH, -pD / 2, x, pH + 1, -pD / 2
            Bld.Line pM, x, pH + 1, -pD / 2, x + 1, pH + 1, -pD / 2
            Bld.Line pM, x + 1, pH + 1, -pD / 2, x + 1, pH, -pD / 2
            Bld.Line pM, x, pH, pD / 2, x, pH + 1, pD / 2
            Bld.Line pM, x, pH + 1, pD / 2, x + 1, pH + 1, pD / 2
            Bld.Line pM, x + 1, pH + 1, pD / 2, x + 1, pH, pD / 2
         end repeat
         break
      case "tall"
         -- a plant room on the roof and a mast
         Bld.Box pM, -pW / 5, pH, -pD / 5, pW / 5, pH + 3, pD / 5
         Bld.Line pM, 0, pH + 3, 0, 0, pH + 10, 0
         break
      default
         -- flat: a low parapet
         Bld.Rect pM, pW, pD, pH + 0.6
         Bld.Line pM, -pW / 2, pH, -pD / 2, -pW / 2, pH + 0.6, -pD / 2
         Bld.Line pM, pW / 2, pH, pD / 2, pW / 2, pH + 0.6, pD / 2
   end switch
end Bld.RoofLines

-------------------------------------------------------------------- doors and windows (uDead's)

-- a part lying in its wall (axis x: along x, axis z: along z), from its foot (y 0) up pH metres:
-- the frame and a diagonal; a window has the other diagonal too (boarded); a roller door has
-- slats
function Bld.PartMesh pKind, pW, pH, pAxis
   local tM, tA, tB, k
   put Bld.NewMesh() into tM
   put pW / 2 into tA
   put -pW / 2 into tB
   Bld.PLine tM, pAxis, tB, 0, tA, 0
   Bld.PLine tM, pAxis, tB, pH, tA, pH
   Bld.PLine tM, pAxis, tB, 0, tB, pH
   Bld.PLine tM, pAxis, tA, 0, tA, pH
   if pKind is "roller" then
      repeat with k = 1 to 7
         Bld.PLine tM, pAxis, tB, pH * k / 8, tA, pH * k / 8
      end repeat
   else
      Bld.PLine tM, pAxis, tB, 0, tA, pH
      if pKind is "window" or pKind is "heavydoor" then Bld.PLine tM, pAxis, tB, pH, tA, 0
   end if
   delete variable tM["at"]
   return tM
end Bld.PartMesh

function Bld.PartName pKind, pW, pH, pAxis
   return "Bld.P" & pKind & round(pW * 10) & "x" & round(pH * 10) & pAxis
end Bld.PartName

on Bld.PLine @pM, pAxis, pU1, pY1, pU2, pY2
   if pAxis is "x" then
      Bld.Line pM, pU1, pY1, 0, pU2, pY2, 0
   else
      Bld.Line pM, 0, pY1, pU1, 0, pY2, pU2
   end if
end Bld.PLine

-------------------------------------------------------------------- the mesh, in the engine's own form

function Bld.NewMesh
   local tM
   put 0 into tM["count"]
   put empty into tM["faces"]
   put empty into tM["lines"]
   return tM
end Bld.NewMesh

-- a line between two points in metres (y up); in engine units, y down
on Bld.Line @pM, pX1, pY1, pZ1, pX2, pY2, pZ2
   local tA, tB
   put Bld.Vertex(pM, pX1, pY1, pZ1) into tA
   put Bld.Vertex(pM, pX2, pY2, pZ2) into tB
   if pM["lines"] is empty then
      put tA && tB into pM["lines"]
   else
      put cr & tA && tB after pM["lines"]
   end if
end Bld.Line

-- a vertex (shared when two lines meet at the same point)
function Bld.Vertex @pM, pX, pY, pZ
   local tKey
   put round(pX * kM, 2) & "," & round(-pY * kM, 2) & "," & round(pZ * kM, 2) into tKey
   if pM["at"][tKey] is not empty then return pM["at"][tKey]
   add 1 to pM["count"]
   put round(pX * kM, 2) into pM["vx"][pM["count"]]
   put round(-pY * kM, 2) into pM["vy"][pM["count"]]
   put round(pZ * kM, 2) into pM["vz"][pM["count"]]
   put pM["count"] into pM["at"][tKey]
   return pM["count"]
end Bld.Vertex

on Bld.Rect @pM, pW, pD, pY
   Bld.Line pM, -pW / 2, pY, -pD / 2, pW / 2, pY, -pD / 2
   Bld.Line pM, pW / 2, pY, -pD / 2, pW / 2, pY, pD / 2
   Bld.Line pM, pW / 2, pY, pD / 2, -pW / 2, pY, pD / 2
   Bld.Line pM, -pW / 2, pY, pD / 2, -pW / 2, pY, -pD / 2
end Bld.Rect

on Bld.Box @pM, pX1, pY1, pZ1, pX2, pY2, pZ2
   Bld.Line pM, pX1, pY1, pZ1, pX2, pY1, pZ1
   Bld.Line pM, pX2, pY1, pZ1, pX2, pY1, pZ2
   Bld.Line pM, pX2, pY1, pZ2, pX1, pY1, pZ2
   Bld.Line pM, pX1, pY1, pZ2, pX1, pY1, pZ1
   Bld.Line pM, pX1, pY2, pZ1, pX2, pY2, pZ1
   Bld.Line pM, pX2, pY2, pZ1, pX2, pY2, pZ2
   Bld.Line pM, pX2, pY2, pZ2, pX1, pY2, pZ2
   Bld.Line pM, pX1, pY2, pZ2, pX1, pY2, pZ1
   Bld.Line pM, pX1, pY1, pZ1, pX1, pY2, pZ1
   Bld.Line pM, pX2, pY1, pZ1, pX2, pY2, pZ1
   Bld.Line pM, pX2, pY1, pZ2, pX2, pY2, pZ2
   Bld.Line pM, pX1, pY1, pZ2, pX1, pY2, pZ2
end Bld.Box
