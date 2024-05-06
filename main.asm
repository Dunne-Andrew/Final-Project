; Andrew Dunne
; 5/ 5 / 24
; Provide functionality for the read/write functions
; To provide an easier way of testing all the different program components I programmed it so that the program will 
; never end unless stopped force stopped


.386P                                           ; 8068 or x86 code version 38

.model flat	                                    ; memory model

extern	 initUtilities:proc
extern	 inputStringParser:proc
extern	 calculate:proc
extern	 writeInt:proc
extern	 writeline:proc
; extern	 readline:proc

extern   _ExitProcess@4: near


.data                                           ; data section is used to store data such as global variables
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