proc rem_leading_spaces,gbuf3,abuf3
	mov dword [leadspace],1
	mov esi,[@gbuf3]
	mov edi,[@abuf3]
	mov eax,1
	while eax,ne,0
		lodsb
		if al,e,32
			if dword[leadspace],e,1
				;call MessageBoxA,[Windowhandle],esi,"hi",0
				jmp nextchar_on_line
			endif
		else
			if al,e,09
				if dword[leadspace],e,1
					;if byte[esi],ne,39
						jmp nextchar_on_line
					;endif
				endif		
			endif		
		endif
		mov dword[leadspace],0
		if al,e,10
			mov dword[leadspace],1
		endif
		stosb
	nextchar_on_line:
	wend
	mov al,0
	stosb
endproc