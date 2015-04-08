.386      
    .model flat,stdcall      
    option casemap:none 

include masm32.inc
include contra_api.inc

.data
;data structure
;hero,background objects,foreground objects

;=================================
CollisionRect	STRUCT
	r_width		WORD	0
	r_length	WORD	0
CollisionRect	ENDS
;=================================

;=================================
Position STRUCT
	pos_X	WORD	0;
	pos_Y	WORD	0;
Position ENDS
;=================================
	
;=================================
Weapon	STRUCT
	;weapon type	B,M,L,R,S,F,
	w_type	BYTE	R;
Weapon	ENDS
;=================================

;=================================
Hero STRUCT
	;enemy:2,3,red_hero:1,bluehero:0
	identity	BYTE	0
	life		BYTE	0
	;action jump,run,stand by,die,lie
	action		BYTE	0
	;0:FALSE,1:TRUE
	shoot		BYTE	0
	ALIGN		Position
	position	Position	<>
	direction	Position	<>
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
	t_type	BYTE	0	
	shoot	BYTE	0
	life	BYTE	0
	ALIGN	Position
	position	Position	<>
	direction	Position	<>
	range CollisionRect	<>
Tower	ENDS
;=================================

;=================================
Bridge	STRUCT
	boom	BYTE	0
	ALIGN	Position
	position	Position	<>
	range	CollisionRect	<>
	
Bridge	ENDS
;=================================

.code
;=================================
CollisionJudge PROC

CollisionJudge ENDP


;=================================
InitMap		PROC

InitMap ENDP

;=================================
ResetStat	PROC

ResetStat ENDP

;=================================
Action		PROC

Action ENDP




END