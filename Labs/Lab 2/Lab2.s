;ARM1.s Source code for my first program on the ARM Cortex M3
;Function Modify some registers so we can observe the results in the debugger
;Author - Dave Duguid
;Modified August 2012 Trevor Douglas

;Name: Jeremy Cross
;Student ID: 200319513
;Assign: Lab Assignment 2
;Class: ENSE 352-093
;Due Date: September 30 2019

; Directives
	PRESERVE8
	THUMB
		
; Vector Table Mapped to Address 0 at Reset, Linker requires __Vectors to be exported
	AREA RESET, DATA, READONLY
	EXPORT 	__Vectors


__Vectors DCD 0x20002000 ; stack pointer value when stack is empty
	DCD Reset_Handler ; reset vector
	
	ALIGN


;My program, Linker requires Reset_Handler and it must be exported
	AREA MYCODE, CODE, READONLY
	ENTRY

	EXPORT Reset_Handler
		
		
Reset_Handler ;We only have one line of actual application code
	
	; Ry = R1, Rz = R2, Rx = R3
	
Beginning ;label
		
	;moves 0x00000001 into R1, 0x00000002 into R2 (LDR)
	MOV R1, #0x00000001
	MOV R2, #0x00000002

	;add R1 and R2 into R3, without affecting condition codes
	ADD R3, R1, R2

	;moves 0xFFFFFFFF into R2
	MOV R2, #0xFFFFFFFF

	;add R1 and R2 into R3, with affecting condition codes
	ADDS R3, R1, R2 ;zero flag and carry flag
	
	;push R1, R2, R3 onto the stack pointer register (R13)
	PUSH {R1, R2, R3}
	
	;moves 0x2 into R1
	MOV R1, #0x2
	
	;add R1 and R2, with affecting condition codes, note flags
	ADDS R3, R1, R2 ;carry flag
	
	;moves 0x7FFFFFFF into R1, 0x7FFFFFFF into R2
	MOV R1, #0x7FFFFFFF
	MOV R2, #0x7FFFFFFF
	
	;add R1 and R2 into R3, with affecting conditions, note flags
	ADDS R3, R1, R2 ;negative flag and overflow flag
	
	B Beginning ;loop
	
	ALIGN
	
	END
