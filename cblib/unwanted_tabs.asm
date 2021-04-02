proc unwanted_tabs,gbuf5,abuf5
	mov esi,[@gbuf5]
	mov edi,[@abuf5]
	mov eax,1
	mov dword[insidequote],0
	while al,ne,0
		lodsb
		if al,e,'"'
			dec esi
			dec esi
			if byte[esi],e,39
				inc esi
				inc esi
				if byte[esi],e,39
					jmp near storethechar1
				else
					dec esi
					dec esi
				endif
			else
				if byte[esi],e,92
					if byte[esi-1],ne,92
						inc esi
						inc esi
						jmp near storethechar1
					endif
				endif					
			endif
			inc esi
			inc esi
			not dword [insidequote]
		endif
		
		if al,e,09h ; tab
			if dword[insidequote],e,0         ;;; if byte not inside double quotes
				mov al,32
			endif
		endif
		storethechar1:
		stosb
	wend
endproc