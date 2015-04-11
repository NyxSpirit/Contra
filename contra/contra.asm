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

IDR_WAVE1 EQU 104

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
rect1	CollisionRect	<10,20,<1,2>>
rect2	CollisionRect	<50,50,<2,2>>


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
		CW_USEDEFAULT, BACKGROUNDIMAGE_UNITWIDTH * DISPLAY_SCALE * 10, BACKGROUNDIMAGE_HEIGHT * DISPLAY_SCALE , NULL,
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
	Local jumpHeight: DWORD
	Local moveImageIndex: BYTE
	LOCAL rect: RECT 
	mov jumpHeight, 0
	mov moveImageIndex, 0
	.while TRUE
		.if contra.swim == 1
			.if jumpHeight < CONTRA_FLOAT_HEIGHT
				mov contra.move_dy, -CONTRA_FLOAT_SPEED
				add jumpHeight, CONTRA_FLOAT_SPEED
			.else
				mov contra.move_dy, CONTRA_FLOAT_SPEED
			.endif
		.else
			.if contra.jump == 1 
				.if jumpHeight < MAX_JUMP_HEIGHT
					mov contra.move_dy, -CONTRA_BASIC_JUMP_SPEED
					add jumpHeight, CONTRA_BASIC_JUMP_SPEED
				.else
					mov contra.move_dy, CONTRA_BASIC_JUMP_SPEED
				.endif
			.endif
		.endif
		
		.if contra.position.pos_x > 200
			.if contra.move_dx > 0
				mov eax, contra.move_dx
				sub backgroundOffset, eax
				mov contra.move_dx, 0	
			.endif
		.endif
		mov eax, contra.move_dx
		add contra.position.pos_x, eax
		mov eax, contra.move_dy
		add contra.position.pos_y, eax

		.if contra.move_dx > 0
			.if contra.swim == 1
				mov eax, hPlayerSwimRightImage
				mov contra.hImage, eax
			.else
				inc moveImageIndex
				movzx esi, moveImageIndex
				mov eax, hPlayerMoveRightImage[esi * TYPE hPlayerMoveRightImage];
				mov contra.hImage, eax
				.if moveImageIndex == 6
					mov moveImageIndex, 1
				.endif
			.endif
		.else
			.if contra.swim == 1
				mov eax, hPlayerSwimRightImage
				mov contra.hImage, eax
			.else
				mov eax, hPlayerMoveRightImage;
				mov contra.hImage, eax
			.endif
		.endif

		invoke InvalidateRect, hWnd, NULL, 1
		;invoke UpdateWindow, hWnd
		; ================  collision check
		
		.if contra.swim == 1
			.if contra.position.pos_x > 400			;Horizon check   --- water 2 ground
				mov contra.swim, 0
				mov contra.jump, 0
				mov jumpHeight, 0	
				mov contra.move_dy, 0
				sub contra.position.pos_y, CONTRA_HEIGHT
			.endif
		.endif
		.if contra.position.pos_y > 360            ;vertical check  --- Water
			mov contra.jump, 0
			mov jumpHeight, 0	
			mov contra.move_dy, 0

			mov contra.swim, 1
		.endif
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
   LOCAL buffer [32] :BYTE
   .if uMsg == WM_CREATE
		
		mov startupinput.GdiplusVersion, 1 
		invoke GdiplusStartup, addr token, addr startupinput, NULL
		
		invoke LoadImageSeries, ADDR playerMoveRightFile, 7, addr hPlayerMoveRightImage, ADDR IMAGETYPE_PNG
		
		invoke UnicodeStr, ADDR playerSwimRightFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hPlayerSwimRightImage
		
		
		invoke UnicodeStr, ADDR wallBGFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hWallBGImage
		
		;invoke SetBKColor, hWnd, black

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
	.elseif uMsg == WM_ERASEBKGND
		
	.elseif uMsg == WM_KEYDOWN 
		invoke GetKeyboardState, addr keyState 
		.if keyState[VK_D] >= 128
			invoke TakeAction, addr contra, CMD_MOVERIGHT
		.elseif keyState[VK_A] >= 128
			invoke TakeAction, addr contra, CMD_MOVELEFT
		.endif
		.if keyState[VK_S] >= 128
			invoke TakeAction, addr contra, CMD_CRAWL
		.endif
		.if keyState[VK_K] >= 128
			invoke TakeAction, addr contra, CMD_JUMP
		.endif
		.if keyState[VK_J] >= 128
			invoke TakeAction, addr contra, CMD_SHOOT
		.endif
		invoke InvalidateRect, hWnd, NULL, 1
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
LoadImageSeries PROC, basicFileName: DWORD, number: BYTE, seriesHandle: DWORD, imageTypeName: DWORD
	LOCAL fileName [32] :BYTE
	LOCAL fileNameBuffer [32] :BYTE
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
    
	invoke PaintObject, hGraphics, addr contra
	
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
						imageWidth ,imageHeight 
	ret
 PaintObject ENDP
 PaintBackground PROC, hGraphics:DWORD
	   
	invoke GdipDrawImageRectI, hGraphics, hWallBGImage, backgroundOffset ,0, BACKGROUNDIMAGE_UNITWIDTH * DISPLAY_SCALE, BACKGROUNDIMAGE_HEIGHT * DISPLAY_SCALE 
	mov eax, backgroundOffset
	add eax, 64
	invoke GdipDrawImageRectI, hGraphics, hWallBGImage, eax ,0, BACKGROUNDIMAGE_UNITWIDTH * DISPLAY_SCALE, BACKGROUNDIMAGE_HEIGHT * DISPLAY_SCALE  
	mov eax, backgroundOffset
	add eax, 128
	invoke GdipDrawImageRectI, hGraphics, hWallBGImage, eax ,0, BACKGROUNDIMAGE_UNITWIDTH * DISPLAY_SCALE, BACKGROUNDIMAGE_HEIGHT * DISPLAY_SCALE 
	mov eax, backgroundOffset
	add eax, 192
	invoke GdipDrawImageRectI, hGraphics, hWallBGImage, eax ,0, BACKGROUNDIMAGE_UNITWIDTH * DISPLAY_SCALE, BACKGROUNDIMAGE_HEIGHT * DISPLAY_SCALE 
	ret
 PaintBackground ENDP
end start 