;%include "nagoa+.inc"
%include "cb.inc"
API GetModuleHandleA, kernel32.dll
API RegisterClassExA, user32.dll
API SetWindowTextA,user32.dll

API LoadIconA,user32.dll
API CreateWindowExA, user32.dll
API MessageBoxA, user32.dll
API SendDlgItemMessageA,user32.dll
API SendMessageA, user32.dll
API DefWindowProcA, user32.dll
API ExitProcess, kernel32.dll
API GetMessageA, user32.dll
API DispatchMessageA, user32.dll
API TranslateMessage,user32.dll
API SetFocus,user32.dll
API SetDlgItemTextA,user32.dll

API ShowWindow,user32.dll
API UpdateWindow,user32.dll
API GetCommandLineA,kernel32.dll
API PostQuitMessage,user32.dll
API LoadCursorA,user32.dll
API LoadAcceleratorsA,user32.dll
API TranslateAcceleratorA,user32.dll

API GetStockObject,gdi32.dll
API GetOpenFileNameA,comdlg32.dll
API GetSaveFileNameA,comdlg32.dll
API EnableWindow,user32.dll


API CreateFileA,kernel32.dll
API ReadFile,kernel32.dll
API WriteFile,kernel32.dll
API GetFileSize,kernel32.dll
API GlobalAlloc,kernel32.dll
API CloseHandle,kernel32.dll
API GlobalFree,kernel32.dll

segment .data USE32
OPEN_MENUITEM EQU 1200H
SAVE_MENUITEM EQU 1201H
EXIT_MENUITEM EQU 1202H
ABOUT_MENUITEM EQU 1203H
MAINEDIT_ID EQU 1204H
BTFY_BUTTON EQU 1205H
Windowname db 'PEcb',0
CommandLine	dd 0
Windowhandle            	dd 0
Instance        	dd 0
Windowclassname db "OurWindowclass",0

menuname db "pecbmenu",0
OurWindowclass:	
istruc WNDCLASSEX
	at WNDCLASSEX.cbSize,		dd WNDCLASSEX_size
	at WNDCLASSEX.style,		dd CS_HREDRAW|CS_VREDRAW
	at WNDCLASSEX.lpfnWndProc,	dd WindowProc
	at WNDCLASSEX.hbrBackground,	dd COLOR_BTNFACE+1
	at WNDCLASSEX.lpszMenuName,	dd menuname
	at WNDCLASSEX.lpszClassName,	dd Windowclassname
iend

acctablename db "pecbacc",0
acchandle dd 0
ofn: 
istruc OPENFILENAME
	at OPENFILENAME.lStructSize, dd OPENFILENAME_size
iend 
abouttext db "  PEcb V1.05 - PowerElex C beautifier",13,10,\
		"Created using NASM win32 assembler",13,10,\
		"                                -mathi",13,10,\
		"                 mathiisalive@yahoo.com",0
		
savetitle db "Save File",0
itm1: times 128 db 0
opentitle db "Open File",0
filter db "C Source Files",0,"*.c",0,"C++ Source files",0,"*.cpp",0,"C Header files",0,"*.h",0,0
filtersave db "All Files",0,"*.*",0,0
drive db "c:\",0
fileerror db "Error opening input file",0
segment .bss USE32

MessageBuffer resb MSG_size
globalbuffer resb 1048576
auxdata resb 2096576
appname resb 4
hyphen resb 4
filename resb 1024
hEdit resd 1
hTitleEdit resd 1
hbutton resd 1
hinputfile resd 1
fileloaded resd 1
pathdir resb 1024
dirend resd 1
length resd 1
projname resd 1
currentpiecehandle resd 1
nooffile resd 1
bytestoread resd 1
actuallyread resd 1
actuallywritten resd 1
hGmem resd 1
ptrdata resd 1
joindata resb 8192 
joindatalen resd 1
joindatapos resd 1
hjoin resd 1
hmainedit resd 1
insidequote resd 1
firstspace resd 1
houtfile resd 1
bracketstack resd 1
sqbracketstack resd 1
firsttab resd 1
leadspace resd 1
no_of_tab resd 1
singstate resd 1
insidecomment resd 1
multicomment resd 1
inside_bracket_special resd 1
arrdec resd 1
preproc resd 1
segment .code USE32
..start:

call GetModuleHandleA, 0
mov dword [Instance], eax

call GetCommandLineA
mov dword [CommandLine], eax
loccall WinMain, [Instance], NULL, eax, SW_SHOW
getout:
call ExitProcess, eax
proc WinMain, hInstance, hPrevInstance, lpCmdLine, nCmdShow
       mov dword[appname],"PEcb"
       mov dword[hyphen]," -- "
       mov eax, dword [Instance]
       mov dword [OurWindowclass+WNDCLASSEX.hInstance], eax
       call LoadIconA, NULL, IDI_APPLICATION
       mov dword [OurWindowclass+WNDCLASSEX.hIcon], eax
       mov dword [OurWindowclass+WNDCLASSEX.hIconSm], eax
       call LoadCursorA, NULL, IDC_ARROW
       mov dword [OurWindowclass+WNDCLASSEX.hCursor], eax
       
       call LoadAcceleratorsA,[Instance],acctablename
       mov [acchandle],eax
       
       call RegisterClassExA,OurWindowclass
       test eax, eax
       jnz .DoAndShow
       return

.DoAndShow:
   
      ;--- create and show the main program window
	call CreateWindowExA,NULL,Windowclassname,Windowname,WS_OVERLAPPED|WS_VISIBLE|WS_CAPTION|WS_MINIMIZEBOX |WS_SYSMENU,100,100,800,600, NULL, NULL, [Instance], NULL
	mov dword [Windowhandle], eax
	call ShowWindow, [Windowhandle], [@nCmdShow]
	call UpdateWindow,[Windowhandle]

; -- every time user moves mouse or imput some msg this loop is activated
; -- in order to get all messages imputed by the user 
.loop
	call GetMessageA,MessageBuffer, NULL, 0, 0         
	cmp eax, 0
	jb .erro
	je .fin
	call TranslateAcceleratorA,[Windowhandle],[acchandle],MessageBuffer
	call TranslateMessage,MessageBuffer
	call DispatchMessageA,MessageBuffer
	jmp .loop
	.erro:
	call MessageBoxA, 0, "ERROR", "Sorry ...", MB_OK
	.fin:
	mov eax, dword[MessageBuffer+MSG.wParam]
endproc
proc WindowProc,hwnd,uMsg,wParam,lParam
	mov eax, dword [@uMsg]
	if eax,e,WM_CLOSE
		
	endif
	if eax,e,WM_DESTROY
		
		call PostQuitMessage, 0	
		xor eax,eax
	endif
	if eax,e,WM_CREATE
		%assign .style  WS_CHILD | WS_VISIBLE |ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL|WS_VSCROLL|WS_HSCROLL|ES_WANTRETURN
		call CreateWindowExA, WS_EX_CLIENTEDGE, "EDIT","",.style ,50,50,700,450,[@hwnd],MAINEDIT_ID, [Instance], NULL 
		mov [hmainedit],eax
		call CreateWindowExA,NULL,"BUTTON","Beautify",WS_CHILD |WS_TABSTOP|WS_VISIBLE|BS_PUSHBUTTON|BS_DEFPUSHBUTTON,325,10,80,30,[@hwnd],BTFY_BUTTON ,[Instance],NULL
		mov [hbutton],eax
		;call EnableWindow,[hbutton],FALSE
		
		;call GetStockObject,DEFAULT_GUI_FONT
		;call SendMessageA,[hmainedit],WM_SETFONT,eax
	endif
	if dword [@uMsg],e,WM_COMMAND
		if word [@wParam],e,ABOUT_MENUITEM
			call MessageBoxA,[@hwnd],abouttext,"PEcb",0  ; some info
		endif
		if word [@wParam],e,EXIT_MENUITEM
			call ExitProcess,0
		endif
		if word [@wParam],e,OPEN_MENUITEM
			
			mov dword[filename],0
			
			mov dword [ofn+OPENFILENAME.lStructSize],dword OPENFILENAME_size
			push dword  [Windowhandle]
			pop dword[ofn+OPENFILENAME.hwndOwner]
			push dword [OurWindowclass+WNDCLASSEX.hInstance]
			pop dword[ofn+OPENFILENAME.hInstance]
			mov dword[ofn+OPENFILENAME.lpstrFilter],dword filter
			mov dword[ofn+OPENFILENAME.lpstrFile],dword filename
			mov dword[ofn+OPENFILENAME.nMaxFile],dword 8192
			mov dword[ofn+OPENFILENAME.lpstrInitialDir],dword drive
			mov dword[ofn+OPENFILENAME.lpstrTitle],dword opentitle
			mov dword[ofn+OPENFILENAME.Flags],dword OFN_LONGNAMES ;| OFN_EXPLORER
			
			call GetOpenFileNameA,ofn ; open dialog
			or eax,eax
			jz near returnback1
			
			call CreateFileA,filename,GENERIC_READ,FILE_SHARE_READ|FILE_SHARE_DELETE|FILE_SHARE_WRITE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE, NULL
			mov [hinputfile],eax
			if eax,e,INVALID_HANDLE_VALUE
				call MessageBoxA,[@hwnd],fileerror,"ERROR",0
				jmp near returnback1
			endif
			call SetDlgItemTextA,[@hwnd],MAINEDIT_ID,""
			call GetFileSize,[hinputfile],NULL
			mov [bytestoread],eax
			
			call ReadFile,[hinputfile],globalbuffer,[bytestoread],actuallyread,NULL
			call SetWindowTextA,[@hwnd],appname
			mov eax,globalbuffer
			mov ebx,[actuallyread]
			add eax,ebx
			mov byte[eax],0
			loccall unixtowindows, globalbuffer,auxdata
			call SetDlgItemTextA,[@hwnd],MAINEDIT_ID,auxdata
			loccall getlatestdir,filename
			;call EnableWindow,[hbutton],TRUE
			call CloseHandle,[hinputfile]
			call SetFocus,[hbutton]
			returnback1:
			return		
		endif
		if word [@wParam],e,SAVE_MENUITEM
			mov dword[filename],0
						
			mov dword [ofn+OPENFILENAME.lStructSize],dword OPENFILENAME_size
			push dword  [Windowhandle]
			pop dword[ofn+OPENFILENAME.hwndOwner]
			push dword [OurWindowclass+WNDCLASSEX.hInstance]
			pop dword[ofn+OPENFILENAME.hInstance]
			mov dword[ofn+OPENFILENAME.lpstrFilter],dword filtersave
			mov dword[ofn+OPENFILENAME.lpstrFile],dword filename
			mov dword[ofn+OPENFILENAME.nMaxFile],dword 8192
			mov dword[ofn+OPENFILENAME.lpstrInitialDir],dword drive
			mov dword[ofn+OPENFILENAME.lpstrTitle],dword savetitle
			mov dword[ofn+OPENFILENAME.Flags],dword OFN_LONGNAMES ;| OFN_EXPLORER

			call GetSaveFileNameA,ofn ; save dialog
			or eax,eax
			jz near returnback2
			call CreateFileA,filename,GENERIC_WRITE,NULL,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE, NULL
			mov [houtfile],eax
			call SendDlgItemMessageA,[@hwnd],MAINEDIT_ID,WM_GETTEXTLENGTH,0,0
			mov [length],eax
			call WriteFile,[houtfile],auxdata,eax,actuallywritten,NULL
			call CloseHandle,[houtfile]
			returnback2:
			return
		endif
		if word [@wParam],e,BTFY_BUTTON
			
			call SendDlgItemMessageA,[@hwnd],MAINEDIT_ID,WM_GETTEXTLENGTH,0,0
			mov [length],eax
			add eax,1
			mov [length],eax
			mov dword[globalbuffer],0
			call SendDlgItemMessageA,[@hwnd],MAINEDIT_ID,WM_GETTEXT,[length],globalbuffer
			loccall skip_pre_portion,globalbuffer,auxdata,[length]
			push esi
			push edi
			push esi
			push edi
			loccall unwanted_tabs,esi,edi
			
			pop edi
			pop esi
			loccall remove_extra_space,edi,esi
			pop edi
			pop esi
			dec edi
			if byte[edi],ne,10
				inc edi
				mov word [edi],2573
				inc edi
				inc edi
			else
				inc edi
			endif			
		
			loccall insert_returnchar,esi,edi
		;call MessageBoxA,[Windowhandle],auxdata,"after insert return",0
			loccall rem_leading_spaces,auxdata,globalbuffer
		;call MessageBoxA,[Windowhandle],globalbuffer,"rem leading spaces",0			
			loccall provide_indentation,globalbuffer,auxdata
			if eax,e,-1
			jmp near defaultaction
			endif
		;call MessageBoxA,[Windowhandle],auxdata,"after indentation",0			
			call SetDlgItemTextA,[@hwnd],MAINEDIT_ID,auxdata
		endif
	endif
	defaultaction:
	call DefWindowProcA, [@hwnd], [@uMsg], [@wParam], [@lParam]
	return
endproc
proc getlatestdir,path
	mov esi,[@path]
	mov edi,drive
	xor eax,eax
	storedrive:
	lodsb	
	stosb
	or eax,eax	
	jz donedrive
	jmp storedrive
donedrive:
	std
	mov al,'\'
	repne scasb
	inc edi
	inc edi
	xor eax,eax
	stosb
	cld
endproc
proc unixtowindows,src,dest
	mov esi,[@src]
	mov edi,[@dest]
	
	while byte[esi],ne,0
		lodsb
		if al,e,10
			if byte [esi],e,10
				jmp near letsskip_ten
			endif
			if byte[esi-2],ne,13
				mov byte[edi],13
				inc edi
			endif
		endif
		stosb
	letsskip_ten:
	wend
	mov al,0
	stosb
endproc
%include "remove_extra_space.asm"
%include "insert_returnchar.asm"
%include "skip_pre_portion.asm"
%include "rem_leading_spaces.asm"
%include "provide_indentation.asm"
%include "unwanted_tabs.asm"