proc remove_extra_space,gbuf,abuf
	mov esi,[@gbuf]
	
	mov edi,[@abuf]
	
	mov eax,1
	mov dword[insidequote],0
	mov dword[firstspace],1
	mov dword[firsttab],1
	mov dword[insidecomment],0
	mov dword[multicomment],0
	while al,ne,0
		lodsb
		if al,e,20h ; space
			if byte[esi],ne,39
				if dword[insidequote],e,0         ;;; if byte not inside double quotes
					if dword[firstspace],e,1
						mov dword[firstspace],0
						stosb
						jmp near nextbyte
					else
						jmp near nextbyte
					endif	
				else
					stosb
					jmp near nextbyte
				endif
			endif
			
		else
			mov dword[firstspace],1
		endif
		if al,e,09h ; tab
			if dword[insidequote],e,0         ;;; if byte not inside double quotes
				if dword[firsttab],e,1
					mov dword[firsttab],0
					stosb
					jmp near nextbyte
				else
					jmp near nextbyte
				endif

			else
				stosb
				jmp near nextbyte
			endif

		else
			mov dword[firsttab],1
		endif
		
		if al,a,32
			if al,b,128
				if al,e,'/'
					if dword[insidequote],e,0
						
						if byte[esi],e,'/'
							mov dword[insidecomment],1
						endif
						if byte [esi],e,'*'
							if dword[insidecomment],e,0
								mov dword[multicomment],1
								mov dword[insidecomment],1
							endif
						endif
						dec esi
						dec esi
						if byte[esi],e,'*'
							
							mov dword[multicomment],0
							mov dword[insidecomment],0
						endif
						inc esi
						inc esi
					endif
					
				endif
				if al,e,'"'
					if dword[insidecomment],e,0
						dec esi
						dec esi
						if byte[esi],e,39
							inc esi
							inc esi
							if byte[esi],e,39
								jmp near storequote
							else
								dec esi
								dec esi
							endif
						else
							if byte[esi],e,92
								if byte[esi-1],ne,92
									inc esi
									inc esi
									jmp near storequote
								endif
							endif					
						endif
						inc esi
						inc esi
						not dword [insidequote]
					endif
				endif	
				storequote:
				stosb
				jmp near nextbyte
			endif
		endif
		;if al,e,13
		;	if dword[insidecomment],ne,0
		;		stosb
		;	endif
		;endif
		
		if al,e,10
			if dword[insidecomment],ne,0
				mov byte[edi],13
				inc edi
				stosb				
				if dword[multicomment],e,0
					mov dword [insidecomment],0
				endif
				mov dword[preproc],0	
			else
				push eax
				push esi
				loccall return_next_printable,esi
				if al,e,'#'
					mov byte[edi],13
					inc edi
					mov al,10
					stosb	
					mov dword[preproc],1
				else
					if dword[preproc],e,1
						mov byte[edi],13
						inc edi
						mov al,10
						stosb	
						mov dword[preproc],0
					endif
				endif
				pop esi
				pop eax
			endif
			
		endif
		
		
		nextbyte:
	wend
	mov al,0
	stosb
endproc

