; Andrew Dunne
; 5/ 5 / 24
; Provide functionality for the read/write functions


.386P                                           ; 8068 or x86 code version 386

.model flat	                                    ; memory model

extern  writeline:proc
extern	 readline:proc


.data                                           ; data section is used to store data such as global variables
    written				dword   ?
    prompt              byte        'Input equation: (+, -, *, /) A B:',10
    readBuffer          byte 1024 dup(00h)
    operator            dword   ?
    A                   dword   ?
    B                   dword   ?
    next                dword   0  ; operator - 0, A - 1, B - 2
    index               dword   0  


.code
inputStringParser PROC near
_inputStringParser:

    
    push 34
    push offset prompt
    call writeline

    
    push  offset readBuffer
    call  readline
    ; push  30
    ; push  offset readBuffer
    ; call  writeline
    mov index, 0

_parseLoop:
    cmp next, 0
    jne _parseA
    ; this is where the operator is parsed
    push index
    call operatorParse
    pop index
    pop operator
    mov edx, operator


_parseA:        ; this is where A is parsed
    cmp next, 1
    jne  _parseB
    push index
    call intParse
    pop index
    pop  A
    mov eax, A

_parseB:        ; this is where B is parsed
    cmp next, 2
    jne  _isDone
    push index
    call intParse
    pop index
    pop  B
    mov ebx, B
_isDone:
    cmp next, 3
    je _end
    ; inc index
    inc next
    jmp _parseLoop
_end:
    pop eax
    push operator
    push A
    push B
    push eax
    
    ret


inputStringParser ENDP

operatorParse PROC near
_operatorParse:

   pop eax
   pop ecx                      ; index
   push eax 

   ; Take what was read and convert to a operator ID
    mov   eax, 0               ; Initialize the operator
   ; mov   ecx, 0               ; Initialize index into buffer
    mov   ebx, 0               ; Make sure upper bits are all zero.
_findLoop:
    mov   bl, [readBuffer+ecx]
    cmp   bl, '+'
    jne   _checkSubtract
    mov eax, 1
    jmp _endLoop

_checkSubtract: 
    cmp   bl, '-'
    jne   _checkMultiplication
    mov eax, 2
    jmp _endLoop

_checkMultiplication:
    cmp   bl, '*'
    jne   _checkDivision
    mov eax, 3
    jmp _endLoop

_checkDivision:
    cmp   bl, '/'
    jne   _invalid
    mov eax, 4
    jmp _endLoop

_invalid:
    inc   ecx                   ; Go to next location in number
    jmp   _findLoop
 _endLoop:

    pop ebx
    push eax
    push ecx
    push ebx
    ret


operatorParse ENDP

intParse PROC near
_intParse:

   pop eax
   pop ecx                      ; index
   push eax

   mov edx, 0                   ; has number flag


 ; Take what was read and convert to a number
    mov   eax, 0               ; Initialize the number
   ; mov   ecx, 0              ; Initialize index into buffer; used for testing
    mov   ebx, 0               ; Make sure upper bits are all zero
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
    mov edx, 1
    jmp   _findNumberLoop
 _endNumberLoop:
    inc ecx
    cmp edx, 1
    jne _findNumberLoop

    pop ebx
    push eax
    push ecx
    push ebx
    ret
intParse ENDP

END