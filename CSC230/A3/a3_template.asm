; a3_template.asm
; CSC 230 - Summer 2018
; 
; Starter code for A3.
;
; B. Bird - 07/01/2018

.include "lcd_function_defs.inc"

; Stack pointer and SREG registers (in data space)
.equ SPH_DS = 0x5E
.equ SPL_DS = 0x5D
.equ SREG_DS = 0x5F

; Initial address (16-bit) for the stack pointer
.equ STACK_INIT = 0x21FF

; Definitions for button values from the ADC
; Some boards may use the values in option B
; The code below used less than comparisons so option A should work for both
; Option A (v 1.1)
; .equ ADC_BTN_RIGHT = 0x032
; .equ ADC_BTN_UP = 0x0FA
; .equ ADC_BTN_DOWN = 0x1C2
; .equ ADC_BTN_LEFT = 0x28A
; .equ ADC_BTN_SELECT = 0x352
; Option B (v 1.0)
.equ ADC_BTN_RIGHT = 0x032
.equ ADC_BTN_UP = 0x0C3
.equ ADC_BTN_DOWN = 0x17C
.equ ADC_BTN_LEFT = 0x22B
.equ ADC_BTN_SELECT = 0x316

; Definitions for the analog/digital converter (ADC)
.equ ADCSRA_DS	= 0x7A ; Control and Status Register A
.equ ADCSRB_DS	= 0x7B ; Control and Status Register B
.equ ADMUX_DS	= 0x7C ; Multiplexer Register
.equ ADCL_DS	= 0x78 ; Output register (high bits)
.equ ADCH_DS	= 0x79 ; Output register (low bits)

; Definitions of the special register addresses for timer 0 (in data space)
.equ GTCCR_DS = 0x43
.equ OCR0A_DS = 0x47
.equ OCR0B_DS = 0x48
.equ TCCR0A_DS = 0x44
.equ TCCR0B_DS = 0x45
.equ TCNT0_DS  = 0x46
.equ TIFR0_DS  = 0x35
.equ TIMSK0_DS = 0x6E
.DEF STATUS = R20
.equ DELAY_ITERATIONS = 18000
.DEF IGNORE = R21
.DEF LAPPED = R22
.cseg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                          Reset/Interrupt Vectors                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.org 0x0000 ; RESET vector
	jmp main_begin
	
; Add interrupt handlers for timer interrupts here. See Section 14 (page 101) of the datasheet for addresses.
.org 0x002a
	jmp TIMER0_OC_ISR 
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Main Program                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; According to the datasheet, the last interrupt vector has address 0x0070, so the first
; "unreserved" location is 0x0072
.org 0x0074
main_begin:

	; Initialize the stack
	ldi r16, high(STACK_INIT)
	sts SPH_DS, r16
	ldi r16, low(STACK_INIT)
	sts SPL_DS, r16
	
	; Initialize the LCD
	
	;call TIMER0_SETUP ; Set up timer 0 control registers (function below)
	
	ldi r16, 0
	sts OC_INTERRUPT_COUNTER, r16

	
	;sei ; Set the I flag in SREG to enable interrupt processing
	call SET_MAX_ARRAY
	CALL SET_TIME_ARRAY
	CALL SET_LINE_TWO
	LDI LAPPED,0
	; Set up ADCSRA (ADEN = 1, ADPS2:ADPS0 = 111 for divisor of 128)
	ldi	r16, 0x87
	sts	ADCSRA_DS, r16
	
	; Set up ADCSRB (all bits 0)
	ldi	r16, 0x00
	sts	ADCSRB_DS, r16
	
	; Set up ADMUX (MUX4:MUX0 = 00000, ADLAR = 0, REFS1:REFS0 = 1)
	ldi	r16, 0x40
	sts	ADMUX_DS, r16
	
	
	; Now, check the button values until something below the highest threshold
	; (ADC_BTN_SELECT) is returned from the ADC.
	
	; Store the threshold in r21:r20
	; ldi	r20, low(ADC_BTN_SELECT)
	; ldi	r21, high(ADC_BTN_SELECT)
	clr r21
	

	call lcd_init
DONEMAIN:
	
	; Start an ADC conversion
	
	; Set the ADSC bit to 1 in the ADCSRA register to start a conversion
	lds	r16, ADCSRA_DS
	ori	r16, 0x40
	sts	ADCSRA_DS, r16
	
	; Wait for the conversion to finish
wait_for_adc:
	lds		r16, ADCSRA_DS
	andi	r16, 0x40
	brne	wait_for_adc
	
	; Load the ADC result into the X pair (XH:XL). Note that XH and XL are defined above.
	lds	XL, ADCL_DS
	lds	XH, ADCH_DS
	;CALL DELAY
	ldi r18, low(ADC_BTN_RIGHT)
	ldi r17, high(ADC_BTN_RIGHT)
	cp XL, r18
	cpc XH, R17
	brlo RIGHT	
	
	ldi r18, low(ADC_BTN_UP)
	ldi r17, high(ADC_BTN_UP)
	cp XL, r18
	cpc XH, R17
	brlo UP
	
	ldi r18, low(ADC_BTN_DOWN)
	ldi r17, high(ADC_BTN_DOWN)
	cp XL, r18
	cpc XH, R17
	brlo DOWN
	
	ldi r18, low(ADC_BTN_LEFT)
	ldi r17, high(ADC_BTN_LEFT)
	cp XL, r18
	cpc XH, R17
	brlo LEFT
	
	
	ldi r18, low(ADC_BTN_SELECT)
	ldi r17, high(ADC_BTN_SELECT)
	cp XL, r18
	cpc XH, R17
	brlo SELECT
	LDI IGNORE,0
	CALL DISPLAY_LCD
		JMP DONEMAIN
		
		
DOWN:
	CPI IGNORE,1
	BREQ DONEMAIN	
	CALL SET_LINE_TWO
	LDI LAPPED,0
	JMP DONEMAIN	

RIGHT:
	CPI IGNORE,1
	BREQ DONEMAIN
	JMP DONEMAIN	
	
SELECT:
	CPI IGNORE,1
	BREQ DONEMAIN
	LDI IGNORE,1
	LDI R16,0
	CP R16, STATUS
	BREQ PAUSED
	CLI
	LDI STATUS, 0
	CALL DELAY
	JMP DONEMAIN
PAUSED:
	 call TIMER0_SETUP
	 SEI
	 LDI STATUS,1
	 CALL DELAY	 
	 JMP DONEMAIN
	 
LEFT:
	CPI IGNORE, 1
	BREQ BYE
	LDI IGNORE,1
	CLI
	CALL SET_TIME_ARRAY
BYE:	
	JMP DONEMAIN
	 
UP:
	CPI IGNORE,1
	BREQ DONEZOS
	LDI IGNORE,1
	CALL DELAY
	CALL DISPLAY_CURRENT_LAP
DONEZOS:
	JMP DONEMAIN
	


;	HANDLES LAPS  ;

DISPLAY_CURRENT_LAP:
	push r16
	push r17
	push XL
	push XH
	push YL
	push YH
	push ZL
	push ZH

	ldi XL, low(TIME)
	ldi XH, high(TIME)
	ldi YL, low(LINE_TWO)
	ldi YH, high(LINE_TWO)

	cpi LAPPED, 0
	breq RIGHTSIDE

LEFTSIDES:
	jmp LEFTSIDE

RIGHTSIDE:
	ldi r16, '0'
	st Y+, r16
	ldi r16, '0'
	st Y+, r16
	ldi r16, ':'
	st Y+, r16
	ldi r16, '0'
	st Y+, r16
	ldi r16, '0'
	st Y+, r16
	ldi r16, '.'
	st Y+, r16
	ldi r16, '0'
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ld r16, X+
	CALL GET_DIGIT
	st Y+, r16
	ld r16, X+
	CALL GET_DIGIT
	st Y+, r16
	ldi r16, ':'
	st Y+, r16
	ld r16, X+
	CALL GET_DIGIT
	st Y+, r16
	ld r16, X+
	CALL GET_DIGIT
	st Y+, r16
	ldi r16, '.'
	st Y+, r16
	ld r16, X+
	CALL GET_DIGIT
	st Y+, r16
	LDI R16,0
	ST Y+,R16
	; LCD functions expect their arguments to be pushed onto the stack before calling (in order)
	ldi r16, 1 ; Row number
	push r16
	ldi r16, 0 ; Column number
	push r16
	; Call the function
	call lcd_gotoxy
	; Pop the argument values back off the stack (we don't need them so just discard them)
	pop r16
	pop r16

	; Now call lcd_puts to display the string. lcd_puts takes the base address of the string
	; as its argument on the stack (with the high byte pushed first)
	ldi r16, high(LINE_TWO)
	push r16
	ldi r16, low(LINE_TWO)
	push r16
	call lcd_puts
	pop r16
	pop r16

	ldi XL, low(TIME)
	ldi XH, high(TIME)
	ldi ZL, low(CURRENT_LAP)
	ldi ZH, high(CURRENT_LAP)

	ld r16, X+
	st Z+, r16
	ld r16, X+
	st Z+, r16
	ld r16, X+
	st Z+, r16
	ld r16, X+
	st Z+, r16
	ld r16, X+
	st Z+, r16

	ldi LAPPED, 1

	rjmp donelap

LEFTSIDE:
	ldi YL, low(LINE_TWO)
	ldi YH, high(LINE_TWO)
	ldi ZL, low(CURRENT_LAP)
	ldi ZH, high(CURRENT_LAP)
	ldi XL, low(TIME)
	ldi XH, high(TIME)


	ld r16, Z+
	CALL GET_DIGIT
	st Y+, r16
	ld r16, Z+
	CALL GET_DIGIT
	st Y+, r16
	ldi r16, ':'
	st Y+, r16
	ld r16, Z+
	CALL GET_DIGIT
	st Y+, r16
	ld r16, Z+
	CALL GET_DIGIT
	st Y+, r16
	ldi r16, '.'
	st Y+, r16
	ld r16, Z+
	CALL GET_DIGIT
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ld r16, X+
	CALL GET_DIGIT
	st Y+, r16
	ld r16, X+
	CALL GET_DIGIT
	st Y+, r16
	ldi r16, ':'
	st Y+, r16
	ld r16, X+
	CALL GET_DIGIT
	st Y+, r16
	ld r16, X+
	CALL GET_DIGIT
	st Y+, r16
	ldi r16, '.'
	st Y+, r16
	ld r16, X+
	CALL GET_DIGIT
	st Y+, r16
	LDI R16,0
	ST Y+,R16
	; LCD functions expect their arguments to be pushed onto the stack before calling (in order)
	ldi r16, 1 ; Row number
	push r16
	ldi r16, 0 ; Column number
	push r16
	; Call the function
	call lcd_gotoxy
	; Pop the argument values back off the stack (we don't need them so just discard them)
	pop r16
	pop r16

	; Now call lcd_puts to display the string. lcd_puts takes the base address of the string
	; as its argument on the stack (with the high byte pushed first)
	ldi r16, high(LINE_TWO)
	push r16
	ldi r16, low(LINE_TWO)
	push r16
	call lcd_puts
	pop r16
	pop r16

	ldi XL, low(TIME)
	ldi XH, high(TIME)
	ldi ZL, low(CURRENT_LAP)
	ldi ZH, high(CURRENT_LAP)

	ld r16, X+
	st Z+, r16
	ld r16, X+
	st Z+, r16
	ld r16, X+
	st Z+, r16
	ld r16, X+
	st Z+, r16
	ld r16, X+
	st Z+, r16


donelap:
	pop ZH
	pop ZL
	pop YH
	pop YL
	pop XH
	pop XL
	pop r17
	pop r16
	ret

; INITALIZES MAX TIME ARRAY ;
	
SET_MAX_ARRAY:
		PUSH R16
		LDI ZL,LOW(MAX_TIME)
		LDI ZH, HIGH(MAX_TIME)
		LDI R16, 9
		ST Z+,R16
		ST Z+,R16
		LDI R16,5
		ST Z+,R16
		LDI R16,9
		ST Z+,R16
		ST Z+,R16
		POP R16
		RET

		
;INITALIZES CURRENT TIME TO 00:00.0 ;		
		
SET_TIME_ARRAY:
			PUSH R16
			PUSH YH
			PUSH YL
			LDI YL,LOW(TIME)
			LDI YH,HIGH(TIME)
			LDI R16,0
			ST Y+,R16
			ST Y+,R16
			ST Y+,R16
			ST Y+,R16
			ST Y+,R16
			POP YL
			POP YH
			POP R16
			RET


;INCREMENTS TIME INSIDE ISR;
			
INC_TIME:
	PUSH R16
	push r17
	push YL
	push YH
	push XL
	push XH
	push ZL
	push ZH

	ldi XL, low(TIME+4)
	ldi XH, high(TIME+4)
	ldi YL, low(MAX_TIME+4)
	ldi YH, high(MAX_TIME+4)

ONE:
	ld r16, X
	ld r17, Y
	cp r16, r17
	breq TWO
	INC R16
	st X, r16
	rjmp done
TWO:
	ldi r16, 0
	st X, r16
	sbiw X, 1
	sbiw Y, 1
	ld r16, X
	ld r17, Y
	cp r16, r17
	breq THREE
	INC R16
	st X, r16
	rjmp done
THREE:
	ldi r16, 0
	st X, r16
	sbiw X, 1
	sbiw Y, 1
	ld r16, X
	ld r17, Y
	cp r16, r17
	breq FOUR
	INC R16
	st X, r16
	rjmp done
FOUR:
	ldi r16, 0
	st X, r16
	sbiw X, 1
	sbiw Y, 1
	ld r16, X
	ld r17, Y
	cp r16, r17
	breq FIVE
	INC R16
	st X, r16
	rjmp done
FIVE:
	ldi r16, 0
	st X, r16
	sbiw X, 1
	sbiw Y, 1
	ld r16, X
	INC R16
	st X, r16

done:
	pop ZH
	pop ZL
	pop XH
	pop XL
	pop YH
	pop YL
	pop r17
	pop r16
	ret


;	INITALIZES SECOND ROW  ;

SET_LINE_TWO:
	push r16
	push XL
	push XH
	push YL
	push YH
	push ZL
	push ZH

	; Load the address of LINE_ONE into Y
	ldi YL, low(LINE_TWO)
	ldi YH, high(LINE_TWO)
	; Set the contents of the array to be "Hello World" with a sequence
	; of manual ldi/st instructions
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16

	; Add a null terminator
	ldi r16, 0
	st Y+, r16

	; LCD functions expect their arguments to be pushed onto the stack before calling (in order)
	ldi r16, 1 ; Row number
	push r16
	ldi r16, 0 ; Column number
	push r16
	; Call the function
	call lcd_gotoxy
	; Pop the argument values back off the stack (we don't need them so just discard them)
	pop r16
	pop r16

	; Now call lcd_puts to display the string. lcd_puts takes the base address of the string
	; as its argument on the stack (with the high byte pushed first)
	ldi r16, high(LINE_TWO)
	push r16
	ldi r16, low(LINE_TWO)
	push r16
	call lcd_puts
	pop r16
	pop r16

	pop ZH
	pop ZL
	pop YH
	pop YL
	pop XH
	pop XL
	pop r16

	ret
	
DISPLAY_LCD:
	push r16
	push r17
	push YL
	push YH
	ldi ZL, low(TIME)
	ldi ZH, high(TIME)
	LDI YL,LOW(LINE_ONE)
	LDI YH,HIGH(LINE_ONE)
	ldi r16, 'T'
	st Y+, r16
	ldi r16, 'I'
	st Y+, r16
	ldi r16, 'M'
	st Y+, r16
	ldi r16, 'E'
	st Y+, r16
	ldi r16, ':'
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ld r16, Z+
	CALL GET_DIGIT
	st Y+, r16
	ld r16, Z+
	CALL GET_DIGIT
	st Y+, r16
	ldi r16, ':'
	st Y+, r16
	ld r16, Z+
	CALL GET_DIGIT
	st Y+, r16
	ld r16, Z+
	CALL GET_DIGIT
	st Y+, r16
	LDI R16, '.'
	ST Y+,R16
	LD R16, Z+
	CALL GET_DIGIT
	ST Y+,R16
	LDI R16,0 
	ST Y+,R16
		; LCD functions expect their arguments to be pushed onto the stack before calling (in order)
	ldi r16, 0 ; Row number
	push r16
	ldi r16, 0 ; Column number
	push r16
	; Call the function
	call lcd_gotoxy
	; Pop the argument values back off the stack (we don't need them so just discard them)
	pop r16
	pop r16

	; Now call lcd_puts to display the string. lcd_puts takes the base address of the string
	; as its argument on the stack (with the high byte pushed first)
	ldi r16, high(LINE_ONE)
	push r16
	ldi r16, low(LINE_ONE)
	push r16
	call lcd_puts
	pop r16
	pop r16

	pop YH
	pop YL
	pop r17
	pop r16
	ret
	
; TAKEN FROM LECTURE NOTES POSTED BY WILLIAM B BIRD ;	
	
GET_DIGIT:
	push r17
	
	; The character '0' has ASCII value 48, and the character codes
	; for the other digits follow '0' consecutively, so we can obtain
	; the character code for an arbitrary single digit by simply
	; adding 48 (or just using the constant '0') to the digit.
	ldi r17, '0' ; Could also write "ldi r17, 48"
	add r16, r17
	
	pop r17
	ret
	
	
	
TIMER0_SETUP:
	push r16
	
	; Control register A
	; We set control register A to 0x02 to enable CTC mode. Note that we can use
	; output compare interrupts without CTC mode, but CTC mode has the benefit
	; of automatically clearing the counter after the TOP value is reached.
	; (See timing diagram in section 16.8, page 124 of the datasheet)
	; The documentation for output compare modes in the datasheet is a bit
	; confusing: note that we enable CTC mode but leave all other bits of 
	; control register A in "normal port operation" (the OC0A and OC0B pins
	; discussed in the documentation are for hardware coupling, not interrupts)
	ldi r16, 0x02
	sts TCCR0A_DS, r16
	
	; Control register B
	; Select prescaler = clock/1024 and all other control bits 0 (see page 126 of the datasheet)
	ldi r16, 0x03
	sts	TCCR0B_DS, r16
	; Once TCCR0B is set, the timer will begin ticking
	
	; Set OCR0A to the output compare value. This will be the last value that the
	; timer's counter actually holds (it will be cleared on the NEXT incrementation)
	; (There is also a register OCR0B for a second simultaneous output compare)
	ldi r16, 124 ; Set the TOP value to 124 (so 125 increments happen before an interrupt)
	sts OCR0A_DS, r16
	; Question: How many output compare interrupts will occur per second?
	
	; Interrupt mask register (to select which interrupts to enable)
	; We set bit 1 of TIMSK0 to enable output compare interrupt A
	ldi r16, 0x02
	sts TIMSK0_DS, r16
	
	; Interrupt flag register
	; Writing a 1 to bit 0 of this register clears any interrupt state that might
	; already exist (thereby resetting the interrupt state).
	ldi r16, 0x01
	sts TIFR0_DS, r16
		
	
	pop r16
	ret
	
; TIMER0_OVERFLOW_ISR()
; This is not a regular function, but an interrupt handler, so there are no
; arguments or return value, and the RET instruction is not used. Instead,
; the "interrupt return" (RETI) instruction is used to end the ISR.
; Although it's not a regular function, we still have to follow normal
; function style for saving registers.
TIMER0_OC_ISR:
	push r16
	lds r16, SREG_DS ; Load the value of SREG into r16
	push r16 ; Push SREG onto the stack
	;push r17
	
	; Increment the value of OVERFLOW_INTERRUPT_COUNTER
	lds r16, OC_INTERRUPT_COUNTER
	inc r16
	sts OC_INTERRUPT_COUNTER, r16
	
	CPI R16,200
	; If the incrementation did not cause an overflow,
	; we're done.
	brNE timer0_isr_done
	
	CLR R16
	; Otherwise, 256 interrupts have occurred since the last
	; time we flipped the state, so load the LED_STATE value
	; and flip it
	CALL INC_TIME
	
	
; ;	CPI R16
; DONE:	
	
timer0_isr_done:
	
	;pop r17
	; The next stack value is the value of SREG
	pop r16 ; Pop SREG into r16
	sts SREG_DS, r16 ; Store r16 into SREG
	; Now pop the original saved r16 value
	pop r16

	reti ; Return from interrupt

	
stop:
	rjmp stop
		
delay:
	; Since we need r16-r19, r20 and r21, push all of those registers onto the stack.
	push r16
	push r17
	push r18
	push r19
	push r20
	push r21
	ldi r16, low(DELAY_ITERATIONS)
	ldi r17, byte2(DELAY_ITERATIONS)
	ldi r18, byte3(DELAY_ITERATIONS)
	ldi r19, byte4(DELAY_ITERATIONS)
delay_loop:
	; Subtract 1 from r16:r19
	ldi r20, 0x01
	ldi r21, 0x00
	sub r16, r20
	sbc r17, r21
	sbc r18, r21
	sbc r19, r21
	; If the last sbc set the Z flag, then r16:r19 = 0, so terminate the loop.
	; Otherwise, continue.
	brne delay_loop
	
	pop r21
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	ret	
	
; Include LCD library code
.include "lcd_function_code.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Data Section                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.dseg
; Note that no .org 0x200 statement should be present
; Put variables and data arrays here...
OC_INTERRUPT_COUNTER: .byte 1 
TIME: .byte 5
MAX_TIME: .BYTE 5
LINE_ONE: .BYTE 100
CURRENT_LAP: .BYTE 5
LAST_LAP: .BYTE 5
LINE_TWO: .BYTE 100