proc insert_returnchar,gbuf1,abuf1
	mov esi,[@gbuf1]
	mov edi,[@abuf1]
	mov eax,1
	mov dword[insidequote],0
	mov dword[firstspace],1
	mov dword[bracketstack],0
	mov dword[sqbracketstack],0
	mov dword[insidecomment],0
	mov dword[multicomment],0
	mov dword[inside_bracket_special],0
	
	while al,ne,0
		lodsb
		if al,e,'"'
			if dword[insidecomment],e,0
				dec esi
				dec esi
				if byte[esi],e,39
					inc esi
					inc esi
					if byte[esi],e,39
						jmp near storechar
					else
						dec esi
						dec esi
					endif
				else
					if byte[esi],e,92
						if byte[esi-1],ne,92
							inc esi
							inc esi
							jmp near storechar
						endif
					endif
					
				endif
				inc esi
				inc esi
				not dword [insidequote]
			endif
		endif
		
		if al,e,'('
			if dword [insidequote],e,0
				if byte[esi],ne,39
					openbracket_ok1:
					if dword[insidecomment],e,0
						inc dword [bracketstack]
						mov dword[inside_bracket_special],0
					endif
				else
					if byte[esi-2],ne,39
						jmp near openbracket_ok1
					endif
				endif
				
			endif
		endif		
		if al,e,')'
			if dword [insidequote],e,0
				if byte[esi],ne,39
					closebracket_ok1:
					if dword[insidecomment],e,0
						dec dword [bracketstack]
					endif
				else
					if byte[esi-2],ne,39
						jmp near closebracket_ok1
					endif
				endif
			endif
		endif	
		if al,e,'['
			if dword [insidequote],e,0
				if byte[esi],ne,39
					opensqbrac_ok1:
					if dword[insidecomment],e,0
						inc dword [sqbracketstack]
					endif
				else
					if byte[esi-2],ne,39
						jmp near opensqbrac_ok1
					endif
				endif
			endif
		endif		
		if al,e,']'
			if dword [insidequote],e,0
				if byte[esi],ne,39
					closesqbrac_ok2:
					if dword[insidecomment],e,0
						dec dword [sqbracketstack]
					endif
				else
					
					if byte[esi-2],ne,39
						jmp near closesqbrac_ok2
					endif
				endif
			endif
		endif			
			
		if al,e,'/'
			if dword[insidequote],e,0
				if byte[esi],ne,39
					if dword[insidecomment],e,0
						if byte[esi],e,'*'
							if byte[esi-2],ne,'/'
								mov word[edi],2573  ;; vert tab and line feed
								inc edi
								inc edi
							endif
						endif
					endif
				endif
			endif
		endif
		storechar:
		stosb
		if al,e,92 ;backslash
			if dword [insidequote],e,0
				if byte[esi],ne,39
					if dword[insidecomment],e,0
						mov word[edi],2573  ;; vert tab and line feed
						inc edi
						inc edi
					endif
				endif
			endif
		endif
		if al,e,'e'
			if dword [insidequote],e,0
				if byte[esi],ne,39
					if dword[insidecomment],e,0
						if dword[esi-4],e,"else"
							push eax
							push esi
							loccall return_next_printable,esi
							if al,ne,'i'
								mov word[edi],2573  ;; vert tab and line feed
								inc edi
								inc edi
							endif
							pop esi
							pop eax
							
						endif
					endif
				endif
			endif
		endif
		if al,e,'}'
			if dword [insidequote],e,0
				if byte[esi],ne,39
					if dword[insidecomment],e,0
						push eax
						push esi
						loccall return_next_printable,esi
						if al,ne,';'
							mov word[edi],2573  ;; vert tab and line feed
							inc edi
							inc edi
						endif
						pop esi
						pop eax
					endif
				endif
			endif
		endif
		if al,e,':'
			if byte[esi],ne,39
				if byte[esi],ne,':'
					if byte[esi-2],ne,':'
						if dword [insidequote],e,0
							if dword[insidecomment],e,0
								mov word[edi],2573  ;; vert tab and line feed
								inc edi
								inc edi				
							endif
						endif
					endif
				endif
			endif
		endif	
		if al,e,';'
			if dword [insidequote],e,0
				if dword[insidecomment],e,0
					if dword[bracketstack],e,0
						if byte[esi],ne,39
							push eax
							push esi
							loccall return_next_printable,esi
							;pusha
							;int2str eax,itm1
							;call MessageBoxA,[Windowhandle],itm1,"hi",0
							;popa
							
							if al,ne,92  ;backslash
								if al,ne,'/'
									mov word[edi],2573  ;; vert tab and line feed
									inc edi
									inc edi
								endif
							endif
							
							pop esi
							pop eax					
						endif
					endif
				endif
			endif
		endif
		if al,e,')'
			if dword [insidequote],e,0
				if dword[insidecomment],e,0
					if byte[esi],ne,39
						closebracket_ok2:
						if dword[bracketstack],e,0
							if dword[sqbracketstack],e,0
								push eax
								push esi
								loccall return_next_printable,esi
								if al,ne,';'
									if al,ne,':'
										if al,ne,'/'
											if dword[inside_bracket_special],ne,0
												mov word[edi],2573  ;; vert tab and line feed
												inc edi
												inc edi
												mov dword[inside_bracket_special],0
											
											else
												if al,e,'{'
													mov word[edi],2573  ;; vert tab and line feed
													inc edi
													inc edi
												endif
											endif

										endif

									endif
								endif

								pop esi
								pop eax
							endif
						endif
					else
						if byte[esi-2],ne,39
							jmp near closebracket_ok2
						endif
					endif
				endif
			endif
		endif
		if al,e,'{'
			if dword [insidequote],e,0
				if dword[insidecomment],e,0
					if byte[esi],ne,39
						push eax
						push esi
						loccall return_next_printable,esi
						if al,ne,'"'
							if al,b,48
								if al,ne,'-'
									if al,ne,'.'
										if al,ne,39
											mov word[edi],2573  ;; vert tab and line feed
											inc edi
											inc edi
										endif
									endif
								endif
							endif
							if al,a,57
								mov word[edi],2573  ;; vert tab and line feed
								inc edi
								inc edi						
							endif

						endif
						pop esi
						pop eax
						
					endif
				endif
			endif
		endif	
		if al,e,'/'
			if dword[insidequote],e,0
;				if byte[esi],ne,39
					if byte[esi],e,'/'
						mov dword[insidecomment],1
					endif
					if byte[esi],e,'*'
						;pusha
						;call MessageBoxA,[Windowhandle],esi,"hi",0
						;popa
						if dword[insidecomment],e,0
							mov dword[multicomment],1
							mov dword[insidecomment],1
						endif
					endif					
					dec esi
					dec esi
					if byte[esi],e,'*'
						mov word[edi],2573
						inc edi
						inc edi
						mov dword[insidecomment],0
						mov dword[multicomment],0
					endif
					inc esi
					inc esi
					
				endif
			endif
		endif
		
		if dword[insidequote],e,0
			if al,b,48
				if al,ne,40
					if al,ne,32
						if al,ne,41
							if al,ne,34
								if word[esi],ne," )"
									if byte[esi],ne,')'
										inc dword[inside_bracket_special]
									endif
								endif
							endif
						endif
					endif
				endif
			else
				if al,a,57
					if al,b,65
						inc dword[inside_bracket_special]
					endif
				endif
				if al,a,90
					if al,b,97
						inc dword[inside_bracket_special]
					endif
				endif
				if al,a,122
					inc dword[inside_bracket_special]
				endif
			endif
		endif
		
		if al,e,10
			if dword[multicomment],e,0
				if dword[insidecomment],e,1
					mov dword[insidecomment],0
				endif
			endif
		endif
	wend
	mov al,0
	stosb
endproc
proc return_next_printable,startindex
	mov esi,[@startindex]
	while al,ne,0
		lodsb
		if al,a,32
			if al,b,128
				;pusha
				;int2str eax,itm1
				;call MessageBoxA,[Windowhandle],esi,"hi",0
				;popa
				jmp  near return_to_caller
			endif
		endif
	wend
	mov eax,-1
	return_to_caller:
endproc