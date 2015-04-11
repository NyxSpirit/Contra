IFNDEF CONTRA_API_INC
.data
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
	hImage	DWORD     0
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