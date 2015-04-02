TITLE DATA STRUCTURE	(datastruct.asm)

;data structure
;hero,background objects,foreground objects

;----------------------------
CollisionRect	STRUCT
	width	WORD	0
	length	WORD	0
CollisionRect	ENDS
;----------------------------

;----------------------------
Position STRUCT
	pos_X	WORD	0;
	pos_Y	WORD	0;
Position ENDS
;----------------------------
	
;----------------------------
Weapon	STRUCT
	;weapon type	B,M,L,R,S,F,
	type	BYTE	R;
Weapon	ENDS
;----------------------------

;----------------------------
Hero STRUCT
	;enemy:2,3,red_hero:1,bluehero:0
	identity	BYTE	0	
	position	Position	?
	direction	Position	?
	life		BYTE	0
	;action jump,run,stand by,die,lie
	action		BYTE	0
	;0:FALSE,1:TRUE
	shoot		BYTE	0
	range		CollisionRect	?
Hero ENDS
;----------------------------

;----------------------------
Bullet	STRUCT
	;bullet alliance 0:hero 1:enemy
	alliance	BYTE	0
	position	Position	?
	direction	Position	?
	speed	BYTE	1
	range	CollisionRect	?
Bullet	ENDS
;----------------------------

;----------------------------
Ground	STRUCT
	position	Position	?
	range	CollisionRect	?
Ground	ENDS
;----------------------------

;----------------------------
Tower	STRUCT
	;tower type 0,1,2
	type	BYTE	0;
	range CollisionRect	?
	shoot	BYTE	0
	life	BYTE	0
	position	Position	?
	direction	Position	?
Tower	ENDS
;----------------------------

;----------------------------
Bridge	STRUCT
	position	Position	?
	range	CollisionRect	?
	boom	BYTE	0
Bridge	EDNS
;----------------------------

;----------------------------
