IFNDEF CONTRA_INC
include contra_api.inc

WinMain		PROTO :DWORD, :DWORD, :DWORD, :DWORD 
SoundProc   PROTO

UnicodeStr	PROTO :DWORD,:DWORD
StrConcat	PROTO :PTR BYTE,:PTR BYTE
LoadImageSeries PROTO : DWORD, : BYTE,  : DWORD,  : DWORD
LoadImageResources PROTO 
PaintBackground PROTO :DWORD
PaintObjects PROTO :DWORD
PaintObject PROTO :DWORD, :DWORD

ContraTakeAction PROTO


DISPLAY_SCALE EQU 2


IDR_WAVE1 EQU 104
.data
;============================== resources declarment=============\

 IMAGETYPE_BMP db "bmp", 0  
 IMAGETYPE_PNG db "png", 0
 
 backgroundFile db "Res\\map\\map_stage1.bmp",0

 playerMoveRightFiles db "Res\\player\\player_right",0
 playerMoveLeftFiles db "Res\\player\\player_left", 0
 playerJumpRightFiles db "Res\\player\\player_jump_right", 0
 playerJumpLeftFiles db "Res\\player\\player_jump_left", 0
 playerDieRightFiles db "Res\\player\\player_die_right", 0
 playerDieLeftFiles db "Res\\player\\player_die_left", 0
 playerStandRightFile db "Res\\player\\player_left1_face.png", 0
 playerStandLeftFile db "Res\\player\\player_stand_left.png", 0
 playerCrawlRightFile db "Res\\player\\player_down_right.png", 0
 playerCrawlLeftFile db "Res\\player\\player_down_left.png", 0
 playerSwimShootRightFile db "Res\\player\\player_water_right1.png", 0
 playerSwimRightFile db "Res\\player\\player_water_right2.png", 0
 playerSwimLeftFile db "Res\\player\\player_water_left2.png", 0
 playerFallRightFile db "Res\\player\\player_fall_right.png", 0
 playerFallLeftFile db "Res\\player\\player_fall_left.png", 0
 playerDiveFile db "Res\\player\\player_dive.png", 0
;============================== Window Params =========
 ClassName db "WinClass", 0
 AppName db "Contra", 0 

;PAGE_SCALE REAL4 0.1
;=============================== Game params ===========
 contra Hero <<0,100>,<0,0,<0,0>>,0,0,0,0,0,0,0,0,<0>,0,0,0,0>
 background Background <>
 ;=============================  Window and View Handles ========
 hInstance HINSTANCE ?
 
 hBackgroundImage dd ?

 hPlayerCrawlRightImage dd ?
 hPlayerCrawlLeftImage dd ?
 hPlayerStandRightImage dd ?
 hPlayerStandLeftImage dd ?
 hPlayerSwimLeftImage dd ?
 hPlayerSwimRightImage dd ?
 hPlayerSwimShootRightImage dd ?
 hPlayerFallRightImage dd ?
 hPlayerFallLeftImage dd ?
 hPlayerDiveImage dd ?

 hPlayerMoveRightImages dd 6 dup (?)
 hPlayerMoveLeftImages dd 6 dup (?)
 hPlayerJumpRightImages dd 4 dup (?)
 hPlayerJumpLeftImages dd 4 dup (?)
 hPlayerDieRightImages dd 7 dup (?)
 hPlayerDieLeftImages dd 7 dup (?)
 hMusic dd ?

 ;==============  Thread Handles
 dwThreadID DWORD ?
 hBGMThread DWORD ?
 hRunThread DWORD ?
 ;==============  Others
 keyState BYTE 256 dup (?)
 token DWORD ?
 startupinput GdiplusStartupInput<?>


 ENDIF