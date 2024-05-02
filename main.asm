.386P
.model flat


extern   initUtilities:proc
extern   _ExitProcess@4: near


.data

.code
main PROC near
_main:

	call initUtilities

	push	0
	call	_ExitProcess@4

main ENDP
END