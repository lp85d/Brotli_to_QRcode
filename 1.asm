.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib

.data
ClassName db "SimpleWinClass", 0
AppName db "TON Crypto Widget", 0
TextMsg db "TON: 5.45 USD", 0

.data?
hInstance HINSTANCE ?
hwnd HWND ?
hdc HDC ?
ps PAINTSTRUCT <>
msg MSG <>

.const
WindowWidth equ 250
WindowHeight equ 180

.code
start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax
    
    ; Регистрация класса окна
    call RegisterWindowClass
    
    ; Создание окна
    invoke CreateWindowEx, 0, addr ClassName, addr AppName, \
                         WS_OVERLAPPEDWINDOW, 100, 100, \
                         WindowWidth, WindowHeight, NULL, NULL, \
                         hInstance, NULL
    mov hwnd, eax
    
    ; Отображение окна
    invoke ShowWindow, hwnd, SW_SHOWNORMAL
    invoke UpdateWindow, hwnd
    
    ; Цикл сообщений
    .while TRUE
        invoke GetMessage, addr msg, NULL, 0, 0
        .break .if (!eax)
        invoke TranslateMessage, addr msg
        invoke DispatchMessage, addr msg
    .endw
    
    mov eax, msg.wParam
    invoke ExitProcess, eax

RegisterWindowClass proc
    local wc:WNDCLASS
    
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, offset WndProc
    mov wc.cbClsExtra, NULL
    mov wc.cbWndExtra, NULL
    push hInstance
    pop wc.hInstance
    mov wc.hIcon, NULL
    invoke LoadCursor, NULL, IDC_ARROW
    mov wc.hCursor, eax
    mov wc.hbrBackground, COLOR_WINDOW+1
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, offset ClassName
    
    invoke RegisterClass, addr wc
    ret
RegisterWindowClass endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    .if uMsg == WM_DESTROY
        invoke PostQuitMessage, 0
    .elseif uMsg == WM_PAINT
        invoke BeginPaint, hWnd, addr ps
        mov hdc, eax
        invoke TextOut, hdc, 10, 30, addr TextMsg, sizeof TextMsg - 1
        invoke EndPaint, hWnd, addr ps
    .else
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif
    
    xor eax, eax
    ret
WndProc endp

end start