script "WindowShape"
######################################################################################
## LIBRARY: "WindowShape"  (LIB_DEV/livecode, 16 Nov 2026, Opus; this copy: iGame3D XT/Tools, which
## carries its own tools. Change LIB_DEV/livecode/window_shape.livecodescript, then copy it here.)
## Any image can be a window's outline: where the image is transparent there is no window.
## After Scott Rossi's WindowLab (Tactile Media, www.tactilemedia.com; the owner's copy in
## LIB_LLMOUT/Read/Scott_Rossi_Window_Lab/windowlab.rev): the whole trick is
##     set the windowShape of stack S to the id of an image in S
## and, for a window with no title bar, moving it yourself (Shape.DragWindow).
##
##   start using stack "<path>/window_shape.livecodescript"
##   Shape.Make "MyStack", "oval", 300, 150         -- a ready-made outline: rect, round, oval
##   Shape.FromControl "MyStack", the long id of graphic "Star"   -- any control's picture
##   Shape.FromFile "MyStack", "/path/mask.png"     -- any image file (its alpha is the outline)
##   Shape.FromImage "MyStack", the id of image "Mask" of stack "MyStack"
##   Shape.PaintStart "MyStack"  ...brush and erase...  Shape.PaintEnd "MyStack"   (paint mode)
##   Shape.Clear "MyStack"                          -- the ordinary window again
##   in a control's script:  on mouseDown / Shape.DragWindow / end mouseDown
## The outline is the image "WindowMask" in the stack; the stack takes its size.
## Paint mode: the mask shows over a magenta ground; the brush paints window, the eraser
## (Shape.Eraser true) takes it away; Shape.PaintEnd makes it the outline.
## Tests: OXT-BEYOND/tests/t38_window_shape.txt (headless). Try it: window_shape_lab.livecodescript.
######################################################################################

constant kMask = "WindowMask"
constant kGround = "WindowMaskGround"

local sBrush, sEraser   -- paint mode: the brush size, the eraser on

-- pImageId (an image of pStack) becomes the outline; the stack is resized to it
command Shape.FromImage pStack, pImageId
   local tW, tH
   if there is not a stack pStack then return "no stack" && pStack
   if there is not an image id pImageId of stack pStack then return "no image" && pImageId && "in" && pStack
   put the width of image id pImageId of stack pStack into tW
   put the height of image id pImageId of stack pStack into tH
   lock screen
   set the topLeft of image id pImageId of stack pStack to 0, 0
   Shape.SizeTo pStack, tW, tH
   set the windowShape of stack pStack to pImageId
   unlock screen
   return empty
end Shape.FromImage

-- an image file (PNG or GIF with transparency) becomes the outline
command Shape.FromFile pStack, pFile
   local tData
   if there is not a file pFile then return "no file" && pFile
   put URL ("binfile:" & pFile) into tData
   Shape.SetMask pStack, tData
   if the result is not empty then return the result
   Shape.FromImage pStack, the id of image kMask of stack pStack
   return the result
end Shape.FromFile

-- any control's picture (a graphic, a group, a field...) becomes the outline: where nothing is
-- drawn, there is no window
command Shape.FromControl pStack, pControl
   local tData, tErr
   try
      export snapshot from pControl to tData as PNG
   catch tErr
      return "no picture of" && pControl & ":" && line 1 of tErr
   end try
   Shape.SetMask pStack, tData
   if the result is not empty then return the result
   Shape.FromImage pStack, the id of image kMask of stack pStack
   return the result
end Shape.FromControl

-- a ready-made outline: "rect", "round" (corner pRadius), "oval" (a circle when pW = pH)
command Shape.Make pStack, pKind, pW, pH, pRadius
   local tG, tWas
   if there is not a stack pStack then return "no stack" && pStack
   if pW is not a number or pW < 8 then put 200 into pW
   if pH is not a number or pH < 8 then put pW into pH
   if pRadius is not a number then put 24 into pRadius
   put the defaultStack into tWas
   set the defaultStack to pStack
   lock screen
   lock messages
   reset the templateGraphic
   create graphic "WindowShapeTemp" in card 1 of stack pStack
   put the long id of graphic "WindowShapeTemp" of card 1 of stack pStack into tG
   switch pKind
      case "oval"
      case "circle"
         set the style of tG to "oval"
         break
      case "round"
         set the style of tG to "roundrect"
         set the roundRadius of tG to pRadius
         break
      default
         set the style of tG to "rectangle"
   end switch
   set the filled of tG to true
   set the opaque of tG to true
   set the lineSize of tG to 0
   set the backgroundColor of tG to "white"
   set the rect of tG to 0, 0, pW, pH
   unlock messages
   Shape.FromControl pStack, tG
   delete tG
   unlock screen
   if there is a stack tWas then set the defaultStack to tWas
   return empty
end Shape.Make

-- the ordinary rectangular window again (the mask image stays, hidden)
command Shape.Clear pStack
   if there is not a stack pStack then exit Shape.Clear
   set the windowShape of stack pStack to 0
   if there is an image kMask of stack pStack then set the visible of image kMask of stack pStack to false
end Shape.Clear

-- the outline's image id, 0 when the window is ordinary
function Shape.Current pStack
   if there is not a stack pStack then return 0
   return the windowShape of stack pStack
end Shape.Current

-------------------------------------------------------------------- paint mode

-- paint the outline by hand: the mask shows over a magenta ground (white is window); the
-- brush is chosen while the mouse is over it (Shape.Eraser true: the eraser)
command Shape.PaintStart pStack, pW, pH
   local tWas, tErr
   if there is not a stack pStack then return "no stack" && pStack
   put the defaultStack into tWas
   set the defaultStack to pStack
   lock screen
   lock messages
   set the windowShape of stack pStack to 0
   if pW is not a number then put the width of stack pStack into pW
   if pH is not a number then put the height of stack pStack into pH
   if there is not a graphic kGround of card 1 of stack pStack then
      reset the templateGraphic
      create graphic kGround in card 1 of stack pStack
      set the style of graphic kGround of card 1 of stack pStack to "rectangle"
      set the opaque of graphic kGround of card 1 of stack pStack to true
      set the lineSize of graphic kGround of card 1 of stack pStack to 0
      set the backgroundColor of graphic kGround of card 1 of stack pStack to "#FF00FF"
   end if
   set the rect of graphic kGround of card 1 of stack pStack to 0, 0, pW, pH
   set the visible of graphic kGround of card 1 of stack pStack to true
   if there is not an image kMask of card 1 of stack pStack then
      reset the templateImage
      create image kMask in card 1 of stack pStack
   end if
   if the width of image kMask of card 1 of stack pStack is not pW or the height of image kMask of card 1 of stack pStack is not pH then
      set the rect of image kMask of card 1 of stack pStack to 0, 0, pW, pH
      Shape.PaintClear pStack
   end if
   set the topLeft of image kMask of card 1 of stack pStack to 0, 0
   set the layer of graphic kGround of card 1 of stack pStack to top
   set the layer of image kMask of card 1 of stack pStack to top
   set the visible of image kMask of card 1 of stack pStack to true
   set the script of image kMask of card 1 of stack pStack to "on mouseEnter" & cr & "   Shape.PaintTool" & cr & "end mouseEnter" & cr & \
         "on mouseLeave" & cr & "   choose browse tool" & cr & "end mouseLeave"
   if sBrush is empty then put 8 into sBrush
   try
      set the brushColor to "white"
      set the brush to sBrush
   catch tErr
      -- no paint tools (a run with no screen): nothing to set
   end try
   unlock messages
   unlock screen
   if there is a stack tWas then set the defaultStack to tWas
   return empty
end Shape.PaintStart

-- the paint tool for the mask (called as the mouse comes over it)
command Shape.PaintTool
   if sEraser is true then
      set the eraser to 3
      choose eraser tool
   else
      set the brushColor to "white"
      if sBrush is not empty then set the brush to sBrush
      choose brush tool
   end if
end Shape.PaintTool

-- the brush size (one of the engine's brushes, 1-35) and the eraser
command Shape.Brush pN
   if pN is a number then put pN into sBrush
end Shape.Brush

command Shape.Eraser pFlag
   put (pFlag is true) into sEraser
end Shape.Eraser

-- empty the painted mask (everything magenta again)
command Shape.PaintClear pStack
   local tW, tH
   if there is not an image kMask of stack pStack then exit Shape.PaintClear
   put the width of image kMask of stack pStack into tW
   put the height of image kMask of stack pStack into tH
   set the imageData of image kMask of stack pStack to Shape.AlphaFill(tW * tH * 4, 255)
   set the alphaData of image kMask of stack pStack to Shape.AlphaFill(tW * tH, 0)
end Shape.PaintClear

-- done painting: what was painted is the window
command Shape.PaintEnd pStack
   choose browse tool
   if there is not an image kMask of stack pStack then return "nothing painted"
   if there is a graphic kGround of stack pStack then set the visible of graphic kGround of stack pStack to false
   if Shape.Painted(pStack) is 0 then return "nothing painted"
   Shape.FromImage pStack, the id of image kMask of stack pStack
   return the result
end Shape.PaintEnd

-- how many pixels of the mask are window (alpha over half)
function Shape.Painted pStack
   local tA, tN, tB
   if there is not an image kMask of stack pStack then return 0
   put the alphaData of image kMask of stack pStack into tA
   put 0 into tN
   repeat for each byte tB in tA
      if byteToNum(tB) > 127 then add 1 to tN
   end repeat
   return tN
end Shape.Painted

-------------------------------------------------------------------- moving a window with no title bar

-- in a control's mouseDown: the window follows the mouse until it is let go
command Shape.DragWindow pStack
   local tStart, tTL, tX, tY
   if pStack is empty then put the short name of the topStack into pStack
   put the screenMouseLoc into tStart
   put the topLeft of stack pStack into tTL
   repeat while the mouse is down
      put item 1 of tTL + item 1 of the screenMouseLoc - item 1 of tStart into tX
      put item 2 of tTL + item 2 of the screenMouseLoc - item 2 of tStart into tY
      if (tX & comma & tY) is not the topLeft of stack pStack then set the topLeft of stack pStack to tX, tY
      wait 10 milliseconds with messages
   end repeat
end Shape.DragWindow

-------------------------------------------------------------------- helpers

-- the mask image of pStack holds pData (PNG / GIF bytes), at the top left, hidden (the
-- outline needs no picture on the card)
command Shape.SetMask pStack, pData
   if there is not a stack pStack then return "no stack" && pStack
   if pData is empty then return "no picture"
   lock messages
   if there is not an image kMask of card 1 of stack pStack then
      reset the templateImage
      create image kMask in card 1 of stack pStack
   end if
   set the text of image kMask of card 1 of stack pStack to pData
   set the topLeft of image kMask of card 1 of stack pStack to 0, 0
   set the visible of image kMask of card 1 of stack pStack to false
   unlock messages
   return empty
end Shape.SetMask

-- the stack the size of its outline, its top left kept
command Shape.SizeTo pStack, pW, pH
   local tL, tT
   put the left of stack pStack into tL
   put the top of stack pStack into tT
   set the rect of stack pStack to tL, tT, tL + pW, tT + pH
end Shape.SizeTo

function Shape.AlphaFill pCount, pValue
   local tOut
   put numToByte(pValue) into tOut
   repeat while the number of bytes of tOut * 2 <= pCount
      put tOut after tOut
   end repeat
   repeat while the number of bytes of tOut < pCount
      put numToByte(pValue) after tOut
   end repeat
   return tOut
end Shape.AlphaFill
