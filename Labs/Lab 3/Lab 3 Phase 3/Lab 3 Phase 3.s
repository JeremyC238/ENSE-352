;Name: Jeremy Cross
;Student ID: 200319513
;Assign: Lab Assignment 3 Phase 3
;Class: ENSE 352-093
;Due Date: October 19 2016

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
	
	LDR R0, = string1
	MOV R1, #0 ;sets the vowel counter to 0 in R1
	BL	charSplit ; branchs to the charSplit subroutine
	
done	
	
	B done
	
	ENDP
	
charSplit		PROC
	
	LDRB R2, [R0] ;loads R2 with the value at the memory address 
	CMP R2, #0 ;checks if R2 is 0
	BNE countVowels ;if not null then branch to countVowel
	
	BX LR
	
countVowels		
	
	;TEQ = test equivalence
	TEQ R2, #'a' ;if char is equal to 'a'
	TEQNE R2, #'e' ;else if char is equal to 'e'
	TEQNE R2, #'i' ;else if char is equal to 'i'
	TEQNE R2, #'o' ;else if char is equal to 'o'
	TEQNE R2, #'u' ;else if char is equal to 'u'
	TEQNE R2, #'A' ;else if char is equal to 'A'
	TEQNE R2, #'E' ;else if char is equal to 'E'	
	TEQNE R2, #'I' ;else if char is equal to 'I'
	TEQNE R2, #'O' ;else if char is equal to 'O'
	TEQNE R2, #'U' ;else if char is equal to 'U'
	ADDEQ R1, R1 , #1 ;if vowel found then increment vowel counter
	
	ADD R0, #1 ;increments the memory address stored by R2 
	B  charSplit
				
	ENDP
		


;string1		DCB		"abcde"
string1		DCB		"ENSE 352 is fun and I am learning ARM assembly!"

;string2		DCB		"abcde",0
string2		DCB		"Yes I really love it!",0

	END
