# iGame3D XT

Monday, November 16, 2026. The iGame3D editor remade in xTalk on the Vibecode3D engine, moved here
from LIB_GAMES on the owner's word (16 Nov): it is a tool, not a game. Shipping title
**iGame3D XT** (xRay on the xt3d core, Box2DXT / xRayBox with Box2D), on itch.io as xAction.
It is not in the game launcher (that one is for games only).

| Edition | Where | |
|---|---|---|
| We know it works | `main` here (= branch `ig3d-editor-works`) | as you ran it on 16 Nov: the 2008 Data folder and the LIB_MOCAP clips found on your PC |
| Standalone | branch `ig3d-editor-standalone` | nothing outside itself: template Data folder, generated models (Aquarius done); plan in `STANDALONE_PLAN.md` there |

- `Vibecode3D_Play_Ig3dEditor.livecodescript`: the editor (a Vibecode3D card script).
- `Tools/`: its tool windows (Inspector, Replace With Model, the drag preview), copied from
  LIB_ig3d branch `v3d-editor-tools`. This edition still opens them from LIB_ig3d; the
  standalone edition opens these copies.
- `_manifest_2008/`: Spark's survey of the 2008 Data folder (WTF index, glossary drafts), moved
  from LIB_GAMES. Its tools read the 2008 folder, which now lives only in git: LIB_GAMES commit
  5a62a5d (branch `ig3d-editor-works` there), `git -C ~/projects/LIB_GAMES archive 5a62a5d
  igame3D_2008_Texts | tar -x` brings it back.
