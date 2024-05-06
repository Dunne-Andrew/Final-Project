; Andrew Dunne
; 5/ 5 / 24
; Provide functionality for the read/write functions


.386P                                           ; 8068 or x86 code version 386

.model flat	                                    ; memory model

.data                                           ; data section is used to store data such as global variables
	operator            dword   ?
    A                   dword   ?
    B                   dword   ?

.code
calculate PROC near
_calculate:
	
	pop eax
	pop B
	pop A
	pop operator
	push eax

    cmp operator, 1
    jne   _checkSubtract
    mov eax, A
    add eax, B
    jmp _endcalculate

_checkSubtract: 
    cmp operator, 2
    jne   _checkMultiplication
    mov eax, A
    sub eax, B
    jmp _endcalculate

_checkMultiplication:
    cmp operator, 3
    jne   _checkDivision
    mov eax, A
    imul eax, B
    jmp _endcalculate

_checkDivision:
    cmp operator, 4
    jne   _invalid
    mov edx, 0
    mov eax, A
    idiv B
    jmp _endcalculate

_invalid:

_endcalculate:
    pop edx
    push eax
    push edx
    
    ret

calculate ENDP
END