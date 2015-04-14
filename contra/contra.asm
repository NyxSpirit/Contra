TITLE main.asm      
    .model flat,stdcall      
    option casemap:none  

include windows.inc
include user32.inc
include masm32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc
include winmm.inc
include gdiplus.inc
include ole32.inc

includelib ole32.lib
includelib gdiplus.lib
includelib winmm.lib
includelib shell32.lib
includelib gdi32.lib
includelib kernel32.lib
includelib user32.lib
includelib masm32.lib

include contra.inc
.code

start:
 invoke GetModuleHandle, NULL
 mov hInstance, eax
 invoke WinMain, hInstance, NULL, NULL, 0
 invoke ExitProcess, eax

 WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR,
CmdShow:DWORD
	 local wc:WNDCLASSEX
	 local msg:MSG
	 local hwnd:HWND 

	 mov wc.cbSize, SIZEOF WNDCLASSEX
	 mov wc.style, CS_HREDRAW or CS_VREDRAW
	 mov wc.lpfnWndProc, offset WndProc
	 mov wc.cbClsExtra, NULL
	 mov wc.cbWndExtra, NULL
	 push hInstance
	 pop wc.hInstance
	 mov wc.hbrBackground, NULL
	 mov wc.lpszMenuName, NULL
	 mov wc.lpszClassName, offset ClassName
	 invoke LoadIcon, NULL, IDI_APPLICATION
	 mov wc.hIcon, eax
	 mov wc.hIconSm, eax
	 invoke LoadCursor, NULL, IDC_ARROW
	 mov wc.hCursor, eax
	 invoke RegisterClassEx, addr wc 

	 invoke CreateWindowEx, 0, addr ClassName, addr AppName, 
		WS_VISIBLE or  WS_DLGFRAME, CW_USEDEFAULT, 
		CW_USEDEFAULT, SCREEN_WIDTH, SCREEN_HEIGHT, NULL,
		NULL, hInst, NULL
	 mov hwnd, eax 

	 .while TRUE
		 invoke GetMessage, addr msg, NULL, 0, 0
		 .break .if (!eax)
		 invoke TranslateMessage, addr msg
		 invoke DispatchMessage, addr msg
	 .endw 

	 mov eax, msg.wParam
	 ret
 WinMain endp 
  

 RunProc PROC hWnd:HWND
	LOCAL rect: RECT 
	.while TRUE
		invoke HandleEvents
		invoke ContraTakeAction
		invoke DynamicRobotsTakeAction 
		invoke StaticRobotsTakeAction
		invoke TowerTakeAction

		invoke BulletsMove

		invoke InvalidateRect, hWnd, NULL, 1		
		invoke Sleep, 100
		inc clock
	.endw
	ret
 RunProc ENDP
 
 HandleEvents PROC USES esi edi ecx
	local index:DWORD
	local newRobot: PTR Hero
	local startTime: DWORD
	mov ecx, eventQueue.number
	.if ecx == 0
		ret
	.endif
	dec ecx
	mov index, ecx
	mov eax, TYPE Event
	mul cl
	lea esi, eventQueue.events[eax]

	.while TRUE
		mov eax, [esi].Event.clock_limit
		.if clock > eax
			mov eax, 0
			sub eax, background.b_offset
			.if eax > [esi].Event.location_limit
				
			; All satisfied, start executing 
				.if [esi].Event.e_type == EVENTTYPE_CREATESTATICROBOT
					invoke CreateRobot, addr staticRobotQueue, HEROTYPE_STATICROBOT, [esi].Event.position.pos_x, [esi].Event.position.pos_y
					mov newRobot, eax
					mov ebx, clock
					mov startTime, ebx
					add startTime, 1
					invoke CreateRobotEvent, addr eventQueue, EVENTTYPE_ROBOTSHOOT, newRobot, startTime, [esi].Event.location_limit, [esi].Event.position.pos_x, [esi].Event.position.pos_y
					add startTime, ROBOT_SHOOT_LASTTIME
					invoke CreateRobotEvent, addr eventQueue, EVENTTYPE_ROBOTSTOPSHOOT, newRobot,  startTime, 0, [esi].Event.position.pos_x, [esi].Event.position.pos_y

				.elseif [esi].Event.e_type == EVENTTYPE_ROBOTSHOOT
					mov edi, [esi].Event.actor

					.if [edi].Hero.action != HEROACTION_DIE
						mov [edi].Hero.shoot, 1
						mov [edi].Hero.weapon.time_to_next_shot, 0
						mov ebx, clock
						mov startTime, ebx
						add startTime, ROBOT_SHOOT_INTERVAL
						invoke CreateRobotEvent, addr eventQueue, EVENTTYPE_ROBOTSHOOT, edi, startTime, 0, [esi].Event.position.pos_x, [esi].Event.position.pos_y
						add startTime, ROBOT_SHOOT_LASTTIME
						invoke CreateRobotEvent, addr eventQueue, EVENTTYPE_ROBOTSTOPSHOOT, edi,  startTime, 0, [esi].Event.position.pos_x, [esi].Event.position.pos_y
					.endif
				.elseif [esi].Event.e_type == EVENTTYPE_ROBOTSTOPSHOOT
					mov edi, [esi].Event.actor
					mov [edi].Hero.shoot, 0
				.elseif [esi].Event.e_type == EVENTTYPE_CREATEDYNAMICROBOT
					invoke CreateRobot, addr dynamicRobotQueue, HEROTYPE_DYNAMICROBOT, [esi].Event.position.pos_x, [esi].Event.position.pos_y
					mov newRobot, eax
					mov edi, newRobot
					.if [edi].Hero.position.pos_x > 250
						mov [edi].Hero.face_direction, DIRECTION_LEFT
						mov [edi].Hero.move_dx, -CONTRA_BASIC_MOV_SPEED
					.else
						mov [edi].Hero.face_direction, DIRECTION_LEFT
						mov [edi].Hero.move_dx, -CONTRA_BASIC_MOV_SPEED
					.endif
					mov ebx, clock
					mov startTime, ebx
					add startTime, 20
					invoke CreateRobotEvent, addr eventQueue, EVENTTYPE_CREATEDYNAMICROBOT, 0, startTime, 0, SCREEN_WIDTH, 20
				.elseif [esi].Event.e_type == EVENTTYPE_CREATETOWER
					invoke CreateRobot, addr towerQueue, HEROTYPE_TOWER,  [esi].Event.position.pos_x, [esi].Event.position.pos_y
					mov edi, eax
					mov [edi].Hero.shoot, 1
					mov [edi].Hero.weapon.time_to_next_shot, 0
					mov ebx, clock
					mov startTime, ebx
					add startTime, ROBOT_SHOOT_INTERVAL
					invoke CreateRobotEvent, addr eventQueue, EVENTTYPE_ROBOTSHOOT, edi, startTime, 0, [esi].Event.position.pos_x, [esi].Event.position.pos_y
					add startTime, ROBOT_SHOOT_LASTTIME
					invoke CreateRobotEvent, addr eventQueue, EVENTTYPE_ROBOTSTOPSHOOT, edi,  startTime, 0, [esi].Event.position.pos_x, [esi].Event.position.pos_y
				
				.elseif [esi].Event.e_type == EVENTTYPE_BRIDGEBOOM
					lea edi, bridges
					.if [esi].Event.actor > 0
						add edi, TYPE Bridge
					.endif
					mov ecx, [edi].Bridge.action_index

					inc [edi].Bridge.action_index
										
				.endif
@@:			; End execution:
				
			invoke DeleteEvent, addr eventQueue, index
			.endif
		.endif

		.if index == 0
			jmp @f
		.endif 
		sub esi, TYPE Event
		dec index
	.endw
@@:

	ret
 HandleEvents ENDP

 WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
   LOCAL ps:PAINTSTRUCT 
   LOCAL hdc:HDC 
   LOCAL hMemDC:HDC 
   LOCAL rect:RECT 
   LOCAL hGraphics: DWORD
   LOCAL buffer [64] :BYTE

   .if	uMsg == WM_CREATE && wndstart == CONTRA_STATE_NULL
		mov startupinput.GdiplusVersion, 1 
		invoke GdiplusStartup, addr token, addr startupinput, NULL
		invoke UnicodeStr, ADDR  contraLoadingImage1, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr  hContraLoadingImage1
		invoke CreateThread, 0, 0, SoundProc, 0, 0, ADDR dwThreadID
		mov hBGMThread, eax
   .elseif wndstart == CONTRA_STATE_START

		mov	wndstart,CONTRA_STATE_RUNNING	
		mov startupinput.GdiplusVersion, 1 
		invoke GdiplusStartup, addr token, addr startupinput, NULL
		
		; ==========invoke LoadImageResources
		
		invoke UnicodeStr, ADDR backgroundFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hBackgroundImage
		
		invoke LoadImageSeries, ADDR playerMoveRightFiles, 6, addr hPlayerMoveRightImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR playerMoveLeftFiles, 6, addr hPlayerMoveLeftImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR playerJumpRightFiles, 4, addr hPlayerJumpRightImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR playerJumpLeftFiles, 4, addr hPlayerJumpLeftImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR playerDieRightFiles, 7, addr hPlayerDieRightImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR playerDieLeftFiles, 7, addr hPlayerDieLeftImages, ADDR IMAGETYPE_PNG
		
		invoke UnicodeStr, ADDR playerStandRightFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hPlayerStandRightImage
		invoke UnicodeStr, ADDR playerStandLeftFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hPlayerStandLeftImage
		invoke UnicodeStr, ADDR playerSwimRightFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hPlayerSwimRightImage
		invoke UnicodeStr, ADDR playerSwimLeftFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hPlayerSwimLeftImage
		invoke UnicodeStr, ADDR playerCrawlRightFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hPlayerCrawlRightImage
		invoke UnicodeStr, ADDR playerCrawlLeftFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hPlayerCrawlLeftImage
		invoke UnicodeStr, ADDR playerFallRightFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hPlayerFallRightImage
		invoke UnicodeStr, ADDR playerFallLeftFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hPlayerFallLeftImage
		invoke UnicodeStr, ADDR playerDiveFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hPlayerDiveImage
		
		invoke LoadImageSeries, ADDR staticRobotShootRightFiles, 2, addr hStaticRobotShootRightImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR staticRobotShootRightDownFiles, 2, addr hStaticRobotShootRightDownImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR staticRobotShootRightUpFiles, 2, addr hStaticRobotShootRightUpImages, ADDR IMAGETYPE_PNG
		
		invoke LoadImageSeries, ADDR staticRobotShootLeftFiles, 2, addr hStaticRobotShootLeftImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR staticRobotShootLeftDownFiles, 2, addr hStaticRobotShootLeftDownImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR staticRobotShootLeftUpFiles, 2, addr hStaticRobotShootLeftUpImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR staticRobotDieLeftFiles, 4, addr hStaticRobotDieLeftImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR staticRobotDieRightFiles, 4, addr hStaticRobotDieRightImages, ADDR IMAGETYPE_PNG

		invoke LoadImageSeries, ADDR dynamicRobotRunRightFiles, 5, addr hDynamicRobotRunRightImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR dynamicRobotDieRightFiles, 4, addr hDynamicRobotDieRightImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR dynamicRobotRunLeftFiles, 5, addr hDynamicRobotRunLeftImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR dynamicRobotDieLeftFiles, 4, addr hDynamicRobotDieLeftImages, ADDR IMAGETYPE_PNG
		invoke UnicodeStr, ADDR  dynamicRobotJumpRightFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr  hDynamicRobotJumpRightImage
		invoke UnicodeStr, ADDR  dynamicRobotJumpLeftFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr  hDynamicRobotJumpLeftImage

		invoke LoadImageSeries, ADDR bulletFiles, 4, addr hBulletImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR towerFiles, 11, addr hTowerImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR towerBoomFiles, 3, addr hTowerBoomImages, ADDR IMAGETYPE_PNG
		invoke LoadImageSeries, ADDR bridgeBoomFiles, 3, addr hBridgeBoomImages, ADDR IMAGETYPE_PNG


		; ==========LoadImageResources end

		
		invoke InitGame

		invoke CreateThread, 0, 0, SoundProc, 0, 0, ADDR dwThreadID
		mov hBGMThread, eax
		
		invoke CreateThread, 0, 0, RunProc, hWnd,0, ADDR dwThreadID
		mov hRunThread, eax

   .elseif uMsg == WM_PAINT && wndstart == CONTRA_STATE_RUNNING
		invoke BeginPaint,hWnd,addr ps 
		mov hdc, eax
		invoke CreateCompatibleDC, hdc
		mov hMemDC, eax
		;invoke SelectObject,hMemDC,hBitmap 
		;invoke GetClientRect,hWnd,addr rect 
		;invoke BitBlt,hdc,0,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY
		;invoke BitBlt, hDC, 0, 0
		invoke GdipCreateFromHDC, hdc, addr hGraphics 
		invoke GdipSetPageUnit, hGraphics, UnitPixel

		invoke PaintBackground, hGraphics
		invoke PaintObjects, hGraphics

		invoke GdipDeleteGraphics, hGraphics
		
		invoke DeleteDC, hMemDC
		invoke EndPaint,hWnd,addr ps
	.elseif uMsg == WM_PAINT && wndstart == CONTRA_STATE_NULL
		invoke BeginPaint,hWnd,addr ps 
		mov hdc, eax
		invoke CreateCompatibleDC, hdc
		mov hMemDC, eax

		invoke GdipCreateFromHDC, hdc, addr hGraphics 
		invoke GdipSetPageUnit, hGraphics, UnitPixel

		invoke PaintLoading, hGraphics

		invoke GdipDeleteGraphics, hGraphics
		
		invoke DeleteDC, hMemDC
		invoke EndPaint,hWnd,addr ps
	.elseif uMsg == WM_KEYDOWN && wndstart == CONTRA_STATE_RUNNING	
		invoke GetKeyboardState, addr keyState 
		
		.if keyState[VK_D] >= 128
			invoke TakeAction, addr contra, CMD_MOVERIGHT
		.elseif keyState[VK_A] >= 128
			invoke TakeAction, addr contra, CMD_MOVELEFT
		.else
			invoke TakeAction, addr contra, CMD_STAND
		.endif
		.if keyState[VK_S] >= 128
			invoke TakeAction, addr contra, CMD_DOWN
		.elseif keyState[VK_W] >= 128
			invoke TakeAction, addr contra, CMD_UP
		.endif
		.if keyState[VK_K] >= 128
			invoke TakeAction, addr contra, CMD_JUMP
		.endif
		
		.if keyState[VK_J] >= 128
			.if keyState[VK_W] >= 128
				mov contra.shoot_dy, -1
			.elseif keyState[VK_S] >= 128
				mov contra.shoot_dy, 1
			.else
				mov contra.shoot_dy, 0
			.endif
			.if keyState[VK_D] >= 128
				mov contra.shoot_dx, 1
			.elseif keyState[VK_A] >= 128
				mov contra.shoot_dx, -1
			.elseif contra.shoot_dy == 0
				.if contra.face_direction == DIRECTION_RIGHT
					mov contra.shoot_dx, 1
				.else 
					mov contra.shoot_dx, -1
				.endif
			.else
				mov contra.shoot_dx, 0
			.endif 
			mov ebx, contra.weapon.bullet_speed
			mov eax, contra.shoot_dx
			imul bl
			mov contra.shoot_dx, eax
			mov eax, contra.shoot_dy
			imul bl
			mov contra.shoot_dy, eax
			invoke TakeAction, addr contra, CMD_SHOOT
		.endif
	.elseif uMsg == WM_KEYUP && wndstart == CONTRA_STATE_RUNNING	
		
		.if wParam == VK_ESCAPE
			mov	wndstart,CONTRA_STATE_NULL
			invoke DeleteObject, hMusic
			invoke CloseHandle,hBGMThread
			invoke CloseHandle,hRunThread
			invoke GdiplusShutdown, token
		.elseif	wParam == VK_F1
			mov	contra.life,30
		.endif

		.if wParam == VK_D			
			jmp @f
		.elseif wParam == VK_A
@@:
			invoke GetKeyboardState, addr keyState 
			.if keyState[VK_D] >= 128
				invoke TakeAction, addr contra, CMD_MOVERIGHT
			.elseif keyState[VK_A] >= 128
				invoke TakeAction, addr contra, CMD_MOVELEFT
			.elseif keyState[VK_S] >= 128
				invoke TakeAction, addr contra, CMD_DOWN
			.else
				invoke TakeAction, addr contra, CMD_STAND
			.endif
		.elseif wParam == VK_J
			invoke TakeAction, addr contra, CMD_CANCELSHOOT
		.elseif wParam == VK_S
			invoke TakeAction, addr contra, CMD_CANCELCRAWL
		.endif

	.elseif uMsg == WM_KEYUP &&  wndstart == CONTRA_STATE_NULL
		.if	wParam == VK_RETURN
			mov wndstart,1
		.endif
	.elseif uMsg == WM_DESTROY && wndstart == CONTRA_STATE_RUNNING	
		invoke DeleteObject, hMusic
		invoke CloseHandle,hBGMThread
		invoke CloseHandle,hRunThread
		invoke GdiplusShutdown, token
		invoke PostQuitMessage, 0
	.else
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam
		ret
	.endif
	xor eax, eax
	ret	
 WndProc endp 

; ===================================================== Loading and initiating
;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;

InitGame PROC
	; ==========init game params
	invoke InitContra, addr contra 
	invoke InitEvents, addr eventQueue
	invoke InitMap, addr background

	mov staticRobotQueue.number, 0
	mov dynamicRobotQueue.number, 0
	mov towerQueue.number, 0

	mov contraBullets.number, 0
	mov enemyBullets.number, 0
	;mov wndstart, 0
	mov clock, 0

	ret
InitGame ENDP

LoadImageResources PROC
	local buffer [64] :BYTE
	

	ret
LoadImageResources ENDP

LoadImageSeries PROC, basicFileName: DWORD, number: BYTE, seriesHandle: DWORD, imageTypeName: DWORD
	LOCAL fileName [64] :BYTE
	LOCAL fileNameBuffer [64] :BYTE
	LOCAL hImage: DWORD
	mov ecx, 0
	@@:
	    push ecx
		mov fileName, 0
		invoke  StrConcat, addr fileName, basicFileName
		mov esi, eax
		movzx eax, cl
		add al, '1'
		mov fileName[esi*TYPE fileName], al
		inc esi
		mov fileName[esi*TYPE fileName], '.'
		inc esi
		mov fileName[esi*TYPE fileName], 0

		invoke StrConcat, addr fileName, imageTypeName
		invoke	UnicodeStr,ADDR	 fileName, ADDR fileNameBuffer
		invoke GdipLoadImageFromFile, addr fileNameBuffer,	addr hImage
		mov eax, hImage
		pop ecx
		mov esi, seriesHandle
		add esi, ecx
		add esi, ecx
		add esi, ecx
		add esi, ecx
		mov DWORD PTR [esi], eax
		inc ecx
	cmp cl, number
	jne @b
	ret
 LoadImageSeries ENDP



; ================================================  Sound and view
;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;
 SoundProc PROC
	invoke PlaySound, IDR_WAVE1, hInstance,SND_RESOURCE or SND_ASYNC
	ret
 SoundProc ENDP
 
 PaintObjects PROC USES ecx esi,
	 hGraphics:DWORD
    local cnt: DWORD

		invoke PaintObject, hGraphics, addr contra
	
	mov ecx, contraBullets.number
	mov cnt, ecx
	.while cnt > 0
		mov eax, cnt
		dec eax 
		mov bl,TYPE Bullet
		mul bl
		invoke PaintObject, hGraphics, addr contraBullets.bullets[eax]
		dec cnt 
	.endw

	mov ecx, enemyBullets.number
	mov cnt, ecx
	.while cnt > 0
		mov eax, cnt
		dec eax 
		mov bl,TYPE Bullet
		mul bl
		invoke PaintObject, hGraphics, addr enemyBullets.bullets[eax]
		dec cnt 
	.endw
	
	mov ecx, staticRobotQueue.number
	mov cnt, ecx
	.while cnt > 0
		mov eax, cnt
		dec eax
		mov bl, TYPE Hero
		mul bl
		lea esi,staticRobotQueue.robots[eax]
		.if [esi].Hero.action != HEROACTION_GONE
			invoke PaintObject, hGraphics, esi 
		.endif
		dec cnt
	.endw

	mov ecx, dynamicRobotQueue.number
	mov cnt, ecx
	.while cnt > 0
		mov eax, cnt
		dec eax
		mov bl, TYPE Hero
		mul bl
		invoke PaintObject, hGraphics, addr dynamicRobotQueue.robots[eax]
		dec cnt
	.endw

	mov ecx, towerQueue.number
	mov cnt, ecx
	.while cnt > 0
		mov eax, cnt
		dec eax
		mov bl, TYPE Hero
		mul bl
		lea esi,towerQueue.robots[eax]
		.if [esi].Hero.action != HEROACTION_GONE
			invoke PaintObject, hGraphics, esi 
		.endif
		dec cnt
	.endw

	ret
 PaintObjects ENDP
 
 PaintObject PROC, hGraphics:DWORD, hObj:DWORD
    local imageWidth :DWORD
	local imageHeight : DWORD
	mov esi, hObj
	
	mov ecx, (Object PTR [esi]).hImage
	invoke GdipGetImageWidth, ecx, addr imageWidth
	mov ebx,imageWidth
	mov al,DISPLAY_SCALE
	mul bx
	mov imageWidth, eax
	mov ecx, (Object PTR [esi]).hImage
	invoke GdipGetImageHeight, ecx, addr imageHeight
	mov ebx,imageHeight
	mov al,DISPLAY_SCALE
	mul bx
	mov imageHeight, eax
	invoke GdipDrawImageRectI, hGraphics, (Object PTR [esi]).hImage,(Object PTR [esi]).position.pos_x,(Object PTR [esi]).position.pos_y,
						imageWidth, imageHeight
	ret
 PaintObject ENDP

 PaintBackground PROC uses esi edi, hGraphics:DWORD
	local imageWidth :DWORD   
	local imageHeight:DWORD
	local hImage :PTR DWORD
	local posx   :SDWORD
	local posy   :SDWORD
	;invoke GdipDrawImageRectI, hGraphics, hBackgroundImage, background.b_offset ,0, BACKGROUNDIMAGE_UNITWIDTH * DISPLAY_SCALE, BACKGROUNDIMAGE_HEIGHT * DISPLAY_SCALE 
	invoke GdipGetImageWidth, hBackgroundImage, addr imageWidth
	invoke GdipGetImageHeight, hBackgroundImage, addr imageHeight
	invoke GdipDrawImageRectI, hGraphics, hBackgroundImage, background.b_offset ,0, imageWidth , imageHeight

	;================ paint bridges
	lea esi, bridges
	lea edi, [esi].Bridge.hImages
	mov hImage, edi
	mov eax, [esi].Bridge.position.pos_x
	mov posx,   eax
	mov eax, background.b_offset
	add posx,   eax
	mov eax, [esi].Bridge.position.pos_y
	mov posy,   eax
	mov imageWidth , 64
	mov imageHeight , 100
	
	mov edi, hImage
	mov eax, [edi]
	.if eax != 0
	invoke GdipDrawImageRectI, hGraphics, eax, posx , posy, imageWidth , imageHeight
	add hImage, TYPE DWORD
	mov edi, hImage
	mov eax, [edi]
	.if eax!= 0
	add posx, BRIDGE_WIDTH
	invoke GdipDrawImageRectI, hGraphics, eax, posx , posy, imageWidth , imageHeight
	add hImage, TYPE DWORD
	mov edi, hImage
	mov eax, [edi]
	.if eax!= 0
	add posx, BRIDGE_WIDTH
	invoke GdipDrawImageRectI, hGraphics, eax, posx , posy, imageWidth , imageHeight
	add hImage, TYPE DWORD
	mov edi, hImage
	mov eax, [edi]
	.if eax!= 0
	add posx, BRIDGE_WIDTH
	invoke GdipDrawImageRectI, hGraphics, eax, posx , posy, imageWidth , imageHeight
	.endif
	.endif
	.endif
	.endif

	lea esi, bridges
	add esi, TYPE Bridge
	mov eax, [esi].Bridge.position.pos_x
	mov posx,   eax
	mov eax, background.b_offset
	add posx,   eax
	mov eax, [esi].Bridge.position.pos_y
	mov posy,   eax
	mov imageWidth , 64
	mov imageHeight , 100
	
	mov edi, hImage
	mov eax, [edi]
	.if eax != 0
	invoke GdipDrawImageRectI, hGraphics, eax, posx , posy, imageWidth , imageHeight
	add hImage, TYPE DWORD
	mov edi, hImage
	mov eax, [edi]
	.if eax!= 0
	add posx, BRIDGE_WIDTH
	invoke GdipDrawImageRectI, hGraphics, eax, posx , posy, imageWidth , imageHeight
	add hImage, TYPE DWORD
	mov edi, hImage
	mov eax, [edi]
	.if eax!= 0
	add posx, BRIDGE_WIDTH
	invoke GdipDrawImageRectI, hGraphics, eax, posx , posy, imageWidth , imageHeight
	add hImage, TYPE DWORD
	mov edi, hImage
	mov eax, [edi]
	.if eax!= 0
	add posx, BRIDGE_WIDTH
	invoke GdipDrawImageRectI, hGraphics, eax, posx , posy, imageWidth , imageHeight
	.endif
	.endif
	.endif
	.endif
	ret
 PaintBackground ENDP

  PaintLoading PROC, hGraphics:DWORD
	local imageWidth :DWORD   
	local imageHeight:DWORD
	;invoke GdipDrawImageRectI, hGraphics, hBackgroundImage, background.b_offset ,0, BACKGROUNDIMAGE_UNITWIDTH * DISPLAY_SCALE, BACKGROUNDIMAGE_HEIGHT * DISPLAY_SCALE 
	invoke GdipGetImageWidth, hContraLoadingImage1, addr imageWidth
	invoke GdipGetImageHeight, hContraLoadingImage1, addr imageHeight
	invoke GdipDrawImageRectI, hGraphics, hContraLoadingImage1, 0 ,0, imageWidth , imageHeight
	
	ret
 PaintLoading ENDP

; ============================================= Action Logic ======================================================= 
; ;;;;;;;;;
;;;;;;;;;;;

 ContraTakeAction PROC
	.if contra.action == HEROACTION_DIE
		.if contra.face_direction == DIRECTION_RIGHT
			mov contra.move_dx, -CONTRA_BASIC_MOV_SPEED
			mov esi, contra.action_imageIndex
			mov eax, hPlayerDieRightImages[esi * TYPE DWORD];
			mov contra.hImage, eax
			inc contra.action_imageIndex
		.else
			mov contra.move_dx, CONTRA_BASIC_MOV_SPEED
			mov esi, contra.action_imageIndex
			mov eax, hPlayerDieLeftImages[esi * TYPE DWORD];
			mov contra.hImage, eax
			inc contra.action_imageIndex
		.endif
	.elseif contra.action == HEROACTION_SWIM
		.if contra.jump_height < CONTRA_FLOAT_HEIGHT
			mov contra.move_dy, -CONTRA_FLOAT_SPEED
			add contra.jump_height, CONTRA_FLOAT_SPEED
		.else
			mov contra.move_dy, CONTRA_FLOAT_SPEED
		.endif
		.if contra.face_direction == DIRECTION_RIGHT
			mov eax, hPlayerSwimRightImage
			mov contra.hImage, eax
		.else
			mov eax, hPlayerSwimLeftImage
			mov contra.hImage, eax
		.endif
	.elseif contra.action == HEROACTION_JUMP
		.if contra.jump_height < MAX_JUMP_HEIGHT
			mov contra.move_dy, -CONTRA_BASIC_JUMP_SPEED
			add contra.jump_height, CONTRA_BASIC_JUMP_SPEED
		.else
			mov contra.move_dy, CONTRA_BASIC_JUMP_SPEED
		.endif
		.if contra.face_direction == DIRECTION_RIGHT
			mov esi, contra.action_imageIndex
			mov eax, hPlayerJumpRightImages[esi * TYPE DWORD];
			mov contra.hImage, eax
			inc contra.action_imageIndex
			.if contra.action_imageIndex == 4
				mov contra.action_imageIndex, 0
			.endif
		.else
			mov esi, contra.action_imageIndex
			mov eax, hPlayerJumpLeftImages[esi * TYPE DWORD];
			mov contra.hImage, eax
			inc contra.action_imageIndex
			.if contra.action_imageIndex == 4
				mov contra.action_imageIndex, 0
			.endif
		.endif
	.elseif contra.action == HEROACTION_CRAWL
		.if contra.face_direction == DIRECTION_RIGHT
			mov eax, hPlayerCrawlRightImage
			mov contra.hImage, eax
		.else
			mov eax, hPlayerCrawlLeftImage
			mov contra.hImage, eax
		.endif
	.elseif contra.action == HEROACTION_RUN
		.if contra.face_direction == DIRECTION_RIGHT
			mov esi, contra.action_imageIndex
			mov eax, hPlayerMoveRightImages[esi * TYPE DWORD];
			mov contra.hImage, eax
			inc contra.action_imageIndex
			.if contra.action_imageIndex == 6
				mov contra.action_imageIndex, 0
			.endif
		.else
			mov esi, contra.action_imageIndex
			mov eax, hPlayerMoveLeftImages[esi * TYPE DWORD];
			mov contra.hImage, eax
			inc contra.action_imageIndex
			.if contra.action_imageIndex == 6
				mov contra.action_imageIndex, 0
			.endif
		.endif
	.elseif contra.action == HEROACTION_DIVE
		.if contra.jump_height < CONTRA_FLOAT_HEIGHT
			mov contra.move_dy, -CONTRA_FLOAT_SPEED
			add contra.jump_height, CONTRA_FLOAT_SPEED
		.else
			mov contra.move_dy, CONTRA_FLOAT_SPEED
		.endif
			mov eax, hPlayerDiveImage
			mov contra.hImage, eax
	.elseif contra.action == HEROACTION_FALL
		.if contra.face_direction == DIRECTION_RIGHT
			mov eax, hPlayerFallRightImage;
			mov contra.hImage, eax
		.else
			mov eax, hPlayerFallLeftImage;
			mov contra.hImage, eax
		.endif
	.else
		.if contra.face_direction == DIRECTION_RIGHT
			mov eax, hPlayerStandRightImage;
			mov contra.hImage, eax
		.else
			mov eax, hPlayerStandLeftImage;
			mov contra.hImage, eax
		.endif
	.endif
		
	invoke CollisionBackgroundJudge, addr contra, addr background

	 
    .if contra.action == HEROACTION_DIE && contra.action_imageIndex == 7
		invoke InitContra, addr contra 
		mov eax, hPlayerJumpRightImages
		mov contra.hImage, eax
	.endif		

	; blink when invincible
	.if contra.invincible_time > 0
		mov eax, contra.invincible_time
		mov bl, 2
		div bl
		.if ah == 0
			mov contra.hImage, 0
		.endif
		dec contra.invincible_time
	.elseif contra.action != HEROACTION_DIE
		invoke CollisionBulletJudge, addr contra, addr enemyBullets
		invoke CollisionEnemyJudge, addr contra, addr staticRobotQueue
		invoke CollisionEnemyJudge, addr contra, addr dynamicRobotQueue
	.endif

	.if contra.shoot == 1 && contra.action != HEROACTION_DIE
		invoke OpenFire, addr contraBullets, addr contra
	.endif

	; keep contra in the view
	mov background.move_length, 0
	.if contra.position.pos_x > 210 && contra.move_dx > 0
		mov eax, CONTRA_BASIC_MOV_SPEED
		sub background.b_offset, eax
		mov background.move_length, eax	
		invoke UpdateHeroPosition, addr contra, eax
	.elseif contra.position.pos_x < 5 && contra.move_dx < 0
		mov contra.move_dx, 0
		invoke UpdateHeroPosition, addr contra, 0
	.else
		invoke UpdateHeroPosition, addr contra, 0
	.endif
	ret
 ContraTakeAction ENDP

 StaticRobotsTakeAction PROC USES edi esi
	local index: DWORD
	mov ecx, staticRobotQueue.number
	mov index, ecx
	mov eax, TYPE Hero
	mul cl
	lea esi, staticRobotQueue.robots[eax]
	
	.while index > 0
		dec index
		sub esi, TYPE Hero

		.if [esi].Hero.action == HEROACTION_GONE 
			.continue
		.endif

		; turn to contra
		mov eax, [esi].Hero.range.position.pos_x
		add eax, 40
		mov ebx, [esi].Hero.range.position.pos_x
		sub ebx, 40
		.if contra.range.position.pos_x > eax
			mov [esi].Hero.face_direction, DIRECTION_RIGHT
			mov [esi].Hero.shoot_dx, 1
		.elseif contra.range.position.pos_x < ebx
			mov [esi].Hero.face_direction, DIRECTION_LEFT
			mov [esi].Hero.shoot_dx, -1
		.else
			mov [esi].Hero.shoot_dx, 0
		.endif

		mov eax, [esi].Hero.range.position.pos_y
		add eax, 80
		mov ebx, [esi].Hero.range.position.pos_y
		sub ebx, 80

		.if contra.range.position.pos_y > eax
			mov [esi].Hero.shoot_dy, 1
		.elseif contra.range.position.pos_y < ebx
			mov [esi].Hero.shoot_dy, -1
		.else
			.if [esi].Hero.shoot_dx == 0
				mov [esi].Hero.shoot_dx, 1
			.endif
				mov [esi].Hero.shoot_dy, 0
		.endif
 		mov ebx, [esi].Hero.weapon.bullet_speed
		mov eax, [esi].Hero.shoot_dx
		imul bl
		mov [esi].Hero.shoot_dx, eax
		mov eax, [esi].Hero.shoot_dy
		imul bl
		mov [esi].Hero.shoot_dy, eax

		.if [esi].Hero.action == HEROACTION_DIE
			.if [esi].Hero.face_direction == DIRECTION_RIGHT
				mov [esi].Hero.move_dx, -CONTRA_BASIC_MOV_SPEED
				mov edi, [esi].Hero.action_imageIndex
				mov eax, hStaticRobotDieRightImages[edi * TYPE DWORD];
				mov [esi].Hero.hImage, eax
				inc [esi].Hero.action_imageIndex
				.if [esi].Hero.action_imageIndex == 4
					invoke UpdateHeroAction, esi, HEROACTION_GONE
					.continue
				.endif		
			.else
				mov [esi].Hero.move_dx, CONTRA_BASIC_MOV_SPEED
				mov edi, [esi].Hero.action_imageIndex
				mov eax, hStaticRobotDieLeftImages[edi * TYPE DWORD];
				mov [esi].Hero.hImage, eax
				inc [esi].Hero.action_imageIndex
				.if [esi].Hero.action_imageIndex == 4
					invoke UpdateHeroAction, esi, HEROACTION_GONE
					.continue
				.endif
			.endif
		.elseif [esi].Hero.action == HEROACTION_STAND
			.if [esi].Hero.face_direction == DIRECTION_RIGHT
				.if [esi].Hero.shoot_dy > 0
					mov eax, hStaticRobotShootRightDownImages
				.elseif [esi].Hero.shoot_dy < 0
					mov eax, hStaticRobotShootRightUpImages
				.else
					mov eax, hStaticRobotShootRightImages
				.endif
				mov [esi].Hero.hImage, eax
			.else
				.if [esi].Hero.shoot_dy > 0
					mov eax, hStaticRobotShootLeftDownImages
				.elseif [esi].Hero.shoot_dy < 0
					mov eax, hStaticRobotShootLeftUpImages
				.else
					mov eax, hStaticRobotShootLeftImages
				.endif
				mov [esi].Hero.hImage, eax
			.endif
		.endif

		.if [esi].Hero.shoot == 1 && [esi].Hero.action != HEROACTION_DIE
			invoke OpenFire, addr enemyBullets, esi
		.endif
		
		.if [esi].Hero.action != HEROACTION_DIE
			invoke CollisionBackgroundJudge, esi, addr background
			invoke CollisionBulletJudge, esi, addr contraBullets
		.endif	
		
		invoke UpdateHeroPosition, esi, background.move_length
		invoke isHeroOutofScreen, esi
		.if eax == 1
			invoke UpdateHeroAction, esi, HEROACTION_GONE
		.endif
	.endw
	ret
 StaticRobotsTakeAction ENDP 

 DynamicRobotsTakeAction PROC USES edi esi
	local index: DWORD
	mov ecx, dynamicRobotQueue.number
	mov index, ecx
		mov eax, TYPE Hero
	mul cl
	lea esi, dynamicRobotQueue.robots[eax]
	
	.while index > 0
		dec index
		sub esi, TYPE Hero
	 
			.if [esi].Hero.action == HEROACTION_DIE
				.if [esi].Hero.face_direction == DIRECTION_RIGHT
					mov [esi].Hero.move_dx, -CONTRA_BASIC_MOV_SPEED
					mov edi, [esi].Hero.action_imageIndex
					mov eax, hDynamicRobotDieRightImages[edi * TYPE DWORD];
					mov [esi].Hero.hImage, eax
					inc [esi].Hero.action_imageIndex
					.if [esi].Hero.action_imageIndex == 4
						invoke DeleteRobot, addr dynamicRobotQueue, index
						.continue
					.endif		
				.else
					mov [esi].Hero.move_dx, CONTRA_BASIC_MOV_SPEED
					mov edi, [esi].Hero.action_imageIndex
					mov eax, hDynamicRobotDieLeftImages[edi * TYPE DWORD];
					mov [esi].Hero.hImage, eax
					inc [esi].Hero.action_imageIndex
					.if [esi].Hero.action_imageIndex == 4
						invoke DeleteRobot, addr dynamicRobotQueue, index
						.continue
					.endif
				.endif
			.elseif [esi].Hero.action == HEROACTION_JUMP
				.if [esi].Hero.jump_height < MAX_JUMP_HEIGHT
					mov [esi].Hero.move_dy, -CONTRA_BASIC_JUMP_SPEED
					add [esi].Hero.jump_height, CONTRA_BASIC_JUMP_SPEED
				.else
					mov [esi].Hero.move_dy, CONTRA_BASIC_JUMP_SPEED
				.endif
				.if [esi].Hero.face_direction == DIRECTION_RIGHT
					mov eax, hDynamicRobotJumpRightImage;
					mov [esi].Hero.hImage, eax
				.else
					mov eax, hDynamicRobotJumpLeftImage;
					mov [esi].Hero.hImage, eax
				.endif
			.elseif [esi].Hero.action == HEROACTION_RUN
				.if [esi].Hero.face_direction == DIRECTION_RIGHT
					mov edi, [esi].Hero.action_imageIndex
					mov eax, hDynamicRobotRunRightImages[edi * TYPE DWORD];
					mov [esi].Hero.hImage, eax
					inc [esi].Hero.action_imageIndex
					.if [esi].Hero.action_imageIndex == 4
						mov [esi].Hero.action_imageIndex, 0
					.endif
				.else
					mov edi, [esi].Hero.action_imageIndex
					mov eax, hDynamicRobotRunLeftImages[edi * TYPE DWORD];
					mov [esi].Hero.hImage, eax
					inc [esi].Hero.action_imageIndex
					.if [esi].Hero.action_imageIndex == 4
						mov [esi].Hero.action_imageIndex, 0
					.endif
				.endif
			.elseif [esi].Hero.action == HEROACTION_FALL
				.if [esi].Hero.face_direction == DIRECTION_RIGHT
					mov eax, hDynamicRobotJumpRightImage;
					mov [esi].Hero.hImage, eax
				.else
					mov eax, hDynamicRobotJumpLeftImage;
					mov [esi].Hero.hImage, eax
				.endif
			.else
			.endif
		
		.if [esi].Hero.action != HEROACTION_DIE
			invoke CollisionBackgroundJudge, esi, addr background
			invoke CollisionBulletJudge, esi, addr contraBullets
		.endif	
		
		invoke UpdateHeroPosition, esi, background.move_length
		.if [esi].Hero.action == HEROACTION_SWIM
			invoke DeleteRobot, addr dynamicRobotQueue, index
		.endif
		invoke isHeroOutofScreen, esi
		.if eax == 1
			invoke DeleteRobot, addr dynamicRobotQueue, index
		.endif
	.endw

	ret
 DynamicRobotsTakeAction ENDP 

 TowerTakeAction PROC USES edi esi
	local index: DWORD
	mov ecx, towerQueue.number
	mov index, ecx
	mov eax, TYPE Hero
	mul cl
	lea esi, towerQueue.robots[eax]
	
	.while index > 0
		dec index
		sub esi, TYPE Hero

		.if [esi].Hero.action == HEROACTION_GONE 
			.continue
		.endif
		; turn to contra
		mov eax, [esi].Hero.range.position.pos_x
		add eax, 40
		mov ebx, [esi].Hero.range.position.pos_x
		sub ebx, 40
		.if contra.range.position.pos_x > eax
			mov [esi].Hero.face_direction, DIRECTION_RIGHT
			mov [esi].Hero.shoot_dx, 1
		.elseif contra.range.position.pos_x < ebx
			mov [esi].Hero.face_direction, DIRECTION_LEFT
			mov [esi].Hero.shoot_dx, -1
		.else
			mov [esi].Hero.shoot_dx, 0
		.endif

		mov eax, [esi].Hero.range.position.pos_y
		add eax, 80
		mov ebx, [esi].Hero.range.position.pos_y
		sub ebx, 80

		.if contra.range.position.pos_y > eax
			mov [esi].Hero.shoot_dy, 1
		.elseif contra.range.position.pos_y < ebx
			mov [esi].Hero.shoot_dy, -1
		.else
			.if [esi].Hero.shoot_dx == 0
				mov [esi].Hero.shoot_dx, 1
			.endif
				mov [esi].Hero.shoot_dy, 0
		.endif
 		mov ebx, [esi].Hero.weapon.bullet_speed
		mov eax, [esi].Hero.shoot_dx
		imul bl
		mov [esi].Hero.shoot_dx, eax
		mov eax, [esi].Hero.shoot_dy
		imul bl
		mov [esi].Hero.shoot_dy, eax

		.if [esi].Hero.action == TOWERACTION_OPEN
			mov edi, [esi].Hero.action_imageIndex
			mov eax, hTowerShowupImages[edi *TYPE DWORD]
			mov [esi].Hero.hImage, eax
			inc [esi].Hero.action_imageIndex
			.if [esi].Hero.action_imageIndex == 4
				mov [esi].Hero.action, HEROACTION_STAND
			.endif
		.elseif [esi].Hero.action == HEROACTION_DIE
			.if [esi].Hero.face_direction == DIRECTION_RIGHT
				mov edi, [esi].Hero.action_imageIndex
				mov eax, hTowerBoomImages[edi * TYPE DWORD];
				mov [esi].Hero.hImage, eax
				inc [esi].Hero.action_imageIndex
				.if [esi].Hero.action_imageIndex == 2
					invoke UpdateHeroAction, esi, HEROACTION_GONE
					.continue
				.endif		
			.else
				mov edi, [esi].Hero.action_imageIndex
				mov eax, hTowerBoomImages[edi * TYPE DWORD];
				mov [esi].Hero.hImage, eax
				inc [esi].Hero.action_imageIndex
				.if [esi].Hero.action_imageIndex == 2
					invoke UpdateHeroAction, esi, HEROACTION_GONE
					.continue
				.endif
			.endif
		.elseif [esi].Hero.action == HEROACTION_STAND
			.if [esi].Hero.shoot_dx > 0
				.if [esi].Hero.shoot_dy > 0
					mov eax, 4
				.elseif [esi].Hero.shoot_dy < 0
					mov eax, 1
				.else
					mov eax, 3
				.endif
			.elseif [esi].Hero.shoot_dx < 0
				.if [esi].Hero.shoot_dy > 0
					mov eax, 7
				.elseif [esi].Hero.shoot_dy < 0
					mov eax, 8
				.else
					mov eax, 9
				.endif
			.else
				.if [esi].Hero.shoot_dy > 0
					mov eax, 6
				.else
					mov eax, 2
				.endif
			.endif
				dec eax
				mov eax, hTowerImages[eax * TYPE DWORD]
				mov [esi].Hero.hImage, eax
		.endif	

		.if [esi].Hero.shoot == 1 && [esi].Hero.action == HEROACTION_STAND
			invoke OpenFire, addr enemyBullets, esi
		.endif

		.if [esi].Hero.action == HEROACTION_STAND
			invoke CollisionBulletJudge, esi, addr contraBullets
		.endif	
		
		mov [esi].Hero.move_dx, 0
		mov [esi].Hero.move_dy, 0
		invoke UpdateHeroPosition, esi, background.move_length

		invoke isHeroOutofScreen, esi
		.if eax == 1
			invoke UpdateHeroAction, esi, HEROACTION_GONE
		.endif
	.endw
	ret
 TowerTakeAction ENDP
 
 
 
 OpenFire PROC USES esi,
	pBullets: PTR Bullets, actor: PTR Hero
	mov esi, actor
	.if [esi].Hero.identity == HEROTYPE_BLUECONTRA
		mov eax, 1
	.else
		mov eax, 3
	.endif
	lea esi, [esi].Hero.weapon
	.if [esi].Weapon.time_to_next_shot == 0
		invoke CreateBullet, pBullets, actor, hBulletImages[eax * TYPE DWORD]
		mov eax, [esi].Weapon.shot_interval_time
		mov [esi].Weapon.time_to_next_shot, eax
	.else
		dec [esi].Weapon.time_to_next_shot
	.endif
	ret	
 OpenFire ENDP
 
 BulletsMove PROC USES ebx
	local cnt: DWORD
	mov eax, contraBullets.number
	mov cnt, eax
	.while cnt > 0
		mov eax, cnt
		dec eax
		mov bl, TYPE Bullet
		mul bl
		mov esi, eax

		mov eax, contraBullets.bullets[esi].move_dx
		add contraBullets.bullets[esi].position.pos_x, eax
		add contraBullets.bullets[esi].range.position.pos_x, eax
		mov eax, background.move_length
		sub contraBullets.bullets[esi].position.pos_x, eax
		sub contraBullets.bullets[esi].range.position.pos_x, eax
		mov eax, contraBullets.bullets[esi].move_dy
		add contraBullets.bullets[esi].position.pos_y, eax
		add contraBullets.bullets[esi].range.position.pos_y, eax

		mov eax, contraBullets.bullets[esi].position.pos_x
		mov ebx, contraBullets.bullets[esi].position.pos_y
		
		dec cnt 
		.if eax > SCREEN_WIDTH || ebx > SCREEN_HEIGHT 
			invoke DeleteBullet, addr contraBullets, cnt
		.endif
	.endw

	mov eax, enemyBullets.number
	mov cnt, eax
	.while cnt > 0
		mov eax, cnt
		dec eax
		mov bl, TYPE Bullet
		mul bl
		mov esi, eax

		mov eax, enemyBullets.bullets[esi].move_dx
		add enemyBullets.bullets[esi].position.pos_x, eax
		add enemyBullets.bullets[esi].range.position.pos_x, eax
		mov eax, background.move_length
		sub enemyBullets.bullets[esi].position.pos_x, eax
		sub enemyBullets.bullets[esi].range.position.pos_x, eax
		mov eax, enemyBullets.bullets[esi].move_dy
		add enemyBullets.bullets[esi].position.pos_y, eax
		add enemyBullets.bullets[esi].range.position.pos_y, eax

		mov eax, enemyBullets.bullets[esi].position.pos_x
		mov ebx, enemyBullets.bullets[esi].position.pos_y
		
		dec cnt 
		.if eax > SCREEN_WIDTH || ebx > SCREEN_HEIGHT 
			invoke DeleteBullet, addr enemyBullets, cnt
		.endif
	.endw
	ret
 BulletsMove ENDP

; ==============================  Functions
;;;;;;;;
;;;;;;;;
 isHeroOutofScreen PROC USES esi,
    hero:PTR Hero
	local x:SDWORD
	local y:SDWORD

	mov esi, hero
	mov eax, [esi].Hero.range.position.pos_x
	mov x, eax
	mov eax, [esi].Hero.range.position.pos_y
	mov y, eax
	.if x > SCREEN_WIDTH + 100 || y > SCREEN_HEIGHT
		mov eax, 1
		ret
	.endif
	
	mov eax, [esi].Hero.range.r_width
	mov ebx, [esi].Hero.range.r_height
	add x, eax
	add y, ebx

	.if x < -100 || y < -100
		mov eax, 1
		ret
	.endif

	mov eax, 0
	ret
 isHeroOutofScreen ENDP
  UnicodeStr	PROC USES esi Source:DWORD,Dest:DWORD
												; convert a string to UNICODE
	mov		esi,Source
	mov		edx,Dest
	xor		eax,eax
	sub		eax,1
@@:
	add		eax,1
	movzx	ecx,BYTE PTR [esi+eax]
	mov		WORD PTR [edx+eax*2],cx
	test	ecx,ecx
	jnz		@b
	ret

UnicodeStr	ENDP
 StrConcat PROC USES esi edi ecx,
	target : PTR BYTE,
	source : PTR BYTE
	
	cld
	INVOKE StrLen, [target]
	mov edi, eax
	add edi, target
	mov esi, source
	INVOKE StrLen, [source]
	mov ecx, eax
	inc ecx
	rep movsb
	INVOKE StrLen, [target]
	ret
StrConcat ENDP
end start 