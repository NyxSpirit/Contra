IFNDEF CONTRA_API_INC
.data
;data structure
;hero,background objects,foreground objects

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

.code
CollisionJudge	PROTO	:PTR CollisionRect,	:PTR CollisionRect
InitMap			PROTO
ResetStat		PROTO
Action			PROTO	:PTR Hero,:DWORD
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