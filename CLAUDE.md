# LIB_EDITOR: notes for AI models
- Read ../LIB_SYSTEM/LIB_ALPHA.md first. The owner's ethos: form follows function; small tools.
- Every example is ONE method: a Vibecode3D card script in examples/, a <Prefix>.State function,
  <Prefix>.TestKeys, and a headless run (tests/headless.sh). Keep it as small as it can be.
- Map data only through ../LIB_BIT/editor/livecode/lib_cellmap.livecodescript (.cellmap files).
- `repeat while`, not stepped `repeat with` (LiveCode 9.6.3 overshoots).
