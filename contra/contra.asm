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

		invoke ContraTakeAction
		.if contra.shoot == 1
			invoke CreateBullet, addr contraBullets, addr contra, hBulletImage
		.endif
		invoke BulletsMove

		invoke InvalidateRect, hWnd, NULL, 1		
		invoke Sleep, 100
	.endw
	ret
 RunProc ENDP
 

 WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
   LOCAL ps:PAINTSTRUCT 
   LOCAL hdc:HDC 
   LOCAL hMemDC:HDC 
   LOCAL rect:RECT 
   LOCAL hGraphics: DWORD
   LOCAL buffer [64] :BYTE
   .if uMsg == WM_CREATE
		
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

		
		invoke UnicodeStr, ADDR bulletFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hBulletImage

		invoke CreateHero, addr contra 
		
		invoke CreateThread, 0, 0, SoundProc, 0, 0, ADDR dwThreadID
		mov hBGMThread, eax
		
		invoke CreateThread, 0, 0, RunProc, hWnd,0, ADDR dwThreadID
		mov hRunThread, eax

   .elseif uMsg == WM_PAINT 
		invoke BeginPaint,hWnd,addr ps 
		mov hdc, eax
		invoke CreateCompatibleDC, hdc
		mov hMemDC, eax
		invoke GdipCreateFromHDC, hdc, addr hGraphics 
		invoke GdipSetPageUnit, hGraphics, UnitPixel
		 
		invoke PaintBackground, hGraphics
		invoke PaintObjects, hGraphics

		invoke GdipDeleteGraphics, hGraphics
		invoke DeleteDC, hMemDC
		invoke EndPaint,hWnd,addr ps

	.elseif uMsg == WM_KEYDOWN 
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
				mov contra.shoot_dy, -BULLET_SPEED
			.elseif keyState[VK_S] >= 128
				mov contra.shoot_dy, BULLET_SPEED
			.else
				mov contra.shoot_dy, 0
			.endif
			.if keyState[VK_D] >= 128
				mov contra.shoot_dx, BULLET_SPEED
			.elseif keyState[VK_A] >= 128
				mov contra.shoot_dx, -BULLET_SPEED
			.elseif contra.shoot_dy == 0
				.if contra.face_direction == DIRECTION_RIGHT
					mov contra.shoot_dx, BULLET_SPEED
				.else 
					mov contra.shoot_dx, -BULLET_SPEED
				.endif
			.else
				mov contra.shoot_dx, 0
			.endif 
			invoke TakeAction, addr contra, CMD_SHOOT
		.endif
	.elseif uMsg == WM_KEYUP
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

	.elseif uMsg == WM_DESTROY
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
 SoundProc PROC
	invoke PlaySound, IDR_WAVE1, hInstance,SND_RESOURCE or SND_ASYNC
	ret
 SoundProc ENDP
 
 PaintObjects PROC, hGraphics:DWORD
    local cnt: DWORD
	invoke PaintObject, hGraphics, addr contra
	
	mov ecx, contraBullets.number
	mov cnt, ecx
	.while cnt > 0
		mov eax, cnt
		dec eax
		.if cnt == 2
			lea ecx, contraBullets.bullets[eax]
		.endif
		mov bl,TYPE Bullet
		mul bl
		invoke PaintObject, hGraphics, addr contraBullets.bullets[eax]
		dec cnt 
	.endw
	
	ret
 PaintObjects ENDP
 
 PaintObject PROC, hGraphics:DWORD, hObj:DWORD
    local imageWidth :DWORD
	local imageHeight : DWORD
	mov esi, hObj
	
	invoke GdipGetImageWidth, (Object PTR [esi]).hImage, addr imageWidth
	mov ebx,imageWidth
	mov al,DISPLAY_SCALE
	mul bx
	mov imageWidth, eax
	invoke GdipGetImageHeight, (Object PTR [esi]).hImage, addr imageHeight
	mov ebx,imageHeight
	mov al,DISPLAY_SCALE
	mul bx
	mov imageHeight, eax
	invoke GdipDrawImageRectI, hGraphics, (Object PTR [esi]).hImage,(Object PTR [esi]).position.pos_x,(Object PTR [esi]).position.pos_y,
						imageWidth, imageHeight
	ret
 PaintObject ENDP
 PaintBackground PROC, hGraphics:DWORD
	local imageWidth :DWORD   
	local imageHeight:DWORD
	;invoke GdipDrawImageRectI, hGraphics, hBackgroundImage, background.b_offset ,0, BACKGROUNDIMAGE_UNITWIDTH * DISPLAY_SCALE, BACKGROUNDIMAGE_HEIGHT * DISPLAY_SCALE 
	invoke GdipGetImageWidth, hBackgroundImage, addr imageWidth
	invoke GdipGetImageHeight, hBackgroundImage, addr imageHeight
	invoke GdipDrawImageRectI, hGraphics, hBackgroundImage, background.b_offset ,0, imageWidth , imageHeight

	invoke InitMap,addr background
	ret
 PaintBackground ENDP

 ContraTakeAction PROC
	.if contra.action == HEROACTION_DIE
		.if contra.face_direction == DIRECTION_RIGHT
			mov contra.move_dx, -CONTRA_BASIC_MOV_SPEED
			mov esi, contra.action_imageIndex
			mov eax, hPlayerDieRightImages[esi * TYPE DWORD];
			mov contra.hImage, eax
			inc contra.action_imageIndex
			.if contra.action_imageIndex == 7
				invoke CreateHero, addr contra 
			.endif
		.else
			mov contra.move_dx, CONTRA_BASIC_MOV_SPEED
			mov esi, contra.action_imageIndex
			mov eax, hPlayerDieLeftImages[esi * TYPE DWORD];
			mov contra.hImage, eax
			inc contra.action_imageIndex
			.if contra.action_imageIndex == 7
				invoke CreateHero, addr contra 
			.endif
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

	; keep contra in the view
	.if contra.position.pos_x > 250
		.if contra.move_dx > 0
			mov eax, contra.move_dx
			sub background.b_offset, eax
			mov contra.move_dx, 0	
		.endif
	.endif
	.if contra.position.pos_x < 5
		.if contra.move_dx < 0
			mov contra.move_dx, 0
		.endif
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
	.endif


	; update object positions
	invoke UpdateHeroPosition, addr contra
	ret
 ContraTakeAction ENDP

 BulletsMove PROC
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
		mov eax, contraBullets.bullets[esi].move_dy
		add contraBullets.bullets[esi].position.pos_y, eax

		mov eax, contraBullets.bullets[esi].position.pos_x
		mov ebx, contraBullets.bullets[esi].position.pos_y
		
		dec cnt 
		.if eax > SCREEN_WIDTH || ebx > SCREEN_HEIGHT 
			invoke DeleteBullet, addr contraBullets, cnt
		.endif
	.endw
	ret
 BulletsMove ENDP

end start 