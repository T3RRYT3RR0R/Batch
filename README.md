# Batch
A collection of batch scripts

Fade.bat 
  An example script for sprite based batch games.
  Note: batch sprites are not bitmaps. They are realised using associated delayed variables
  Demonstrates:
   - transparency        ; by matching sprite Background color definition to screen background color definition
   - fading              ; by modifying definitions of sprite or screen color variables between frames
   - collision detextion ; Algorithm based Implemetation of bounding box based collison test
   - non blocking input  ; utilizing an embedded exe utility
   - frame rate control  ; utilizing an algorithm to calculate time elapsed

 Yahtzee.bat
   An implementation of the game yahtzee. includes an embedded exe BG.exe to facilitate mouse input.
