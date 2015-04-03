.386
.model flat, stdcall
option casemap :none
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

IDR_WAVE1 EQU 104

WinMain proto :DWORD, :DWORD, :DWORD, :DWORD 
UnicodeStr			PROTO :DWORD,:DWORD
.data
;============================== resources declarment=============
 hgdiImage db "Res\\player_die_left5.png",0

 ClassName db "WinClass", 0
 AppName db "Contra", 0 


 hero_posx DWORD 0
 hero_posy DWORD 0
 


.data?
 ;=============================  Window and View Handles ========
 hInstance HINSTANCE ?
 dwThreadID DWORD ?
 hPlayerImage dd ?
 hMusic dd ?

 hBGMThread DWORD ?

 buffer dd 32 dup(?)
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
		WS_OVERLAPPEDWINDOW or WS_VISIBLE, CW_USEDEFAULT, 
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL,
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

 WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
   LOCAL ps:PAINTSTRUCT 
   LOCAL hdc:HDC 
   LOCAL hMemDC:HDC 
   LOCAL rect:RECT 
   LOCAL token:DWORD
   LOCAL startupinput: GdiplusStartupInput
   LOCAL hGraphics: DWORD
   .if uMsg == WM_CREATE
		
		mov startupinput.GdiplusVersion, 1 
		invoke GdiplusStartup, addr token, addr startupinput, NULL
		invoke	UnicodeStr,ADDR hgdiImage, ADDR buffer
		invoke GdipLoadImageFromFile, addr buffer, addr hPlayerImage
		 
		invoke CreateThread, 0, 0, SoundProc, 0BADF00Dh,0,ADDR dwThreadID
		mov hBGMThread, eax


   .elseif uMsg == WM_PAINT 

		invoke GdipCreateFromHWND, hWnd, addr hGraphics 

		invoke GdipDrawImageI, hGraphics, hPlayerImage,hero_posx,hero_posy

		invoke GdipDeleteGraphics, hGraphics
	.elseif uMsg == WM_KEYDOWN
		.if wParam == VK_RIGHT
			add hero_posx, 5
			invoke InvalidateRect, hWnd, NULL, 1
		.elseif wParam == VK_DOWN
			add hero_posy, 5
			invoke InvalidateRect, hWnd, NULL, 1
		.elseif wParam == VK_UP
			.if hero_posy >= 5
				sub hero_posy, 5
			.endif
			invoke InvalidateRect, hWnd, NULL, 1
		.endif
	.elseif uMsg == WM_DESTROY
		invoke DeleteObject, hMusic
		invoke CloseHandle,hBGMThread
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

end start 