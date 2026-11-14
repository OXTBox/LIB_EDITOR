#!/usr/bin/env bash
# headless.sh - run an example card with no window: tests/headless.sh <Example> <Prefix> "<keys>:<steps> ..."
# e.g. tests/headless.sh E01_Blocks E01 "0:5"
# Uses LIB_GAMES' engine stand-ins (tools/engine_stubs.livecodescript on its spark-arcade branch)
# and LIB_MCP's standalone. Prints <Prefix>.State() after each key group, then the HUD.
HERE="$(cd "$(dirname "$0")" && pwd)"
EX="$1"; PRE="$2"; PLAN="$3"
STUBS="$HERE/_engine_stubs.livecodescript"
git -C "$HERE/../../LIB_GAMES" show spark-arcade:tools/engine_stubs.livecodescript > "$STUBS" || exit 1
W="//wsl\$/Ubuntu$HERE"
{
cat <<LC
if there is a stack "EditorExample" then delete stack "EditorExample"
create invisible stack "EditorExample"
put URL "file:$W/_engine_stubs.livecodescript" into tStub
delete line 1 of tStub
set the script of stack "EditorExample" to tStub
set the fileName of stack "EditorExample" to "$W/../examples/x.livecode"
set the script of card 1 of stack "EditorExample" to URL "file:$W/../examples/$EX.livecodescript"
put the result into tCompile
dispatch "$PRE.TestKeys" to card 1 of stack "EditorExample" with "0"
dispatch "Game.OnStart" to card 1 of stack "EditorExample"
dispatch function "$PRE.State" to card 1 of stack "EditorExample"
put "start: " & the result & cr into tLog
LC
for part in $PLAN; do
  keys="${part%%:*}"; steps="${part##*:}"
  cat <<LC
dispatch "$PRE.TestKeys" to card 1 of stack "EditorExample" with "$keys"
repeat $steps times
dispatch "Game.OnUpdate" to card 1 of stack "EditorExample"
end repeat
dispatch function "$PRE.State" to card 1 of stack "EditorExample"
put "$keys x$steps: " & the result & cr after tLog
LC
done
cat <<LC
dispatch function "Stub.HUD" to stack "EditorExample"
return "compile: " & tCompile & cr & tLog & the result
LC
} | "$HERE/../../LIB_MCP/tools/lcmcp" --standalone run -
