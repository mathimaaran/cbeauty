

STRUC BROWSEINFO 
 .hwndOwner      resd 1
 .pidlRoot       resd 1
 .pszDisplayName resd 1
 .lpszTitle      resd 1
 .ulFlags        resd 1
 .lpfn           resd 1
 .lParam         resd 1
 .iImage         resd 1
ENDSTRUC

%define call call_   
%MACRO pushd  1
  push DWORD %1
 %ENDMACRO

%macro CONST 2+  ; macro to insert constant into code
 jmp near %%skip ; jump to macro-local label
 %1 %2  ; mark label and define data
 %%skip:   ; macro-local label
%endm

%macro STDPUSH 1  ; macro to push argument list
 %ifnum %1  ; argument is a number
  ; check number to fit in signed byte
  %if %1 >= -128 && %1 <= 127
   push byte %1
  %else ; cannot be pushed as signed byte
   push dword %1
  %endif
 %else  ; argument is not a number
  %ifstr %1 ; argument is a string
   CONST %%str, db %1, 0 ; define macro-local label
   push dword %%str
  %else ; neither string nor number (label or register)
   push dword %1
  %endif
 %endif
%endmacro

STRUC OPENFILENAME
.lStructSize RESD 1
.hwndOwner RESD 1
.hInstance RESD 1
.lpstrFilter RESD 1
.lpstrCustomFilter RESD 1
.nMaxCustFilter RESD 1
.nFilterIndex RESD 1
.lpstrFile RESD 1
.nMaxFile RESD 1
.lpstrFileTitle RESD 1
.nMaxFileTitle RESD 1
.lpstrInitialDir RESD 1
.lpstrTitle RESD 1
.Flags RESD 1
.nFileOffset RESW 1
.nFileExtension RESW 1
.lpstrDefExt RESD 1
.lCustData RESD 1
.lpfnHook RESD 1
.lpTemplateName RESD 1
ENDSTRUC

STRUC WNDCLASSEX
.cbSize RESD 1
.style RESD 1
.lpfnWndProc RESD 1
.cbClsExtra RESD 1
.cbWndExtra RESD 1
.hInstance RESD 1
.hIcon RESD 1
.hCursor RESD 1
.hbrBackground RESD 1
.lpszMenuName RESD 1
.lpszClassName RESD 1
.hIconSm RESD 1
ENDSTRUC

%macro API 2                                   ;Function , Library
	import %1 %2
	extern %1
%endmacro

%idefine ADDR_   "ADDR_",
%idefine addr_    "ADDR_",
%define addr      ADDR_
%define ADDR     ADDR_


%imacro call_ 1-*  
%assign i	%0
	%if %0 > 1
		%rep %0 - 1
			%rotate -1  
			%assign i	i-1		                               
			%rotate -1
			%ifidni %1,"ADDR_"
			%rotate 1
			lea	eax,	[%1]
			push	eax
			%rotate -1
			%assign i	i-1
			%else		
			%rotate 1
			STDPUSH {%1}     
			%endif
			%if i <=1
			%exitrep
			%endif
		%endrep		
		%rotate -1
	%endif
	%ifndef %1_definida
                ; � uma fun�ao externa ?   ( hgb )
                extern %1     ; declare API function as external
                CALL [%1]          ; call API function via IAT
        %else
                ;� uma  fun�ao local
                CALL %1
        %endif
%endmacro


;=== [ end macro call_ ] =====================
%imacro loccall 1-*  
%assign i	%0
	%if %0 > 1
		%rep %0 - 1
			%rotate -1  
			%assign i	i-1
			; ===== ADDR_
			%rotate -1
			%ifidni %1,"ADDR_"
				%rotate 1
				lea	eax,	[%1]
				push	eax
				%rotate -1
				%assign i	i-1
			%else		
				%rotate 1
				STDPUSH {%1}
			%endif
			

			%if i <=1
				%exitrep
			%endif
		%endrep		
		%rotate -1
	%endif  
	CALL %1
%endmacro
;===================== [ LOCAL FUNCTIONS END *LOCCALL* ]
%define loccall LOCCALL

%macro terminar_ 1
        %1terminar_:
%endmacro


%macro proc 1-33
; %error proc %1
%assign SizeLocalAdd 0  ; inicializar o size das locais a zero
%assign stack_var  1     ; inicializar a stack pra primeira  variavel declarada
%assign c_l 1  ; INICILIZAR OS ARGUMENTOS PARA O PRIMEIRO !
%assign n_l %0-1
%assign numarg_ %0-1   ; para fazer ret final

%define nome_rotina %1

%push proc

%1:


push ebp
mov ebp,esp
;== loop para defenir parametros
%rep %0-1
%rotate 1
%xdefine @%1  ebp+4 +c_l*4 
 %assign c_l c_l+1
%endrep      
;=== loop end  para defenir parametros
%endmacro
;; ==================

%macro cdecl_endproc 0-1  ; .... :)
terminar_ nome_rotina
;; %error numero de parametros da fun�ao =  n_l

leave
ret
;ret 4*numarg_
;; %error  ret 4*numarg_
;; %error endproc
%endmacro



%macro endproc 0-1  ; .... :)
terminar_ nome_rotina
;; %error numero de parametros da fun�ao =  n_l

leave
ret 4*numarg_
;; %error  ret 4*numarg_
;; %error endproc
%endmacro

%imacro if 3-*
        %push if
        %if %0 = 3
                cmp     %1, %3
                j%-2    near %$i
        %else
                %assign %$c 0
                %rep (%0 / 3)
                        cmp     %1, %3
                        j%2     near %$i%$c
                        %rotate 3
                %endrep
                jmp     near %$i
                %$i%$c:
        %endif


%endmacro

%imacro else 0
        %ifctx if
                %repl else
                jmp     near %$e
                %$i:
        %else
                ; %error "Expected 'if' or 'ifand' before 'else'"
        %endif
%endmacro
%imacro endif 0
        %ifctx if
                %$i:
                %pop
        %elifctx else
                %$e:
                %pop
        %else
                ; %error "Expected 'if' before 'endif'"
        %endif
%endmacro
;***************************
; Window Styles 

    %define WS_OVERLAPPED       0x00000000
    %define WS_POPUP            0x80000000
    %define WS_CHILD            0x40000000
    %define WS_MINIMIZE         0x20000000
    %define WS_VISIBLE          0x10000000
    %define WS_DISABLED         0x08000000
    %define WS_CLIPSIBLINGS     0x04000000
    %define WS_CLIPCHILDREN     0x02000000
    %define WS_MAXIMIZE         0x01000000
    %define WS_CAPTION          0x00C00000
    %define WS_BORDER           0x00800000
    %define WS_DLGFRAME         0x00400000
    %define WS_VSCROLL          0x00200000
    %define WS_HSCROLL          0x00100000
    %define WS_SYSMENU          0x00080000
    %define WS_THICKFRAME       0x00040000
    %define WS_GROUP            0x00020000
    %define WS_TABSTOP          0x00010000
    
    %define WS_MINIMIZEBOX      0x00020000
    %define WS_MAXIMIZEBOX      0x00010000

    %define WS_TILED            WS_OVERLAPPED
    %define WS_ICONIC           WS_MINIMIZE
    %define WS_SIZEBOX          WS_THICKFRAME
    %define WS_TILEDWINDOW      WS_OVERLAPPEDWINDOW

    ; Common Window Styles 

    %define WS_OVERLAPPEDWINDOW (WS_OVERLAPPED     | \
                                 WS_CAPTION        | \
                                 WS_SYSMENU        | \
                                 WS_THICKFRAME     | \
                                 WS_MINIMIZEBOX    | \
                                 WS_MAXIMIZEBOX)
    
    %define WS_POPUPWINDOW      (WS_POPUP          | \
                                 WS_BORDER         | \
                                 WS_SYSMENU)
    
    %define WS_CHILDWINDOW      (WS_CHILD)

    ; Extended Window Styles 

    %define WS_EX_DLGMODALFRAME     0x00000001
    %define WS_EX_NOPARENTNOTIFY    0x00000004
    %define WS_EX_TOPMOST           0x00000008L
    %define WS_EX_ACCEPTFILES       0x00000010
    %define WS_EX_TRANSPARENT       0x00000020
    %define WS_EX_MDICHILD          0x00000040
    %define WS_EX_TOOLWINDOW        0x00000080
    %define WS_EX_WINDOWEDGE        0x00000100
    %define WS_EX_CLIENTEDGE        0x00000200
    %define WS_EX_CONTEXTHELP       0x00000400
    %define WS_EX_RIGHT             0x00001000
    %define WS_EX_LEFT              0x00000000
    %define WS_EX_RTLREADING        0x00002000
    %define WS_EX_LTRREADING        0x00000000
    %define WS_EX_LEFTSCROLLBAR     0x00004000
    %define WS_EX_RIGHTSCROLLBAR    0x00000000
    %define WS_EX_CONTROLPARENT     0x00010000
    %define WS_EX_STATICEDGE        0x00020000
    %define WS_EX_APPWINDOW         0x00040000
    %define WS_EX_OVERLAPPEDWINDOW  (WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE)
    %define WS_EX_PALETTEWINDOW     (WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST)

    ; Class styles 

    %define CS_VREDRAW          0x0001
    %define CS_HREDRAW          0x0002
    %define CS_DBLCLKS          0x0008
    %define CS_OWNDC            0x0020
    %define CS_CLASSDC          0x0040
    %define CS_PARENTDC         0x0080
    %define CS_NOCLOSE          0x0200
    %define CS_SAVEBITS         0x0800
    %define CS_BYTEALIGNCLIENT  0x1000
    %define CS_BYTEALIGNWINDOW  0x2000
    %define CS_GLOBALCLASS      0x4000
    
    %define CS_IME              0x00010000
%define TRUE 1
%define FALSE 0
%define NULL 0
%define BM_SETIMAGE 0F7h
%define IMAGE_ICON 1
   
%define BS_ICON 40h
%define TBS_TOOLTIPS            0x0100
DEFAULT_CS_STYLE equ CS_VREDRAW + CS_HREDRAW + CS_DBLCLKS
%define COLOR_WINDOW 5
%define OFN_ALLOWMULTISELECT 00000200h
%define WM_SETFOCUS                     0x0007
    %define WM_KILLFOCUS                    0x0008
    %define WM_ENABLE                       0x000A
    %define WM_SETREDRAW                    0x000B
    %define WM_SETTEXT                      0x000C
    %define WM_GETTEXT                      0x000D
    %define WM_GETTEXTLENGTH                0x000E
    %define WM_PAINT                        0x000F
    %define WM_CLOSE                        0x0010
    %define WM_QUERYENDSESSION              0x0011
    %define WM_QUIT                         0x0012
    %define WM_QUERYOPEN                    0x0013
    %define WM_ERASEBKGND                   0x0014
    %define WM_SYSCOLORCHANGE               0x0015
    %define WM_ENDSESSION                   0x0016
    %define WM_SHOWWINDOW                   0x0018
    %define WM_WININICHANGE                 0x001A
    %define WM_SETTINGCHANGE                WM_WININICHANGE
    
    %define WM_DEVMODECHANGE                0x001B
    %define WM_ACTIVATEAPP                  0x001C
    %define WM_FONTCHANGE                   0x001D
    %define WM_TIMECHANGE                   0x001E
    %define WM_CANCELMODE                   0x001F
    %define WM_SETCURSOR                    0x0020
    %define WM_MOUSEACTIVATE                0x0021
    %define WM_CHILDACTIVATE                0x0022
    %define WM_QUEUESYNC                    0x0023
    
    %define WM_GETMINMAXINFO                0x0024
    %define WM_PAINTICON                    0x0026
    %define WM_ICONERASEBKGND               0x0027
    %define WM_NEXTDLGCTL                   0x0028
    %define WM_SPOOLERSTATUS                0x002A
    %define WM_DRAWITEM                     0x002B
    %define WM_MEASUREITEM                  0x002C
    %define WM_DELETEITEM                   0x002D
    %define WM_VKEYTOITEM                   0x002E
    %define WM_CHARTOITEM                   0x002F
    %define WM_SETFONT                      0x0030
    %define WM_GETFONT                      0x0031
    %define WM_SETHOTKEY                    0x0032
    %define WM_GETHOTKEY                    0x0033
    %define WM_QUERYDRAGICON                0x0037
    %define WM_COMPAREITEM                  0x0039
    %define WM_GETOBJECT                    0x003D
    %define WM_COMPACTING                   0x0041
    %define WM_COMMNOTIFY                   0x0044
    %define WM_WINDOWPOSCHANGING            0x0046
    %define WM_WINDOWPOSCHANGED             0x0047
    %define WM_POWER                        0x0048
%define BN_CLICKED          0
%define WM_COMMAND 111h
%define WM_HSCROLL 114h
%define WM_DESTROY                      0x0002
%define OFN_EXPLORER 00080000h
%define OFN_LONGNAMES 00200000h
%define OFN_HIDEREADONLY 00000004h
%define LB_ADDSTRING 180h

%define MB_OK 0h
%macro str2int 1
        push    ebx ;
        push    esi ;
        push    edi ;
        mov ebx, 0
        mov ecx, 0
        xor eax,eax
        mov ebx,0000000Ah
        mov esi,%1
        %%ConvertLoop:
        movzx ecx,byte [esi] ;Zeichen laden.
        test ecx,ecx
        jz  short %%ExitConvertLoop ;0 => Exit
        inc esi
        sub cl,30h ;0-9...
        mul ebx ;Ergebnis * 10
        add eax,ecx ;+ n�chste Ziffer
        jmp short %%ConvertLoop
        %%ExitConvertLoop:
        pop     edi
        pop     esi
        pop     ebx
%endmacro
%macro int2str 2
        push    ebx ;
        push    esi ;
        push    edi ;
        %%start:
        mov  eax, %1
        xor  ecx, ecx
        mov  ebx, 000ah
        %%DecConvert:
        xor  edx,  edx
        div  ebx
        add  edx,  0030h
        push edx
        inc  ecx
        or   eax,  eax
        jnz  short %%DecConvert
        mov  edi,  %2
        %%SortDec:
        pop   eax
        stosb
        loop  %%SortDec
        mov eax, 0h
        stosb
        pop     edi
        pop     esi
        pop     ebx
%endmacro
%define MF_SEPARATOR 800h
%define GENERIC_READ 80000000h
%define GENERIC_WRITE 40000000h
%define FILE_SHARE_READ 1h
%define FILE_SHARE_DELETE  4
%define FILE_SHARE_WRITE 2h
%define CREATE_NEW 1
%define CREATE_ALWAYS 2
%define OPEN_EXISTING 3
%define FILE_ATTRIBUTE_ARCHIVE 20h
%define INVALID_HANDLE_VALUE -1
%define GPTR GMEM_FIXED|GMEM_ZEROINIT
%define GMEM_FIXED 0h
%define GMEM_ZEROINIT 40h
%define OFN_OVERWRITEPROMPT 00000002h
%define BS_USERBUTTON       0x00000008
%define BS_DEFPUSHBUTTON    0x00000001
%define BS_FLAT             0x00008000
%define BS_PUSHBUTTON       0x00000000
%define ES_NUMBER           0x2000
%define ES_AUTOHSCROLL      0x0080
%define WM_CREATE 1h
STRUC POINT
.x RESD 1
.y RESD 1
ENDSTRUC

STRUC MSG
.hwnd RESD 1
.message RESD 1
.wParam RESD 1
.lParam RESD 1
.time RESD 1
.pt RESB POINT_size
ENDSTRUC
    %define SW_SHOW             5
%define COLOR_BTNFACE 15
    %define SW_SHOWNORMAL       1
%define ES_AUTOVSCROLL      0x0040

%macro  return  0-1
%ifctx proc
%if %0
%if %1=1
xor     eax, eax
inc     eax
%elif %1=0
xor     eax, eax
%else
mov eax, %1
%endif
%endif
l_ret_l
%endif

%endmacro
%macro l_ret_l 0
            _brincar nome_rotina,terminar_
%endmacro
%macro _brincar 2
             jmp near %1%2
%endmacro
    %define IDI_APPLICATION     32512
%define IDC_ARROW 32512
    %define ES_RIGHT            0x0002
%define ES_READONLY 800h
%define DEFAULT_GUI_FONT 17
%define WM_SETFONT 30h
%define MB_YESNOCANCEL 3h
%define MB_YESNO 4h
%define MB_OKCANCEL 1h
    %define IDOK                1
    %define IDCANCEL            2
    %define IDABORT             3
    %define IDRETRY             4
    %define IDIGNORE            5
    %define IDYES               6
    %define IDNO                7
    %define IDCLOSE         8
    %define IDHELP          9
%define ES_MULTILINE 4h
 %define ES_WANTRETURN       0x1000
%define ES_AUTOVSCROLL      0x0040
%define ES_AUTOHSCROLL      0x0080
;*************************************************
; HLL macros - while/wend
;
%imacro while 3-*
        %push while
        %$w:
        %if %0 = 3
                cmp     %1, %3
                j%-2    near %$x
        %else
                %assign %$c 0
                %rep (%0 / 3)
                        cmp     %1, %3
                        j%2     near %$w%$c
                        %rotate 3
                %endrep
                jmp     %$x
                %$w%$c:
        %endif
%endmacro
%imacro whileand 3-*
        %push while
        %$w:
        %if %0 = 3
                cmp     %1, %3
                j%-2    near %$x
        %else
                %assign %$c 0
                %rep (%0 / 3)
                        cmp     %1, %3
                        j%-2    near %$x
                        %rotate 3
                %endrep
        %endif
%endmacro
%imacro wend 0
        %ifctx while
                jmp     %$w
        %$x:
                %pop
        %else
                ; %error "Expected 'while' before 'wend'"
        %endif
%endmacro

;****************************************************
;            end                HLL macros
;****************************************************


