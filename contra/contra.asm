TITLE main.asm      
    .386      
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

MAX_JUMP_HEIGHT EQU 80
CONTRA_BASIC_MOV_SPEED EQU 5
CONTRA_BASIC_JUMP_SPEED EQU 15
CONTRA_FLOAT_HEIGHT EQU 6
CONTRA_FLOAT_SPEED EQU 2
CONTRA_HEIGHT EQU 25


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
	 mov wc.hbrBackground, 1
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
		CW_USEDEFAULT, 500, 400, NULL,
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
 
 SoundProc PROC
	invoke PlaySound, IDR_WAVE1, hInstance,SND_RESOURCE or SND_ASYNC
	ret
 SoundProc ENDP

 RunProc PROC hWnd:HWND
	Local jumpHeight: DWORD
	Local moveImageIndex: BYTE
	LOCAL rect: RECT 
	mov jumpHeight, 0
	mov moveImageIndex, 0
	.while TRUE
		.if contraSwim == 1
			.if jumpHeight < CONTRA_FLOAT_HEIGHT
				mov contraMoveDy, -CONTRA_FLOAT_SPEED
				add jumpHeight, CONTRA_FLOAT_SPEED
			.else
				mov contraMoveDy, CONTRA_FLOAT_SPEED
			.endif
		.else
			.if contraJump == 1 
				.if jumpHeight < MAX_JUMP_HEIGHT
					mov contraMoveDy, -CONTRA_BASIC_JUMP_SPEED
					add jumpHeight, CONTRA_BASIC_JUMP_SPEED
				.else
					mov contraMoveDy, CONTRA_BASIC_JUMP_SPEED
				.endif
			.endif
		.endif
			
		.if contraMoveRight == 1
			mov contraMoveDx, CONTRA_BASIC_MOV_SPEED
		.elseif contraMoveLeft == 1
			mov contraMoveDx, -CONTRA_BASIC_MOV_SPEED
		.else
			mov contraMoveDx, 0
		.endif

		mov eax, contraMoveDx
		add contraPosx, eax
		mov rect.left, eax
		mov rect.right, eax
		mov eax, contraMoveDy
		add contraPosy, eax
		mov rect.top, eax
		mov rect.bottom, eax
		.if contraMoveRight == 1
			.if contraSwim == 1
				mov eax, hPlayerSwimRightImage
				mov hPlayerImage, eax
			.else
				inc moveImageIndex
				movzx esi, moveImageIndex
				mov eax, hPlayerMoveRightImage[esi * TYPE hPlayerMoveRightImage];
				mov hPlayerImage, eax
				.if moveImageIndex == 6
					mov moveImageIndex, 1
				.endif
			.endif
		.else
			.if contraSwim == 1
				mov eax, hPlayerSwimRightImage
				mov hPlayerImage, eax
			.else
				mov eax, hPlayerMoveRightImage;
				mov hPlayerImage, eax
			.endif
		.endif

		invoke InvalidateRect, hWnd, NULL, 1
		;invoke UpdateWindow, hWnd
		; ================  collision check
		.if contraSwim == 1
			.if contraPosx > 400			;Horizon check   --- water 2 ground
				mov contraSwim, 0
				mov contraJump, 0
				mov jumpHeight, 0	
				mov contraMoveDy, 0
				sub contraPosy, CONTRA_HEIGHT
			.endif
		.endif
		.if contraPosy > 300            ;vertical check  --- Water
			mov contraJump, 0
			mov jumpHeight, 0	
			mov contraMoveDy, 0

			mov contraSwim, 1
		.endif
		invoke Sleep, 100
	.endw
	ret
 RunProc ENDP

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
 
 LoadImageResources PROC
	

	ret
 LoadImageResources ENDP


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

		call LoadImageResources
		invoke LoadImageSeries, ADDR playerMoveRightFile, 7, addr hPlayerMoveRightImage, ADDR IMAGETYPE_BMP
		
		invoke UnicodeStr, ADDR playerSwimRightFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hPlayerSwimRightImage

		mov eax, hPlayerMoveRightImage;
		mov hPlayerImage, eax

		invoke UnicodeStr, ADDR wallBGFile, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hWallBGImage


		invoke CreateThread, 0, 0, SoundProc, 0, 0, ADDR dwThreadID
		mov hBGMThread, eax
		
		invoke CreateThread, 0, 0, RunProc, hWnd,0, ADDR dwThreadID
		mov hRunThread, eax
   .elseif uMsg == WM_PAINT 

		invoke GdipCreateFromHWND, hWnd, addr hGraphics 
		
		;invoke GdipGetPageScale, hGraphics, addr PAGE_SCALE

		invoke GdipDrawImageI, hGraphics, hPlayerImage,contraPosx,contraPosy
		invoke GdipDrawImageI, hGraphics, hWallBGImage, 420, 300 

		invoke GdipDeleteGraphics, hGraphics
		 
	.elseif uMsg == WM_KEYDOWN 
		invoke GetKeyboardState, addr keyState 
		.if keyState[VK_D] >= 128
			mov contraMoveRight, 1
		.elseif keyState[VK_A] >= 128
			mov contraMoveLeft, 1
		.endif
		.if keyState[VK_S] >= 128
			mov contraCrawl, 1
		.endif
		.if keyState[VK_K] >= 128
			mov contraJump, 1
		.endif
		.if keyState[VK_J] >= 128
			mov contraShoot, 1
		.endif
		invoke InvalidateRect, hWnd, NULL, 1
	.elseif uMsg == WM_KEYUP
		.if wParam == VK_D			
			mov contraMoveRight, 0
			invoke GetKeyboardState, addr keyState 
			.if keyState[VK_D] >= 128
				mov contraMoveRight, 1
			.elseif keyState[VK_A] >= 128
				mov contraMoveLeft, 1
			.endif
		.elseif wParam == VK_A
			mov contraMoveLeft, 0
		.elseif wParam == VK_J
			mov contraShoot, 0
		.elseif wParam == VK_S
			mov contraCrawl, 0
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
end start 