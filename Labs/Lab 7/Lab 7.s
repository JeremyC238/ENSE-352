;Name: Jeremy Cross
;Student ID: 200319513
;Assign: Lab Assignment 7
;Class: ENSE 352
;Due Date: 2019

; GPIO Test program - Dave Duguid, 2011
; Modified Trevor Douglas 2014

;;; Directives
            PRESERVE8
            THUMB       

        		 
;;; Equates

INITIAL_MSP	EQU		0x20001000	; Initial Main Stack Pointer Value


;PORT A GPIO - Base Addr: 0x40010800
GPIOA_CRL	EQU		0x40010800	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOA_CRH	EQU		0x40010804	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOA_IDR	EQU		0x40010808	; (0x08) Port Input Data Register
GPIOA_ODR	EQU		0x4001080C	; (0x0C) Port Output Data Register
GPIOA_BSRR	EQU		0x40010810	; (0x10) Port Bit Set/Reset Register
GPIOA_BRR	EQU		0x40010814	; (0x14) Port Bit Reset Register
GPIOA_LCKR	EQU		0x40010818	; (0x18) Port Configuration Lock Register

;PORT B GPIO - Base Addr: 0x40010C00
GPIOB_CRL	EQU		0x40010C00	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOB_CRH	EQU		0x40010C04	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOB_IDR	EQU		0x40010C08	; (0x08) Port Input Data Register
GPIOB_ODR	EQU		0x40010C0C	; (0x0C) Port Output Data Register
GPIOB_BSRR	EQU		0x40010C10	; (0x10) Port Bit Set/Reset Register
GPIOB_BRR	EQU		0x40010C14	; (0x14) Port Bit Reset Register
GPIOB_LCKR	EQU		0x40010C18	; (0x18) Port Configuration Lock Register

;The onboard LEDS are on port C bits 8 and 9
;PORT C GPIO - Base Addr: 0x40011000
GPIOC_CRL	EQU		0x40011000	; (0x00) Port Configuration Register for Px7 -> Px0
GPIOC_CRH	EQU		0x40011004	; (0x04) Port Configuration Register for Px15 -> Px8
GPIOC_IDR	EQU		0x40011008	; (0x08) Port Input Data Register
GPIOC_ODR	EQU		0x4001100C	; (0x0C) Port Output Data Register
GPIOC_BSRR	EQU		0x40011010	; (0x10) Port Bit Set/Reset Register
GPIOC_BRR	EQU		0x40011014	; (0x14) Port Bit Reset Register
GPIOC_LCKR	EQU		0x40011018	; (0x18) Port Configuration Lock Register

;Registers for configuring and enabling the clocks
;RCC Registers - Base Addr: 0x40021000
RCC_CR		EQU		0x40021000	; Clock Control Register
RCC_CFGR	EQU		0x40021004	; Clock Configuration Register
RCC_CIR		EQU		0x40021008	; Clock Interrupt Register
RCC_APB2RSTR	EQU	0x4002100C	; APB2 Peripheral Reset Register
RCC_APB1RSTR	EQU	0x40021010	; APB1 Peripheral Reset Register
RCC_AHBENR	EQU		0x40021014	; AHB Peripheral Clock Enable Register

RCC_APB2ENR	EQU		0x40021018	; APB2 Peripheral Clock Enable Register  -- Used

RCC_APB1ENR	EQU		0x4002101C	; APB1 Peripheral Clock Enable Register
RCC_BDCR	EQU		0x40021020	; Backup Domain Control Register
RCC_CSR		EQU		0x40021024	; Control/Status Register
RCC_CFGR2	EQU		0x4002102C	; Clock Configuration Register 2

; Times for delay routines
        
DELAYTIME	EQU		1600000		; (200 ms/24MHz PLL)


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
	
mainLoop
	
	bl readMainBoardButtons
	bl writeMainBoardLEDS
	
	B	mainLoop
	ENDP


;;;;;;;;Subroutines ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	
;This routine will enable the clock for the Ports that you need	
	ALIGN
GPIO_ClockInit PROC

	; Students to write.  Registers   .. RCC_APB2ENR
	; ENEL 384 Pushbuttons: SW2(Red): PB8, SW3(Black): PB9, SW4(Blue): PC12 *****NEW for 2015**** SW5(Green): PA5
	; ENEL 384 board LEDs: D1 - PA9, D2 - PA10, D3 - PA11, D4 - PA12
	
	ldr r0, = RCC_APB2ENR
	mov r1, #0x1C ; binary = 0001 0100, turns on the clock for port a, b and c
	str r1, [r0]

	BX LR
	ENDP
		
	ALIGN
	
		

;This routine enables the GPIO for the LED's.  By default the I/O lines are input so we only need to configure for ouptut.
	ALIGN
GPIO_init  PROC
	
	; ENEL 384 board LEDs: D1 - PA9, D2 - PA10, D3 - PA11, D4 - PA12
	
	; binary = 0011 0011 0011 0011 0000, sets the bits for PA9, PA10, PA11, PA12
	; 11 for mode sets the max speed to 50MHz, leaving the CNF bits to 00 sets to
	; general purpose output push-pull
	
	; for the LEDs
	ldr r2, = GPIOA_CRH
	ldr r3, = 0xfff3333f
	str r3, [r2]
	
	
	BX LR
	ENDP

readMainBoardButtons	PROC
	
	push {r0, r1, r6}
	
	; My final output is on r3 so clear it
	ldr r3, = 0x0
		
	; read the state of sw2 and sw3 on port B on bits 8 and 9
	ldr r6, = GPIOB_IDR
	ldr r0, [r6]
	; isolate bit 8 and 9
	ldr r1, = 0x00000300
	and r0, r1 ; r0 now contains the switch input for sw2 and sw3
	lsr r0, #8
	orr r3, r0 ; switch 2 and 3 are ready
	
	; read the state of sw4 on port c bit 12
	ldr r6, = GPIOC_IDR
	ldr r0, [r6]
	; isolate bit 12 of port c
	ldr r1, = 0x00001000
	and r0, r1
	lsr r0, #10
	orr r3, r0
	
	; read the state of sw5 on port a bit 5
	ldr r6, = GPIOA_IDR
	ldr r0, [r6]
	; isolate bit 5 of port a
	ldr r1, = 0x00000020
	and r0, r1
	lsr r0, #2
	orr r3, r0
	
	pop {r0, r1, r6}
	bx lr
	ENDP
		
writeMainBoardLEDS	PROC
	
	push {r0, r1, r6}
	
	lsl r3, #9
	
	; turn on 384 board LEDS
	ldr r6, = GPIOA_ODR
	ldr r0, [r6]
	
	; mask of clear bits 9, 10, 11, 12
	ldr r1, = 0xe1ff
	and r0, r1 ; this will clear those bits
	orr r0, r3
	str r0, [r6]
	
	pop {r0, r1, r6}
	bx lr
	ENDP


	ALIGN
	END