;Name: Jeremy Cross
;Student ID: 200319513
;Assign: Lab Assignment 3 Phase 2
;Class: ENSE 352-093
;Due Date: October 7 2019

;;; Directives
            PRESERVE8
            THUMB  
			
			
;;; Equates

INITIAL_MSP	EQU		0x20001000	; Initial Main Stack Pointer Value	Allocating 
								; 1000 bytes to the stack as it grows down.
			     
								    
; Vector Table Mapped to Address 0 at Reset
; Linker requires __Vectors to be exported

      AREA    RESET, DATA, READONLY
      EXPORT  __Vectors

__Vectors	DCD		INITIAL_MSP			; stack pointer value when stack is empty
        	DCD		Reset_Handler		; reset vector
	 		
			ALIGN

;The program
; Linker requires Reset_Handler

      AREA    MYCODE, CODE, READONLY



			ENTRY
			EXPORT	Reset_Handler

			ALIGN
				

Reset_Handler	PROC
	
	MOV R0, #3 ; factorial
	
	BL factorial
	
	B done
	
	ENDP
	
factorial	PROC ; subroutine for calculating factorial 
	
	MOV R2, #1 ; hold the built factorial
	
	CMP R0, #0 ; check if factorial is zero
	BEQ zeroCondition ; if so than finish program
		
loop
	
	ADD R1, #1 ;increment
	CMP R1, R0 ;CMP = compare
	
	MUL R3, R1, R2
	
	MOV R2, R3
	
	BNE loop ; BNE = branch not equal
	
zeroCondition

	BX LR
	
	ENDP

done	PROC
	B done
	
	ENDP
	
	END