; GPIO Test program - Dave Duguid, 2011
; Modified Trevor Douglas 2014

; Jeremy Cross
; 200319513
; ENSE 352 Lab 6

;;; Directives
            PRESERVE8
            THUMB       

        		 
;;; Equates

INITIAL_MSP	EQU		0x20001000	; Initial Main Stack Pointer Value


;The onboard LEDS are on port C bits 8 and 9
;PORT C GPIO - Base Addr: 0x40011000
GPIOC_CRL	EQU		0x40011000	; (0x00) Port Configuration Register for Px7 -> Px0
RCC_APB2ENR	EQU		0x40021018	; APB2 Peripheral Clock Enable Register
	
GPIOc_CRH	EQU		0x40011004 
GPIOa_CRL	EQU		0x40010800	
GPIOc_ODR	EQU		0x4001100C 
GPIOa_IDR	EQU		0x40010808

; Times for delay routines
        
TIME_DELAY	EQU		200000		



; Vector Table Mapped to Address 0 at Reset
            AREA    RESET, Data, READONLY
            EXPORT  __Vectors

__Vectors	DCD		INITIAL_MSP			; stack pointer value when stack is empty
        	DCD		Reset_Handler		; reset vector
			
            AREA    MYCODE, CODE, READONLY
			EXPORT	Reset_Handler
			ENTRY

Reset_Handler		PROC

	BL GPIO_ClockInit
	BL GPIO_init
	ldr r0, = GPIOc_ODR
	ldr r1, = TIME_DELAY
	ldr r2, = GPIOa_IDR
	
; mainLoop for students to write in.	
mainLoop
		
	mov r8, #0
	
	;bl phase2
	;bl phase2
	
	b phase3
	
	B	mainLoop
	
	ENDP

;;;;;;;;Subroutines ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
;This routine will enable the clock for the Ports that you need	
	ALIGN
GPIO_ClockInit PROC

	ldr r3, = RCC_APB2ENR
	mov r4, #0x14 ; binary = 0001 0100, turns on the clock for port a and c
	str r4, [r3]

	BX LR
	ENDP
		
	ALIGN

;This routine enables the GPIO for the LED;s
GPIO_init  PROC
	
	; binary = 0011 0011, sets the mode bits for both port C pins 8 and 9
	; 11 for mode sets the max speed to 50MHz, leaving the CNF bits to 00 sets to
	; general purpose output push-pull
	ldr r2, = GPIOc_CRH
	mov r5, #0x33 	
	str r5, [r2]
	
	; binary = 0100, leave mode to 00 for input mode, then set CNF to 01 for floating point
	ldr r6, = GPIOa_CRL
	mov r7, #0x4 
	str r7, [r6]

	BX LR
	ENDP

	ALIGN

phase2 PROC
	
delayLEDs
	push {r1}
	
clockCountDown

	cmp r1, #0 
	beq alternateLEDs ; once clock at 0 branch out
	
	sub	r1, r1, #1 ; decreases clock until it reaches 0
	
	b clockCountDown
	
alternateLEDs
	
	pop{r1} ;reset clock
	
	cmp r8, #0
	beq turnOnLED8
	
	cmp r8, #1
	beq turnOnLED9
	

turnOnLED8
	; turn on led 8
	mov r10, #0x0100 ; turns on led 8
	str r10, [r0]
	
	add r8, #1
	bx lr ; branch back to apply clock
	
	
turnOnLED9
	;turn on led 9 
	mov r10, #0x0200 ; turns on led 9
	str r10, [r0]
	
	sub r8, #1
	bx lr ; branch back to apply clock
	

	ENDP
		
	ALIGN

; button has been pressed for phase 3
phase3 PROC 
	
	ldr r9, = GPIOa_IDR
	ldr r11, [r9]
	;isolate bit 0 of port a
	ldr r12, = 0x00000001
	and r11, r12
	cmp r11, #0x00000001
	beq turnOnLED8

turnOffLight

	mov r10, #0x0000 ; turns off led 8
	str r10, [r0]
	
	bx lr
	
	ENDP
		
	ALIGN
		
	END