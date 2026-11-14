#!/usr/bin/env bash
# e13_test.sh - E13 Walk The Map with no window: places the hero around the sample map and walks.
#   tests/e13_test.sh        prints one line a scene: cell | height (hu) | effect | ...  then PASS / FAIL
# Uses the same engine stand-ins as headless.sh (LIB_GAMES spark-arcade) and LIB_MCP's standalone.
# It checks the rules (where the hero ends, at what height, which effect); it draws nothing.
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then sed -n 2,5p "$0"; exit 0; fi
HERE="$(cd "$(dirname "$0")" && pwd)"
STUBS="$HERE/_engine_stubs.livecodescript"
git -C "$HERE/../../LIB_GAMES" show spark-arcade:tools/engine_stubs.livecodescript > "$STUBS" || exit 1
W="//wsl\$/Ubuntu$HERE"
scene() {   # name col row yawDegrees keys steps expected-prefix
cat <<LC
dispatch "E13.TestPlace" to card 1 of stack "EditorExample" with $2, $3, $4
dispatch "E13.TestKeys" to card 1 of stack "EditorExample" with "$5"
repeat $6 times
dispatch "Game.OnUpdate" to card 1 of stack "EditorExample"
end repeat
dispatch function "E13.State" to card 1 of stack "EditorExample"
put the result into tS
if tS begins with "$7" then
put "ok    $1: " & tS & cr after tLog
else
put "FAIL  $1: " & tS & "   (wanted $7)" & cr after tLog
put false into tAll
end if
LC
}
OUT=$({
cat <<LC
if there is a stack "EditorExample" then delete stack "EditorExample"
create invisible stack "EditorExample"
put URL "file:$W/_engine_stubs.livecodescript" into tStub
delete line 1 of tStub
set the script of stack "EditorExample" to tStub
set the fileName of stack "EditorExample" to "$W/../examples/x.livecode"
set the script of card 1 of stack "EditorExample" to URL "file:$W/../examples/E13_WalkTheMap.livecodescript"
put true into tAll
dispatch "E13.TestKeys" to card 1 of stack "EditorExample" with "0"
put the milliseconds into tT
dispatch "Game.OnStart" to card 1 of stack "EditorExample"
dispatch function "E13.State" to card 1 of stack "EditorExample"
put "start (" & (the milliseconds - tT) & " ms): " & the result & cr into tLog
LC
scene "stands still on the start cell"            12 10 0   "0" 5             "12,10|y 1|start|idle"
scene "west down the pool steps to the bottom"    10 13 270 "119,65505" 200   "7,13|y -59|swim"
scene "east up the steps and out of the pool"     7 13 90   "119,65505" 265   "12,13|y 1|path"
scene "east up the dais to the goal"              12 13 90  "119,65505" 105   "15,13|y 47|goal"
scene "the yard wall stops the hero"              22 10 90  "119,65505" 60    "23,10|y 1|path|idle"
scene "the tower wall stops the hero"             21 9 0    "119,65505" 150   "21,7|y 1|path|idle"
scene "through the tower door"                    20 9 0    "119,65505" 110   "20,6|y 1|path"
scene "the teleporter sends the hero to a cloud"  21 5 0    "119,65505" 30    "15,4|y 231|path"
scene "off the cloud's edge: falls to the yard"   15 4 "180, true" "119,65505" 90 "15,7|y 7|"
scene "the roofed maze hallway, out to the yard"  2 6 90    "119,65505" 290   "10,6|y 1|path"
cat <<LC
dispatch "E13.TestKeys" to card 1 of stack "EditorExample" with "114"
dispatch "Game.OnUpdate" to card 1 of stack "EditorExample"
dispatch function "E13.State" to card 1 of stack "EditorExample"
put "R (relief off): " & the result & cr after tLog
if "860 lines" is not in the result then put false into tAll
dispatch "E13.TestKeys" to card 1 of stack "EditorExample" with "109"
dispatch "Game.OnUpdate" to card 1 of stack "EditorExample"
dispatch function "E13.State" to card 1 of stack "EditorExample"
put "M (next map, version 1 file): " & the result & cr after tLog
if "amazing_couple" is not in the result then put false into tAll
LC
scene "amazing_couple: south down the first hall" 2 2 180   "119,65505" 80    "2,"
cat <<LC
put the milliseconds into tT
dispatch "E13.TestKeys" to card 1 of stack "EditorExample" with "119"
repeat 100 times
dispatch "Game.OnUpdate" to card 1 of stack "EditorExample"
end repeat
put "100 steps of game rules: " & (the milliseconds - tT) / 100 & " ms a step" & cr after tLog
dispatch function "Stub.HUD" to stack "EditorExample"
put the result after tLog
if tAll then
return tLog & "PASS"
else
return tLog & "FAIL"
end if
LC
} | "$HERE/../../LIB_MCP/tools/lcmcp" --standalone run -)
echo "$OUT"
case "$OUT" in *PASS) exit 0;; *) exit 1;; esac
