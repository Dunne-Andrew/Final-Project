; Andrew Dunne
; 5/ 5 / 24
; Provide functionality for the read/write functions


.386P                                           ; 8068 or x86 code version 386

.model flat	                                    ; memory model

extern  _GetStdHandle@4:near
extern  _WriteConsoleA@20:near
extern  _ReadConsoleA@20:near


.data                                           ; data section is used to store data such as global variables

outputHandle		dword   ?						; Storage the the handle for input and output. uninitslized
inputHandle         dword   ?
readBuffer byte 1024 dup(00h)
writeBuffer byte 1024 dup(00h)
numCharsRead        dword 1
count   dword   1
countDown dword 1
wBIndex  dword ?
written				dword   ?
results           byte        "n = "
	
.code

initUtilities PROC near  ; This is the initializer function 
_initUtilities:


	push    -11
	call    _GetStdHandle@4
	mov     outputHandle, eax
    push    -10
	call    _GetStdHandle@4
	mov     inputHandle, eax

	ret

initUtilities ENDP




; Convert number to string
; For all routines, the last item to be pushed on the stack is the return address, save it to a register
; then save any other expected parameters in registers, then restore the return address to the stack.
; Use of registers (important to document so they are not overwritten)
; EAX - Set with lower 32-bits of 64-bit dividend, after idiv holds the quotient
; EDX - Set with upper 32-bits of 64-bit dividend, after idiv holds the remainder
; EBX - used as divisor, safest to set each time before divide
; ECX - Last available general register. Used as index into buffer to be written.
writeInt PROC near
_writeInt:
        pop ebx                    ; Save the return address
        pop eax                    ; Save first number to convert in register EAX
        push ebx                ; Restore return address, this frees up EBX for use here.
        mov count, 0            ; Reset count
_convertLoop:
        ; Find the remainder and put on stack
        ; The choices are div for 8-bit division and idiv for 64-bit division. To use full registers, I had to use 64-bit division
        mov  edx, 0                ; idiv starts with a 64-bit number in registers edx:eax, therefore I zero out edx.
        mov  ebx, 10            ; Divide by 10.
        idiv ebx
        add  edx,'0'            ; Make remainder into a character
        push edx                ; Put in on the stack for printing this digit
        inc  count
        cmp  eax, 0
        jg   _convertLoop        ; Go back if there are more characters
        mov  wBIndex, offset writeBuffer
        mov     ebx, wBIndex
        mov  byte ptr [ebx], ' '; Add starting blank space
        inc  ebx            ; Go to next byte location
        mov     ecx, count            ; EBX is being reloading each divide, so I can use it here to
        mov     countDown, ecx        ; transfer value to set up counter to go through all numbers
_fillString:
        pop     eax                ; Remove the first stacked digit
        mov  [ebx], al            ; Write it in the array
        dec     countDown
        inc  ebx                ; Go to next byte location
        cmp     countDown, 0
        jg   _fillString
        mov  byte ptr[ebx], 0        ;Add end zero
        inc  count                ; Take into account extra space
        push count                ; How many characters to print
        push offset writeBuffer ; And the buffer itself
        call writeline
        ret                        ; And return
writeInt ENDP

writeline PROC near
_writeline :
pop		eax; pop the address of the stack into eax
pop		edx
pop		ecx; Pop top of stack and put into ECX
push	eax; Push content of EAX onto the top of the stack.

; WriteConsole(handle, &msg[0], numCharsToWrite, &written, 0)
push    0
push    offset written
push    ecx; return ecx to the stack for the call to _WriteConsoleA@20 (20 is how many bits are in the call stack)
push    edx
push    outputHandle
call    _WriteConsoleA@20
ret
writeline ENDP

readline PROC near
_readline: ; ReadConsole(handle,&readBuffer[0], numCharsToRead, numCharsRead, 0)
        pop  eax
        pop  ebx
        push eax
        push 0
        push offset numCharsRead
        push 255
        push ebx
        push inputHandle
        call _ReadConsoleA@20
        
        ret
readline ENDP



END
