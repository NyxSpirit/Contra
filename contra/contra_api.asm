.386      
    .model flat,stdcall      
    option casemap:none 
	
include masm32.inc
include contra_api.inc


.data

.code
;================================
CollisionEnemyJudge		PROC hero:PTR Hero,robots:PTR Robots
	Local	robot:PTR Hero,robotnumber:DWORD,herorect:CollisionRect,c_offset:DWORD,index:DWORD
	pusha
	mov esi,hero
	mov ebx,robots
	mov	eax,[ebx].Robots.number
	mov	robotnumber,eax

	.if robotnumber <= 0
		ret
	.endif

	lea edi,[ebx].Robots.robots
	mov	c_offset,TYPE Hero

	mov index,0
L1:
	invoke CollisionJudge,addr [esi].Hero.range,addr [edi].Hero.range
	.if	eax == 1
		invoke UpdateHeroAction,hero,HEROACTION_DIE 
	.endif
	add	edi,c_offset
	inc index
	mov	eax,index
	.if eax >= robotnumber
		jmp quit
	.endif
	jmp L1
quit:
	popa
	ret
CollisionEnemyJudge		ENDP
;================================

;================================
CollisionBulletJudge	PROC hero:PTR Hero,bullets:PTR Bullets
	Local	bullet:PTR Bullet,bulletnumber:DWORD,herorect:CollisionRect,c_offset:DWORD,index:DWORD
	
	pusha
	mov esi,hero
	mov	ebx,bullets
	mov	eax,[ebx].Bullets.number
	mov	bulletnumber,eax
	
	.if	bulletnumber <= 0
		ret
	.endif
	
	lea	edi,[ebx].Bullets.bullets
	mov	c_offset,TYPE Bullet

	mov index,0
L1:
	invoke CollisionJudge,addr [esi].Hero.range,addr [edi].Bullet.range
	.if	eax == 1
		invoke UpdateHeroAction,hero,HEROACTION_DIE 
		invoke DeleteBullet,bullets,index
	.endif
	add	edi,c_offset
	inc index
	mov	eax,index
	.if eax >= bulletnumber
		jmp quit
	.endif
	jmp L1
quit:
	popa
	ret
CollisionBulletJudge    ENDP
;================================
CollisionBackgroundJudge	PROC hero:PTR Hero,background:PTR BackGround

	LOCAL	rect_down:CollisionRect,rect_right:CollisionRect,rect_left:CollisionRect,
			x:SDWORD,y:SDWORD,position:SDWORD,img_width:DWORD,img_height:DWORD,fall_speed:DWORD,divisor:DWORD
	;0:air,1:water,2:ground,3:bridge
	
	mov		esi,hero
	.if		[esi].Hero.move_dy < 0
			ret
	.endif
	mov		img_width,BACKGROUNDIMAGE_UNITWIDTH
	mov		img_height,BACKGROUNDIMAGE_UNITHEIGHT
	mov		fall_speed,CONTRA_BASIC_JUMP_SPEED
	
	mov		edx,0
	mov		eax,[esi].Hero.range.r_width
	mov		divisor,2
	div		divisor
	add		eax,[esi].Hero.range.position.pos_x	;half of image width

	mov		ebx,[esi].Hero.range.position.pos_y
	add		ebx,[esi].Hero.range.r_height	;contra image height
	mov		ecx,background	

	;down block
	mov		edx,0
	sub		eax,[ecx].Background.b_offset
	div		img_width
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

	.if		ebx >= 410 && bl == 0
			invoke UpdateHeroAction, hero, HEROACTION_DIE
			mov	[esi].Hero.position.pos_y,350
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
			mov	eax,img_height
			mul	y
			sub eax,95
			mov	[esi].Hero.position.pos_y,eax
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
	.endif

	mov		ecx,background
	mov		eax,position
	sub		eax,BACKGROUNDTOTALWIDTH
	add		eax,1
	mov		bl,[ecx].Background.b_array[eax]
	sub		eax,2
	mov		cl,[ecx].Background.b_array[eax]
	.if	[esi].Hero.action == HEROACTION_SWIM
		.if	[esi].Hero.move_dx > 0
			.if	bl == BGTYPE_GROUND
				add	[esi].Hero.position.pos_y,-25
				add	[esi].Hero.position.pos_x,15
				invoke UpdateHeroAction, hero, HEROACTION_STAND					
			.endif
		.elseif	[esi].Hero.move_dx < 0
			.if	cl == BGTYPE_GROUND
				add	[esi].Hero.position.pos_y,-25
				add	[esi].Hero.position.pos_x,-15
				invoke UpdateHeroAction, hero, HEROACTION_STAND
			.endif
		.else
		.endif
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
				.if	ebx <r1_height
					mov	eax,1
					ret
				.else
					mov eax,0
					ret
				.endif
			.else
				mov ebx,r1_y
				sub ebx,r2_y
				.if	ebx <r2_height
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

InitMap		PROC	USES esi,
	background:PTR Background
	mov esi,background
	mov	[esi].Background.b_offset,-32
	invoke FillMap, background, 12, 1, 56, BGTYPE_WATER
	invoke FillMap, background, 6, 2, 15, BGTYPE_GROUND
	invoke FillMap, background, 8, 6, 8, BGTYPE_GROUND
	invoke FillMap, background, 10, 9, 9, BGTYPE_GROUND
	invoke FillMap, background, 12, 10, 11, BGTYPE_GROUND
	invoke FillMap, background, 10, 12, 12, BGTYPE_GROUND
	invoke FillMap, background, 8, 14, 15, BGTYPE_GROUND
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

InitEvents PROC USES esi edi,events:PTR Events
	mov esi, events
	lea edi, [esi].Events.events

	mov [edi].Event.e_type, EVENTTYPE_CREATETOWER
	mov [edi].Event.actor, 0
	mov [edi].Event.clock_limit, 0
	mov [edi].Event.location_limit, 120
	mov [edi].Event.position.pos_x, 520
	mov [edi].Event.position.pos_y, 200
	inc [esi].Events.number
	add edi, TYPE Event

	mov [edi].Event.e_type, EVENTTYPE_CREATESTATICROBOT
	mov [edi].Event.actor, 0
	mov [edi].Event.clock_limit, 0
	mov [edi].Event.location_limit, 1280-520
	mov [edi].Event.position.pos_x, 520
	mov [edi].Event.position.pos_y, 200
	inc [esi].Events.number
	add edi, TYPE Event
	mov [edi].Event.e_type, EVENTTYPE_CREATESTATICROBOT
	mov [edi].Event.actor, 0
	mov [edi].Event.clock_limit, 0
	mov [edi].Event.location_limit, 2496-520
	mov [edi].Event.position.pos_x, 520
	mov [edi].Event.position.pos_y, 100
	inc [esi].Events.number
	add edi, TYPE Event
	mov [edi].Event.e_type, EVENTTYPE_CREATESTATICROBOT
	mov [edi].Event.actor, 0
	mov [edi].Event.clock_limit, 0
	mov [edi].Event.location_limit, 2688 - 520
	mov [edi].Event.position.pos_x, 520
	mov [edi].Event.position.pos_y, 100
	inc [esi].Events.number
	add edi, TYPE Event
	mov [edi].Event.e_type, EVENTTYPE_CREATESTATICROBOT
	mov [edi].Event.actor, 0
	mov [edi].Event.clock_limit, 0
	mov [edi].Event.location_limit, 3072-520
	mov [edi].Event.position.pos_x, 520
	mov [edi].Event.position.pos_y, 0
	inc [esi].Events.number
	add edi, TYPE Event
	mov [edi].Event.e_type, EVENTTYPE_CREATESTATICROBOT
	mov [edi].Event.actor, 0
	mov [edi].Event.clock_limit, 0
	mov [edi].Event.location_limit, 4800-520
	mov [edi].Event.position.pos_x, 520
	mov [edi].Event.position.pos_y, 100
	inc [esi].Events.number
	add edi, TYPE Event

	mov [edi].Event.e_type, EVENTTYPE_CREATETOWER
	mov [edi].Event.actor, 0
	mov [edi].Event.clock_limit, 0
	mov [edi].Event.location_limit, 700-520
	mov [edi].Event.position.pos_x, 520
	mov [edi].Event.position.pos_y, 200
	inc [esi].Events.number
	add edi, TYPE Event
	mov [edi].Event.e_type, EVENTTYPE_CREATETOWER
	mov [edi].Event.actor, 0
	mov [edi].Event.clock_limit, 0
	mov [edi].Event.location_limit, 900-520
	mov [edi].Event.position.pos_x, 520
	mov [edi].Event.position.pos_y, 300
	inc [esi].Events.number
	add edi, TYPE Event

	
	ret
	
InitEvents ENDP
;=================================
ResetStat	PROC

ResetStat ENDP

;===================================
InitContra PROC USES esi,
	 hero:PTR Hero
	mov esi, hero
	mov [esi].Hero.position.pos_x, -2
	mov [esi].Hero.position.pos_y, 0
	mov [esi].Hero.action, HEROACTION_JUMP
	mov [esi].Hero.move_dx, 0
	mov [esi].Hero.move_dy, CONTRA_BASIC_JUMP_SPEED
	mov [esi].Hero.invincible_time, CONTRA_INVINCIBLE_TIME
	mov [esi].Hero.shoot, 0
	mov [esi].Hero.face_direction, DIRECTION_RIGHT
	invoke SetWeapon, esi, WEAPONTYPE_B
	mov eax, [esi].Hero.weapon.bullet_speed
	mov [esi].Hero.shoot_dx, eax
	mov [esi].Hero.shoot_dy, 0 
	mov [esi].Hero.action_imageIndex, 0
	mov [esi].Hero.jump_height, MAX_JUMP_HEIGHT
	invoke UpdateHeroCollisionRect, hero
	ret
InitContra ENDP
;==================================
CreateRobot PROC USES esi,
	robots:PTR Robots, r_type:BYTE, posx:SDWORD, posy:SDWORD
	local cnt:DWORD

 	mov esi, robots
	mov eax, [esi].Robots.number
	inc [esi].Robots.number
	mov bl, TYPE Hero
	mul bl
	lea esi, [esi].Robots.robots[eax]
	
	mov eax, posx
	mov [esi].Hero.position.pos_x, eax
	mov eax, posy
	mov [esi].Hero.position.pos_y, eax
	mov al, r_type
	mov [esi].Hero.identity, al
	.if r_type == HEROTYPE_STATICROBOT
		mov [esi].Hero.action, HEROACTION_STAND
		mov [esi].Hero.move_dx, 0
		mov [esi].Hero.move_dy, 0
		mov [esi].Hero.invincible_time, 0
		mov [esi].Hero.shoot, 0
		mov [esi].Hero.face_direction, DIRECTION_LEFT
		invoke SetWeapon, esi, WEAPONTYPE_ROBOT
		mov [esi].Hero.shoot_dx, 0
		mov [esi].Hero.shoot_dy, 0
		mov [esi].Hero.life, 1
	.elseif r_type == HEROTYPE_DYNAMICROBOT
		mov [esi].Hero.action, HEROACTION_FALL
		mov [esi].Hero.move_dx, -CONTRA_BASIC_MOV_SPEED
		mov [esi].Hero.move_dy, 0
		mov [esi].Hero.life, 1
	.elseif r_type == HEROTYPE_TOWER
		mov [esi].Hero.action, TOWERACTION_OPEN
		mov [esi].Hero.move_dx, 0
		mov [esi].Hero.move_dy, 0
		mov [esi].Hero.invincible_time, 0
		mov [esi].Hero.shoot, 0
		mov [esi].Hero.face_direction, DIRECTION_LEFT
		mov [esi].Hero.life, 5
	.endif
	mov [esi].Hero.action_imageIndex, 0
	mov [esi].Hero.jump_height, 0
	
	invoke UpdateHeroCollisionRect, esi

	mov eax, esi
	ret
CreateRobot ENDP
;=================================
DeleteRobot PROC	USES esi ebx edi,
	robots:PTR Robots,index:DWORD
	local num : DWORD
	
	mov esi, robots

	mov eax, [esi].Robots.number
	mov num, eax

	mov ecx, num
	sub ecx, index
	mov eax, TYPE Hero
	mul cx
	mov ecx, eax

	mov ebx, index
	mov eax, TYPE Hero
	mul bx
	lea edi, [esi].Robots.robots[eax]
	add eax, TYPE Hero
	lea esi, [esi].Robots.robots[eax]
	rep movsb
	
	mov esi, robots
	dec [esi].Robots.number

	ret
DeleteRobot	ENDP
CreateRobotEvent PROC   USES esi,
	events:PTR Events, e_type: DWORD, actor:DWORD,  clock_limit:DWORD, location_limit:DWORD, pos_x:SDWORD, pos_y:SDWORD
	mov esi, events
	mov eax, [esi].Events.number
	inc [esi].Events.number
	mov bl, TYPE Event
	mul bl
	lea esi, [esi].Events.events[eax]
	
	mov eax, pos_x
	mov [esi].Event.position.pos_x, eax
	mov eax, pos_y
	mov [esi].Event.position.pos_y, eax
	mov eax, e_type
	mov [esi].Event.e_type, eax
	mov eax, actor
	mov [esi].Event.actor, eax
	mov eax, clock_limit
	mov [esi].Event.clock_limit, eax
	mov eax, location_limit
	mov [esi].Event.location_limit, eax

	mov eax, esi
	ret 
CreateRobotEvent ENDP
;=================================
DeleteEvent PROC   USES esi ebx edi,
	events:PTR Events,index:DWORD
	local num : DWORD
	mov esi, events

	mov eax, [esi].Events.number
	mov num, eax

	mov ecx, num
	sub ecx, index
	mov eax, TYPE Event
	mul cx
	mov ecx, eax

	mov ebx, index
	mov eax, TYPE Event
	mul bx
	lea edi, [esi].Events.events[eax]
	add eax, TYPE Event
	lea esi, [esi].Events.events[eax]
	rep movsb
	
	mov esi, events
	dec [esi].Events.number

	ret
DeleteEvent ENDP
;=================================
;command action:0:standby,1:run,2:jump,3:lie,4:die,5:shoot,6:cancel shoot
TakeAction	PROC		USES esi,
	hero:PTR Hero,command:DWORD
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
			.if formerAction == HEROACTION_CRAWL && [esi].Hero.position.pos_y < 340
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
				mov [esi].Hero.weapon.time_to_next_shot, 0
				mov [esi].Hero.shoot, 1
			.elseif formerAction == HEROACTION_JUMP || formerAction == HEROACTION_FALL
				mov [esi].Hero.weapon.time_to_next_shot, 0
				mov [esi].Hero.shoot, 1
			.elseif formerAction == HEROACTION_CRAWL
				mov [esi].Hero.shoot_dy, 0
				.if [esi].Hero.face_direction == DIRECTION_RIGHT
					mov eax, [esi].Hero.weapon.bullet_speed
					mov [esi].Hero.shoot_dx, eax
				.else 
					mov eax, 0
					sub eax, [esi].Hero.weapon.bullet_speed
					mov [esi].Hero.shoot_dx, eax
				.endif
				mov [esi].Hero.weapon.time_to_next_shot, 0
				mov [esi].Hero.shoot, 1
			.elseif formerAction == HEROACTION_SWIM
				mov [esi].Hero.weapon.time_to_next_shot, 0
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
UpdateHeroAction PROC USES esi,
	hero:PTR Hero, newAction: DWORD
	mov eax, newAction
	.if eax != [esi].Hero.action
		.if newAction == HEROACTION_FALL
			.if	[esi].Hero.action == HEROACTION_CRAWL
				add [esi].Hero.position.pos_y, 32
			.endif
		.endif
		.if newAction == HEROACTION_STAND
			.if [esi].Hero.move_dx != 0
				mov eax, HEROACTION_RUN
			.endif
		.endif
		.if newAction == HEROACTION_DIE
			.if [esi].Hero.face_direction == DIRECTION_RIGHT
				mov [esi].Hero.move_dx, -10
				mov [esi].Hero.move_dy, -20
			.else 
				mov [esi].Hero.move_dx, 10
				mov [esi].Hero.move_dy, -20
			.endif
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
SetWeapon	PROC	USES esi,
	hero:PTR Hero, w_type: BYTE
	mov		esi,hero
	lea		esi, [esi].Hero.weapon
	.if w_type == WEAPONTYPE_B
		mov		[esi].Weapon.shot_interval_time, 2
		mov		[esi].Weapon.time_to_next_shot,  0
		mov     [esi].Weapon.triple_bullet,      0
		mov     [esi].Weapon.bullet_speed ,      25
	.elseif w_type == WEAPONTYPE_ROBOT
		mov		[esi].Weapon.shot_interval_time, 5
		mov		[esi].Weapon.time_to_next_shot,  0
		mov     [esi].Weapon.triple_bullet,      18
		mov     [esi].Weapon.bullet_speed ,      18
	.elseif w_type == WEAPONTYPE_S
		mov		[esi].Weapon.shot_interval_time, 2
		mov		[esi].Weapon.time_to_next_shot,  0
		mov     [esi].Weapon.triple_bullet,      1
		mov     [esi].Weapon.triple_bullet,      25
	.else
	.endif

	ret
SetWeapon	ENDP
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
ChangeBulletRect	PROC	USES esi,
	bullet:PTR Bullet,rect:PTR	CollisionRect
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
CreateBullet PROC USES esi edi, 
	 bullets:PTR Bullets,hero:PTR Hero, hImage: DWORD
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
	add	eax,	64
	.if	[esi].Hero.face_direction == DIRECTION_RIGHT
		sub	eax,80
	.endif
	mov [esi].Bullet.position.pos_x, eax
	mov [esi].Bullet.range.position.pos_x, eax

	mov eax, [edi].Hero.range.r_height
	shr eax, 1
	sub eax, 15
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
DeleteBullet  PROC USES esi ebx edi,
	bullets:PTR Bullets,index:DWORD
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
UpdateHeroPosition  PROC hero:PTR Hero, bgMoveLength:DWORD
	mov		esi, hero

	mov eax, [esi].Hero.move_dx
	add [esi].Hero.position.pos_x, eax
	add [esi].Hero.range.position.pos_x, eax
	mov eax, [esi].Hero.move_dy
	add [esi].Hero.position.pos_y, eax
	add [esi].Hero.range.position.pos_y, eax

	mov eax, bgMoveLength
	sub [esi].Hero.position.pos_x, eax
	sub [esi].Hero.range.position.pos_x, eax
	ret
UpdateHeroPosition  ENDP  

;=======================================
UpdateHeroCollisionRect PROC USES esi,
	hero: PTR Hero
	local rect: CollisionRect
	mov esi, hero
	.if [esi].Hero.action == HEROACTION_RUN
		mov rect.r_width,  30
		mov rect.r_height, 70
		mov eax, [esi].Hero.position.pos_x
		add eax,          20
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          30
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_STAND
		mov rect.r_width,  30
		mov rect.r_height, 70
		mov eax, [esi].Hero.position.pos_x
		add eax,          20
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          30
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_JUMP
		mov rect.r_width,  30
		mov rect.r_height, 68
		mov eax, [esi].Hero.position.pos_x
		add eax,          20
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          32
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_FALL
		mov rect.r_width,  30
		mov rect.r_height, 70
		mov eax, [esi].Hero.position.pos_x
		add eax,          20
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          30
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_DIE
		mov rect.r_width,  70
		mov rect.r_height, 20
		mov eax, [esi].Hero.position.pos_x
		add eax,          0
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          80
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_DIVE
		mov rect.r_width,  0
		mov rect.r_height, 0
		mov eax, [esi].Hero.position.pos_x
		add eax,          20
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          80
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_SWIM
		mov rect.r_width,  30
		mov rect.r_height, 30
		mov eax, [esi].Hero.position.pos_x
		add eax,          20
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          70
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.elseif [esi].Hero.action == HEROACTION_CRAWL
		mov rect.r_width,  70
		mov rect.r_height, 20
		mov eax, [esi].Hero.position.pos_x
		add eax,          0
		mov rect.position.pos_x, eax
		mov eax, [esi].Hero.position.pos_y
		add eax,          80
		mov rect.position.pos_y, eax
		invoke ChangeHeroRect, hero, addr rect
	.else
	.endif
	ret	
UpdateHeroCollisionRect ENDP
ChangeHeroRect	PROC	USES esi,
	hero:PTR Hero,rect:PTR	CollisionRect
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
