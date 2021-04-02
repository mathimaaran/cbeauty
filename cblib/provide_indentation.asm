proc provide_indentation,gbuf4,abuf4
	mov esi,[@gbuf4]
	mov edi,[@abuf4]
	mov eax,1
	mov dword[insidequote],0
	mov dword[singstate],0
	mov dword[bracketstack],0
	mov dword[no_of_tab],0
	mov dword[insidecomment],0
	mov dword[multicomment],0
	mov dword[inside_bracket_special],0
	mov dword[arrdec],0
	
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
						jmp near storethebyte
					else
						dec esi
						dec esi
					endif
				else
					if byte[esi],e,92
						if byte[esi-1],ne,92
							inc esi
							inc esi
							jmp near storethebyte
						endif
					endif					
				endif
				inc esi
				inc esi
				not dword [insidequote]
			endif
		endif
		if al,e,'('
			if dword [insidecomment],e,0
				if dword [insidequote],e,0
					dec esi
					dec esi
					if byte[esi],ne,39
						inc dword [bracketstack]
						mov dword[inside_bracket_special],0
					endif
					inc esi
					inc esi
				endif
			endif
		endif		
		if al,e,')'
			if dword [insidecomment],e,0
				if byte[esi],ne,39
					closebracket_ok3:
					if dword [insidequote],e,0
						dec dword [bracketstack]
					endif
				else
					if byte[esi-2],ne,39
						jmp near closebracket_ok3
					endif
				endif
			endif
		endif			
		if al,e,'{'
			if dword [insidecomment],e,0
				if dword [insidequote],e,0
					dec esi
					dec esi
					if byte[esi],ne,39
						inc dword[no_of_tab] ;;;;;;;;;;;here
					endif
					inc esi
					inc esi
				endif
			endif
		endif
		if al,e,'}'
			if dword [insidecomment],e,0
				if dword [insidequote],e,0
					if byte[esi],ne,39
						dec edi
						if byte[edi],ne,9
							inc edi
						endif
						if dword[no_of_tab],ne,0
							dec dword[no_of_tab]
						else
							mov eax,esi
							sub eax,[@gbuf4]
							int2str eax,itm1
							;call MessageBoxA,[Windowhandle],itm1,"PEcb Error",0
							mov eax,-1
							jmp near someerror
						endif
						
					endif
				endif
			endif
		endif
		
		storethebyte:
		stosb
		
		if al,e,'/'
			if dword[insidequote],e,0
				dec esi
				dec esi
				if byte[esi],ne,39
					inc esi
					inc esi
					if byte[esi],e,'/'
						if dword[multicomment],e,0
							mov dword[insidecomment],1
						endif
					endif
					if byte[esi],e,'*'
						if dword[insidecomment],e,0
							mov dword[insidecomment],1
							mov dword[multicomment],1
						endif
					endif
					dec esi
					dec esi
					if byte[esi],e,'*'
						mov dword[insidecomment],0
						mov dword[multicomment],0
					endif
					inc esi
					inc esi
				else
				inc esi
				inc esi
				endif
				
			endif
		endif		

		if al,e,10
			push eax
			mov al,9
			mov edx,[no_of_tab]
			if dword [singstate],e,1
				inc edx
				mov dword[singstate],0
			endif
			while edx,ne,0
				mov byte[edi],al
				inc edi
				dec edx
			wend
						
			pop eax
			if dword[insidecomment],ne,0
				if dword[multicomment],e,0
					mov dword[insidecomment],0
				endif
			endif
		endif
		if dword[insidequote],e,0
			if al,b,48
				if al,ne,40
					if al,ne,41
						if al,ne,32
							inc dword[inside_bracket_special]
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
		if al,e,'e'
			if dword [insidequote],e,0
				if byte[esi],ne,39
					if dword[insidecomment],e,0
						if dword[esi-4],e,"else"
							
							push eax
							push esi
							loccall return_next_printable,esi
							if al,ne,'i'
								if al,ne,'{'
									mov dword [singstate],1
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
			if dword [insidecomment],e,0
				if dword [insidequote],e,0
					if byte[esi],ne,39
						closebracket_ok4:
						if dword[bracketstack],e,0
							push eax
							push esi
							loccall return_next_printable,esi
							if al,ne,'{'
								if al,ne,';'
									if al,ne,'/'
										if dword[inside_bracket_special],ne,0
											;pusha
											;int2str eax,itm1
											;call MessageBoxA,[Windowhandle],itm1,"hi",0
											;popa
											mov dword [singstate],1
										endif
									endif
								endif
							endif
	
							pop esi
							pop eax
						endif
					else
						if byte[esi-2],ne,39
							jmp near closebracket_ok4
						endif
					endif
				endif
			endif
		endif		
	wend

someerror:
endproc