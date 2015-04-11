IFNDEF CONTRA_API_INC

CMD_MOVERIGHT EQU 1
CMD_MOVELEFT EQU 2
CMD_JUMP EQU 3
CMD_CRAWL EQU 4
CMD_SHOOT EQU 5
CMD_CANCELSHOOT EQU 6
CMD_CANCELCRAWL EQU 7
CMD_STAND EQU 8
CMD_UP EQU 9

DIRECTION_UP EQU 0
DIRECTION_RIGHT EQU 90
DIRECTION_DOWN EQU 180
DIRECTION_LEFT EQU 270

MAX_JUMP_HEIGHT EQU 80
CONTRA_BASIC_MOV_SPEED EQU 5
CONTRA_BASIC_JUMP_SPEED EQU 15
CONTRA_FLOAT_HEIGHT EQU 6
CONTRA_FLOAT_SPEED EQU 2
CONTRA_HEIGHT EQU 25
.data
;data structure
;hero,background objects,foreground objects
BACKGROUNDHEIGHT	EQU	16
BACKGROUNDWIDTH		EQU	20
BACKGROUNDTOTALWIDTH		EQU	200

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
	;weapon type	0:B,1:M,2:L,3:R,4:S,5:F,
	w_type	DWORD	0;
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
	;0:none,1:grass,...
	b_total_width	DWORD	BACKGROUNDTOTALWIDTH
	b_width		DWORD	BACKGROUNDWIDTH
	b_height	DWORD	BACKGROUNDHEIGHT
	b_array		DWORD	BACKGROUNDTOTALWIDTH * BACKGROUNDHEIGHT DUP(0)
BackGround	ENDS
;=================================
.code
CollisionJudge	PROTO	:PTR CollisionRect,	:PTR CollisionRect
InitMap			PROTO
ResetStat		PROTO
TakeAction			PROTO	:PTR Hero,:DWORD
ChangeHeroDirection	PROTO :PTR Hero,:DWORD
ChangeHeroStat	PROTO	:PTR Hero,:DWORD
SwitchWeapon	PROTO	:PTR Hero,:PTR Weapon
BridgeBomb		PROTO	:PTR Bridge
ChangeTowerDirection	PROTO	:PTR Tower,:DWORD
TowerShoot		PROTO	:PTR Tower,:DWORD
TowerDamage		PROTO	:PTR Tower
ChangeBulletPosition	PROTO	:PTR Bullet,:PTR Position
ChangeBulletRect	PROTO	:PTR Bullet,:PTR	CollisionRect


ENDIF