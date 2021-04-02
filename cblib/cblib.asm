%include "cb.inc"

segment .data USE32

abouttext db "  PEcb V1.05 - PowerElex C beautifier",13,10,\
		"Created using NASM win32 assembler",13,10,\
		"                                -mathi",13,10,\
		"                 mathiisalive@yahoo.com",0
		
itm1: times 128 db 0

segment .bss USE32

MessageBuffer resb MSG_size
;;globalbuffer resb 1048576
;;auxdata resb 2096576
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

segment .text USE32
global _cb_beautify
proc _cb_beautify,globalbuffer,auxdata,length
	push edi ;//save edi and esi since this is called from c++
	push esi

	loccall skip_pre_portion,[@globalbuffer],[@auxdata],[@length]
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
	loccall rem_leading_spaces,[@auxdata],[@globalbuffer]
    ;call MessageBoxA,[Windowhandle],globalbuffer,"rem leading spaces",0			
	loccall provide_indentation,[@globalbuffer],[@auxdata]
	if eax,e,-1
		jmp near defaultaction
	endif
    ;;;ELSE


	;;; return the [@globalbuffer?]

	defaultaction:
	pop esi
	pop edi
cdecl_endproc
;;;;;endproc
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