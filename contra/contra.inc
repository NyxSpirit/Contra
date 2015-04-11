IFNDEF CONTRA_INC



WinMain		PROTO :DWORD, :DWORD, :DWORD, :DWORD 
SoundProc   PROTO

UnicodeStr	PROTO :DWORD,:DWORD
StrConcat	PROTO :PTR BYTE,:PTR BYTE
LoadImageSeries PROTO : DWORD, : BYTE,  : DWORD,  : DWORD

PaintBackground PROTO :DWORD
PaintObjects PROTO :DWORD

BACKGROUNDIMAGE_HEIGHT EQU 256
BACKGROUNDIMAGE_UNITWIDTH EQU 32
PLAYERIMAGE_HEIGHT EQU 40
PLAYERIMAGE_WIDTH EQU 50
DISPLAY_SCALE EQU 2


DIRECTION_UP EQU 0
DIRECTION_RIGHT EQU 90
DIRECTION_DOWN EQU 180
DIRECTION_LEFT EQU 270

BACKGROUNDHEIGHT	EQU	16
BACKGROUNDWIDTH		EQU	20
BACKGROUNDTOTLEWIDTH		EQU	200

;=================================
Position STRUCT
	pos_x	SDWORD	0;
	pos_y	SDWORD	0;
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
;Hero,Tower,Bullet,Ground,Bridge
Object	STRUCT
	position	Position	<>
	ALIGN	CollisionRect
	collision_rect	CollisionRect	<>
	hImage	DWORD     0
Object	ENDS
;=================================

;=================================
Weapon	STRUCT
	;weapon type	B,M,L,R,S,F,
	w_type	DWORD	R;
Weapon	ENDS
;=================================

;=================================
Hero STRUCT
	position	Position	<>
	ALIGN		CollisionRect
	range		CollisionRect	<>
	hImage		DWORD     0
		;enemy:2,3,red_hero:1,bluehero:0
	identity	BYTE	0
		;action:0:standby,1:run,2:jump,3:lie,4:die,5:shoot,6:cancel shoot
		;action		BYTE	0
		;0:FALSE,1:TRUE
	shoot		DWORD	0
	swim		DWORD	0
	jump		DWORD	0
	fall		DWORD	0
	crawl		DWORD	0
	life		DWORD	0
	weapon		Weapon	<>
	shootdirection	DWORD	0
	movedirection	DWORD	0
	move_dx		SDWORD 0
	move_dy		SDWORD 0 
Hero ENDS
;=================================

;=================================
Bullet	STRUCT
	position	Position	<>
	ALIGN		CollisionRect
	range		CollisionRect	<>
	hImage		DWORD     0
	;bullet alliance 0:hero 1:enemy
	alliance	BYTE	0
	speed		BYTE	1
	ALIGN		Position	
	direction	DWORD	0
Bullet	ENDS
;=================================

;=================================
Ground	STRUCT
	position	Position	<>
	ALIGN		CollisionRect
	range	CollisionRect	<>
	hImage	DWORD     0
Ground	ENDS
;=================================

;=================================
Tower	STRUCT
	position	Position	<>
	ALIGN		CollisionRect
	range	CollisionRect	<>
	hImage	DWORD     0
	;tower type 0,1,2
	t_type	DWORD	0	
	shoot	DWORD	0
	life	DWORD	0
	ALIGN	DWORD
	direction	DWORD	0
Tower	ENDS
;=================================

;=================================
Bridge	STRUCT
	position	Position	<>
	ALIGN	CollisionRect
	range	CollisionRect	<>
	hImage	DWORD     0
	bomb	BYTE	0	
Bridge	ENDS
;=================================

;=================================
BackGround	STRUCT
	b_totle_width	DWORD	BACKGROUNDTOTLEWIDTH
	b_width		DWORD	BACKGROUNDWIDTH
	b_height	DWORD	BACKGROUNDHEIGHT
	b_array		DWORD	BACKGROUNDTOTLEWIDTH * BACKGROUNDHEIGHT DUP(0)
BackGround	ENDS
;=================================

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
 contra Hero <<0,128>,<0,0,<0,0>>,0,0,0,0,0,0,<0>,0>
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