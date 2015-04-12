.386      
    .model flat,stdcall      
    option casemap:none 
	
include masm32.inc
include contra_api.inc


.data

.code

CollisionBackgroundJudge	PROC hero:PTR Hero,background:PTR BackGround
	;0:air,1:water,2:ground,3:bridge
	
	ret
CollisionBackgroundJudge	ENDP

;=================================
CollisionJudge PROC Rect1:PTR CollisionRect,
	Rect2:PTR CollisionRect

	LOCAL	r1_width:DWORD,r1_height:DWORD,r2_width:DWORD,r2_height:DWORD,
			r1_x:DWORD,r1_y:DWORD,r2_x:DWORD,r2_y:DWORD

	mov		eax,0
	mov		esi,Rect1
	mov		ebx,[esi].CollisionRect.r_width
	mov		r1_width,ebx
	mov		ebx,[esi].CollisionRect.r_height
	mov		r1_height,ebx
	mov		ebx,[esi].CollisionRect.position.pos_x
	mov		r1_x,ebx
	mov		ebx,[esi].CollisionRect.position.pos_y
	mov		r1_y,ebx

	mov		esi,Rect2
	mov		ebx,[esi].CollisionRect.r_width
	mov		r2_width,ebx
	mov		ebx,[esi].CollisionRect.r_height
	mov		r2_height,ebx
	mov		ebx,[esi].CollisionRect.position.pos_x
	mov		r2_x,ebx
	mov		ebx,[esi].CollisionRect.position.pos_y
	mov		r2_y,ebx
	
	mov		ecx,r1_x
	mov		edx,r2_x
	.if		ecx < edx
		mov	ebx,r2_x
		sub	ebx,r1_x
		.if	ebx < r1_width
			mov	ecx,r1_y
			mov	edx,r2_y
			.if	ecx < edx
				mov	ebx,r2_y
				sub	ebx,r1_y
				.if	ebx <r2_height
					mov	eax,1
					ret
				.else
					mov eax,0
					ret
				.endif
			.else
				mov ebx,r1_y
				sub ebx,r2_y
				.if	ebx <r1_height
					mov eax,1
					ret
				.else
					mov eax,0
					ret
				.endif
			.endif
		.else
			mov	eax,0
			ret
		.endif
	.else
		mov ebx,r1_x
		sub	ebx,r2_x
		.if	ebx < r1_width
			mov ecx,r1_y
			mov	edx,r2_y
			.if	ecx < edx
				mov	ebx,r2_y
				sub	ebx,r1_y
				.if	ebx <r2_height
					mov	eax,1
					ret
				.else
					mov eax,0
					ret
				.endif
			.else
				mov ebx,r1_y
				sub ebx,r2_y
				.if	ebx <r1_height
					mov eax,1
					ret
				.else
					mov eax,0
					ret
				.endif
			.endif
		.else
			mov	eax,0
			ret
		.endif
	.endif
				
	ret
CollisionJudge ENDP


;=================================
InitMap		PROC	
	
InitMap ENDP

;=================================
ResetStat	PROC

ResetStat ENDP

;===================================
CreateHero PROC hero:PTR Hero
	mov esi, hero
	mov [esi].Hero.position.pos_x, 0
	mov [esi].Hero.position.pos_y, 0
	mov [esi].Hero.action, HEROACTION_JUMP
	mov [esi].Hero.move_dx, 0
	mov [esi].Hero.move_dy, CONTRA_BASIC_JUMP_SPEED
	mov [esi].Hero.invincible_time, CONTRA_INVINCIBLE_TIME
	mov [esi].Hero.shoot, 0
	mov [esi].Hero.face_direction, DIRECTION_RIGHT
	mov [esi].Hero.shootdirection, DIRECTION_RIGHT
	;mov [esi].Hero.weapon, <>
	mov [esi].Hero.action_imageIndex, 0
	mov [esi].Hero.jump_height, MAX_JUMP_HEIGHT
	ret
CreateHero ENDP

;=================================
;command action:0:standby,1:run,2:jump,3:lie,4:die,5:shoot,6:cancel shoot
TakeAction		PROC	hero:PTR Hero,command:DWORD
	local formerAction: DWORD
	mov		esi,hero

	;cmd run
	mov eax, [esi].Hero.action
	mov formerAction, eax 

	.if formerAction == HEROACTION_DIE
		mov [esi].Hero.action_imageIndex, 0
		jmp @f
	.endif

	.if		command == CMD_MOVERIGHT
			.if formerAction == HEROACTION_DIVE
			.else
				mov [esi].Hero.move_dx, CONTRA_BASIC_MOV_SPEED
				mov [esi].Hero.face_direction, DIRECTION_RIGHT
				.if formerAction == HEROACTION_STAND || formerAction == HEROACTION_CRAWL
					mov [esi].Hero.action, HEROACTION_RUN
				.endif
			.endif
	.elseif command == CMD_MOVELEFT
			.if formerAction == HEROACTION_DIVE
			.else
				mov [esi].Hero.move_dx, -CONTRA_BASIC_MOV_SPEED
				mov [esi].Hero.face_direction, DIRECTION_LEFT
				.if formerAction == HEROACTION_STAND || formerAction == HEROACTION_CRAWL
					mov [esi].Hero.action, HEROACTION_RUN
				.endif
			.endif
	.elseif command == CMD_STAND
			mov [esi].Hero.move_dx, 0
			.if formerAction == HEROACTION_RUN
				mov [esi].Hero.action, HEROACTION_STAND
			.endif
	.elseif command == CMD_JUMP
			.if (formerAction == HEROACTION_STAND) 
				mov [esi].Hero.action, HEROACTION_JUMP
			.endif
			.if (formerAction ==HEROACTION_RUN)
				mov [esi].Hero.action, HEROACTION_JUMP
			.endif
			.if formerAction == HEROACTION_CRAWL
				mov [esi].Hero.move_dy, CONTRA_BASIC_JUMP_SPEED
				mov [esi].Hero.action, HEROACTION_FALL
			.endif
	.elseif command == CMD_DOWN
			.if formerAction == HEROACTION_SWIM
				mov [esi].Hero.action, HEROACTION_DIVE
			.elseif formerAction == HEROACTION_STAND
				mov [esi].Hero.action, HEROACTION_CRAWL
			.endif
	.elseif command == CMD_UP
	.elseif command == CMD_SHOOT
			mov [esi].Hero.shoot, 1
	.elseif command == CMD_CANCELSHOOT
			mov [esi].Hero.shoot, 0
	.elseif command == CMD_CANCELCRAWL
			.if formerAction == HEROACTION_CRAWL
				mov [esi].Hero.action, HEROACTION_STAND
			.elseif formerAction == HEROACTION_DIVE
				mov [esi].Hero.action, HEROACTION_SWIM
			.endif
	.endif

	mov eax, formerAction
	.if eax != [esi].Hero.action
		mov [esi].Hero.action_imageIndex, 0
		invoke UpdateHeroCollisionRect, hero
	.endif
@@:
	ret
TakeAction ENDP
;==================================

;==================================
;direction	angle 360:initial,0:up,45:up-right,90:right,180:down:270:left...
ChangeHeroDirection	PROC	hero:PTR Hero,direction:DWORD
	mov		esi,hero
	mov		eax,direction
	;mov		[esi].Hero.direction,eax
	ret
ChangeHeroDirection	ENDP
;==================================

;==================================
;stat:0:init,1:swim,
ChangeHeroStat	PROC	hero:PTR Hero,stat:DWORD
	mov		esi,hero
	mov		eax,stat
	ret
ChangeHeroStat	ENDP
;==================================

;==================================
SwitchWeapon	PROC	hero:PTR Hero,weapon:PTR Weapon
	mov		esi,hero
	mov		eax,weapon
	mov		ebx,[eax].Weapon.w_type
	mov		[esi].Hero.weapon,ebx

	ret
SwitchWeapon	ENDP
;==================================

;==================================
BridgeBomb	PROC	bridge:PTR Bridge
	mov		esi,bridge
	mov		[esi].Bridge.bomb,1
	ret
BridgeBomb	ENDP
;==================================

;==================================
ChangeTowerDirection	PROC	tower:PTR Tower,direction:DWORD
	mov		esi,tower
	mov		eax,direction
	mov		[esi].Tower.direction,eax
	ret	
ChangeTowerDirection	ENDP
;==================================

;==================================
;cmd  shoot:1,cancelshoot:0
TowerShoot		PROC		tower:PTR Tower,cmd:DWORD
	mov		esi,tower
	mov		eax,cmd
	mov		[esi].Tower.shoot,eax

	ret
TowerShoot		ENDP
;==================================

;==================================
TowerDamage	PROC		tower:PTR Tower
	mov		esi,tower
	mov		eax,[esi].Tower.life
	sub		eax,1
	mov		[esi].Tower.life,eax
	
	ret
TowerDamage	ENDP
;==================================

;==================================
ChangeBulletPosition	PROC	bullet:PTR Bullet,position:PTR Position
	mov		esi,bullet
	mov		eax,position
	mov		ebx,[eax].Position.pos_x
	mov		ecx,[eax].Position.pos_y
	mov		[esi].Bullet.position.pos_x,ebx
	mov		[esi].Bullet.position.pos_y,ecx
	ret
ChangeBulletPosition ENDP
;==================================

;==================================
ChangeBulletRect	PROC	bullet:PTR Bullet,rect:PTR	CollisionRect
	mov		esi,bullet
	mov		eax,rect

	mov		ebx,[eax].CollisionRect.position.pos_x
	mov		[esi].Bullet.range.position.pos_x,ebx

	mov		ebx,[eax].CollisionRect.position.pos_y
	mov		[esi].Bullet.range.position.pos_y,ebx

	mov		ebx,[eax].CollisionRect.r_width
	mov		[esi].Bullet.range.r_width,ebx

	mov		ebx,[eax].CollisionRect.r_height
	mov		[esi].Bullet.range.r_height,ebx

	ret
ChangeBulletRect	ENDP
;================================

;==================================
UpdateHeroPosition  PROC hero:PTR Hero
	mov		esi, hero

	mov eax, [esi].Hero.move_dx
	add [esi].Hero.position.pos_x, eax
	add [esi].Hero.range.position.pos_x, eax
	mov eax, [esi].Hero.move_dy
	add [esi].Hero.position.pos_y, eax
	add [esi].Hero.range.position.pos_y, eax

	ret
UpdateHeroPosition  ENDP  

;=======================================
UpdateHeroCollisionRect PROC hero: PTR Hero
	local rect: CollisionRect
	mov esi, hero
	.if [esi].Hero.action == HEROACTION_RUN
		mov rect.r_width, 30
		mov rect.r_height, 40
		mov eax, [esi].Hero.position.pos_x
		add eax, 10
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax, 10
		mov rect.position.pos_y, eax
	
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_JUMP
		mov rect.r_width, 20
		mov rect.r_height, 20
		mov eax, [esi].Hero.position.pos_x
		add eax, 10
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax, 10
		mov rect.position.pos_y, eax
	
		invoke ChangeHeroRect, hero, addr rect
	.else
	.endif
	ret	
UpdateHeroCollisionRect ENDP
ChangeHeroRect	PROC	hero:PTR Hero,rect:PTR	CollisionRect
	mov		esi,hero
	mov		eax,rect

	mov		ebx,[eax].CollisionRect.position.pos_x
	mov		[esi].Hero.range.position.pos_x,ebx

	mov		ebx,[eax].CollisionRect.position.pos_y
	mov		[esi].Hero.range.position.pos_y,ebx

	mov		ebx,[eax].CollisionRect.r_width
	mov		[esi].Hero.range.r_width,ebx

	mov		ebx,[eax].CollisionRect.r_height
	mov		[esi].Hero.range.r_height,ebx

	ret
ChangeHeroRect	ENDP
;================================


END