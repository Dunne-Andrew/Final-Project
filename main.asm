.386P
.model flat


extern	 initUtilities:proc

extern	 inputStringParser:proc
extern	 calculate:proc
extern	 writeInt:proc
extern	 writeline:proc
; extern	 readline:proc

extern   _ExitProcess@4: near


.data
	result              byte        'The answer is: '
	reset				byte		10,10

.code
main PROC near
_main:

	call initUtilities
	call inputStringParser
	call calculate
	; pop eax
	push 15
    push offset result
    call writeline
	; push eax
	call writeInt
	push 2
	push offset reset
	call writeline
	jmp _main

	push	0
	call	_ExitProcess@4

main ENDP
END