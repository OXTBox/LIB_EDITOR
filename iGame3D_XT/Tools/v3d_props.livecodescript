script "v3d_props"
######################################################################################
## PROPS  (iGame3D XT, workstream A, 16 Nov 2026)
## Every other model group of the 2008 Data folder, made procedurally from a plain name:
## dungeon parts, building parts, furniture, containers, shapes, street things, foliage, land and
## air vehicles, weapons, tools, animals, misc, floors, walls, skies, signs. The 2008 inventory
## said which kinds of thing are needed; the names here are generic on purpose (no names from
## other people's games). Nothing is read from disk and no engine call is made: meshes come back
## in the engine's own array form (count, vx/vy/vz, lines) for the caller to Mesh.Define.
##
##   Prop.Groups()          the groups, comma separated
##   Prop.Names(group)      the names in a group
##   Prop.Make(name)        the mesh (metres x 10 units, standing on y 0, y up is negative)
##   Prop.GroupOf(name)     which group a name is in
######################################################################################

constant kM = 10

function Prop.Groups
   return "Dungeon,Building parts,Furniture,Containers,Shapes,Street,Foliage,Vehicles,Aircraft,Weapons,Tools,Animals,Misc,Floors,Walls,Sky,Signs"
end Prop.Groups

function Prop.Names pGroup
   switch pGroup
      case "Dungeon"
         return "arch,column,dungeon_wall,arched_bridge,corridor,crossing,platform,stone_block,stairs"
      case "Building parts"
         return "door_frame,garage_door,balustrade,steps,spiral_stair,wall_lamp,brazier,slat_fence,beam"
      case "Furniture"
         return "chair,table,desk,bed,couch,bookshelf,cabinet,nightstand,dresser,office_chair,tv,safe,bench"
      case "Containers"
         return "crate,barrel,bucket,vase,cargo_box,briefcase,bin"
      case "Shapes"
         return "cube,sphere,cylinder,cone,pyramid,boulder,crystal,brick,ring"
      case "Street"
         return "lamp_post,traffic_cone,road_block,speed_sign,road,pavement,hydrant"
      case "Foliage"
         return "tree,dead_tree,palm,pine,bush,tall_grass,potted_plant"
      case "Vehicles"
         return "car,truck,ambulance,bus,tanker,jeep,tank,skateboard"
      case "Aircraft"
         return "plane,jet,helicopter,gunship,bomber,saucer"
      case "Weapons"
         return "pistol,rifle,shotgun,smg,sniper_rifle,rocket_launcher,grenade,bomb,sword,dagger,spear,axe,halberd,throwing_star"
      case "Tools"
         return "ladder,mallet,shovel,monitor"
      case "Animals"
         return "bird,deer,horse,whale,starfish,dinosaur,worm,mantis"
      case "Misc"
         return "grave,book,propane_tank,pallet,spotlight,turbine,swing,slide,crosshair,powerup"
      case "Floors"
         return "grid_floor,water_plane,sand_plane"
      case "Walls"
         return "wall_3m,wall_12m,broken_wall,wood_fence"
      case "Sky"
         return "night_sky,desert_sky,sunset_sky"
      case "Signs"
         return "sign_board,billboard"
   end switch
   return empty
end Prop.Names

function Prop.GroupOf pName
   local tG
   repeat for each item tG in Prop.Groups()
      if pName is among the items of Prop.Names(tG) then return tG
   end repeat
   return empty
end Prop.GroupOf

-------------------------------------------------------------------- the models

function Prop.Make pName
   local tM, k, a, tR
   put Prop.NewMesh() into tM
   switch pName
      -- dungeon
      case "arch"
         Prop.Arch tM, 0, 0, 4, 4.5, 1
         break
      case "column"
         Prop.Box tM, 0, 0, 0, 1.2, 0.3, 1.2
         Prop.Cyl tM, 0, 0.3, 0, 0.4, 4, 10
         Prop.Box tM, 0, 4.3, 0, 1.2, 0.3, 1.2
         break
      case "dungeon_wall"
         Prop.Box tM, 0, 0, 0, 6, 4, 1
         repeat with k = 1 to 3
            Prop.Line tM, -3, k, -0.5, 3, k, -0.5
         end repeat
         break
      case "arched_bridge"
         Prop.Box tM, 0, 2.5, 0, 10, 0.5, 3
         Prop.Arch tM, 0, 0, 8, 2.5, 3
         break
      case "corridor"
         Prop.Box tM, -2, 0, 0, 0.5, 3, 8
         Prop.Box tM, 2, 0, 0, 0.5, 3, 8
         Prop.Box tM, 0, 3, 0, 4.5, 0.4, 8
         break
      case "crossing"
         Prop.Box tM, 0, 0, 0, 8, 0.2, 2.5
         Prop.Box tM, 0, 0, 0, 2.5, 0.2, 8
         break
      case "platform"
         Prop.Box tM, 0, 0, 0, 5, 1, 5
         Prop.Steps tM, 0, -3.3, 1, 3
         break
      case "stone_block"
         Prop.Box tM, 0, 0, 0, 1.5, 1, 1
         break
      case "stairs"
         Prop.Steps tM, 0, 0, 3, 8
         break
      -- building parts
      case "door_frame"
         Prop.Line tM, -0.6, 0, 0, -0.6, 2.2, 0
         Prop.Line tM, 0.6, 0, 0, 0.6, 2.2, 0
         Prop.Line tM, -0.6, 2.2, 0, 0.6, 2.2, 0
         Prop.Box tM, 0.15, 0, 0.3, 0.9, 2.1, 0.05
         break
      case "garage_door"
         Prop.Box tM, 0, 0, 0, 3, 2.4, 0.1
         repeat with k = 1 to 5
            Prop.Line tM, -1.5, k * 0.4, -0.05, 1.5, k * 0.4, -0.05
         end repeat
         break
      case "balustrade"
         Prop.Box tM, 0, 0.9, 0, 4, 0.15, 0.2
         repeat with k = 0 to 8
            Prop.Cyl tM, -2 + k * 0.5, 0, 0, 0.06, 0.9, 6
         end repeat
         break
      case "steps"
         Prop.Steps tM, 0, 0, 2, 4
         break
      case "spiral_stair"
         Prop.Cyl tM, 0, 0, 0, 0.15, 4, 6
         repeat with k = 0 to 15
            put k * 0.45 into a
            Prop.Line tM, 0, k * 0.25, 0, 1.4 * cos(a), k * 0.25, 1.4 * sin(a)
            Prop.Line tM, 1.4 * cos(a), k * 0.25, 1.4 * sin(a), 1.4 * cos(a + 0.45), (k + 1) * 0.25, 1.4 * sin(a + 0.45)
         end repeat
         break
      case "wall_lamp"
         Prop.Box tM, 0, 1.8, 0, 0.2, 0.3, 0.1
         Prop.Line tM, 0, 1.95, 0, 0, 1.95, -0.3
         Prop.Sphere tM, 0, 1.95, -0.4, 0.12, 6
         break
      case "brazier"
         Prop.Cyl tM, 0, 0, 0, 0.1, 1, 6
         Prop.Cone tM, 0, 1.4, 0, 0.5, -0.4, 8
         repeat with k = 0 to 4
            Prop.Line tM, -0.3 + k * 0.15, 1.4, 0, -0.2 + k * 0.1, 1.9 + (k mod 2) * 0.3, 0
         end repeat
         break
      case "slat_fence"
         Prop.Line tM, -3, 0.4, 0, 3, 0.4, 0
         Prop.Line tM, -3, 1.2, 0, 3, 1.2, 0
         repeat with k = 0 to 12
            Prop.Line tM, -3 + k * 0.5, 0, 0, -3 + k * 0.5, 1.5, 0
         end repeat
         break
      case "beam"
         Prop.Box tM, 0, 3, 0, 6, 0.3, 0.3
         break
      -- furniture
      case "chair"
         Prop.Legs tM, 0.45, 0.45, 0.45
         Prop.Box tM, 0, 0.45, 0, 0.5, 0.05, 0.5
         Prop.Box tM, 0, 0.5, 0.22, 0.5, 0.5, 0.05
         break
      case "table"
         Prop.Legs tM, 1.4, 0.8, 0.72
         Prop.Box tM, 0, 0.72, 0, 1.6, 0.05, 1
         break
      case "desk"
         Prop.Box tM, -0.55, 0, 0, 0.45, 0.72, 0.7
         Prop.Legs tM, 1.3, 0.6, 0.72
         Prop.Box tM, 0, 0.72, 0, 1.5, 0.05, 0.75
         break
      case "bed"
         Prop.Box tM, 0, 0, 0, 1.6, 0.45, 2.1
         Prop.Box tM, 0, 0, 1.02, 1.6, 1.1, 0.06
         Prop.Box tM, 0, 0.45, 0.75, 1.2, 0.12, 0.4
         break
      case "couch"
         Prop.Box tM, 0, 0, 0, 2, 0.45, 0.9
         Prop.Box tM, 0, 0.45, 0.35, 2, 0.45, 0.2
         Prop.Box tM, -0.9, 0.45, 0, 0.2, 0.25, 0.9
         Prop.Box tM, 0.9, 0.45, 0, 0.2, 0.25, 0.9
         break
      case "bookshelf"
         Prop.Box tM, 0, 0, 0, 1, 2, 0.35
         repeat with k = 1 to 4
            Prop.Line tM, -0.5, k * 0.4, -0.17, 0.5, k * 0.4, -0.17
         end repeat
         break
      case "cabinet"
         Prop.Box tM, 0, 0, 0, 0.8, 1, 0.5
         Prop.Line tM, 0, 0, -0.25, 0, 1, -0.25
         break
      case "nightstand"
         Prop.Box tM, 0, 0, 0, 0.5, 0.55, 0.4
         Prop.Line tM, -0.25, 0.35, -0.2, 0.25, 0.35, -0.2
         break
      case "dresser"
         Prop.Box tM, 0, 0, 0, 1.2, 0.85, 0.5
         Prop.Box tM, 0, 0.85, 0.2, 0.9, 0.9, 0.04
         repeat with k = 1 to 2
            Prop.Line tM, -0.6, k * 0.28, -0.25, 0.6, k * 0.28, -0.25
         end repeat
         break
      case "office_chair"
         Prop.Cyl tM, 0, 0.05, 0, 0.05, 0.4, 6
         repeat with k = 0 to 4
            put k * 1.2566 into a
            Prop.Line tM, 0, 0.05, 0, 0.3 * cos(a), 0.05, 0.3 * sin(a)
         end repeat
         Prop.Box tM, 0, 0.45, 0, 0.5, 0.06, 0.5
         Prop.Box tM, 0, 0.55, 0.23, 0.45, 0.6, 0.05
         break
      case "tv"
         Prop.Box tM, 0, 0, 0, 0.6, 0.6, 0.4
         Prop.Box tM, 0, 0.6, 0, 1.1, 0.65, 0.08
         break
      case "safe"
         Prop.Box tM, 0, 0, 0, 0.8, 1, 0.7
         Prop.Ring tM, 0, 0.5, -0.36, 0.12, 8, "z"
         break
      case "bench"
         Prop.Legs tM, 1.6, 0.35, 0.45
         Prop.Box tM, 0, 0.45, 0, 1.8, 0.05, 0.4
         break
      -- containers
      case "crate"
         Prop.Box tM, 0, 0, 0, 1, 1, 1
         Prop.Line tM, -0.5, 0, -0.5, 0.5, 1, -0.5
         Prop.Line tM, -0.5, 1, -0.5, 0.5, 0, -0.5
         break
      case "barrel"
         Prop.Cyl tM, 0, 0, 0, 0.3, 0.9, 10
         Prop.Ring tM, 0, 0.3, 0, 0.32, 10, "y"
         Prop.Ring tM, 0, 0.6, 0, 0.32, 10, "y"
         break
      case "bucket"
         Prop.Cone tM, 0, 0, 0, 0.13, 0.3, 8
         Prop.Ring tM, 0, 0.3, 0, 0.17, 8, "y"
         break
      case "vase"
         Prop.Ring tM, 0, 0, 0, 0.1, 8, "y"
         Prop.Ring tM, 0, 0.25, 0, 0.2, 8, "y"
         Prop.Ring tM, 0, 0.5, 0, 0.07, 8, "y"
         Prop.Ring tM, 0, 0.6, 0, 0.1, 8, "y"
         repeat with k = 0 to 3
            put k * 1.5708 into a
            Prop.Line tM, 0.1 * cos(a), 0, 0.1 * sin(a), 0.2 * cos(a), 0.25, 0.2 * sin(a)
            Prop.Line tM, 0.2 * cos(a), 0.25, 0.2 * sin(a), 0.07 * cos(a), 0.5, 0.07 * sin(a)
            Prop.Line tM, 0.07 * cos(a), 0.5, 0.07 * sin(a), 0.1 * cos(a), 0.6, 0.1 * sin(a)
         end repeat
         break
      case "cargo_box"
         Prop.Box tM, 0, 0, 0, 6, 2.6, 2.4
         repeat with k = 1 to 11
            Prop.Line tM, -3 + k * 0.5, 0, -1.2, -3 + k * 0.5, 2.6, -1.2
         end repeat
         break
      case "briefcase"
         Prop.Box tM, 0, 0, 0, 0.45, 0.33, 0.1
         Prop.Line tM, -0.08, 0.33, 0, -0.08, 0.38, 0
         Prop.Line tM, -0.08, 0.38, 0, 0.08, 0.38, 0
         Prop.Line tM, 0.08, 0.38, 0, 0.08, 0.33, 0
         break
      case "bin"
         Prop.Cyl tM, 0, 0, 0, 0.3, 0.9, 10
         Prop.Cone tM, 0, 0.9, 0, 0.32, 0.12, 10
         break
      -- shapes
      case "cube"
         Prop.Box tM, 0, 0, 0, 1, 1, 1
         break
      case "sphere"
         Prop.Sphere tM, 0, 0.5, 0, 0.5, 10
         break
      case "cylinder"
         Prop.Cyl tM, 0, 0, 0, 0.5, 1, 12
         break
      case "cone"
         Prop.Cone tM, 0, 0, 0, 0.5, 1, 12
         break
      case "pyramid"
         Prop.Cone tM, 0, 0, 0, 0.7, 1, 4
         break
      case "boulder"
         Prop.Blob tM, 0, 0.6, 0, 0.8, 7, 31
         break
      case "crystal"
         Prop.Cone tM, 0, 0.6, 0, 0.25, 0.8, 6
         Prop.Cone tM, 0, 0.6, 0, 0.25, -0.6, 6
         break
      case "brick"
         Prop.Box tM, 0, 0, 0, 0.4, 0.15, 0.2
         break
      case "ring"
         Prop.Ring tM, 0, 0.5, 0, 0.5, 16, "z"
         Prop.Ring tM, 0, 0.5, 0, 0.35, 16, "z"
         break
      -- street
      case "lamp_post"
         Prop.Cyl tM, 0, 0, 0, 0.08, 5, 6
         Prop.Line tM, 0, 5, 0, 0.8, 5.2, 0
         Prop.Cone tM, 0.8, 4.9, 0, 0.3, 0.3, 6
         break
      case "traffic_cone"
         Prop.Box tM, 0, 0, 0, 0.4, 0.04, 0.4
         Prop.Cone tM, 0, 0.04, 0, 0.15, 0.6, 8
         Prop.Ring tM, 0, 0.3, 0, 0.09, 8, "y"
         break
      case "road_block"
         Prop.Legs tM, 2, 0.3, 1
         Prop.Box tM, 0, 0.7, 0, 2.2, 0.25, 0.08
         repeat with k = 0 to 4
            Prop.Line tM, -1.1 + k * 0.45, 0.7, -0.04, -0.85 + k * 0.45, 0.95, -0.04
         end repeat
         break
      case "speed_sign"
         Prop.Cyl tM, 0, 0, 0, 0.04, 2.2, 6
         Prop.Ring tM, 0, 2.5, -0.05, 0.35, 12, "z"
         break
      case "road"
         Prop.Rect tM, 0, 0, 0, 7, 20
         repeat with k = 0 to 4
            Prop.Line tM, 0, 0, -10 + k * 4.5, 0, 0, -8 + k * 4.5
         end repeat
         break
      case "pavement"
         Prop.Rect tM, 0, 0.15, 0, 2, 10
         repeat with k = 1 to 9
            Prop.Line tM, -1, 0.15, -5 + k, 1, 0.15, -5 + k
         end repeat
         break
      case "hydrant"
         Prop.Cyl tM, 0, 0, 0, 0.13, 0.6, 8
         Prop.Sphere tM, 0, 0.6, 0, 0.13, 6
         Prop.Cyl tM, -0.25, 0.4, 0, 0.05, 0.5, 6, "x"
         break
      -- foliage
      case "tree"
         Prop.Cyl tM, 0, 0, 0, 0.25, 2.5, 6
         Prop.Blob tM, 0, 4, 0, 2, 8, 7
         break
      case "dead_tree"
         Prop.Cyl tM, 0, 0, 0, 0.25, 3, 6
         Prop.Line tM, 0, 2, 0, 1.2, 3.5, 0.3
         Prop.Line tM, 0, 2.5, 0, -1, 3.8, -0.4
         Prop.Line tM, 0, 3, 0, 0.3, 4.3, -0.9
         Prop.Line tM, 0.6, 2.8, 0.15, 1.1, 2.9, 0.9
         break
      case "palm"
         repeat with k = 0 to 5
            Prop.Line tM, k * 0.12, k, 0, (k + 1) * 0.12, k + 1, 0
         end repeat
         repeat with k = 0 to 6
            put k * 0.8976 into a
            Prop.Line tM, 0.72, 6, 0, 0.72 + 2.2 * cos(a), 5.2, 2.2 * sin(a)
         end repeat
         break
      case "pine"
         Prop.Cyl tM, 0, 0, 0, 0.2, 1, 6
         Prop.Cone tM, 0, 1, 0, 1.6, 2, 8
         Prop.Cone tM, 0, 2.4, 0, 1.2, 1.8, 8
         Prop.Cone tM, 0, 3.6, 0, 0.8, 1.6, 8
         break
      case "bush"
         Prop.Blob tM, 0, 0.6, 0, 0.8, 7, 13
         break
      case "tall_grass"
         repeat with k = 0 to 14
            put k * 2.4 into a
            Prop.Line tM, 0.3 * cos(a), 0, 0.3 * sin(a), 0.5 * cos(a + 0.3), 0.9 + (k mod 3) * 0.2, 0.5 * sin(a + 0.3)
         end repeat
         break
      case "potted_plant"
         Prop.Cone tM, 0, 0, 0, 0.18, 0.35, 8
         Prop.Ring tM, 0, 0.35, 0, 0.24, 8, "y"
         repeat with k = 0 to 6
            put k * 0.8976 into a
            Prop.Line tM, 0, 0.35, 0, 0.4 * cos(a), 0.9 + (k mod 2) * 0.3, 0.4 * sin(a)
         end repeat
         break
      -- vehicles (the front is -z)
      case "car"
         Prop.Car tM, 1.8, 4.4, 0.7, 0.6, 0.35
         break
      case "jeep"
         Prop.Car tM, 1.9, 4, 0.9, 0.7, 0.42
         Prop.Line tM, -0.9, 1.6, 0.5, 0.9, 1.6, 0.5
         break
      case "ambulance"
         Prop.Box tM, 0, 0.4, 0.6, 2, 2, 3.6
         Prop.Box tM, 0, 0.4, -1.9, 2, 1.1, 1.2
         Prop.Wheels tM, 2, 4.6, 0.4
         Prop.Line tM, -0.3, 1.6, -1.2, 0.3, 1.6, -1.2
         Prop.Line tM, 0, 1.3, -1.2, 0, 1.9, -1.2
         break
      case "truck"
         Prop.Box tM, 0, 0.5, 1, 2.4, 2.8, 5
         Prop.Box tM, 0, 0.5, -2.2, 2.4, 1.8, 1.6
         Prop.Wheels tM, 2.4, 6.6, 0.5
         break
      case "tanker"
         Prop.Cyl tM, 0, 1.5, -1.4, 1.1, 6, 10, "z"
         Prop.Box tM, 0, 0.5, -3.2, 2.4, 1.8, 1.6
         Prop.Wheels tM, 2.4, 7, 0.5
         break
      case "bus"
         Prop.Box tM, 0, 0.5, 0, 2.5, 2.6, 11
         repeat with k = 0 to 8
            Prop.Box tM, -1.26, 1.7, -4.8 + k * 1.2, 0.01, 0.8, 0.9
         end repeat
         Prop.Wheels tM, 2.5, 9, 0.5
         break
      case "tank"
         Prop.Box tM, 0, 0.3, 0, 3.4, 1, 6.5
         Prop.Box tM, 0, 1.3, 0.5, 2.2, 0.8, 2.8
         Prop.Cyl tM, 0, 1.7, -0.9, 0.1, 4, 6, "z"
         repeat with k = 0 to 6
            Prop.Ring tM, -1.5, 0.4, -2.8 + k * 0.93, 0.4, 8, "x"
            Prop.Ring tM, 1.5, 0.4, -2.8 + k * 0.93, 0.4, 8, "x"
         end repeat
         break
      case "skateboard"
         Prop.Box tM, 0, 0.1, 0, 0.22, 0.02, 0.8
         Prop.Ring tM, -0.1, 0.05, -0.28, 0.05, 6, "x"
         Prop.Ring tM, 0.1, 0.05, -0.28, 0.05, 6, "x"
         Prop.Ring tM, -0.1, 0.05, 0.28, 0.05, 6, "x"
         Prop.Ring tM, 0.1, 0.05, 0.28, 0.05, 6, "x"
         break
      -- aircraft (the nose is -z; they float 3 m up)
      case "plane"
         Prop.Cyl tM, 0, 3, -4, 0.5, 8, 8, "z"
         Prop.Wing tM, 0, 3, -1, 11, 1.6
         Prop.Wing tM, 0, 3.1, 3.4, 4, 0.9
         Prop.Line tM, 0, 3.5, 3.2, 0, 5, 4
         Prop.Line tM, 0, 5, 4, 0, 3.5, 4
         break
      case "jet"
         Prop.Cone tM, 0, 3, -5, 0.6, -2, 8, "z"
         Prop.Cyl tM, 0, 3, -3, 0.6, 7, 8, "z"
         Prop.Line tM, 0, 3, -2, -4, 3, 2.5
         Prop.Line tM, -4, 3, 2.5, 0, 3, 3
         Prop.Line tM, 0, 3, -2, 4, 3, 2.5
         Prop.Line tM, 4, 3, 2.5, 0, 3, 3
         Prop.Line tM, 0, 3.5, 2.5, 0, 5.2, 4
         break
      case "helicopter"
         Prop.Sphere tM, 0, 2.2, -0.5, 1.2, 8
         Prop.Cyl tM, 0, 2.4, 0.6, 0.25, 5, 6, "z"
         Prop.Line tM, -4, 3.6, -0.5, 4, 3.6, -0.5
         Prop.Line tM, 0, 3.6, -4.5, 0, 3.6, 3.5
         Prop.Line tM, 0, 3.4, -0.5, 0, 3.6, -0.5
         Prop.Line tM, -0.9, 1, -1.5, -0.9, 1, 1
         Prop.Line tM, 0.9, 1, -1.5, 0.9, 1, 1
         break
      case "gunship"
         Prop.Box tM, 0, 2, 0, 2.4, 1.8, 7
         Prop.Wing tM, 0, 2.6, -0.5, 7, 1.2
         Prop.Ring tM, -3.5, 3.4, -0.5, 1.4, 10, "y"
         Prop.Ring tM, 3.5, 3.4, -0.5, 1.4, 10, "y"
         break
      case "bomber"
         Prop.Cyl tM, 0, 3, -5, 0.8, 11, 8, "z"
         Prop.Wing tM, 0, 3, -1, 18, 2.4
         Prop.Wing tM, 0, 3.2, 5.2, 5, 1
         repeat with k = 0 to 3
            Prop.Cyl tM, -6 + k * 4, 2.6, -1.6, 0.35, 1.4, 6, "z"
         end repeat
         break
      case "saucer"
         Prop.Ring tM, 0, 3, 0, 3, 16, "y"
         Prop.Ring tM, 0, 3.4, 0, 2, 16, "y"
         Prop.Ring tM, 0, 2.7, 0, 1.6, 16, "y"
         Prop.Sphere tM, 0, 3.6, 0, 0.9, 8
         repeat with k = 0 to 7
            put k * 0.7854 into a
            Prop.Line tM, 1.6 * cos(a), 2.7, 1.6 * sin(a), 3 * cos(a), 3, 3 * sin(a)
            Prop.Line tM, 3 * cos(a), 3, 3 * sin(a), 2 * cos(a), 3.4, 2 * sin(a)
         end repeat
         break
      -- weapons (lying along x, 1 m up, as on a table or in a hand)
      case "pistol"
         Prop.Box tM, 0.05, 1, 0, 0.22, 0.04, 0.03
         Prop.Box tM, -0.04, 0.88, 0, 0.04, 0.12, 0.03
         break
      case "rifle"
         Prop.Gun tM, 1.0, 0.3, true
         break
      case "shotgun"
         Prop.Gun tM, 1.1, 0.35, false
         Prop.Line tM, 0.1, 1.03, 0, 0.7, 1.03, 0
         break
      case "smg"
         Prop.Gun tM, 0.6, 0.18, true
         break
      case "sniper_rifle"
         Prop.Gun tM, 1.3, 0.35, false
         Prop.Cyl tM, -0.05, 1.12, 0, 0.03, 0.35, 6, "x"
         break
      case "rocket_launcher"
         Prop.Cyl tM, -0.6, 1, 0, 0.07, 1.2, 8, "x"
         Prop.Cone tM, 0.6, 1, 0, 0.09, 0.2, 6, "x"
         Prop.Box tM, -0.1, 0.85, 0, 0.05, 0.15, 0.03
         break
      case "grenade"
         Prop.Sphere tM, 0, 1.05, 0, 0.05, 6
         Prop.Line tM, 0, 1.1, 0, 0.04, 1.13, 0
         break
      case "bomb"
         Prop.Cyl tM, -0.4, 1, 0, 0.18, 0.8, 8, "x"
         Prop.Cone tM, -0.4, 1, 0, 0.18, -0.3, 8, "x"
         Prop.Line tM, 0.4, 1, 0, 0.6, 1.2, 0
         Prop.Line tM, 0.4, 1, 0, 0.6, 0.8, 0
         break
      case "sword"
         Prop.Blade tM, 0.9, 0.04
         Prop.Line tM, 0, 0.92, 0, 0, 1.08, 0
         break
      case "dagger"
         Prop.Blade tM, 0.3, 0.025
         break
      case "spear"
         Prop.Line tM, -1, 1, 0, 1, 1, 0
         Prop.Cone tM, 1, 1, 0, 0.04, 0.25, 4, "x"
         break
      case "axe"
         Prop.Line tM, -0.4, 1, 0, 0.4, 1, 0
         Prop.Line tM, 0.3, 1, 0, 0.42, 1.15, 0
         Prop.Line tM, 0.42, 1.15, 0, 0.42, 0.85, 0
         Prop.Line tM, 0.42, 0.85, 0, 0.3, 1, 0
         break
      case "halberd"
         Prop.Line tM, -1, 1, 0, 1, 1, 0
         Prop.Line tM, 0.75, 1, 0, 0.85, 1.25, 0
         Prop.Line tM, 0.85, 1.25, 0, 0.95, 1, 0
         Prop.Line tM, 0.85, 1, 0, 0.85, 0.85, 0
         Prop.Cone tM, 1, 1, 0, 0.03, 0.2, 4, "x"
         break
      case "throwing_star"
         repeat with k = 0 to 3
            put k * 1.5708 into a
            Prop.Line tM, 0.03 * cos(a + 0.785), 1, 0.03 * sin(a + 0.785), 0.12 * cos(a), 1, 0.12 * sin(a)
            Prop.Line tM, 0.12 * cos(a), 1, 0.12 * sin(a), 0.03 * cos(a - 0.785), 1, 0.03 * sin(a - 0.785)
         end repeat
         break
      -- tools
      case "ladder"
         Prop.Line tM, -0.25, 0, 0, -0.25, 3, 0.3
         Prop.Line tM, 0.25, 0, 0, 0.25, 3, 0.3
         repeat with k = 1 to 9
            Prop.Line tM, -0.25, k * 0.3, k * 0.03, 0.25, k * 0.3, k * 0.03
         end repeat
         break
      case "mallet"
         Prop.Line tM, 0, 0, 0, 0, 0.9, 0
         Prop.Cyl tM, -0.15, 0.9, 0, 0.08, 0.3, 8, "x"
         break
      case "shovel"
         Prop.Line tM, 0, 0.3, 0, 0, 1.4, 0
         Prop.Line tM, -0.12, 1.4, 0, 0.12, 1.4, 0
         Prop.Line tM, -0.12, 0.3, 0, 0.12, 0.3, 0
         Prop.Line tM, -0.12, 0.3, 0, 0, 0, 0
         Prop.Line tM, 0.12, 0.3, 0, 0, 0, 0
         break
      case "monitor"
         Prop.Box tM, 0, 0, 0, 0.25, 0.03, 0.2
         Prop.Line tM, 0, 0.03, 0, 0, 0.15, 0
         Prop.Box tM, 0, 0.15, 0, 0.55, 0.35, 0.04
         break
      -- animals (stick and wire, about life size)
      case "bird"
         Prop.Sphere tM, 0, 0.15, 0, 0.08, 6
         Prop.Line tM, 0, 0.17, 0, -0.25, 0.25, 0.05
         Prop.Line tM, 0, 0.17, 0, 0.25, 0.25, 0.05
         Prop.Line tM, 0, 0.15, -0.08, 0, 0.14, -0.14
         break
      case "deer"
         Prop.Quadruped tM, 1.3, 1, 0.5, true
         break
      case "horse"
         Prop.Quadruped tM, 1.8, 1.4, 0.7, false
         break
      case "whale"
         Prop.Blob tM, 0, 1.5, 0, 1.5, 8, 5
         Prop.Line tM, 0, 1.5, 1.4, 0, 1.5, 5
         Prop.Line tM, 0, 1.5, 5, -1.2, 1.5, 5.8
         Prop.Line tM, 0, 1.5, 5, 1.2, 1.5, 5.8
         break
      case "starfish"
         repeat with k = 0 to 4
            put k * 1.2566 into a
            Prop.Line tM, 0.06 * cos(a - 0.6), 0.02, 0.06 * sin(a - 0.6), 0.25 * cos(a), 0.02, 0.25 * sin(a)
            Prop.Line tM, 0.25 * cos(a), 0.02, 0.25 * sin(a), 0.06 * cos(a + 0.6), 0.02, 0.06 * sin(a + 0.6)
         end repeat
         break
      case "dinosaur"
         Prop.Quadruped tM, 6, 3, 1.5, false
         Prop.Line tM, 0, 4.3, -3, 0, 7, -5
         Prop.Line tM, 0, 4, 3, 0, 1, 8
         break
      case "worm"
         repeat with k = 0 to 11
            Prop.Ring tM, 0.15 * sin(k * 0.7), 0.12, -1 + k * 0.18, 0.1, 6, "z"
         end repeat
         break
      case "mantis"
         Prop.Line tM, 0, 0.3, -0.3, 0, 0.3, 0.4
         Prop.Line tM, 0, 0.3, -0.3, 0, 0.6, -0.5
         repeat with k = 0 to 2
            Prop.Line tM, 0, 0.3, k * 0.2, -0.3, 0, k * 0.25
            Prop.Line tM, 0, 0.3, k * 0.2, 0.3, 0, k * 0.25
         end repeat
         Prop.Line tM, 0, 0.5, -0.4, 0, 0.35, -0.7
         break
      -- misc
      case "grave"
         Prop.Arch tM, 0, 0, 0.7, 1, 0.15
         Prop.Rect tM, 0, 0, 1.2, 1, 2
         break
      case "book"
         Prop.Box tM, 0, 0, 0, 0.2, 0.04, 0.28
         break
      case "propane_tank"
         Prop.Cyl tM, 0, 0, 0, 0.18, 0.8, 8
         Prop.Sphere tM, 0, 0.8, 0, 0.18, 6
         break
      case "pallet"
         Prop.Box tM, 0, 0.1, 0, 1.2, 0.04, 1
         repeat with k = 0 to 2
            Prop.Box tM, -0.55 + k * 0.55, 0, 0, 0.1, 0.1, 1
         end repeat
         break
      case "spotlight"
         Prop.Legs tM, 0.8, 0.8, 1.2
         Prop.Cyl tM, 0, 1.5, 0.2, 0.3, 0.6, 8, "z"
         break
      case "turbine"
         Prop.Cyl tM, 0, 0, 0, 0.3, 20, 6
         repeat with k = 0 to 2
            put k * 2.0944 into a
            Prop.Line tM, 0, 20, -0.5, 7 * cos(a), 20 + 7 * sin(a), -0.5
         end repeat
         break
      case "swing"
         Prop.Line tM, -1.5, 0, -0.8, -1.5, 2.4, 0
         Prop.Line tM, -1.5, 0, 0.8, -1.5, 2.4, 0
         Prop.Line tM, 1.5, 0, -0.8, 1.5, 2.4, 0
         Prop.Line tM, 1.5, 0, 0.8, 1.5, 2.4, 0
         Prop.Line tM, -1.5, 2.4, 0, 1.5, 2.4, 0
         Prop.Line tM, -0.3, 2.4, 0, -0.3, 0.5, 0
         Prop.Line tM, 0.3, 2.4, 0, 0.3, 0.5, 0
         Prop.Line tM, -0.3, 0.5, 0, 0.3, 0.5, 0
         break
      case "slide"
         Prop.Line tM, -0.4, 0, 2, -0.4, 2, 2
         Prop.Line tM, 0.4, 0, 2, 0.4, 2, 2
         repeat with k = 1 to 5
            Prop.Line tM, -0.4, k * 0.4, 2, 0.4, k * 0.4, 2
         end repeat
         Prop.Line tM, -0.4, 2, 2, -0.4, 0.2, -1.5
         Prop.Line tM, 0.4, 2, 2, 0.4, 0.2, -1.5
         break
      case "crosshair"
         Prop.Ring tM, 0, 1, 0, 0.3, 16, "z"
         Prop.Line tM, -0.5, 1, 0, -0.1, 1, 0
         Prop.Line tM, 0.1, 1, 0, 0.5, 1, 0
         Prop.Line tM, 0, 0.5, 0, 0, 0.9, 0
         Prop.Line tM, 0, 1.1, 0, 0, 1.5, 0
         break
      case "powerup"
         Prop.Cone tM, 0, 1, 0, 0.3, 0.4, 4
         Prop.Cone tM, 0, 1, 0, 0.3, -0.4, 4
         break
      -- floors, walls, skies, signs
      case "grid_floor"
         repeat with k = 0 to 10
            Prop.Line tM, -10 + k * 2, 0, -10, -10 + k * 2, 0, 10
            Prop.Line tM, -10, 0, -10 + k * 2, 10, 0, -10 + k * 2
         end repeat
         break
      case "water_plane"
         repeat with k = 0 to 8
            repeat with a = 0 to 7
               Prop.Line tM, -10 + a * 2.5, 0, -10 + k * 2.5, -9 + a * 2.5, 0.1, -10 + k * 2.5
               Prop.Line tM, -9 + a * 2.5, 0.1, -10 + k * 2.5, -7.5 + a * 2.5, 0, -10 + k * 2.5
            end repeat
         end repeat
         break
      case "sand_plane"
         Prop.Rect tM, 0, 0, 0, 20, 20
         repeat with k = 0 to 5
            Prop.Line tM, -10, 0, -8 + k * 3, 10, 0, -7 + k * 3
         end repeat
         break
      case "wall_3m"
         Prop.Box tM, 0, 0, 0, 4, 3, 0.3
         break
      case "wall_12m"
         Prop.Box tM, 0, 0, 0, 6, 12, 0.6
         break
      case "broken_wall"
         Prop.Line tM, -2, 0, 0, -2, 3, 0
         Prop.Line tM, -2, 3, 0, -0.5, 3, 0
         Prop.Line tM, -0.5, 3, 0, 0, 2, 0
         Prop.Line tM, 0, 2, 0, 0.6, 2.4, 0
         Prop.Line tM, 0.6, 2.4, 0, 1.2, 1.2, 0
         Prop.Line tM, 1.2, 1.2, 0, 2, 1.5, 0
         Prop.Line tM, 2, 1.5, 0, 2, 0, 0
         Prop.Line tM, 2, 0, 0, -2, 0, 0
         break
      case "wood_fence"
         repeat with k = 0 to 6
            Prop.Line tM, -3 + k, 0, 0, -3 + k, 1.2, 0
            Prop.Line tM, -3 + k, 1.2, 0, -2.85 + k, 1.35, 0
         end repeat
         Prop.Line tM, -3, 0.3, 0, 3, 0.3, 0
         Prop.Line tM, -3, 0.9, 0, 3, 0.9, 0
         break
      case "night_sky"
         Prop.Dome tM, 60, 3
         repeat with k = 1 to 40
            put k * 2.39996 into a
            put 30 + (k mod 7) * 4 into tR
            Prop.Line tM, tR * cos(a), sqrt(max(0, 3600 - tR ^ 2)), tR * sin(a), tR * cos(a) + 0.6, sqrt(max(0, 3600 - tR ^ 2)), tR * sin(a)
         end repeat
         break
      case "desert_sky"
         Prop.Dome tM, 60, 2
         repeat with k = 0 to 23
            put k * 0.2618 into a
            Prop.Line tM, 58 * cos(a), 0, 58 * sin(a), 58 * cos(a + 0.2618), 3 + (k mod 3) * 2, 58 * sin(a + 0.2618)
         end repeat
         break
      case "sunset_sky"
         Prop.Dome tM, 60, 2
         Prop.Ring tM, 0, 6, 55, 5, 16, "z"
         repeat with k = 1 to 4
            Prop.Line tM, -40, 4 + k * 3, 52, 40, 4 + k * 3, 52
         end repeat
         break
      case "sign_board"
         Prop.Line tM, -0.8, 0, 0, -0.8, 2.6, 0
         Prop.Line tM, 0.8, 0, 0, 0.8, 2.6, 0
         Prop.Box tM, 0, 1.6, 0, 2, 1, 0.05
         break
      case "billboard"
         Prop.Line tM, -2, 0, 0, -2, 4, 0
         Prop.Line tM, 2, 0, 0, 2, 4, 0
         Prop.Box tM, 0, 4, 0, 8, 3, 0.1
         repeat with k = 1 to 3
            Prop.Line tM, -3.5, 4 + k * 0.75, -0.05, 3.5, 4 + k * 0.75, -0.05
         end repeat
         break
      default
         Prop.Box tM, 0, 0, 0, 1, 1, 1
   end switch
   delete variable tM["at"]
   return tM
end Prop.Make

-------------------------------------------------------------------- shapes the models are made of

-- a car body: width, length, body height, cabin height, wheel radius
on Prop.Car @pM, pW, pL, pBody, pCab, pWheel
   Prop.Box pM, 0, pWheel, 0, pW, pBody, pL
   Prop.Line pM, -pW / 2, pWheel + pBody, -pL * 0.15, -pW / 2.4, pWheel + pBody + pCab, -pL * 0.02
   Prop.Line pM, pW / 2, pWheel + pBody, -pL * 0.15, pW / 2.4, pWheel + pBody + pCab, -pL * 0.02
   Prop.Line pM, -pW / 2.4, pWheel + pBody + pCab, -pL * 0.02, pW / 2.4, pWheel + pBody + pCab, -pL * 0.02
   Prop.Line pM, -pW / 2.4, pWheel + pBody + pCab, -pL * 0.02, -pW / 2.4, pWheel + pBody + pCab, pL * 0.25
   Prop.Line pM, pW / 2.4, pWheel + pBody + pCab, -pL * 0.02, pW / 2.4, pWheel + pBody + pCab, pL * 0.25
   Prop.Line pM, -pW / 2.4, pWheel + pBody + pCab, pL * 0.25, pW / 2.4, pWheel + pBody + pCab, pL * 0.25
   Prop.Line pM, -pW / 2.4, pWheel + pBody + pCab, pL * 0.25, -pW / 2, pWheel + pBody, pL * 0.35
   Prop.Line pM, pW / 2.4, pWheel + pBody + pCab, pL * 0.25, pW / 2, pWheel + pBody, pL * 0.35
   Prop.Wheels pM, pW, pL, pWheel
end Prop.Car

on Prop.Wheels @pM, pW, pL, pR
   Prop.Ring pM, -pW / 2, pR, -pL * 0.32, pR, 8, "x"
   Prop.Ring pM, pW / 2, pR, -pL * 0.32, pR, 8, "x"
   Prop.Ring pM, -pW / 2, pR, pL * 0.32, pR, 8, "x"
   Prop.Ring pM, pW / 2, pR, pL * 0.32, pR, 8, "x"
end Prop.Wheels

-- a wing across x at height pY, centred on z pZ: span, chord
on Prop.Wing @pM, pX, pY, pZ, pSpan, pChord
   Prop.Line pM, pX - pSpan / 2, pY, pZ - pChord / 3, pX + pSpan / 2, pY, pZ - pChord / 3
   Prop.Line pM, pX - pSpan / 2, pY, pZ + pChord / 2, pX + pSpan / 2, pY, pZ + pChord / 2
   Prop.Line pM, pX - pSpan / 2, pY, pZ - pChord / 3, pX - pSpan / 2, pY, pZ + pChord / 2
   Prop.Line pM, pX + pSpan / 2, pY, pZ - pChord / 3, pX + pSpan / 2, pY, pZ + pChord / 2
end Prop.Wing

-- a long gun along x at 1 m: length, stock length, a magazine or not
on Prop.Gun @pM, pLen, pStock, pMag
   Prop.Line pM, -pLen / 2, 1.03, 0, pLen / 2, 1.03, 0
   Prop.Line pM, -pLen / 2 + pStock, 1, 0, pLen / 4, 1, 0
   Prop.Line pM, -pLen / 2, 0.95, 0, -pLen / 2 + pStock, 1, 0
   Prop.Line pM, -pLen / 2, 0.95, 0, -pLen / 2, 1.03, 0
   Prop.Line pM, -pLen / 2 + pStock + 0.05, 1, 0, -pLen / 2 + pStock, 0.9, 0
   if pMag then Prop.Line pM, -pLen / 2 + pStock + 0.2, 1, 0, -pLen / 2 + pStock + 0.24, 0.85, 0
end Prop.Gun

on Prop.Blade @pM, pLen, pWide
   Prop.Line pM, 0, 1, -pWide, pLen, 1, 0
   Prop.Line pM, 0, 1, pWide, pLen, 1, 0
   Prop.Line pM, 0, 1, -pWide, 0, 1, pWide
   Prop.Line pM, 0, 1, 0, -pLen / 5, 1, 0
end Prop.Blade

-- a four-legged animal: body length, leg height, body height; antlers or not
on Prop.Quadruped @pM, pL, pLeg, pBody, pAntlers
   Prop.Box pM, 0, pLeg, 0, pBody * 0.6, pBody, pL
   Prop.Line pM, -pBody * 0.25, 0, -pL * 0.4, -pBody * 0.25, pLeg, -pL * 0.4
   Prop.Line pM, pBody * 0.25, 0, -pL * 0.4, pBody * 0.25, pLeg, -pL * 0.4
   Prop.Line pM, -pBody * 0.25, 0, pL * 0.4, -pBody * 0.25, pLeg, pL * 0.4
   Prop.Line pM, pBody * 0.25, 0, pL * 0.4, pBody * 0.25, pLeg, pL * 0.4
   Prop.Line pM, 0, pLeg + pBody, -pL / 2, 0, pLeg + pBody * 1.8, -pL * 0.7
   Prop.Box pM, 0, pLeg + pBody * 1.6, -pL * 0.78, pBody * 0.3, pBody * 0.35, pBody * 0.6
   if pAntlers then
      Prop.Line pM, 0, pLeg + pBody * 1.95, -pL * 0.75, -0.4, pLeg + pBody * 2.8, -pL * 0.7
      Prop.Line pM, 0, pLeg + pBody * 1.95, -pL * 0.75, 0.4, pLeg + pBody * 2.8, -pL * 0.7
   end if
end Prop.Quadruped

-- stairs climbing toward -z: width, steps (0.25 m up, 0.3 m deep each)
on Prop.Steps @pM, pX, pZ, pW, pN
   local k
   repeat with k = 0 to pN - 1
      Prop.Box pM, pX, k * 0.25, pZ - k * 0.3, pW, 0.25, 0.3
   end repeat
end Prop.Steps

-- four legs under a top of pW x pD at height pH
on Prop.Legs @pM, pW, pD, pH
   Prop.Line pM, -pW / 2, 0, -pD / 2, -pW / 2, pH, -pD / 2
   Prop.Line pM, pW / 2, 0, -pD / 2, pW / 2, pH, -pD / 2
   Prop.Line pM, -pW / 2, 0, pD / 2, -pW / 2, pH, pD / 2
   Prop.Line pM, pW / 2, 0, pD / 2, pW / 2, pH, pD / 2
end Prop.Legs

-- an arch across x: width, height to the springing, depth
on Prop.Arch @pM, pX, pZ, pW, pH, pD
   local k, a, b
   Prop.Box pM, pX - pW / 2 - 0.3, 0, pZ, 0.6, pH, pD
   Prop.Box pM, pX + pW / 2 + 0.3, 0, pZ, 0.6, pH, pD
   repeat with k = 0 to 7
      put 3.14159 * k / 8 into a
      put 3.14159 * (k + 1) / 8 into b
      Prop.Line pM, pX + pW / 2 * cos(a), pH + pW / 2 * sin(a), pZ - pD / 2, pX + pW / 2 * cos(b), pH + pW / 2 * sin(b), pZ - pD / 2
      Prop.Line pM, pX + pW / 2 * cos(a), pH + pW / 2 * sin(a), pZ + pD / 2, pX + pW / 2 * cos(b), pH + pW / 2 * sin(b), pZ + pD / 2
      Prop.Line pM, pX + pW / 2 * cos(a), pH + pW / 2 * sin(a), pZ - pD / 2, pX + pW / 2 * cos(a), pH + pW / 2 * sin(a), pZ + pD / 2
   end repeat
end Prop.Arch

-- a rounded lump: radius, rings, and a seed that dents it the same way every time
on Prop.Blob @pM, pX, pY, pZ, pR, pN, pSeed
   local i, j, a, b, r1, r2
   repeat with i = 1 to pN - 1
      repeat with j = 0 to pN * 2 - 1
         put pR * (0.8 + 0.2 * sin(i * 3 + j * 1.7 + pSeed)) into r1
         put pR * (0.8 + 0.2 * sin(i * 3 + (j + 1) * 1.7 + pSeed)) into r2
         put 3.14159 * i / pN into a
         put 3.14159 * j / pN into b
         Prop.Line pM, pX + r1 * sin(a) * cos(b), pY + r1 * cos(a), pZ + r1 * sin(a) * sin(b), pX + r2 * sin(a) * cos(b + 3.14159 / pN), pY + r2 * cos(a), pZ + r2 * sin(a) * sin(b + 3.14159 / pN)
      end repeat
   end repeat
end Prop.Blob

-- a sky: a dome of rings and meridians, radius pR
on Prop.Dome @pM, pR, pStep
   local k, a
   repeat with k = 0 to 3
      put k * 0.35 into a
      Prop.Ring pM, 0, pR * sin(a), 0, pR * cos(a), 24, "y"
   end repeat
   repeat with k = 0 to 11 step pStep
      put k * 0.5236 into a
      Prop.Line pM, pR * cos(a), 0, pR * sin(a), 0.36 * pR * cos(a), 0.93 * pR, 0.36 * pR * sin(a)
   end repeat
end Prop.Dome

-------------------------------------------------------------------- the primitives (metres, y up)

-- a box standing on y pY (its foot), centred on x and z
on Prop.Box @pM, pX, pY, pZ, pW, pH, pD
   local x1, x2, z1, z2, y2
   put pX - pW / 2 into x1
   put pX + pW / 2 into x2
   put pZ - pD / 2 into z1
   put pZ + pD / 2 into z2
   put pY + pH into y2
   Prop.Line pM, x1, pY, z1, x2, pY, z1
   Prop.Line pM, x2, pY, z1, x2, pY, z2
   Prop.Line pM, x2, pY, z2, x1, pY, z2
   Prop.Line pM, x1, pY, z2, x1, pY, z1
   Prop.Line pM, x1, y2, z1, x2, y2, z1
   Prop.Line pM, x2, y2, z1, x2, y2, z2
   Prop.Line pM, x2, y2, z2, x1, y2, z2
   Prop.Line pM, x1, y2, z2, x1, y2, z1
   Prop.Line pM, x1, pY, z1, x1, y2, z1
   Prop.Line pM, x2, pY, z1, x2, y2, z1
   Prop.Line pM, x2, pY, z2, x2, y2, z2
   Prop.Line pM, x1, pY, z2, x1, y2, z2
end Prop.Box

-- a flat rectangle on the ground at height pY
on Prop.Rect @pM, pX, pY, pZ, pW, pD
   Prop.Line pM, pX - pW / 2, pY, pZ - pD / 2, pX + pW / 2, pY, pZ - pD / 2
   Prop.Line pM, pX + pW / 2, pY, pZ - pD / 2, pX + pW / 2, pY, pZ + pD / 2
   Prop.Line pM, pX + pW / 2, pY, pZ + pD / 2, pX - pW / 2, pY, pZ + pD / 2
   Prop.Line pM, pX - pW / 2, pY, pZ + pD / 2, pX - pW / 2, pY, pZ - pD / 2
end Prop.Rect

-- a circle of pN sides around the axis "x", "y" or "z"
on Prop.Ring @pM, pX, pY, pZ, pR, pN, pAxis
   local k, a, b
   repeat with k = 0 to pN - 1
      put 6.28318 * k / pN into a
      put 6.28318 * (k + 1) / pN into b
      switch pAxis
         case "x"
            Prop.Line pM, pX, pY + pR * cos(a), pZ + pR * sin(a), pX, pY + pR * cos(b), pZ + pR * sin(b)
            break
         case "z"
            Prop.Line pM, pX + pR * cos(a), pY + pR * sin(a), pZ, pX + pR * cos(b), pY + pR * sin(b), pZ
            break
         default
            Prop.Line pM, pX + pR * cos(a), pY, pZ + pR * sin(a), pX + pR * cos(b), pY, pZ + pR * sin(b)
      end switch
   end repeat
end Prop.Ring

-- a cylinder from its foot, pH long along y (default), or along x or z from pX / pZ
on Prop.Cyl @pM, pX, pY, pZ, pR, pH, pN, pAxis
   local k, a
   if pAxis is empty then put "y" into pAxis
   switch pAxis
      case "x"
         Prop.Ring pM, pX, pY, pZ, pR, pN, "x"
         Prop.Ring pM, pX + pH, pY, pZ, pR, pN, "x"
         repeat with k = 0 to pN - 1 step 2
            put 6.28318 * k / pN into a
            Prop.Line pM, pX, pY + pR * cos(a), pZ + pR * sin(a), pX + pH, pY + pR * cos(a), pZ + pR * sin(a)
         end repeat
         break
      case "z"
         Prop.Ring pM, pX, pY, pZ, pR, pN, "z"
         Prop.Ring pM, pX, pY, pZ + pH, pR, pN, "z"
         repeat with k = 0 to pN - 1 step 2
            put 6.28318 * k / pN into a
            Prop.Line pM, pX + pR * cos(a), pY + pR * sin(a), pZ, pX + pR * cos(a), pY + pR * sin(a), pZ + pH
         end repeat
         break
      default
         Prop.Ring pM, pX, pY, pZ, pR, pN, "y"
         Prop.Ring pM, pX, pY + pH, pZ, pR, pN, "y"
         repeat with k = 0 to pN - 1 step 2
            put 6.28318 * k / pN into a
            Prop.Line pM, pX + pR * cos(a), pY, pZ + pR * sin(a), pX + pR * cos(a), pY + pH, pZ + pR * sin(a)
         end repeat
   end switch
end Prop.Cyl

-- a cone from a ring at its foot to a point pH away (negative: pointing down / back)
on Prop.Cone @pM, pX, pY, pZ, pR, pH, pN, pAxis
   local k, a
   if pAxis is empty then put "y" into pAxis
   Prop.Ring pM, pX, pY, pZ, pR, pN, pAxis
   repeat with k = 0 to pN - 1
      put 6.28318 * k / pN into a
      switch pAxis
         case "x"
            Prop.Line pM, pX, pY + pR * cos(a), pZ + pR * sin(a), pX + pH, pY, pZ
            break
         case "z"
            Prop.Line pM, pX + pR * cos(a), pY + pR * sin(a), pZ, pX, pY, pZ + pH
            break
         default
            Prop.Line pM, pX + pR * cos(a), pY, pZ + pR * sin(a), pX, pY + pH, pZ
      end switch
   end repeat
end Prop.Cone

-- a sphere of rings (latitudes) and meridians around its centre
on Prop.Sphere @pM, pX, pY, pZ, pR, pN
   local k, a
   repeat with k = 1 to pN - 1
      put 3.14159 * k / pN into a
      Prop.Ring pM, pX, pY + pR * cos(a), pZ, pR * sin(a), pN * 2, "y"
   end repeat
   repeat with k = 0 to pN - 1
      put 3.14159 * k / pN into a
      Prop.Meridian pM, pX, pY, pZ, pR, a, pN * 2
   end repeat
end Prop.Sphere

on Prop.Meridian @pM, pX, pY, pZ, pR, pA, pN
   local k, a, b
   repeat with k = 0 to pN - 1
      put 6.28318 * k / pN into a
      put 6.28318 * (k + 1) / pN into b
      Prop.Line pM, pX + pR * sin(a) * cos(pA), pY + pR * cos(a), pZ + pR * sin(a) * sin(pA), pX + pR * sin(b) * cos(pA), pY + pR * cos(b), pZ + pR * sin(b) * sin(pA)
   end repeat
end Prop.Meridian

function Prop.NewMesh
   local tM
   put 0 into tM["count"]
   put empty into tM["faces"]
   put empty into tM["lines"]
   return tM
end Prop.NewMesh

-- a line between two points in metres (y up); engine units, y down; shared vertices
on Prop.Line @pM, pX1, pY1, pZ1, pX2, pY2, pZ2
   local tA, tB
   put Prop.Vertex(pM, pX1, pY1, pZ1) into tA
   put Prop.Vertex(pM, pX2, pY2, pZ2) into tB
   if tA is tB then exit Prop.Line
   if pM["lines"] is empty then
      put tA && tB into pM["lines"]
   else
      put cr & tA && tB after pM["lines"]
   end if
end Prop.Line

function Prop.Vertex @pM, pX, pY, pZ
   local tKey, tX, tY, tZ
   put round(pX * kM, 2) into tX
   put round(-pY * kM, 2) into tY
   put round(pZ * kM, 2) into tZ
   put tX & "," & tY & "," & tZ into tKey
   if pM["at"][tKey] is not empty then return pM["at"][tKey]
   add 1 to pM["count"]
   put tX into pM["vx"][pM["count"]]
   put tY into pM["vy"][pM["count"]]
   put tZ into pM["vz"][pM["count"]]
   put pM["count"] into pM["at"][tKey]
   return pM["count"]
end Prop.Vertex
