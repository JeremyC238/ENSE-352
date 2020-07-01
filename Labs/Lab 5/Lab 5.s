;Name: Jeremy Cross
;Student ID: 200319513
;Assign: Lab Assignment 5
;Class: ENSE 352
;Due Date: October 28 2019

; Directives
	PRESERVE8	
	THUMB   

  ;;; Equates
end_of_stack	equ 0x20001000			;Allocating 4kB of memory for the stack
RAM_START		equ	0x20000000

; Vector Table Mapped to Address 0 at Reset, Linker requires __Vectors to be exported

			AREA    RESET, DATA, READONLY
			EXPORT  __Vectors
;The DCD directive allocates one or more words of memory, aligned on four-byte boundaries, 
;and defines the initial runtime contents of the memory.


__Vectors
				DCD	0x20002000		; stack pointer value when stack is empty
		    DCD	Reset_Handler		; reset vector
	 
				ALIGN

;My  program,  Linker requires Reset_Handler and it must be exported

				AREA    MYCODE, CODE, READONLY
				ENTRY
				EXPORT	Reset_Handler

Reset_Handler PROC
	
	; PHASE 1
	
	; Part 1
	; R0 used as input
	; R1 contain 1 or 0 depending on whether bit 11 is a 1 or 0
	
	MOV R0, #1 ; input registor
	
	BL checkBitEleven
	
	; Part 2
	; R0 used as input
	; R2 holds bit mask
	
	MOV R0, #0 ; input registor
	
	BL clearBit7
	
	; Part 3
	; r0 holds the input (bit mask)
	; r1 holds the answer
	; r2 holds initial bit mask
	; r3 shift counter
	
	MOV R0, #0xff ; input registor
	
	BL countingOnes
	
	; PHASE 2
	
	; hold the value to be shifted
	ldr r0, = 0x12345678 ; input register
	
	; bits 0-3 indicate shift amount
	; bit 5 indicates direction to shift, 1 for rotate left, 0 for rotate right
	mov r1, #0x00000011 ; second input register
	
	bl rot_left_right

done
	b done
	
	ENDP
	
checkBitEleven PROC ; PHASE 1 Part 1
	
	PUSH {R1}
	
	; check bit 11
	and r1, r0, #0x800 ; store result in r1
	
	; shift over to bit 11
	LSR R1, R1, #11
	
	pop {r1}
	
	bx lr
	
	ENDP
	
clearBit7 PROC ; PHASE 1 Part 2
	
	PUSH {R1, r2, r3}
	
	MOV R2, #0x88; holds bit mask
	;MOV R0, #0
	
	ORR R0, R0, R2 ; r0 is now 0x48
	
	MOV R3, #0x08; holds bit mask
	AND R0, R0, R3 ; removes bit 7
	
	POP {R1, r2, r3}
	
	BX LR
	
	ENDP
	
countingOnes PROC ; PHASE 1 Part 3
	
	PUSH {R1, r2, r3}

	;MOV R0, #0xff
	MOV R2, #0x01 ; counter
	
loop
	AND R3, R2, R0
	
	CMP R3, #0x00
	ADDNE R1, R1, #1 ; R1 holds the value
	
	LSL R2, R2, #1
	
	CMP R2, #0x00000100
	BNE loop
	
	POP {R1, r2, r3}
	
	BX LR
	
	ENDP
		
rot_left_right PROC ; PHASE 2
	
	push {r2, r3, r4, r5, r6, r7, r8}
	
	; bit mask to isolate bits 0-3, shift amount
	mov r2, #0x0000000f
	and r3, r1, r2 ; r3 = r1 & 0x0000000f
	
	; bit mask to isolate bit 5 shift direction
	mov r4, #0x00000010
	and r5, r1, r4 ; r5 = r1 & 0x00000010
	
	; bit mask for the first 16 bits of input register r0
	mov r9, #0x0000ffff
	and r6, r0, r9 ; r6 = r0 & 0x0000ffff
	
	cmp r5, #0x00000010 ; shift left
	beq shift_left
	
	cmp r5, #0x00000000 ; shift right
	beq shift_right
	
shift_left
	lsl r6, r6, r3 ; r6 = (r6 << r3)
	
	; clear the upper 16 bits
	and r6, r6, r9 ; r6 = 0x0000ACF0 & 0x0000ffff
	
	; tack on original 16 bits
	ldr r7, = 0xffff0000 ; bit mask for upper 16 bits
	and r8, r0, r7 ; tacks on upper 16 bits
	orr r6, r6, r8 ; r6 = 0x0000ACF0 | 0x12340000
	
	pop {r2, r3, r4, r5, r6, r7, r8}
	
	bx lr
	
shift_right
	lsr r6, r6, r3 ; r6 = (r6 >> r3)
	
	; clear the upper 16 bits
	and r6, r6, r9
	
	; tack on original 16 bits
	ldr r7, = 0xffff0000 ; bit mask for upper 16 bits
	and r8, r0, r7 ; tacks on upper 16 bits
	orr r6, r6, r8

	pop {r2, r3, r4, r5, r6, r7, r8}
	
	bx lr
	
	ENDP
	
	END
		
		
		