IFNDEF CONTRA_INC
include contra_api.inc


WinMain		PROTO :DWORD, :DWORD, :DWORD, :DWORD 
SoundProc   PROTO

UnicodeStr	PROTO :DWORD,:DWORD
StrConcat	PROTO :PTR BYTE,:PTR BYTE
LoadImageSeries PROTO : DWORD, : BYTE,  : DWORD,  : DWORD

PaintBackground PROTO :DWORD
PaintObjects PROTO :DWORD
PaintObject PROTO :DWORD, :DWORD

BACKGROUNDIMAGE_HEIGHT EQU 256
BACKGROUNDIMAGE_UNITWIDTH EQU 32
PLAYERIMAGE_HEIGHT EQU 40
PLAYERIMAGE_WIDTH EQU 50
DISPLAY_SCALE EQU 2

BACKGROUNDHEIGHT	EQU	16
BACKGROUNDWIDTH		EQU	20
BACKGROUNDTOTLEWIDTH		EQU	200

.data
;============================== resources declarment=============\
 playerMoveRightFile db "Res\\player\\player_right",0
 IMAGETYPE_BMP db "bmp", 0  
 IMAGETYPE_PNG db "png", 0
 wallBGFile db "Res\\map\\map_sample.png",0
 playerSwimShootRightFile db "Res\\player\\player_water_right1.png", 0
 playerSwimRightFile db "Res\\player\\player_water_right2.png", 0

;============================== Window Params =========
 ClassName db "WinClass", 0
 AppName db "Contra", 0 

PAGE_SCALE REAL4 0.1
 
;=============================== Game params ===========
 backgroundOffset SDWORD 0
 contra Hero <<0,128>,<0,0,<0,0>>,0,0,0,0,0,0,0,0,<0>,0,0,0,0>
 ;=============================  Window and View Handles ========
 hInstance HINSTANCE ?

 hPlayerMoveRightImage dd 7 dup (?)
 hPlayerSwimRightImage dd ?
 hPlayerSwimShootRightImage dd ?
 hPlayerImage dd ? 
 hWallBGImage dd ?
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