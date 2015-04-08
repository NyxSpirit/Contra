IFNDEF CONTRA_INC



WinMain		PROTO :DWORD, :DWORD, :DWORD, :DWORD 
UnicodeStr	PROTO :DWORD,:DWORD
StrConcat	PROTO :PTR BYTE,:PTR BYTE

.data
;============================== resources declarment=============\
 playerMoveRightFile db "Res\\player\\player_right",0
 IMAGETYPE_BMP db "bmp", 0  
 IMAGeTYPE_PNG db "png", 0
 wallBGFile db "Res\\map\\map_wall1.bmp",0
 playerSwimShootRightFile db "Res\\player\\player_water_right1.bmp", 0
 playerSwimRightFile db "Res\\player\\player_water_right2.bmp", 0

;============================== Window Params =========
 ClassName db "WinClass", 0
 AppName db "Contra", 0 

PAGE_SCALE REAL4 0.1
 
;=============================== Game params ===========
 contraPosx SDWORD 0
 contraPosy SDWORD 200
 contraMoveDx SDWORD 0
 contraMoveDy SDWORD 0 
 contraShootDx SBYTE 0
 contraShootDy SBYTE 0
 contraJump BYTE 0
 contraCrawl BYTE 0
 contraMoveRight BYTE 0
 contraMoveLeft BYTE 0
 contraShoot BYTE 0
 contraSwim BYTE 0

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