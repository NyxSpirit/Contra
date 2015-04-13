.386      
    .model flat,stdcall      
    option casemap:none 
	
include masm32.inc
include contra_api.inc


.data

.code

;================================
CollisionBulletJudge	PROC hero:PTR Hero,bullets:PTR Bullets
	ret
CollisionBulletJudge    ENDP
;================================
CollisionBackgroundJudge	PROC hero:PTR Hero,background:PTR BackGround

	LOCAL	rect_down:CollisionRect,rect_right:CollisionRect,rect_left:CollisionRect,
			x:SDWORD,y:SDWORD,position:SDWORD,img_width:DWORD,img_height:DWORD,fall_speed:DWORD
	;0:air,1:water,2:ground,3:bridge
	
	mov		esi,hero
	.if		[esi].Hero.move_dy < 0
			ret
	.endif
	mov		img_width,BACKGROUNDIMAGE_UNITWIDTH
	mov		img_height,BACKGROUNDIMAGE_UNITHEIGHT
	mov		fall_speed,CONTRA_BASIC_JUMP_SPEED
	
	mov		eax,[esi].Hero.range.position.pos_x
	add		eax,32	;half of image width
	mov		ebx,[esi].Hero.range.position.pos_y
	add		ebx,96	;contra image height
	mov		ecx,background	

	;down block
	mov		edx,0
	sub		eax,[ecx].Background.b_offset
	div		img_width
	.if	edx	> 0
		;inc		eax
	.endif
	mov		x,eax

	mov		edx,0
	mov		eax,ebx
	div		img_height
	mov		y,eax

	mov		eax,BACKGROUNDTOTALWIDTH
	mul		y
	add		eax,x
	mov		position,eax

	mov		ecx,background
	mov		eax,position
	mov		bl,[ecx].Background.b_array[eax]

	.if		ebx >= 500 && bl == 0
			invoke UpdateHeroAction, hero, HEROACTION_DIE
			mov	[esi].Hero.move_dx,0
			mov	[esi].Hero.move_dy,0
			ret
	.endif	

	.if		bl == BGTYPE_AIR
		.if	[esi].Hero.move_dy == 0
			invoke UpdateHeroAction, hero, HEROACTION_FALL
			mov	eax,fall_speed
			mov	[esi].Hero.move_dy,eax
			ret
		.endif
	.elseif	bl == BGTYPE_WATER
		.if	[esi].Hero.move_dy == 0
			invoke UpdateHeroAction, hero, HEROACTION_FALL
			mov	eax,fall_speed
			mov	[esi].Hero.move_dy,eax
			ret
		.endif
	.elseif	bl == BGTYPE_GROUND	
		.if	[esi].Hero.move_dy > 0
			invoke UpdateHeroAction, hero, HEROACTION_STAND
			mov	[esi].Hero.move_dy,0
			ret
		.endif
	.elseif	bl == BGTYPE_BRIDGE
		.if	[esi].Hero.move_dy > 0
			invoke UpdateHeroAction, hero, HEROACTION_STAND
			mov	[esi].Hero.move_dy,0
			ret
		.endif
	.endif

	mov		ecx,background
	mov		eax,position
	sub		eax,BACKGROUNDTOTALWIDTH
	mov		bl,[ecx].Background.b_array[eax]
	.if	bl == BGTYPE_WATER			
			invoke UpdateHeroAction, hero, HEROACTION_SWIM	
			mov	[esi].Hero.move_dy,0				
	.elseif bl == BGTYPE_GROUND						
			;invoke UpdateHeroAction, hero,HEROACTION_STAND
			;mov	[esi].Hero.move_dy,-20
	.endif
	ret
CollisionBackgroundJudge	ENDP
;================================

;=================================
CollisionJudge PROC USES esi ebx,
	Rect1:PTR CollisionRect,
	Rect2:PTR CollisionRect 

	LOCAL	r1_width:DWORD,r1_height:DWORD,r2_width:DWORD,r2_height:DWORD,
			r1_x:SDWORD,r1_y:SDWORD,r2_x:SDWORD,r2_y:SDWORD

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
	.if		r1_x < edx
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
		mov	ebx,r1_x
		sub	ebx,r2_x
		.if	ebx < r2_width
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
FillMap		PROC	background:PTR Background, h:DWORD, l:DWORD, r:DWORD, t:BYTE
	mov  ebx, h
	imul ebx,BACKGROUNDTOTALWIDTH
	add  ebx, l
	dec  ebx
	mov  ecx, r
	sub  ecx, l
	inc  ecx
	mov	 edx, background
	lea  esi, [edx].Background.b_array[ebx]
	mov  bl, t

FillMapLoop:
	mov [esi], bl
	;mov al, [esi]
	inc esi
	loop FillMapLoop

	ret
FillMap ENDP

InitMap		PROC	background:PTR Background
	mov esi,background
	mov	[esi].Background.b_offset,-32
	invoke FillMap, background, 12, 1, 56, BGTYPE_WATER
	invoke FillMap, background, 6, 2, 15, BGTYPE_GROUND
	invoke FillMap, background, 8, 6, 8, BGTYPE_GROUND
	invoke FillMap, background, 10, 9, 9, BGTYPE_GROUND
	invoke FillMap, background, 12, 10, 11, BGTYPE_GROUND
	invoke FillMap, background, 10, 12, 12, BGTYPE_GROUND
	invoke FillMap, background, 10, 14, 15, BGTYPE_GROUND
	invoke FillMap, background, 6, 16, 30, BGTYPE_GROUND
	invoke FillMap, background, 12, 20, 21, BGTYPE_GROUND
	invoke FillMap, background, 9, 21, 23, BGTYPE_GROUND
	invoke FillMap, background, 6, 25, 28, BGTYPE_BRIDGE
	invoke FillMap, background, 6, 31, 45, BGTYPE_GROUND
	invoke FillMap, background, 12, 45, 45, BGTYPE_GROUND
	invoke FillMap, background, 4, 44, 45, BGTYPE_GROUND
	invoke FillMap, background, 6, 34, 37, BGTYPE_BRIDGE
	invoke FillMap, background, 4, 46, 60, BGTYPE_GROUND
	invoke FillMap, background, 12, 46, 47, BGTYPE_GROUND
	invoke FillMap, background, 9, 48, 49, BGTYPE_GROUND
	invoke FillMap, background, 8, 51, 58, BGTYPE_GROUND
	invoke FillMap, background, 12, 55, 60, BGTYPE_GROUND
	invoke FillMap, background, 6, 60, 60, BGTYPE_GROUND
	invoke FillMap, background, 6, 61, 66, BGTYPE_GROUND
	invoke FillMap, background, 4, 66, 70, BGTYPE_GROUND
	invoke FillMap, background, 12, 61, 61, BGTYPE_GROUND
	invoke FillMap, background, 10, 62, 63, BGTYPE_GROUND
	invoke FillMap, background, 10, 65, 66, BGTYPE_GROUND
	invoke FillMap, background, 9, 68, 68, BGTYPE_GROUND
	invoke FillMap, background, 8, 70, 72, BGTYPE_GROUND
	invoke FillMap, background, 6, 72, 73, BGTYPE_GROUND
	invoke FillMap, background, 8, 75, 75, BGTYPE_GROUND
	invoke FillMap, background, 12, 75, 75, BGTYPE_GROUND
	invoke FillMap, background, 8, 76, 76, BGTYPE_GROUND
	invoke FillMap, background, 10, 76, 78, BGTYPE_GROUND
	invoke FillMap, background, 6, 79, 80, BGTYPE_GROUND
	invoke FillMap, background, 4, 80, 81, BGTYPE_GROUND
	invoke FillMap, background, 9, 81, 81, BGTYPE_GROUND
	invoke FillMap, background, 12, 80, 80, BGTYPE_GROUND
	invoke FillMap, background, 6, 83, 84, BGTYPE_GROUND
	invoke FillMap, background, 8, 84, 88, BGTYPE_GROUND
	invoke FillMap, background, 12, 87, 89, BGTYPE_GROUND
	invoke FillMap, background, 10, 91, 92, BGTYPE_GROUND
	invoke FillMap, background, 8, 94, 95, BGTYPE_GROUND
	invoke FillMap, background, 6, 96, 99, BGTYPE_GROUND
	invoke FillMap, background, 9, 97, 99, BGTYPE_GROUND
	invoke FillMap, background, 8, 100, 100, BGTYPE_GROUND
	invoke FillMap, background, 10, 101, 101, BGTYPE_GROUND
	invoke FillMap, background, 12, 96, 109, BGTYPE_GROUND

	ret
InitMap ENDP

InitEvents PROC events:PTR Events
	mov esi, events
	mov [esi].Events.number, 1
	
	mov eax, [esi].Events.number
	mov bl, TYPE Event
	mul bl
	lea edi, [esi].Events.events[eax]

	mov [edi].Event.e_type, EVENTTYPE_CREATEROBOT
	mov [edi].Event.actor, 0
	mov [edi].Event.clock_limit, 0
	mov [edi].Event.location_limit, 0
	
	ret
	
InitEvents ENDP
;=================================
ResetStat	PROC

ResetStat ENDP

;===================================
InitContra PROC hero:PTR Hero
	mov esi, hero
	mov [esi].Hero.position.pos_x, 0
	mov [esi].Hero.position.pos_y, 0
	mov [esi].Hero.action, HEROACTION_JUMP
	mov [esi].Hero.move_dx, 0
	mov [esi].Hero.move_dy, CONTRA_BASIC_JUMP_SPEED
	mov [esi].Hero.invincible_time, CONTRA_INVINCIBLE_TIME
	mov [esi].Hero.shoot, 0
	mov [esi].Hero.face_direction, DIRECTION_RIGHT
	mov [esi].Hero.shoot_dx, BULLET_SPEED
	mov [esi].Hero.shoot_dy, 0
	;mov [esi].Hero.weapon, <>
	mov [esi].Hero.action_imageIndex, 0
	mov [esi].Hero.jump_height, MAX_JUMP_HEIGHT
	invoke UpdateHeroCollisionRect, hero
	ret
InitContra ENDP

;==================================
CreateRobot PROC robots:PTR Robots, posx:DWORD, posy:DWORD
	local cnt:DWORD

	mov esi, robots
	mov eax, [esi].Robots.number
	inc [esi].Robots.number
	mov bl, TYPE Hero
	mul bl
	lea esi, [esi].Robots.robots[eax]
	
	mov [esi].Hero.position.pos_x, 400
	mov [esi].Hero.position.pos_y, 400
	mov [esi].Hero.action, HEROACTION_STAND
	mov [esi].Hero.move_dx, 0
	mov [esi].Hero.move_dy, 0
	mov [esi].Hero.invincible_time, 0
	mov [esi].Hero.shoot, 0
	mov [esi].Hero.face_direction, DIRECTION_LEFT
	mov [esi].Hero.shoot_dx, -BULLET_SPEED
	mov [esi].Hero.shoot_dy, 0
	;mov [esi].Hero.weapon, <>
	mov [esi].Hero.action_imageIndex, 0
	mov [esi].Hero.jump_height, 0
	mov [esi].Hero.life, 1
	invoke UpdateHeroCollisionRect, esi
	ret
CreateRobot ENDP
;=================================
DeleteRobot PROC	robots:PTR Robots, index :DWORD
	ret
DeleteRobot	ENDP
;=================================
;command action:0:standby,1:run,2:jump,3:lie,4:die,5:shoot,6:cancel shoot
TakeAction		PROC	hero:PTR Hero,command:DWORD
	local formerAction: DWORD
	local newAction:DWORD
	mov		esi,hero
	;cmd run
	mov eax, [esi].Hero.action
	mov formerAction, eax 
	mov   newAction, eax
	.if formerAction == HEROACTION_DIE
		jmp @f
	.endif

	.if		command == CMD_MOVERIGHT

			.if formerAction == HEROACTION_DIVE
			.else
				mov [esi].Hero.move_dx, CONTRA_BASIC_MOV_SPEED
				mov [esi].Hero.face_direction, DIRECTION_RIGHT
				.if formerAction == HEROACTION_STAND || formerAction == HEROACTION_CRAWL
					mov newAction, HEROACTION_RUN
				.endif
			.endif
	.elseif command == CMD_MOVELEFT

			.if formerAction == HEROACTION_DIVE
			.else
				mov [esi].Hero.move_dx, -CONTRA_BASIC_MOV_SPEED
				mov [esi].Hero.face_direction, DIRECTION_LEFT
				.if formerAction == HEROACTION_STAND || formerAction == HEROACTION_CRAWL
					mov newAction, HEROACTION_RUN
				.endif
			.endif
	.elseif command == CMD_STAND
			mov [esi].Hero.move_dx, 0
			.if formerAction == HEROACTION_RUN
				mov newAction, HEROACTION_STAND
			.endif
	.elseif command == CMD_JUMP
			.if (formerAction == HEROACTION_STAND) 
				mov newAction, HEROACTION_JUMP
			.endif
			.if (formerAction ==HEROACTION_RUN)
				mov newAction, HEROACTION_JUMP
			.endif
			.if formerAction == HEROACTION_CRAWL
				mov [esi].Hero.move_dy, CONTRA_BASIC_JUMP_SPEED
				mov newAction, HEROACTION_FALL
			.endif
	.elseif command == CMD_DOWN
			.if formerAction == HEROACTION_SWIM
				mov newAction, HEROACTION_DIVE
			.elseif formerAction == HEROACTION_STAND
				mov newAction, HEROACTION_CRAWL
			.endif
	.elseif command == CMD_UP
	.elseif command == CMD_SHOOT
			.if formerAction == HEROACTION_RUN || formerAction == HEROACTION_STAND
				
				mov [esi].Hero.shoot, 1
			.elseif formerAction == HEROACTION_JUMP || formerAction == HEROACTION_FALL
				mov [esi].Hero.shoot, 1
			.elseif formerAction == HEROACTION_CRAWL
				mov [esi].Hero.shoot_dy, 0
				.if [esi].Hero.face_direction == DIRECTION_RIGHT
					mov [esi].Hero.shoot_dx, BULLET_SPEED
				.else 
					mov [esi].Hero.shoot_dx, -BULLET_SPEED
				.endif
				mov [esi].Hero.shoot, 1
			.elseif formerAction == HEROACTION_SWIM
				mov [esi].Hero.shoot, 1
			.endif

	.elseif command == CMD_CANCELSHOOT
			mov [esi].Hero.shoot, 0
	.elseif command == CMD_CANCELCRAWL
			.if formerAction == HEROACTION_CRAWL
				mov newAction, HEROACTION_STAND
			.elseif formerAction == HEROACTION_DIVE
				mov newAction, HEROACTION_SWIM
			.endif
	.endif

	invoke UpdateHeroAction, hero, newAction
	
@@:
	ret
TakeAction ENDP
;==================================
;==================================
UpdateHeroAction PROC hero:PTR Hero, newAction: DWORD
	mov eax, newAction
	.if eax != [esi].Hero.action
		.if newAction == HEROACTION_FALL
			add [esi].Hero.position.pos_y, 12
		.endif
		mov [esi].Hero.action, eax
		mov [esi].Hero.action_imageIndex, 0
		invoke UpdateHeroCollisionRect, hero
		mov [esi].Hero.jump_height, 0

	.endif

	ret
UpdateHeroAction ENDP
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
	ret	
ChangeTowerDirection	ENDP
;==================================

;==================================
;cmd  shoot:1,cancelshoot:0
TowerShoot		PROC		tower:PTR Tower,cmd:DWORD
	mov		esi,tower
	mov		eax,cmd

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
CreateBullet  PROC bullets:PTR Bullets,hero:PTR Hero, hImage: DWORD
	local shootOffsetX: SDWORD
	local shootOffsetY: SDWORD

	mov esi, bullets
	.if [esi].Bullets.number >= MAX_BULLETS_NUMBER
		ret
	.endif
	mov eax, [esi].Bullets.number 
	inc [esi].Bullets.number	
	mov bl, TYPE Bullet
	mul bl
	lea esi, [esi].Bullets.bullets[eax]
	 
	mov edi, hero

	mov eax, [edi].Hero.shoot_dx
	mov [esi].Bullet.move_dx, eax
	;shl eax, 1
	mov shootOffsetX, eax
	
	mov eax, [edi].Hero.shoot_dy
	mov [esi].Bullet.move_dy, eax
	;shl eax, 1
	mov shootOffsetY, eax

	; shoot from the middle of collision rect
	;				plus basic speed vector 
	mov eax, [edi].Hero.range.r_width
	shr eax, 1
	add eax, [edi].Hero.range.position.pos_x
	add eax, shootOffsetX
	mov [esi].Bullet.position.pos_x, eax
	mov [esi].Bullet.range.position.pos_x, eax

	mov eax, [edi].Hero.range.r_height
	shr eax, 1
	add eax, [edi].Hero.range.position.pos_y
	add eax, shootOffsetY
	mov [esi].Bullet.position.pos_y, eax
	mov [esi].Bullet.range.position.pos_y, eax
	
	mov [esi].Bullet.range.r_height, 1
	mov [esi].Bullet.range.r_width, 1

	mov eax, hImage
	mov [esi].Bullet.hImage, eax 
	ret
CreateBullet  ENDP

;==================================

;==================================
DeleteBullet  PROC bullets:PTR Bullets,index:DWORD
	local num : DWORD
	mov esi, bullets

	mov eax, [esi].Bullets.number
	mov num, eax

	mov ecx, num
	sub ecx, index
	mov eax, TYPE Bullet
	mul cx
	mov ecx, eax

	mov ebx, index
	mov eax, TYPE Bullet
	mul bx
	lea edi, [esi].Bullets.bullets[eax]
	add eax, TYPE Bullet
	lea esi, [esi].Bullets.bullets[eax]
	rep movsb
	
	mov esi, bullets
	dec [esi].Bullets.number

	ret
DeleteBullet  ENDP
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
		mov rect.r_width,  30
		mov rect.r_height, 40
		mov eax, [esi].Hero.position.pos_x
		add eax,          10
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          10
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_STAND
		mov rect.r_width,  30
		mov rect.r_height, 40
		mov eax, [esi].Hero.position.pos_x
		add eax,          10
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          10
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_JUMP
		mov rect.r_width,  30
		mov rect.r_height, 40
		mov eax, [esi].Hero.position.pos_x
		add eax,          10
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          10
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_FALL
		mov rect.r_width,  30
		mov rect.r_height, 40
		mov eax, [esi].Hero.position.pos_x
		add eax,          10
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          10
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_DIE
		mov rect.r_width,  30
		mov rect.r_height, 40
		mov eax, [esi].Hero.position.pos_x
		add eax,          10
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          10
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_DIVE
		mov rect.r_width,  30
		mov rect.r_height, 40
		mov eax, [esi].Hero.position.pos_x
		add eax,          10
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          10
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_SWIM
		mov rect.r_width,  30
		mov rect.r_height, 40
		mov eax, [esi].Hero.position.pos_x
		add eax,          10
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          10
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_CRAWL
		mov rect.r_width,  30
		mov rect.r_height, 40
		mov eax, [esi].Hero.position.pos_x
		add eax,          10
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          10
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

END
