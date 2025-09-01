.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\wininet.inc
include \masm32\include\shlwapi.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\wininet.lib
includelib \masm32\lib\shlwapi.lib
includelib \masm32\lib\masm32.lib

; Constants
WINDOW_WIDTH equ 135
WINDOW_HEIGHT equ 50
BTN_SIZE equ 16
ID_TIMER equ 1

; Button IDs
BTN_CLOSE equ 1001
BTN_COLOR equ 1002
BTN_FREQ equ 1003
BTN_OPACITY equ 1004

.data
    ClassName db "TONWidgetClass", 0
    AppName db "TON Crypto Widget", 0
    PriceText db "TON: N/A USD", 0
    BtnCloseText db "X", 0
    BtnColorText db "C", 0
    BtnFreqText db "F", 0
    BtnOpacityText db "O", 0
    ButtonClassName db "BUTTON", 0
    ApiHost db "api.coingecko.com", 0
    ApiUrl db "/api/v3/simple/price?ids=the-open-network&vs_currencies=usd", 0
    UserAgent db "TON Price Widget", 0
    GetMethod db "GET", 0
    ErrorMsg db "TON: Error USD", 0
    TonPrefix db "TON: ", 0
    UsdSuffix db " USD", 0
    UsdStr db "usd", 0
    FontName db "Arial", 0
    Buffer db 1024 dup(0)
    Price db 32 dup(0)
    DisplayText db 32 dup(0)
    TextColors dd 00FF00h, 0FFFFFFh, 0FFAAAAh, 00AAAAh, 0FFFF00h ; green, white, light red, light blue, yellow
    CurrentColorIndex dd 0
    OpacityLevels db 204, 230, 255 ; 80%, 90%, 100%
    CurrentOpacityIndex dd 0
    UpdateFrequencies dd 60000, 300000, 600000 ; 1min, 5min, 10min
    CurrentFreqIndex dd 0
    Dragging db 0
    ; Добавляем переменные для хранения начальной позиции окна и курсора
    StartWindowPos POINT <>
    StartCursorPos POINT <>

.data?
    hInstance HINSTANCE ?
    hWnd HWND ?
    hdc HDC ?
    ps PAINTSTRUCT <>
    rect RECT <>
    x dd ?
    y dd ?
    hInternet dd ?
    hConnection dd ?
    hRequest dd ?
    msg MSG <>

.code
start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax
    
    call MainWindow
    
    invoke ExitProcess, 0

MainWindow proc
    LOCAL wc:WNDCLASSEX
    
    ; Register window class
    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, OFFSET WndProc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    push hInstance
    pop wc.hInstance
    mov wc.hIcon, 0
    invoke LoadCursor, NULL, IDC_ARROW
    mov wc.hCursor, eax
    mov wc.hbrBackground, COLOR_BTNFACE+1
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, OFFSET ClassName
    mov wc.hIconSm, 0
    
    invoke RegisterClassEx, ADDR wc
    
    ; Create main window
    mov eax, WS_EX_TOPMOST
    or eax, WS_EX_TOOLWINDOW
    invoke CreateWindowEx, eax, 
                         ADDR ClassName, 
                         ADDR AppName,
                         WS_POPUP or WS_VISIBLE or WS_BORDER, 
                         100, 100, 
                         WINDOW_WIDTH, WINDOW_HEIGHT, 
                         NULL, NULL, hInstance, NULL
    mov hWnd, eax
    
    ; Create close button
    invoke CreateWindowEx, 0, 
                         ADDR ButtonClassName, 
                         ADDR BtnCloseText,
                         WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 
                         WINDOW_WIDTH-BTN_SIZE, 0, 
                         BTN_SIZE, BTN_SIZE, 
                         hWnd, BTN_CLOSE, hInstance, NULL
    
    ; Create color button
    invoke CreateWindowEx, 0, 
                         ADDR ButtonClassName, 
                         ADDR BtnColorText,
                         WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 
                         0, 0, 
                         BTN_SIZE, BTN_SIZE, 
                         hWnd, BTN_COLOR, hInstance, NULL
    
    ; Create frequency button
    invoke CreateWindowEx, 0, 
                         ADDR ButtonClassName, 
                         ADDR BtnFreqText,
                         WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 
                         0, WINDOW_HEIGHT-BTN_SIZE, 
                         BTN_SIZE, BTN_SIZE, 
                         hWnd, BTN_FREQ, hInstance, NULL
    
    ; Create opacity button
    invoke CreateWindowEx, 0, 
                         ADDR ButtonClassName, 
                         ADDR BtnOpacityText,
                         WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 
                         WINDOW_WIDTH-BTN_SIZE, WINDOW_HEIGHT-BTN_SIZE, 
                         BTN_SIZE, BTN_SIZE, 
                         hWnd, BTN_OPACITY, hInstance, NULL
    
    ; Initialize Internet connection
    invoke InternetOpen, ADDR UserAgent, INTERNET_OPEN_TYPE_DIRECT, NULL, NULL, 0
    .IF eax != NULL
        mov hInternet, eax
        ; Fetch initial data
        call FetchTONPrice
        ; Set timer for updates
        mov eax, [UpdateFrequencies]
        invoke SetTimer, hWnd, ID_TIMER, eax, NULL
    .ENDIF
    
    ; Apply transparency
    mov eax, WS_EX_LAYERED
    or eax, WS_EX_TOPMOST
    or eax, WS_EX_TOOLWINDOW
    invoke SetWindowLong, hWnd, GWL_EXSTYLE, eax
    mov eax, [CurrentOpacityIndex]
    movzx eax, byte ptr [OpacityLevels+eax]
    invoke SetLayeredWindowAttributes, hWnd, 0, eax, LWA_ALPHA
    
    ; Message loop
    .WHILE TRUE
        invoke GetMessage, ADDR msg, NULL, 0, 0
        .BREAK .IF (!eax)
        invoke TranslateMessage, ADDR msg
        invoke DispatchMessage, ADDR msg
    .ENDW
    
    ; Clean up
    .IF hInternet != NULL
        invoke InternetCloseHandle, hInternet
    .ENDIF
    
    mov eax, msg.wParam
    ret
MainWindow endp

FetchTONPrice proc
    LOCAL dwRead:DWORD
    LOCAL jsonStart:DWORD
    LOCAL valueStart:DWORD
    LOCAL valueEnd:DWORD
    
    ; Clear buffer
    invoke RtlZeroMemory, ADDR Buffer, 1024
    
    ; Connect to API server
    invoke InternetConnect, hInternet, ADDR ApiHost, INTERNET_DEFAULT_HTTPS_PORT, NULL, NULL, INTERNET_SERVICE_HTTP, 0, 0
    .IF eax == NULL
        mov esi, OFFSET ErrorMsg
        mov edi, OFFSET DisplayText
        mov ecx, 14
        rep movsb
        ret
    .ENDIF
    mov hConnection, eax
    
    ; Create HTTP request
    invoke HttpOpenRequest, hConnection, ADDR GetMethod, ADDR ApiUrl, NULL, NULL, NULL, INTERNET_FLAG_SECURE, 0
    .IF eax == NULL
        invoke InternetCloseHandle, hConnection
        mov esi, OFFSET ErrorMsg
        mov edi, OFFSET DisplayText
        mov ecx, 14
        rep movsb
        ret
    .ENDIF
    mov hRequest, eax
    
    ; Send request
    invoke HttpSendRequest, hRequest, NULL, 0, NULL, 0
    .IF eax == 0
        invoke InternetCloseHandle, hRequest
        invoke InternetCloseHandle, hConnection
        mov esi, OFFSET ErrorMsg
        mov edi, OFFSET DisplayText
        mov ecx, 14
        rep movsb
        ret
    .ENDIF
    
    ; Read response
    mov dwRead, 0
    invoke InternetReadFile, hRequest, ADDR Buffer, 1023, ADDR dwRead
    .IF eax == 0
        invoke InternetCloseHandle, hRequest
        invoke InternetCloseHandle, hConnection
        mov esi, OFFSET ErrorMsg
        mov edi, OFFSET DisplayText
        mov ecx, 14
        rep movsb
        ret
    .ENDIF
    
    ; Check if we got data
    cmp dwRead, 0
    jne parse_data
    
    ; No data, set error
    invoke InternetCloseHandle, hRequest
    invoke InternetCloseHandle, hConnection
    mov esi, OFFSET ErrorMsg
    mov edi, OFFSET DisplayText
    mov ecx, 14
    rep movsb
    ret
    
parse_data:
    ; Ensure buffer is null-terminated
    mov ebx, dwRead
    mov byte ptr [Buffer+ebx], 0
    
    ; Parse JSON response to find the price
    invoke StrStrIA, ADDR Buffer, ADDR UsdStr ; €спользуем StrStrIA из masm32.inc
    .IF eax == NULL
        invoke InternetCloseHandle, hRequest
        invoke InternetCloseHandle, hConnection
        mov esi, OFFSET ErrorMsg
        mov edi, OFFSET DisplayText
        mov ecx, 14
        rep movsb
        ret
    .ENDIF
    
    add eax, 5 ; Skip "usd":
    mov jsonStart, eax
    
    ; Find the value
    .WHILE byte ptr [eax] == ' ' || byte ptr [eax] == '"'
        inc eax
    .ENDW
    mov valueStart, eax
    
    ; Find end of value
    mov ebx, 0 ; Counter to prevent endless loop
    .WHILE byte ptr [eax] != 0 && byte ptr [eax] != ',' && byte ptr [eax] != '}'
        inc eax
        inc ebx
        cmp ebx, 30
        jge end_find_value ; Safety limit
    .ENDW
end_find_value:
    mov valueEnd, eax
    
    ; Calculate length and copy value
    mov ecx, valueEnd
    sub ecx, valueStart
    .IF ecx > 30
        mov ecx, 30
    .ENDIF
    
    push ecx ; Save length for copy
    
    ; Zero out price buffer
    invoke RtlZeroMemory, ADDR Price, 32
    
    pop ecx ; Restore length
    
    ; Copy price value
    mov esi, valueStart
    mov edi, OFFSET Price
    cmp ecx, 0
    jle skip_copy ; Skip if no length
    rep movsb
skip_copy:
    
    ; Format display text
    invoke RtlZeroMemory, ADDR DisplayText, 32
    
    ; Copy prefix
    mov esi, OFFSET TonPrefix
    mov edi, OFFSET DisplayText
    mov ecx, 5
    rep movsb
    
    ; Concatenate price and suffix
    invoke lstrcat, ADDR DisplayText, ADDR Price
    invoke lstrcat, ADDR DisplayText, ADDR UsdSuffix
    
    ; Clean up handles
    invoke InternetCloseHandle, hRequest
    invoke InternetCloseHandle, hConnection
    
    ; Refresh display
    invoke InvalidateRect, hWnd, NULL, TRUE
    
    ret
FetchTONPrice endp

CycleBgOpacity proc
    ; Cycle through opacity levels
    inc [CurrentOpacityIndex]
    .IF [CurrentOpacityIndex] >= 3
        mov [CurrentOpacityIndex], 0
    .ENDIF
    
    ; Get current opacity value
    mov eax, [CurrentOpacityIndex]
    movzx eax, byte ptr [OpacityLevels+eax]
    
    ; Set new opacity
    invoke SetLayeredWindowAttributes, hWnd, 0, eax, LWA_ALPHA
    ret
CycleBgOpacity endp

CycleTextColor proc
    ; Cycle through text colors
    inc [CurrentColorIndex]
    .IF [CurrentColorIndex] >= 5
        mov [CurrentColorIndex], 0
    .ENDIF
    
    ; Refresh display to show new color
    invoke InvalidateRect, hWnd, NULL, TRUE
    ret
CycleTextColor endp

CycleUpdateFrequency proc
    ; Cycle through update frequencies
    inc [CurrentFreqIndex]
    .IF [CurrentFreqIndex] >= 3
        mov [CurrentFreqIndex], 0
    .ENDIF
    
    ; Get current frequency
    mov eax, [CurrentFreqIndex]
    shl eax, 2 ; Multiply by 4 for DWORD array
    add eax, OFFSET UpdateFrequencies
    mov eax, [eax]
    
    ; Reset timer with new frequency
    invoke KillTimer, hWnd, ID_TIMER
    invoke SetTimer, hWnd, ID_TIMER, eax, NULL
    ret
CycleUpdateFrequency endp

WndProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL hFont:HFONT
    LOCAL textColor:DWORD
    LOCAL pt:POINT
    LOCAL rectBtn:RECT
    LOCAL hBtn:HWND

    .IF uMsg == WM_TIMER
        .IF wParam == ID_TIMER
            call FetchTONPrice
        .ENDIF
        
    .ELSEIF uMsg == WM_PAINT
        invoke BeginPaint, hWin, ADDR ps
        mov hdc, eax
        invoke SetBkMode, hdc, TRANSPARENT
        
        ; Get current text color
        mov eax, [CurrentColorIndex]
        shl eax, 2 ; Multiply by 4 for DWORD array
        add eax, OFFSET TextColors
        mov eax, [eax]
        mov textColor, eax
        
        invoke SetTextColor, hdc, textColor
        
        ; Create font for display
        invoke CreateFont, 14, 0, 0, 0, FW_BOLD, 0, 0, 0, DEFAULT_CHARSET,
                         OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,
                         DEFAULT_PITCH, ADDR FontName
        mov hFont, eax
        invoke SelectObject, hdc, hFont
        
        ; Get string length and display
        invoke lstrlen, ADDR DisplayText
        invoke TextOut, hdc, 18, 20, ADDR DisplayText, eax
        invoke DeleteObject, hFont
        invoke EndPaint, hWin, ADDR ps
        
    .ELSEIF uMsg == WM_LBUTTONDOWN
        ; Check if click is on a button
        mov eax, lParam
        mov pt.x, eax
        and pt.x, 0FFFFh
        mov pt.y, eax
        shr pt.y, 16
        
        ; Check close button
        invoke GetDlgItem, hWin, BTN_CLOSE
        mov hBtn, eax
        invoke GetWindowRect, hBtn, ADDR rectBtn
        invoke PtInRect, ADDR rectBtn, pt.x, pt.y
        .IF eax
            jmp not_dragging
        .ENDIF
        
        ; Check color button
        invoke GetDlgItem, hWin, BTN_COLOR
        mov hBtn, eax
        invoke GetWindowRect, hBtn, ADDR rectBtn
        invoke PtInRect, ADDR rectBtn, pt.x, pt.y
        .IF eax
            jmp not_dragging
        .ENDIF
        
        ; Check frequency button
        invoke GetDlgItem, hWin, BTN_FREQ
        mov hBtn, eax
        invoke GetWindowRect, hBtn, ADDR rectBtn
        invoke PtInRect, ADDR rectBtn, pt.x, pt.y
        .IF eax
            jmp not_dragging
        .ENDIF
        
        ; Check opacity button
        invoke GetDlgItem, hWin, BTN_OPACITY
        mov hBtn, eax
        invoke GetWindowRect, hBtn, ADDR rectBtn
        invoke PtInRect, ADDR rectBtn, pt.x, pt.y
        .IF eax
            jmp not_dragging
        .ENDIF
        
        ; If not on any button, start dragging
        mov Dragging, 1
        invoke SetCapture, hWin
        
        ; Get initial cursor position in screen coordinates
        invoke GetCursorPos, ADDR StartCursorPos
        
        ; Get initial window position
        invoke GetWindowRect, hWin, ADDR rect
        mov eax, rect.left
        mov StartWindowPos.x, eax
        mov eax, rect.top
        mov StartWindowPos.y, eax
        
        jmp dragging_handled
        
    not_dragging:
        ; Let buttons handle the click
        invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ret
        
    dragging_handled:
        
    .ELSEIF uMsg == WM_MOUSEMOVE
        .IF Dragging
            ; Get current cursor position
            invoke GetCursorPos, ADDR pt
            
            ; Calculate new window position
            mov eax, pt.x
            sub eax, StartCursorPos.x
            add eax, StartWindowPos.x
            mov ecx, eax
            
            mov eax, pt.y
            sub eax, StartCursorPos.y
            add eax, StartWindowPos.y
            mov edx, eax
            
            ; Move window
            invoke SetWindowPos, hWin, NULL, ecx, edx, 0, 0, SWP_NOSIZE or SWP_NOZORDER
        .ENDIF
        
    .ELSEIF uMsg == WM_LBUTTONUP
        .IF Dragging
            mov Dragging, 0
            invoke ReleaseCapture
        .ENDIF
        
    .ELSEIF uMsg == WM_COMMAND
        mov eax, wParam
        .IF eax == BTN_CLOSE
            invoke DestroyWindow, hWin
        .ELSEIF eax == BTN_COLOR
            call CycleTextColor
        .ELSEIF eax == BTN_FREQ
            call CycleUpdateFrequency
        .ELSEIF eax == BTN_OPACITY
            call CycleBgOpacity
        .ENDIF
        
    .ELSEIF uMsg == WM_DESTROY
        .IF hInternet != NULL
            invoke InternetCloseHandle, hInternet
        .ENDIF
        invoke KillTimer, hWnd, ID_TIMER
        invoke PostQuitMessage, 0
        
    .ELSE
        invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ret
    .ENDIF
    
    xor eax, eax
    ret
WndProc endp

end start
