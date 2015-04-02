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
includelib winmm.lib
includelib shell32.lib
includelib gdi32.lib
includelib kernel32.lib
includelib user32.lib
includelib masm32.lib

IDB_BITMAP1 EQU  101
IDR_WAVE1 EQU 104

VK_LEFT EQU 025h
VK_UP EQU 026h
VK_OEM_5 EQU 0DCh

WinMain proto :DWORD, :DWORD, :DWORD, :DWORD 

.data
;============================== resources declarment=============

 ClassName db "WinClass", 0
 AppName db "Contra", 0 


 hero_posx DWORD 0
 hero_posy DWORD 0

.data?
 hInstance HINSTANCE ? 
 hBGMThread DWORD ?
 dwThreadID DWORD ?
 hBitmap dd ?
 hMusic dd ?

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
	 mov wc.hbrBackground, COLOR_WINDOW+1 
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
   .if uMsg == WM_CREATE
		invoke LoadBitmap, hInstance, IDB_BITMAP1
		mov hBitmap, eax
		
		invoke CreateThread, 0, 0, SoundProc, 0BADF00Dh,0,ADDR dwThreadID
		mov hBGMThread, eax
   .elseif uMsg == WM_PAINT 
		invoke BeginPaint,hWnd,addr ps 
		mov    hdc,eax 
		invoke CreateCompatibleDC,hdc 
		mov    hMemDC,eax 
		invoke SelectObject,hMemDC,hBitmap 
		invoke GetClientRect,hWnd,addr rect 
		invoke BitBlt,hdc,hero_posx,hero_posy,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY 
		invoke DeleteDC,hMemDC 
		invoke EndPaint,hWnd,addr ps
	.elseif uMsg == WM_KEYDOWN
		.if wParam == VK_LEFT 
			add hero_posx, 5
			invoke InvalidateRect, hWnd, NULL, 1
		.elseif wParam == VK_DOWN
			add hero_posy, 5
			invoke InvalidateRect, hWnd, NULL, 1
			mov hMusic, eax
		.elseif wParam == VK_UP
			
		.endif
	.elseif uMsg == WM_DESTROY
		invoke DeleteObject, hBitmap
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



end start 