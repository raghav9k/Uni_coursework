
; a3_template.asm
; CSC 230 - Summer 2017
;
; A3 Starter code
;
; B. Bird - 06/29/2017

;NAME: RAJATH INUGANTI
;Vno#: V00874612
; No data address definitions are needed since we use the "m2560def.inc" file

.include "m2560def.inc"


.include "lcd_function_defs.inc"

; Special register definitions


; Stack pointer and SREG registers (in data space)
.equ SPH_DATASPACE = 0x5E
.equ SPL_DATASPACE = 0x5D
.equ SREG_ = 0x5F


; Initial address (16-bit) for the stack pointer
.equ STACK_INIT = 0x21FF

; Definitions for the analog/digital converter (ADC) (taken from m2560def.inc)
; See the datasheet for details
.equ ADCSRA_ = 0x7A ; Control and Status Register
.equ ADMUX_ = 0x7C ; Multiplexer Register
.equ ADCL_ = 0x78 ; Output register (high bits)
.equ ADCH_ = 0x79 ; Output register (low bits)

; Port and data direction register definitions (taken from AVR Studio; note that m2560def.inc does not give the data space address of PORTB)
.equ DDRB_ = 0x24
.equ PORTB_ = 0x25


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
.equ GTCCR_ = 0x43
.equ OCR0A_ = 0x47
.equ OCR0B_ = 0x48
.equ TCCR0A_ = 0x44
.equ TCCR0B_ = 0x45
.equ TCNT0_  = 0x46
.equ TIFR0_  = 0x35
.equ TIMSK0_ = 0x6E


.cseg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                          Reset/Interrupt Vectors                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.org 0x0000 ; RESET vector
	jmp main_begin

; Add interrupt handlers for timer interrupts here. See Section 14 (page 101) of the datasheet for addresses.
; According to the datasheet, the interrupt vector for timer 0 overflow is located
; at 0x002e
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
	; Notice that we use "SPH_DATASPACE" instead of just "SPH" for our .def
	; since m2560def.inc defines a different value for SPH which is not compatible
	; with STS.
	ldi r16, high(STACK_INIT)
	sts SPH_DATASPACE, r16
	ldi r16, low(STACK_INIT)
	sts SPL_DATASPACE, r16

	; Initialize the LCD
	call lcd_init

	; Set up ADCSRA (ADEN = 1, ADPS2:ADPS0 = 111 for divisor of 128)
	ldi	r16, 0x87
	sts	ADCSRA_, r16

	; Set up ADMUX (MUX4:MUX0 = 00000, ADLAR = 0, REFS1:REFS0 = 1)
	ldi	r16, 0x40
	sts	ADMUX_, r16

	call INITIAL_SHOW

	call INITIALIZE_MAXIMUM_VALUES

	call INITIALIZE_REAL_TIME

	call INITIALIZE_LINE_TWO

	.def pause = r25
	.def first_time = r24
	.def lap_count = r23
	ldi first_time, 0
	ldi pause, 0
	ldi lap_count, 0
	.def ignore = r22
	ldi ignore, 0

	button_check:
		; Start an ADC conversion
		; Set the ADSC bit to 1 in the ADCSRA register to start a conversion
		lds	r16, ADCSRA_
		ori	r16, 0x40
		sts	ADCSRA_, r16
		; Wait for the conversion to finish
	wait_for_adc:
		lds		r16, ADCSRA_
		andi	r16, 0x40
		brne	wait_for_adc

		; Load the ADC result into the X pair (XH:XL). Note that XH and XL are defined above.
		lds	XL, ADCL_
		lds	XH, ADCH_

		ldi r20, low(ADC_BTN_UP)
		ldi r21, high(ADC_BTN_UP)
		cp	r20, XL ; Low byte
		cpc	r21, XH ; High byte
		brsh UP

		ldi r20, low(ADC_BTN_DOWN)
		ldi r21, high(ADC_BTN_DOWN)
		cp	r20, XL ; Low byte
		cpc	r21, XH ; High byte
		brsh DOWN

		ldi r20, low(ADC_BTN_LEFT)
		ldi r21, high(ADC_BTN_LEFT)
		cp	r20, XL ; Low byte
		cpc	r21, XH ; High byte
		brsh LEFT

		ldi r20, low(ADC_BTN_SELECT)
		ldi r21, high(ADC_BTN_SELECT)
		cp	r20, XL ; Low byte
		cpc	r21, XH ; High byte
		brsh SELECT

		ldi ignore, 0
		rjmp donebutton

	UP:
		cpi ignore, 1
		breq donebutton

		call SET_LAP
		rjmp pressed

	DOWN:
	cpi ignore, 1
	breq donebutton

		call INITIALIZE_LINE_TWO
		ldi lap_count, 0
		rjmp pressed

	LEFT:
	cpi ignore, 1
	breq donebutton

		call CLEAR_TIMER
		ldi pause, 1
		ldi lap_count, 0
		ldi XL, low(REAL_TIME)
		ldi XH, high(REAL_TIME)
		ldi ZL, low(CURRENT_TIME)
		ldi ZH, high(CURRENT_TIME)

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
		rjmp pressed

	SELECT:
	cpi ignore, 1
	breq donebutton

		cpi first_time, 0
		breq timer
		brne donecheck
	timer:
		call TIMER0_SETUP
		sei
		ldi first_time, 1
	donecheck:
		cpi pause, 0
		breq pauseit
		brne unpauseit
	pauseit:
		ldi pause, 1
		rjmp pressed
	unpauseit:
		ldi pause, 0
		rjmp pressed

pressed:
		ldi ignore, 1

	donebutton:
	 	rjmp button_check ; If the ADC value was above the threshold, no button was pressed (so try again)


stop:
	rjmp stop



;------------------------------------------------------------------------------
;INITIALIZE_MAXIMUM_VALUES
;------------------------------------------------------------------------------
INITIALIZE_MAXIMUM_VALUES:
	push r16
	push XL
	push XH

	ldi XL, low(MAXIMUM_VALUES)
	ldi XH, high(MAXIMUM_VALUES)

	ldi r16, '9'
	st X+, r16
	ldi r16, '9'
	st X+, r16
	ldi r16, '5'
	st X+, r16
	ldi r16, '9'
	st X+, r16
	ldi r16, '9'
	st X+, r16

	pop XH
	pop XL
	pop r16
	ret

;------------------------------------------------------------------------------
; INITIALIZE_REAL_TIME
;------------------------------------------------------------------------------
INITIALIZE_REAL_TIME:
	push r16
	push ZL
	push ZH

	ldi ZL, low(REAL_TIME)
	ldi ZH, high(REAL_TIME)

	ldi r16, '0'
	st Z+, r16
	ldi r16, '0'
	st Z+, r16
	ldi r16, '0'
	st Z+, r16
	ldi r16, '0'
	st Z+, r16
	ldi r16, '0'
	st Z+, r16

	pop ZH
	pop ZL
	pop r16
	ret

;------------------------------------------------------------------------------
; TIMER0 SETUP
;------------------------------------------------------------------------------
			;used this from the lectures
TIMER0_SETUP:
	push r16

	; Control register A
	; We set all bits to 0, which enables "normal port operation" and no output-compare
	; mode for all of the bit fields in TCCR0A and also disables "waveform generation mode"
	ldi r16, 0x00
	sts TCCR0A_, r16

	; Control register B
	; Select prescaler = clock/1024 and all other control bits 0 (see page 126 of the datasheet)
	ldi r16, 0x05
	sts	TCCR0B_, r16
	; Once TCCR0B is set, the timer will begin ticking

	; Interrupt mask register (to select which interrupts to enable)
	ldi r16, 0x01 ; Set bit 0 of TIMSK0 to enable overflow interrupt (all other bits 0)
	sts TIMSK0_, r16

	; Interrupt flag register
	; Writing a 1 to bit 0 of this register clears any interrupt state that might
	; already exist (thereby resetting the interrupt state).
	ldi r16, 0x01
	sts TIFR0_, r16


	pop r16
	ret


;------------------------------------------------------------------------------
; INITIAL_SHOW
;------------------------------------------------------------------------------
INITIAL_SHOW:
	push r16
	push XL
	push XH
	push YL
	push YH
	push ZL
	push ZH

	; Load the address of LINE_ONE into Y
	ldi YL, low(LINE_ONE)
	ldi YH, high(LINE_ONE)
	; Set the contents of the array to be "Hello World" with a sequence
	; of manual ldi/st instructions
	ldi r16, 'T'
	st Y+, r16
	ldi r16, 'i'
	st Y+, r16
	ldi r16, 'm'
	st Y+, r16
	ldi r16, 'e'
	st Y+, r16
	ldi r16, ':'
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
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
	ldi r16, ' '
	st Y+, r16

	; Add a null terminator
	ldi r16, 0
	st Y+, r16

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

	pop ZH
	pop ZL
	pop YH
	pop YL
	pop XH
	pop XL
	pop r16

	ret

;------------------------------------------------------------------------------
; INITIALIAZE_LINE_TWO
;------------------------------------------------------------------------------
INITIALIZE_LINE_TWO:
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

;------------------------------------------------------------------------------
; CLEAR_TIMER
;------------------------------------------------------------------------------
CLEAR_TIMER:
	push r16
	push XL
	push XH
	push YL
	push YH
	push ZL
	push ZH

	ldi ZL, low(REAL_TIME)
	ldi ZH, high(REAL_TIME)
	ldi XL, low(REAL_TIME)
	ldi XH, high(REAL_TIME)
	ldi YL, low(LINE_ONE+6)
	ldi YH, high(LINE_ONE+6)

	ldi r16, '0'
	st Z+, r16
	ldi r16, '0'
	st Z+, r16
	ldi r16, '0'
	st Z+, r16
	ldi r16, '0'
	st Z+, r16
	ldi r16, '0'
	st Z+, r16

	ld r16, X
	st Y, r16
	adiw XH:XL, 1
	adiw YH:YL, 1
	ld r16, X
	st Y, r16
	adiw XH:XL, 1
	adiw YH:YL, 2
	ld r16, X
	st Y, r16
	adiw XH:XL, 1
	adiw YH:YL, 1
	ld r16, X
	st Y, r16
	adiw XH:XL, 1
	adiw YH:YL, 2
	ld r16, X
	st Y, r16



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

	pop ZH
	pop ZL
	pop YH
	pop YL
	pop XH
	pop XL
	pop r16
	ret

;------------------------------------------------------------------------------
; TINKER_LCD
;------------------------------------------------------------------------------
TINKER_LCD:
	push r16
	push r17
	push YL
	push YH
	push XL
	push XH
	push ZL
	push ZH

	ldi XL, low(REAL_TIME+4)
	ldi XH, high(REAL_TIME+4)
	ldi YL, low(MAXIMUM_VALUES+4)
	ldi YH, high(MAXIMUM_VALUES+4)

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

;------------------------------------------------------------------------------
; UPDATE_LCD
;------------------------------------------------------------------------------
UPDATE_LCD:
	push r16
	push r17
	push XL
	push XH
	push YL
	push YH

	ldi XL, low(REAL_TIME)
	ldi XH, high(REAL_TIME)
	ldi YL, low(LINE_ONE+6)
	ldi YH, high(LINE_ONE+6)

	ld r16, X
	st Y, r16
	adiw XH:XL, 1
	adiw YH:YL, 1
	ld r16, X
	st Y, r16
	adiw XH:XL, 1
	adiw YH:YL, 2
	ld r16, X
	st Y, r16
	adiw XH:XL, 1
	adiw YH:YL, 1
	ld r16, X
	st Y, r16
	adiw XH:XL, 1
	adiw YH:YL, 2
	ld r16, X
	st Y, r16

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
	pop XH
	pop XL
	pop r17
	pop r16
	ret

;------------------------------------------------------------------------------
; SET_LAP
;------------------------------------------------------------------------------
SET_LAP:
	push r16
	push r17
	push XL
	push XH
	push YL
	push YH
	push ZL
	push ZH

	ldi XL, low(REAL_TIME)
	ldi XH, high(REAL_TIME)
	ldi YL, low(LINE_TWO)
	ldi YH, high(LINE_TWO)

	cpi lap_count, 0
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
	st Y+, r16
	ld r16, X+
	st Y+, r16
	ldi r16, ':'
	st Y+, r16
	ld r16, X+
	st Y+, r16
	ld r16, X+
	st Y+, r16
	ldi r16, '.'
	st Y+, r16
	ld r16, X+
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

	ldi XL, low(REAL_TIME)
	ldi XH, high(REAL_TIME)
	ldi ZL, low(CURRENT_TIME)
	ldi ZH, high(CURRENT_TIME)

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

	ldi lap_count, 1

	rjmp donelap

LEFTSIDE:
	ldi YL, low(LINE_TWO)
	ldi YH, high(LINE_TWO)
	ldi ZL, low(CURRENT_TIME)
	ldi ZH, high(CURRENT_TIME)
	ldi XL, low(REAL_TIME)
	ldi XH, high(REAL_TIME)


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
	ldi r16, '.'
	st Y+, r16
	ld r16, Z+
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ld r16, X+
	st Y+, r16
	ld r16, X+
	st Y+, r16
	ldi r16, ':'
	st Y+, r16
	ld r16, X+
	st Y+, r16
	ld r16, X+
	st Y+, r16
	ldi r16, '.'
	st Y+, r16
	ld r16, X+
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

	ldi XL, low(REAL_TIME)
	ldi XH, high(REAL_TIME)
	ldi ZL, low(CURRENT_TIME)
	ldi ZH, high(CURRENT_TIME)

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

;------------------------------------------------------------------------------
; TIMER0_OVERFLOW_ISR
;------------------------------------------------------------------------------
TIMER0_OVERFLOW_ISR:

	push r16
	lds r16, SREG_ ; Load the value of SREG into r16
	push r16 ; Push SREG onto the stack
	push r20
	push r21

	; Increment the value of OVERFLOW_INTERRUPT_COUNTER
	lds r16, OVERFLOW_INTERRUPT_COUNTER

	;sub-second speed
	subi r16, -10
	rjmp done_testing_speed

	done_testing_speed:
	sts OVERFLOW_INTERRUPT_COUNTER, r16

	cpi r16, 60
	brlo timer0_isr_done

	subi r16, 60
	sts OVERFLOW_INTERRUPT_COUNTER, r16

	cpi pause, 1
	breq timer0_isr_done

	call TINKER_LCD

	call UPDATE_LCD

timer0_isr_done:

	pop r21
	pop r20
	pop r16 ; Pop SREG into r16
	sts SREG_, r16 ; Store r16 into SREG
	; Now pop the original saved r16 value
	pop r16
	; Return from interrupt
	reti

; Include LCD library code
.include "lcd_function_code.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Data Section                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.dseg

OVERFLOW_INTERRUPT_COUNTER: .byte 1 ; Counter for the number of times the overflow interrupt has been triggered.

;first column line of the lcd
LINE_ONE: .byte 20
LINE_TWO: .byte 20
REAL_TIME: .byte 5
MAXIMUM_VALUES: .byte 5
CURRENT_TIME: .byte 5
