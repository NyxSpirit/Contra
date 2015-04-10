IFNDEF CONTRA_INC



WinMain		PROTO :DWORD, :DWORD, :DWORD, :DWORD 
UnicodeStr	PROTO :DWORD,:DWORD
StrConcat	PROTO :PTR BYTE,:PTR BYTE

DIRECTION_LEFT EQU 270
DIRECTION_RIGHT EQU 90
DIRECTION_UP EQU 0
DIRECTION_DOWN EQU 180


;=================================
Position STRUCT
	pos_x	DWORD	0;
	pos_y	DWORD	0;
Position ENDS
;=================================

;=================================
CollisionRect	STRUCT
	r_width		DWORD	0
	r_length	DWORD	0
	ALIGN		Position
	position	Position	<>
CollisionRect	ENDS
;=================================	

;=================================
Weapon	STRUCT
	;weapon type	B,M,L,R,S,F,
	w_type	DWORD	R;
Weapon	ENDS
;=================================

;=================================
Hero STRUCT
	;enemy:2,3,red_hero:1,bluehero:0
	identity	BYTE	0
	;action:0:standby,1:run,2:jump,3:lie,4:die,5:shoot,6:cancel shoot
	action		BYTE	0
	;0:FALSE,1:TRUE
	shoot		DWORD	0
	swim		DWORD	0
	life		DWORD	0
	weapon		Weapon	<>
	ALIGN		DWORD
	direction	DWORD	0
	ALIGN		Position
	position	Position	<>
	range		CollisionRect	<>
Hero ENDS
;=================================

;=================================
Bullet	STRUCT
	;bullet alliance 0:hero 1:enemy
	alliance	BYTE	0
	speed		BYTE	1
	ALIGN		Position
	position	Position	<>
	direction	Position	<>
	range		CollisionRect	<>
Bullet	ENDS
;=================================

;=================================
Ground	STRUCT
	position	Position	<>
	range	CollisionRect	<>
Ground	ENDS
;=================================

;=================================
Tower	STRUCT
	;tower type 0,1,2
	t_type	DWORD	0	
	shoot	DWORD	0
	life	DWORD	0
	ALIGN	DWORD
	direction	DWORD	0
	ALIGN		Position
	position	Position	<>
	range CollisionRect	<>
Tower	ENDS
;=================================

;=================================
Bridge	STRUCT
	bomb	BYTE	0
	ALIGN	Position
	position	Position	<>
	range	CollisionRect	<>
	
Bridge	ENDS
;=================================

.data
;============================== resources declarment=============\
 playerMoveRightFile db "Res\\player\\player_right",0
 IMAGETYPE_BMP db "bmp", 0  
 IMAGETYPE_PNG db "png", 0
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
 backgroundBackoff DWORD 0
 contra Hero <0,0,0,0,0,<0>,0,<0,0>,<0,0,<0,0>>>
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