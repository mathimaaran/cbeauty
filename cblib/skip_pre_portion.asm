proc skip_pre_portion,gbuf2,abuf2,maxlimit
	mov esi,[@gbuf2]
	mov edi,[@abuf2]
	mov eax,123
	mov ecx,[@maxlimit]
	mov dword[insidecomment],0
	mov dword[multicomment],0
	
	while ecx,a,0
		lodsb
		
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
							mov dword[multicomment],1
							mov dword[insidecomment],1
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
			if dword[insidecomment],ne,0
				if dword[multicomment],e,0
					mov dword[insidecomment],0
				endif
			endif
		endif
		if al,e,123
			dec esi
			dec esi
			if byte[esi],ne,39
				if dword[insidecomment],e,0
					if dword[multicomment],e,0
						inc esi            ;; now esi will be pointing to the first'{'
						jmp near end_of_pre
					endif
				endif
			endif
			inc esi
			inc esi
		endif
		stosb
		dec ecx
	wend
	
end_of_pre:
endproc



		
		
		