.386P
.model flat	

extern  _GetStdHandle@4:near
extern  _WriteConsoleA@20:near
extern  _ReadConsoleA@20:near


.data
outputHandle		dword   ?						; Storage the the handle for input and output. uninitslized
inputHandle         dword   ?
numCharsRead        dword 1
readBuffer byte 1024 dup(00h)
writeBuffer byte 1024 dup(00h)
count   dword   1
wBIndex  dword ?
countDown dword 1
written				dword   ?
prompt            byte        'Input a number n: '
results           byte        "n = "
	
.code
initUtilities PROC near
_initUtilities:




	push    -11
	call    _GetStdHandle@4
	mov     outputHandle, eax
    push    -10
	call    _GetStdHandle@4
	mov     inputHandle, eax

	ret

initUtilities ENDP

inputToInteger PROC near 
; Some of you asked for my code to convert string to integer. I ; just built it into my main routine. It should be broken out into ; its own function. That would be a good exercise for you.
_rereadMaxNumber:
    ; Type a prompt for the user
    ; WriteConsole(handle, &Prompt[0], 18, &written, 0)
    push  0
    push  offset written
    push  18
    push  offset prompt
    mov   eax, offset prompt
    push  outputHandle
    call  _WriteConsoleA@20
    ; handle = GetStdHandle(-10)
    push  -10
    call  _GetStdHandle@4
    mov   inputHandle, eax
    call  readline
    ; The following embeds the above code in a common routine, so the more complicated call only needs to be written once.
    ; writeline(&results[0], 12)
    push  4
    push  offset results
    call  writeline
    ; writeline(&readBuffer[0], numCharsToWrite - aka numCharsRead)
    push  numCharsRead
    push  offset readBuffer
    call  writeline
    ; Take what was read and convert to a number
    mov   eax, 0               ; Initialize the number
    mov   ecx, 0               ; Initialize index into buffer
    mov   ebx, 0               ; Make sure upper bits are all zero.
_findNumberLoop:
    mov   bl, [readBuffer+ecx]
    cmp   bl, '9'
    jg   _endNumberLoop
    sub   bl, '0'
    cmp   bl, 0
    jl    _endNumberLoop
    mov   edx, 10              ; save multiplier for later need
    mul   edx
    add   eax, ebx
    inc   ecx                   ; Go to next location in number
    jmp   _findNumberLoop
 _endNumberLoop:
    cmp    eax,0
    jle    _rereadMaxNumber
    cmp    eax, 45
    jg    _rereadMaxNumber

    pop eax
    pop ebx
    push eax
    push ebx
    ret
inputToInteger ENDP


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
_readline: ; ReadConsole(handle, &readBuffer[0], numCharsToRead, numCharsRead, 0)
        push 0
        push offset numCharsRead
        push 255
        push offset readBuffer
        push inputHandle
        call _ReadConsoleA@20
        ret
readline ENDP



END
