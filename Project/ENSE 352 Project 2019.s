; ENSE 352 Project Fall 2019 Semester
; Name: Jeremy Cross
; Student ID: 200319513
; Due: Dec 6 2019 at 11:59pm
; Project: "Whack-a-Mole"


; GPIO Test program - Dave Duguid, 2011
; Modified Trevor Douglas 2014

;;; Directives
            PRESERVE8
            THUMB       

        		 
;;; Equates

INITIAL_MSP	EQU		0x20001000	; Initial Main Stack Pointer Value
SEED_ADDRESS EQU	0X20001008	; Address that stores the seed value


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
; default value = 1600000, (200 ms/24MHz PLL)
DELAYTIME1	EQU		500000 ; delay for start up sequence
DELAYTIME2	EQU		1600000 ; game LED delay
								

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

	ldr r10, = DELAYTIME1 ; start up sequence delay
	ldr r11, = DELAYTIME2 ; delay for the game LEDs
	ldr r12, = 1500
	
	; Use Case 1: Turning on the system
	bl turningOnTheSystem
	
	; Use Case 2: Waiting for player
	bl configureSwitches
	bl ledStartUpSequence
	
	; Use Case 3: Normal Game Play
	; Use Case 4: End Success (player wins the game)
	; Use Case 5: End Failure (player loses the game)
	bl RNGmaker
	
	b	mainLoop
	
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
	
	bx lr
	ENDP
		
	
	
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
	
    bx lr
	ENDP
		
turningOnTheSystem	PROC
	
	push {r0, r1, r2}
	
	; LEDs are on at the start of the game
	; LEDS turn on in Active Low configuration
	ldr r0, = GPIOA_ODR
	ldr r1, [r0]
	ldr r3, = 0xfffe1ff ; value to turn lights on
	and r2, r1, r3
	str r2, [r0] ; sets bits 9, 10, 11, 12 to zero, turning them on
	
	pop {r0, r1, r2}
	
	bx lr
	
	ENDP
		
configureSwitches	PROC
	
	; clock for seed value
	sub r12, r12, #1
	
	push {r0, r1, r2}
	
	ldr r4, = 0x00000000 ; holds the switch inputs
	
	; configuring sw2(red): PB8 to LED1: PA9
	; configuring sw3(black): PB9 to LED2: PA10
	ldr r3, = GPIOB_IDR
	ldr r0, [r3]
	ldr r1, = 0x00000300 ; 0000 0000 0000 0000 0000 0011 0000 0000, sets bits 9 and 10
	and r0, r1 ; insert into GPIOB_IDR
	orr r4, r0
	
	; configuring sw4(blue): PC12 to LED3: PA11
	ldr r3, = GPIOC_IDR
	ldr r0, [r3]
	ldr r1, = 0x00001000 ; 0000 0000 0000 0000 0001 0000 0000 0000, sets bit 12
	and r0, r1 ; insert into GPIOC_IDR
	orr r4, r0
	
	; configuring sw5(green): PA5 t0 LED4: PA12
	ldr r3, = GPIOA_IDR
	ldr r0, [r3]
	ldr r1, = 0x00000020 ; 0000 0000 0000 0000 0000 0000 0010 0000, sets bit 5
	and r0, r1 ; insert into GPIOA_IDR
	orr r4, r0
	
	; check if the swtich inputs have changed
	mov r5, #0x1320
	cmp r4, r5
	it ne
	bxne lr ; brach back to main if change has occured

	pop {r0, r1, r2}
	
	cmp r12, #0
	addeq r12, r12, #1500 ; reset seed counter, when it reaches 0
	
	b configureSwitches ; loop back if no change to inputs
	
	ENDP
		
ledStartUpSequence	PROC
	
	push {lr, r0, r1, r2}
	
	; if the input has changed, one of the buttons is pressed
	; the LEDs turn off
	ldr r3, = GPIOA_ODR
	ldr r0, [r3]
	ldr r1, = 0x1eff
	orr r0, r1
	str r0, [r3]
	
	mov r4, #2 ; loop counter
	
start	

	; add delay
	bl delayLEDs
	
	; start LED sequence
	; turn ON LED1
	ldr r3, = GPIOA_ODR
	ldr r0, [r3]
	ldr r1, = 0xfdff ; bit 9
	and r0, r1
	str r0, [r3]
	
	; add delay
	bl delayLEDs
	
	; turn OFF LED1
	ldr r3, = GPIOA_ODR
	ldr r0, [r3]
	ldr r1, = 0xffff
	orr r0, r1
	str r0, [r3]
	
	; turn ON LED2
	ldr r3, = GPIOA_ODR
	ldr r0, [r3]
	ldr r1, = 0xfbff ; bit 10
	and r0, r1
	str r0, [r3]
	
	; add delay
	bl delayLEDs
	
	; turn OFF LED2
	ldr r3, = GPIOA_ODR
	ldr r0, [r3]
	ldr r1, = 0xffff
	orr r0, r1
	str r0, [r3]
	
	; turn ON LED3
	ldr r3, = GPIOA_ODR
	ldr r0, [r3]
	ldr r1, = 0xf7ff ; bit 11
	and r0, r1
	str r0, [r3]
	
	; add delay
	bl delayLEDs
	
	; turn OFF LED3
	ldr r3, = GPIOA_ODR
	ldr r0, [r3]
	ldr r1, = 0xffff
	orr r0, r1
	str r0, [r3]
	
	; turn ON LED4
	ldr r3, = GPIOA_ODR
	ldr r0, [r3]
	ldr r1, = 0xefff ; bit 12
	and r0, r1
	str r0, [r3]
	
	; add delay
	bl delayLEDs
	
	; turn OFF LED4
	ldr r3, = GPIOA_ODR
	ldr r0, [r3]
	ldr r1, = 0xffff
	orr r0, r1
	str r0, [r3]
	
	sub r4, r4, #1 ; loops twice, subs 1 from the loop counter
	cmp r4, #0 ; if the LED sequence has looped twice than exit the loop
	beq finished

	b start

finished
	
	; add delay
	bl delayLEDs
	
	pop {lr, r0, r1, r2}
	
	bx lr
	
	ENDP
		
delayLEDs	PROC
	
	push {r10}

clockCountDown
	
	cmp r10, #0 
	beq finishedDelay ; once clock at 0 branch out
	
	sub	r10, r10, #1 ; decreases clock until it reaches 0
	
	b clockCountDown

finishedDelay
	
	pop{r10}
	
	bx lr

	ENDP
		
RNGmaker	PROC
	
	; r0 = a (constant) = 1,664,525
	; r1 = c (constant)	= 1,013,904,223
	; r2 = X (seed value) = counter value r12 * r2 after first run
	; r4 = hold RNG logic result
	; r9 = holds the input value from the user
	
	push {lr, r0, r1, r2}
	
	ldr r0, = 0x0019660d ; 1,664,525 , a constant
	ldr r1, = 0x3c6ef35f ; 1,013,904,223 , c constant
	mov r2, #2 ; X value
	mov r10, #1 ; game counter, 16 total rounds

startGame

	cmp r10, #16
	beq SuccessSequence ; once 15 rounds are complete, the game enter success state
	
	; start RNG logic
	mul r4, r2, r0 ; result = X * a
	add r4, r4, r1 ; result = result + c
	
	mov r8, r4 ; holds equation value
	lsr r4, r4, #30
	
	; TURN AN LED ON!!!
	
	ldr r5, = GPIOA_ODR
	ldr r6, [r5]
	
	cmp r4, #0x0000
	moveq r7, #0xfdff ; value for LED 1
	
	cmp r4, #0x0001
	moveq r7, #0xfbff ; value for LED 2
	
	cmp r4, #0x0002
	moveq r7, #0xf7ff ; value for LED 3
	
	cmp r4, #0x0003
	moveq r7, #0xefff ; value for LED 4
	
	and r6, r7
	str r6, [r5]
	
	; the delay for the player
	ldr r11, = DELAYTIME2 ; reset timer for delay
	mov r5, #4
	sdiv r11, r11, r5
	
	; CHECK FOR PLAYER INPUT!!
	
	bl checkSwitchInputs ; takes the input from the player with the switches
	
	cmp r11, #0 ; if player failed to hit the button in time
	beq failureSequence
	
	ldr r3, = 0x1220
	cmp r9, r3 ; value for SW2
	moveq r7, #0x0200 ; bit mask to turn off bit 9 (LED1)
	
	ldr r3, = 0x1120
	cmp r9, r3 ; value for SW3
	moveq r7, #0x0400 ; bit mask to turn off bit 10 (LED2)
	
	ldr r3, = 0x0320
	cmp r9, r3 ; value for SW4
	moveq r7, #0x0800 ; bit mask to turn off bit 11 (LED3)
	
	ldr r3, = 0x1300
	cmp r9, r3 ; value for SW5
	moveq r7, #0x1000 ; bit mask to turn off bit 12 (LED4)
	
	; turn off the appropriate LEDs
	ldr r5, = GPIOA_ODR
	ldr r6, [r5]
	orr r6, r7
	str r6 , [r5]
	
	; check if there is still an led on
	; if so, then player loses
	ldr r5, = GPIOA_ODR
	ldr r6, [r5]
	mov r7, #0xffff
	cmp r6, r7
	bne failureSequence ; if one of the lights is not off, then game ends
	
	; add delay before next pattern
	ldr r11, = DELAYTIME2 ; reset timer for delay
	mov r5, #4
	sdiv r11, r11, r5
	bl delayGameLEDs
	
	; set new X value by using the previous X value * seed (clock value)
	mul r2, r2, r12
	
	add r10, r10, #1 ; increments the game counter

	b startGame

SuccessSequence

	; mulitpliers for delay
	mov r0, #4
	
	; counter for blinking loop
	mov r1, #0

startSuccess

	cmp r1, #5
	beq endSuccess ; once 5 blinking loops have occured, the game ends

	; show all LEDs blinking
	; turns on the LEDs
	ldr r5, = GPIOA_ODR
	ldr r7, [r5]
	ldr r6, = 0xe1ff
	and r7, r6
	str r7, [r5]
	
	ldr r11, = DELAYTIME2 ; reset timer for delay
	sdiv r11, r11, r0 ; decrease delay, increase blinking speed
	bl delayGameLEDs
	
	; turn off all LEDs
	ldr r5, = GPIOA_ODR
	ldr r7, [r5]
	ldr r6, = 0xffff
	orr r7, r6
	str r7, [r5]
	
	ldr r11, = DELAYTIME2 ; reset timer for delay
	sdiv r11, r11, r0 ; decrease delay, increase blinking speed
	bl delayGameLEDs
	
	add r1, r1, #1
	
	b startSuccess
	
endSuccess

	b finishGame
	
failureSequence
	
	; mulitpliers for delay
	mov r0, #2
	
	; turn off remaining LEDs
	ldr r5, = GPIOA_ODR
	ldr r7, [r5]
	ldr r6, = 0xffff
	orr r7, r6
	str r7, [r5]
	
	ldr r11, = DELAYTIME2 ; reset timer for delay
	bl delayGameLEDs
	
	; display level the player lost on
	; use value of r10
	
	; level 1
	cmp r10, #1
	moveq r1, #0xefff
	
	; level 2
	cmp r10, #2
	moveq r1, #0xf7ff
	
	; level 3
	cmp r10, #3
	moveq r1, #0xe7ff
	
	; level 4
	cmp r10, #4
	moveq r1, #0xfbff
	
	; level 5
	cmp r10, #5
	moveq r1, #0xebff
	
	; level 6
	cmp r10, #6
	moveq r1, #0xf3ff
	
	; level 7
	cmp r10, #7
	moveq r1, #0xe3ff
	
	; level 8
	cmp r10, #8
	moveq r1, #0xfdff
	
	; level 9
	cmp r10, #9
	moveq r1, #0xedff
	
	; level 10
	cmp r10, #10
	moveq r1, #0xf5ff
	
	; level 11
	cmp r10, #11
	moveq r1, #0xe5ff
	
	; level 12
	cmp r10, #12
	moveq r1, #0xf9ff
	
	; level 13
	cmp r10, #13
	moveq r1, #0xe9ff
	
	; level 14
	cmp r10, #14
	moveq r1, #0xf1ff
	
	; level 15
	cmp r10, #15
	moveq r1, #0xe1ff
	
	; turn on appropriate LEDs
	ldr r5, = GPIOA_ODR
	ldr r7, [r5]
	and r7, r1
	str r7, [r5]
	
	ldr r11, = DELAYTIME2 ; reset timer for delay
	mul r11, r11, r0
	bl delayGameLEDs
	
	; turn off all LEDs
	ldr r5, = GPIOA_ODR
	ldr r7, [r5]
	ldr r6, = 0xffff
	orr r7, r6
	str r7, [r5]
	
	ldr r11, = DELAYTIME2 ; reset timer for delay
	mul r11, r11, r0
	bl delayGameLEDs
	
	b finishGame
	
finishGame

	pop {lr, r0, r1, r2}
	
	bx lr
		
	ENDP
		
		
checkSwitchInputs	PROC
	
	cmp r11, #0
	beq finishedInputCheck
	
	push {r0, r1, r2}
	
	ldr r9, = 0x00000000 ; holds the switch inputs
	
	; configuring sw2(red): PB8 to LED1: PA9
	; configuring sw3(black): PB9 to LED2: PA10
	ldr r3, = GPIOB_IDR
	ldr r0, [r3]
	ldr r1, = 0x00000300 ; 0000 0000 0000 0000 0000 0011 0000 0000, sets bits 9 and 10
	and r0, r1 ; insert into GPIOB_IDR
	orr r9, r0
	
	; configuring sw4(blue): PC12 to LED3: PA11
	ldr r3, = GPIOC_IDR
	ldr r0, [r3]
	ldr r1, = 0x00001000 ; 0000 0000 0000 0000 0001 0000 0000 0000, sets bit 12
	and r0, r1 ; insert into GPIOC_IDR
	orr r9, r0
	
	; configuring sw5(green): PA5 t0 LED4: PA12
	ldr r3, = GPIOA_IDR
	ldr r0, [r3]
	ldr r1, = 0x00000020 ; 0000 0000 0000 0000 0000 0000 0010 0000, sets bit 5
	and r0, r1 ; insert into GPIOA_IDR
	orr r9, r0
	
	pop {r0, r1, r2}
	
	; check if the swtich inputs have changed
	mov r5, #0x1320
	cmp r9, r5
	it ne
	bxne lr ; brach back if change has occured

	sub r11, r11, #1 ; decreases clock until it reaches 0
	
	b checkSwitchInputs ; loop back if no change to inputs
	
finishedInputCheck

	bx lr
	
	ENDP
		
delayGameLEDs	PROC
	
	push {r11}

gameClockCountDown
	
	cmp r11, #0 
	beq gameFinishedDelay ; once clock at 0 branch out
	
	sub	r11, r11, #1 ; decreases clock until it reaches 0
	
	b gameClockCountDown

gameFinishedDelay
	
	pop{r11}
	
	bx lr

	ENDP

	ALIGN
	END