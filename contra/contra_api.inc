IFNDEF CONTRA_API_INC

DIRECTION_UP EQU 90
DIRECTION_RIGHT EQU 0
DIRECTION_DOWN EQU 270
DIRECTION_LEFT EQU 180

MAX_JUMP_HEIGHT EQU 80
CONTRA_BASIC_MOV_SPEED EQU 8
CONTRA_BASIC_JUMP_SPEED EQU 20
CONTRA_FLOAT_HEIGHT EQU 6
CONTRA_FLOAT_SPEED EQU 2
CONTRA_HEIGHT EQU 25
CONTRA_INVINCIBLE_TIME EQU 17

CONTRA_BULLET_INTERVAL EQU 2

BULLET_SPEED EQU 25

CMD_MOVERIGHT EQU 1
CMD_MOVELEFT EQU 2
CMD_JUMP EQU 3
CMD_DOWN EQU 4
CMD_SHOOT EQU 5
CMD_CANCELSHOOT EQU 6     
CMD_CANCELCRAWL EQU 7
CMD_STAND EQU 8
CMD_UP EQU 9
CMD_SWIM EQU 10

BACKGROUNDHEIGHT	EQU	16
BACKGROUNDSCREENWIDTH		EQU	16
BACKGROUNDTOTALWIDTH		EQU	109

BACKGROUNDIMAGE_HEIGHT EQU 256
BACKGROUNDIMAGE_UNITHEIGHT EQU 32
BACKGROUNDIMAGE_UNITWIDTH EQU 64
PLAYERIMAGE_HEIGHT EQU 40
PLAYERIMAGE_WIDTH EQU 50
SCREEN_HEIGHT EQU 487
SCREEN_WIDTH EQU 520
;=======================================data
;data structure
;hero,background objects,foreground objects
;=================================
Position STRUCT
	pos_x	SDWORD	0;
	pos_y	SDWORD	0;
Position ENDS
;=================================

;=================================
CollisionRect	STRUCT
	r_width		DWORD	0 
	r_height	DWORD	0
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
HEROACTION_STAND EQU 0
HEROACTION_RUN EQU 2
HEROACTION_JUMP EQU 3
HEROACTION_CRAWL EQU 4
HEROACTION_DIE EQU 5
;HEROACTION_SHOOT EQU 6
HEROACTION_DIVE EQU 7
HEROACTION_FALL EQU 8
HEROACTION_SWIM EQU 9


Hero STRUCT
	position	Position	<>
	ALIGN		CollisionRect
	range		CollisionRect	<>
	hImage		DWORD     0
		;enemy:2,3,red_hero:1,bluehero:0
	identity	BYTE	0
		;action:0:standby,1:run,2:jump,3:lie,4:die....
	action		DWORD	0
	action_imageIndex DWORD 0
		;0:FALSE,1:TRUE
	shoot		DWORD	0
	life		DWORD	0
	jump_height DWORD   0
	
	invincible_time  DWORD   0

	weapon		Weapon	<>
	shoot_dx	SDWORD	0
	shoot_dy	SDWORD	0
	face_direction	DWORD	0
	move_dx		SDWORD 0
	move_dy		SDWORD 0 
	
Hero ENDS
;=================================
ALLIANCE_PLAYER EQU 0
ALLIANCE_ENEMY EQU 1
;=================================
Bullet	STRUCT
	position	Position	<>
	ALIGN		CollisionRect
	range		CollisionRect	<>
	hImage		DWORD     0
	ALIGN		Position	
	move_dx		SDWORD    0
	move_dy		SDWORD	  0
Bullet	ENDS
;=================================
;=================================
MAX_BULLETS_NUMBER EQU  20

Bullets  STRUCT
	number 		DWORD	0
	;alliance	BYTE    ALLIANCE_PLAYER
	bullets     Bullet  MAX_BULLETS_NUMBER dup (<>)
Bullets  ENDS
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

BGTYPE_GROUND EQU 1
BGTYPE_WATER EQU 2
BGTYPE_AIR EQU 0
BGTYPE_BRIDGE EQU 3

Background	STRUCT
	b_offset SDWORD 0
	b_array		BYTE 	BACKGROUNDTOTALWIDTH * BACKGROUNDHEIGHT DUP(0)
Background	ENDS
;=================================

CollisionJudge	PROTO	:PTR CollisionRect,	:PTR CollisionRect
CollisionBackgroundJudge PROTO :PTR Hero,:PTR BackGround

InitMap			PROTO	:PTR Background
ResetStat		PROTO

TakeAction			PROTO	:PTR Hero,:DWORD

ChangeHeroDirection	PROTO :PTR Hero,:DWORD
ChangeHeroRect  PROTO   :PTR Hero,:PTR	CollisionRect
ChangeHeroStat	PROTO	:PTR Hero,:DWORD
SwitchWeapon	PROTO	:PTR Hero,:PTR Weapon
CreateHero PROTO :PTR Hero
UpdateHeroCollisionRect PROTO :PTR Hero
UpdateHeroPosition PROTO :PTR Hero
UpdateHeroAction PROTO :PTR Hero, :DWORD

CreateBullet		PROTO   :PTR Bullets,:PTR Hero, :DWORD
DeleteBullet        PROTO   :PTR Bullets,:DWORD
ChangeBulletPosition	PROTO	:PTR Bullet,:PTR Position
ChangeBulletRect	PROTO	:PTR Bullet,:PTR	CollisionRect

ChangeTowerDirection	PROTO	:PTR Tower,:DWORD
TowerShoot		PROTO	:PTR Tower,:DWORD
TowerDamage		PROTO	:PTR Tower

BridgeBomb		PROTO	:PTR Bridge
ENDIF