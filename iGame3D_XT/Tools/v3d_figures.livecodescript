script "v3d_figures"
######################################################################################
## FIGURES  (iGame3D XT, workstream C, 16 Nov 2026)
## Our stick figure, in place of the 2008 character models. One figure, dressed by its ROLE
## (what it does in a game): civilian, soldier, police, mechanic, knight, zombie, robot, alien,
## child, dancer, skeleton, devil, orc, monster. Scripts keep role names for their people:
## civilian_001, soldier_001 ... (Fig.Instance). The same figure as a file: Data/Models/
## stick_figure.gltf (tools/stick_gltf.py), for other engines.
## No file is read and no engine call is made: meshes come back in the engine's own form.
##
##   Fig.Roles()               the roles
##   Fig.Make(role, pose)      pose: stand (default), walk1, walk2; zombies hold their arms out
##   Fig.RoleOf(name)          a 2008 character's role, from words in its name
##   Fig.Instance(role, n)     "soldier_007"
######################################################################################

constant kM = 10

function Fig.Roles
   return "civilian,soldier,police,mechanic,knight,zombie,robot,alien,child,dancer,skeleton,devil,orc,monster"
end Fig.Roles

-- what a 2008 character name was, as a role (the words in the name; else a civilian)
function Fig.RoleOf pName
   local tN
   put toLower(pName) into tN
   if Fig.Has(tN, "cop,officer,police") then return "police"
   if Fig.Has(tN, "bone,skelet") then return "skeleton"
   if Fig.Has(tN, "zombie,undead,dead") then return "zombie"
   if Fig.Has(tN, "robot,mech,droid") then
      if tN contains "mechanic" then return "mechanic"
      return "robot"
   end if
   if Fig.Has(tN, "alien,fly") then return "alien"
   if Fig.Has(tN, "knight") then return "knight"
   if Fig.Has(tN, "devil,demon") then return "devil"
   if Fig.Has(tN, "orc") then return "orc"
   if Fig.Has(tN, "baby,kid,child") then return "child"
   if Fig.Has(tN, "ballerina,dancer") then return "dancer"
   if Fig.Has(tN, "chief,soldier,marine,fighter,arbiter") then return "soldier"
   if Fig.Has(tN, "beast,monster,sack") then return "monster"
   return "civilian"
end Fig.RoleOf

function Fig.Has pText, pWords
   local tW
   repeat for each item tW in pWords
      if pText contains tW then return true
   end repeat
   return false
end Fig.Has

function Fig.Instance pRole, pN
   return pRole & "_" & char -3 to -1 of ("00" & pN)
end Fig.Instance

-- a figure standing on y 0, facing -z, 1.8 m tall (a child 1.1)
function Fig.Make pRole, pPose
   local tM, k, s, tSwing, tArm, tHead
   put Fig.NewMesh() into tM
   put 1 into s
   if pRole is "child" then put 0.62 into s
   if pRole is "orc" or pRole is "monster" then put 1.15 into s
   put 0 into tSwing
   if pPose is "walk1" then put 0.25 into tSwing
   if pPose is "walk2" then put -0.25 into tSwing
   -- legs (hips 0.95 m), spine to the neck (1.5), arms from the shoulders (1.42)
   Fig.L tM, s, -0.12, 0, tSwing, -0.1, 0.5, tSwing / 2
   Fig.L tM, s, -0.1, 0.5, tSwing / 2, -0.1, 0.95, 0
   Fig.L tM, s, 0.12, 0, -tSwing, 0.1, 0.5, -tSwing / 2
   Fig.L tM, s, 0.1, 0.5, -tSwing / 2, 0.1, 0.95, 0
   Fig.L tM, s, -0.1, 0.95, 0, 0.1, 0.95, 0
   Fig.L tM, s, 0, 0.95, 0, 0, 1.5, 0
   Fig.L tM, s, -0.22, 1.42, 0, 0.22, 1.42, 0
   if pRole is "zombie" or pRole is "robot" then
      -- arms out in front
      Fig.L tM, s, -0.22, 1.42, 0, -0.2, 1.4, -0.35
      Fig.L tM, s, -0.2, 1.4, -0.35, -0.18, 1.38, -0.65
      Fig.L tM, s, 0.22, 1.42, 0, 0.2, 1.4, -0.35
      Fig.L tM, s, 0.2, 1.4, -0.35, 0.18, 1.38, -0.65
   else if pRole is "dancer" then
      Fig.L tM, s, -0.22, 1.42, 0, -0.45, 1.6, 0
      Fig.L tM, s, -0.45, 1.6, 0, -0.25, 1.85, 0
      Fig.L tM, s, 0.22, 1.42, 0, 0.45, 1.6, 0
      Fig.L tM, s, 0.45, 1.6, 0, 0.25, 1.85, 0
   else
      Fig.L tM, s, -0.22, 1.42, 0, -0.28, 1.12, -tSwing / 2
      Fig.L tM, s, -0.28, 1.12, -tSwing / 2, -0.28, 0.85, -tSwing
      Fig.L tM, s, 0.22, 1.42, 0, 0.28, 1.12, tSwing / 2
      Fig.L tM, s, 0.28, 1.12, tSwing / 2, 0.28, 0.85, tSwing
   end if
   -- the head
   put 0.12 into tHead
   if pRole is "alien" then put 0.2 into tHead
   if pRole is "robot" then
      Fig.Box tM, s, 0, 1.52, 0, 0.26, 0.26, 0.24
      Fig.L tM, s, 0, 1.78, 0, 0, 1.9, 0
   else
      Fig.Ring tM, s, 0, 1.5 + tHead, 0, tHead, 10, "z"
      Fig.Ring tM, s, 0, 1.5 + tHead, 0, tHead, 10, "x"
   end if
   -- what they wear and carry
   switch pRole
      case "soldier"
         -- a helmet's brim and a rifle across the chest
         Fig.Ring tM, s, 0, 1.66, 0, 0.17, 10, "y"
         Fig.L tM, s, -0.3, 1.0, -0.15, 0.35, 1.45, -0.15
         Fig.L tM, s, 0.1, 1.2, -0.15, 0.08, 1.08, -0.15
         break
      case "police"
         -- a peaked cap and a badge
         Fig.Ring tM, s, 0, 1.67, 0, 0.13, 10, "y"
         Fig.L tM, s, -0.13, 1.67, 0, 0, 1.64, -0.2
         Fig.L tM, s, 0.13, 1.67, 0, 0, 1.64, -0.2
         Fig.Ring tM, s, -0.1, 1.3, -0.02, 0.03, 5, "z"
         break
      case "mechanic"
         -- a wrench in the right hand
         Fig.L tM, s, 0.28, 0.85, 0, 0.28, 0.6, -0.05
         Fig.Ring tM, s, 0.28, 0.57, -0.05, 0.04, 6, "z"
         break
      case "knight"
         -- a sword up and a shield
         Fig.L tM, s, 0.28, 0.85, 0, 0.28, 1.75, -0.1
         Fig.L tM, s, 0.2, 0.95, -0.05, 0.36, 0.95, -0.05
         Fig.Box tM, s, -0.34, 0.9, -0.1, 0.05, 0.55, 0.45
         break
      case "skeleton"
         repeat with k = 1 to 4
            Fig.L tM, s, -0.13, 1.42 - k * 0.1, -0.03, 0.13, 1.42 - k * 0.1, -0.03
         end repeat
         break
      case "devil"
         Fig.L tM, s, -0.08, 1.7, 0, -0.14, 1.86, 0
         Fig.L tM, s, 0.08, 1.7, 0, 0.14, 1.86, 0
         Fig.L tM, s, 0, 0.95, 0, 0, 0.7, 0.4
         Fig.L tM, s, 0, 0.7, 0.4, 0.06, 0.78, 0.48
         break
      case "orc"
         Fig.L tM, s, -0.06, 1.55, -0.1, -0.08, 1.6, -0.15
         Fig.L tM, s, 0.06, 1.55, -0.1, 0.08, 1.6, -0.15
         Fig.L tM, s, -0.28, 0.85, 0, -0.28, 1.4, -0.3
         break
      case "monster"
         Fig.L tM, s, -0.22, 1.42, 0, -0.4, 1.7, 0
         Fig.L tM, s, 0.22, 1.42, 0, 0.4, 1.7, 0
         Fig.L tM, s, 0, 1.5, 0, 0, 1.4, 0.3
         break
      case "alien"
         Fig.L tM, s, -0.07, 1.85, 0, -0.12, 2.02, 0
         Fig.L tM, s, 0.07, 1.85, 0, 0.12, 2.02, 0
         break
      case "dancer"
         -- a tutu
         Fig.Ring tM, s, 0, 0.95, 0, 0.3, 12, "y"
         break
   end switch
   delete variable tM["at"]
   return tM
end Fig.Make

-------------------------------------------------------------------- the engine's mesh form

function Fig.NewMesh
   local tM
   put 0 into tM["count"]
   put empty into tM["faces"]
   put empty into tM["lines"]
   return tM
end Fig.NewMesh

-- a line between two points in metres (scaled by pS, y up); engine units, y down
on Fig.L @pM, pS, pX1, pY1, pZ1, pX2, pY2, pZ2
   local tA, tB
   put Fig.V(pM, pX1 * pS, pY1 * pS, pZ1 * pS) into tA
   put Fig.V(pM, pX2 * pS, pY2 * pS, pZ2 * pS) into tB
   if tA is tB then exit Fig.L
   if pM["lines"] is empty then
      put tA && tB into pM["lines"]
   else
      put cr & tA && tB after pM["lines"]
   end if
end Fig.L

function Fig.V @pM, pX, pY, pZ
   local tKey
   put round(pX * kM, 2) & "," & round(-pY * kM, 2) & "," & round(pZ * kM, 2) into tKey
   if pM["at"][tKey] is not empty then return pM["at"][tKey]
   add 1 to pM["count"]
   put round(pX * kM, 2) into pM["vx"][pM["count"]]
   put round(-pY * kM, 2) into pM["vy"][pM["count"]]
   put round(pZ * kM, 2) into pM["vz"][pM["count"]]
   put pM["count"] into pM["at"][tKey]
   return pM["count"]
end Fig.V

on Fig.Ring @pM, pS, pX, pY, pZ, pR, pN, pAxis
   local k, a, b
   repeat with k = 0 to pN - 1
      put 6.28318 * k / pN into a
      put 6.28318 * (k + 1) / pN into b
      switch pAxis
         case "x"
            Fig.L pM, pS, pX, pY + pR * cos(a), pZ + pR * sin(a), pX, pY + pR * cos(b), pZ + pR * sin(b)
            break
         case "y"
            Fig.L pM, pS, pX + pR * cos(a), pY, pZ + pR * sin(a), pX + pR * cos(b), pY, pZ + pR * sin(b)
            break
         default
            Fig.L pM, pS, pX + pR * cos(a), pY + pR * sin(a), pZ, pX + pR * cos(b), pY + pR * sin(b), pZ
      end switch
   end repeat
end Fig.Ring

on Fig.Box @pM, pS, pX, pY, pZ, pW, pH, pD
   local x1, x2, z1, z2, y2
   put pX - pW / 2 into x1
   put pX + pW / 2 into x2
   put pZ - pD / 2 into z1
   put pZ + pD / 2 into z2
   put pY + pH into y2
   Fig.L pM, pS, x1, pY, z1, x2, pY, z1
   Fig.L pM, pS, x2, pY, z1, x2, pY, z2
   Fig.L pM, pS, x2, pY, z2, x1, pY, z2
   Fig.L pM, pS, x1, pY, z2, x1, pY, z1
   Fig.L pM, pS, x1, y2, z1, x2, y2, z1
   Fig.L pM, pS, x2, y2, z1, x2, y2, z2
   Fig.L pM, pS, x2, y2, z2, x1, y2, z2
   Fig.L pM, pS, x1, y2, z2, x1, y2, z1
   Fig.L pM, pS, x1, pY, z1, x1, y2, z1
   Fig.L pM, pS, x2, pY, z1, x2, y2, z1
   Fig.L pM, pS, x2, pY, z2, x2, y2, z2
   Fig.L pM, pS, x1, pY, z2, x1, y2, z2
end Fig.Box
