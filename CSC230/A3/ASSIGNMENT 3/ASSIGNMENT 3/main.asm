; a3_template.asm
; CSC 230 - Summer 2018
; 
; Starter code for A3.
;
; B. Bird - 07/01/2018

;.include "lcd_function_defs.inc"

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
;.equ ADC_BTN_RIGHT = 0x032
;.equ ADC_BTN_UP = 0x0FA
;.equ ADC_BTN_DOWN = 0x1C2
;.equ ADC_BTN_LEFT = 0x28A
;.equ ADC_BTN_SELECT = 0x352
; Option B (v 1.0)
.equ ADC_BTN_RIGHT = 0x032
.equ ADC_BTN_UP = 0x0C3
.equ ADC_BTN_DOWN = 0x17C
.equ ADC_BTN_LEFT = 0x22B
.equ ADC_BTN_SELECT = 0x316


; Definitions of the special register addresses for timer 0 (in data space)
.equ GTCCR_DS = 0x43
.equ OCR0A_DS = 0x47
.equ OCR0B_DS = 0x48
.equ TCCR0A_DS = 0x44
.equ TCCR0B_DS = 0x45
.equ TCNT0_DS  = 0x46
.equ TIFR0_DS  = 0x35
.equ TIMSK0_DS = 0x6E


.cseg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                          Reset/Interrupt Vectors                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.org 0x0000 ; RESET vector
	jmp main_begin
	
; Add interrupt handlers for timer interrupts here. See Section 14 (page 101) of the datasheet for addresses.
.org 0x002e
	jmp TIMER0_OVERFLOW_ISR 
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Main Program                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; According to the datasheet, the last interrupt vector has address 0x0070, so the first
; "unreserved" location is 0x0072
.org 0x0072
main_begin:

	; Initialize the stack
	ldi r16, high(STACK_INIT)
	sts SPH_DS, r16
	ldi r16, low(STACK_INIT)
	sts SPL_DS, r16
	
	; Initialize the LCD
;	call lcd_init
	call TIMER0_SETUP ; Set up timer 0 control registers (function below)
	
	ldi r16, 0
	sts OVERFLOW_INTERRUPT_COUNTER, r16

	
	sei ; Set the I flag in SREG to enable interrupt processing
	call SET_MAX_ARRAY
	CALL SET_TIME_ARRAY
	CALL INC_TIME
	CALL DISPLAY_LCD
	

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

SET_TIME_ARRAY:
			PUSH R16
			PUSH YH
			PUSH YL
			LDI YL,LOW(TIME)
			LDI YH,HIGH(TIME)
			LDI R16,1
			ST Y+,R16
			ST Y+,R16
			ST Y+,R16
			ST Y+,R16
			ST Y+,R16
			POP YL
			POP YH
			POP R16
			RET
		
INC_TIME:
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
	subi r16, -1
	st X, r16
	rjmp done
TWO:
	ldi r16, '0'
	st X, r16
	sbiw XH:XL, 1
	sbiw YH:YL, 1
	ld r16, X
	ld r17, Y
	cp r16, r17
	breq THREE
	subi r16, -1
	st X, r16
	rjmp done
THREE:
	ldi r16, '0'
	st X, r16
	sbiw XH:XL, 1
	sbiw YH:YL, 1
	ld r16, X
	ld r17, Y
	cp r16, r17
	breq FOUR
	subi r16, -1
	st X, r16
	rjmp done
FOUR:
	ldi r16, '0'
	st X, r16
	sbiw XH:XL, 1
	sbiw YH:YL, 1
	ld r16, X
	ld r17, Y
	cp r16, r17
	breq FIVE
	subi r16, -1
	st X, r16
	rjmp done
FIVE:
	ldi r16, '0'
	st X, r16
	sbiw XH:XL, 1
	sbiw YH:YL, 1
	ld r16, X
	subi r16, -1
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
DISPLAY_LCD:
	push r16
	push r17
	push XL
	push XH
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
	st Y+, r16
	ld r16, Z+
	st Y+, r16
	ldi r16, ':'
	st Y+, r16
	ld r16, Z+
	st Y+, r16
	ld r16, Z+
	st Y+, r16
	LDI R16, '.'
	ST Y+,R16
	LD R16, Z+
	ST Y+,R16
	LDI R16, '0'
	ST Y+,R16
		; LCD functions expect their arguments to be pushed onto the stack before calling (in order)
	ldi r16, 0 ; Row number
	push r16
	ldi r16, 0 ; Column number
	push r16
	; Call the function
;	call lcd_gotoxy
	; Pop the argument values back off the stack (we don't need them so just discard them)
	pop r16
	pop r16

	; Now call lcd_puts to display the string. lcd_puts takes the base address of the string
	; as its argument on the stack (with the high byte pushed first)
	ldi r16, high(LINE_ONE)
	push r16
	ldi r16, low(LINE_ONE)
	push r16
;	call lcd_puts
	pop r16
	pop r16

	pop YH
	pop YL
	pop XH
	pop XL
	pop r17
	pop r16
	ret
	
	
	
	
	
TIMER0_SETUP:
	push r16
	
	; Control register A
	; We set all bits to 0, which enables "normal port operation" and no output-compare
	; mode for all of the bit fields in TCCR0A and also disables "waveform generation mode"
	ldi r16, 0x00
	sts TCCR0A_DS, r16
	
	; Control register B
	; Select prescaler = clock/1024 and all other control bits 0 (see page 126 of the datasheet)
	; Question: How is a prescalar value of clock/256 set? How would the ISR need to change
	; in such a case?
	ldi r16, 0x05 
	sts	TCCR0B_DS, r16
	; Once TCCR0B is set, the timer will begin ticking
	
	; Interrupt mask register (to select which interrupts to enable)
	ldi r16, 0x01 ; Set bit 0 of TIMSK0 to enable overflow interrupt (all other bits 0)
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
TIMER0_OVERFLOW_ISR:
	
	push r16
	; Since we pushed r16, we can now use it.
	; We need to push the contents of SREG (since we don't know whether the code
	; that was running before this ISR was using SREG for something). SREG isn't
	; a normal register, so to access its contents we have to go to data memory.
	; (Note that the address in data memory can be found via AVR Studio or the
	;  definition file. It is set via .equ at the top of this file)
	lds r16, SREG_DS ; Load the value of SREG into r16
	push r16 ; Push SREG onto the stack
	push r17
	
	; Increment the value of OVERFLOW_INTERRUPT_COUNTER
	lds r16, OVERFLOW_INTERRUPT_COUNTER
	inc r16
	sts OVERFLOW_INTERRUPT_COUNTER, r16
	; Compare the value of the overflow counter to 61
	cpi r16, 61
	; If the value is less than 61, we're done
	brlo timer0_isr_done
	
	; If the counter equals 61, clear its value back to 0
	clr r16
	sts OVERFLOW_INTERRUPT_COUNTER, r16
	
	; Otherwise, 61 interrupts have occurred since the last
	; time we flipped the state, so load the LED_STATE value
	; and flip it
	
	
	; We can flip 0 to 1 and 1 to 0 by using XOR
	
timer0_isr_done:
	
	pop r17
	; The next stack value is the value of SREG
	pop r16 ; Pop SREG into r16
	sts SREG_DS, r16 ; Store r16 into SREG
	; Now pop the original saved r16 value
	pop r16

	reti ; Return from interrupt	

	
stop:
	rjmp stop
		
	
	
; Include LCD library code
;.include "lcd_function_code.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Data Section                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.dseg
; Note that no .org 0x200 statement should be present
; Put variables and data arrays here...
OVERFLOW_INTERRUPT_COUNTER: .byte 1 
TIME: .byte 5
MAX_TIME: .BYTE 5
LINE_ONE: .BYTE 100
