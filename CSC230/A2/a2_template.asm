; a2_template.asm
; CSC 230 - Summer 2017
;
;NAME: RAJATH INUGANTI
;VNO : V00874612
;
; Some starter code for Assignment 2. You do not have
; to use this code if you'd rather start from scratch.
;
; B. Bird - 06/01/2017

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                        Constants and Definitions                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Special register definitions
;.def XL = r26
;.def XH = r27
;.def YL = r28
;.def YH = r29
;.def ZL = r30
;.def ZH = r31


; Stack pointer and SREG registers (in data space)
.equ SPH_DS = 0x5E
.equ SPL_DS = 0x5D
.equ SREG_DS = 0x5F


; Initial address (16-bit) for the stack pointer
.equ STACK_INIT = 0x21FF

; Port and data direction register definitions (taken from AVR Studio; note that m2560def.inc does not give the data space address of PORTB_DS)
.equ DDRB_DS = 0x24
.equ PORTB_DS = 0x25
.equ DDRL_DS = 0x10A
.equ PORTL_DS = 0x10B

; Definitions for the analog/digital converter (ADC) (taken from m2560def.inc)
; See the datasheet for details
.equ ADCSRA_DS = 0x7A ; Control and Status Register
.equ ADMUX_DS = 0x7C ; Multiplexer Register
.equ ADCL_DS = 0x78 ; Output register (high bits)
.equ ADCH_DS = 0x79 ; Output register (low bits)

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

; Definitions of the special register addresses for timer 1 (in data space)
.equ TCCR1A_DS = 0x80
.equ TCCR1B_DS = 0x81
.equ TCCR1C_DS = 0x82
.equ TCNT1H_DS = 0x85
.equ TCNT1L_DS = 0x84
.equ TIFR1_DS  = 0x36
.equ TIMSK1_dS = 0x6F

; Definitions of the special register addresses for timer 2 (in data space)
.equ ASSR_DS = 0xB6
.equ OCR2A_DS = 0xB3
.equ OCR2B_DS = 0xB4
.equ TCCR2A_DS = 0xB0
.equ TCCR2B_DS = 0xB1
.equ TCNT2_DS  = 0xB2
.equ TIFR2_DS  = 0x37
.equ TIMSK2_DS = 0x70


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
; "unreserved" location is 0x0074
.org 0x0074
main_begin:

	; Initialize the stack
	ldi r16, high(STACK_INIT)
	sts SPH, r16
	ldi r16, low(STACK_INIT)
	sts SPL, r16

	; Set up the data direction register for PORTB_DS for output
	ldi	r16, 0xff
	sts	DDRB, r16
	sts DDRL, r16


	; Set PORTB_DS = 0x08 (to light the LED at pin 50 but not the LED at pin 52)
	ldi	r16, 0x08
	sts PORTB_DS, r16

	; Set up the ADC

	; Set up ADCSRA (ADEN = 1, ADPS2:ADPS0 = 111 for divisor of 128)
	ldi	r16, 0x87
	sts	ADCSRA, r16

	; Set up ADMUX (MUX4:MUX0 = 00000, ADLAR = 0, REFS1:REFS0 = 1)
	ldi	r16, 0x40
	sts	ADMUX, r16
	
	sei
	call TIMER0_SETUP ; Set up timer 0 control registers (function below)

.def current = r24
.def direction = r18
.def speed = r19
.def invert = r23
.def paused = r22

	ldi invert, 0
	ldi current, 0
	ldi speed, 0
	ldi direction, 1
	ldi paused, 0

button_check:
	cpi invert,	0
	breq normalmode
	call inverted
	rjmp convert
normalmode:
	call normal
	
convert:
	; Start an ADC conversion
	; Set the ADSC bit to 1 in the ADCSRA register to start a conversion
	lds	r16, ADCSRA
	ori	r16, 0x40
	sts	ADCSRA, r16
	; Wait for the conversion to finish
wait_for_adc:
	lds		r16, ADCSRA
	andi	r16, 0x40
	brne	wait_for_adc

	; Load the ADC result into the X pair (XH:XL). Note that XH and XL are defined above.
	lds	XL, ADCL
	lds	XH, ADCH

	; Compare XH:XL with the threshold in r21:r20
	ldi r20, low(ADC_BTN_RIGHT)
	ldi r21, high(ADC_BTN_RIGHT)
	cp	r20, XL ; Low byte
	cpc	r21, XH ; High byte
	brsh norm

	ldi r20, low(ADC_BTN_UP)
	ldi r21, high(ADC_BTN_UP)
	cp	r20, XL ; Low byte
	cpc	r21, XH ; High byte
	brsh fast

	ldi r20, low(ADC_BTN_DOWN)
	ldi r21, high(ADC_BTN_DOWN)
	cp	r20, XL ; Low byte
	cpc	r21, XH ; High byte
	brsh slow

	ldi r20, low(ADC_BTN_LEFT)
	ldi r21, high(ADC_BTN_LEFT)
	cp	r20, XL ; Low byte
	cpc	r21, XH ; High byte
	brsh inv

	ldi r20, low(ADC_BTN_SELECT)
	ldi r21, high(ADC_BTN_SELECT)
	cp	r20, XL ; Low byte
	cpc	r21, XH ; High byte
	brsh special
	
	rjmp donebutton
	
norm:
	ldi invert, 0
	rjmp donebutton

fast:
	ldi speed, 1
	rjmp donebutton

slow:
	ldi speed, 0
	rjmp donebutton

inv:
	ldi invert, 1
	rjmp donebutton

special:
	cpi paused, 0
	breq pauseit
	brne unpauseit
pauseit:
	ldi paused, 1
	rjmp donebutton
unpauseit:
	ldi paused, 0
	rjmp donebutton

donebutton:
 	rjmp button_check ; If the ADC value was above the threshold, no button was pressed (so try again)

	
;------------------------------------------------------------------------------
; TIMER0_SETUP
;------------------------------------------------------------------------------
			;used this from the lectures
TIMER0_SETUP:
	push r16
	
	; Control register A
	; We set all bits to 0, which enables "normal port operation" and no output-compare
	; mode for all of the bit fields in TCCR0A and also disables "waveform generation mode"
	ldi r16, 0x00
	sts TCCR0A, r16
	
	; Control register B
	; Select prescaler = clock/1024 and all other control bits 0 (see page 126 of the datasheet)
	ldi r16, 0x05 
	sts	TCCR0B, r16
	; Once TCCR0B is set, the timer will begin ticking
	
	; Interrupt mask register (to select which interrupts to enable)
	ldi r16, 0x01 ; Set bit 0 of TIMSK0 to enable overflow interrupt (all other bits 0)
	sts TIMSK0, r16
	
	; Interrupt flag register
	; Writing a 1 to bit 0 of this register clears any interrupt state that might
	; already exist (thereby resetting the interrupt state).
	ldi r16, 0x01
	sts TIFR0, r16
		
	
	pop r16
	ret
	
;------------------------------------------------------------------------------
; NORMAL MODE
;------------------------------------------------------------------------------

normal:
	push r16
	push r20 
	push r21
	
	cpi current, 0
	breq B1
	cpi current, 1
	breq B3
	cpi current, 2
	breq L1
	cpi current, 3
	breq L3
	cpi current, 4
	breq L5
	cpi current, 5
	breq L7
	rjmp done
	
B1:
	call clear_leds
	lds r16, PORTB_DS
	ori r16, 0b00000010
	sts PORTB_DS, r16
	rjmp done
B3: 
	call clear_leds
	lds r16, PORTB_DS
	ori r16, 0b00001000
	sts PORTB_DS, r16
	rjmp done
L1:
	call clear_leds
	lds r16, PORTL_DS
	ori r16, 0b00000010
	sts PORTL_DS, r16
	rjmp done
L3:
	call clear_leds
	lds r16, PORTL_DS
	ori r16, 0b00001000
	sts PORTL_DS, r16
	rjmp done
L5:
	call clear_leds
	lds r16, PORTL_DS
	ori r16, 0b00100000
	sts PORTL_DS, r16
	rjmp done
L7:
	call clear_leds
	lds r16, PORTL_DS
	ori r16, 0b10000000
	sts PORTL_DS, r16
	rjmp done
	
done:
	pop r21
	pop r20
	pop r16
	
	ret

;------------------------------------------------------------------------------
; CLEARING LEDS
;------------------------------------------------------------------------------	
			; used this function from labs
clear_leds:
	; This function uses r16, so we will save it onto the stack
	; to preserve whatever value it already has.
	push r16
	
	
	; Set PORTL_DS and PORTB_DS to 0x00
	ldi r16, 0x00
	sts PORTL_DS, r16
	sts PORTB_DS, r16
	
	; Load the saved value of r16
	pop r16
	
	; Return 
	ret
	
;------------------------------------------------------------------------------
; INVERTED MODE
;------------------------------------------------------------------------------

inverted:
	push r16
	push r20
	push r21
	
	cpi current, 0
	breq B12
	cpi current, 1
	breq B32
	cpi current, 2
	breq L12
	cpi current, 3
	breq L32
	cpi current, 4
	breq L52
	cpi current, 5
	breq L72
	rjmp done2
	
B12:
	call clear_leds
	ldi r16, 0b00001000
	sts PORTB_DS, r16
	ldi r16, 0b10101010
	sts PORTL_DS, r16
	rjmp done2
B32:
	call clear_leds
	ldi r16, 0b00000010
	sts PORTB_DS, r16
	ldi r16, 0b10101010
	sts PORTL_DS, r16
	rjmp done2
L12:
	call clear_leds
	ldi r16, 0b00001010
	sts PORTB_DS, r16
	ldi r16, 0b10101000
	sts PORTL_DS, r16
	rjmp done2
L32:
	call clear_leds
	ldi r16, 0b00001010
	sts PORTB_DS, r16
	ldi r16, 0b10100010
	sts PORTL_DS, r16
	rjmp done2
L52:
	call clear_leds
	ldi r16, 0b00001010
	sts PORTB_DS, r16
	ldi r16, 0b10001010
	sts PORTL_DS, r16
	rjmp done2
L72:
	call clear_leds
	ldi r16, 0b00001010
	sts PORTB_DS, r16
	ldi r16, 0b00101010
	sts PORTL_DS, r16
	rjmp done2
	
done2:
	pop r21
	pop r20
	pop r16
	
	ret

;------------------------------------------------------------------------------
; TIMER0_OVERFLOW_ISR()
;------------------------------------------------------------------------------

TIMER0_OVERFLOW_ISR:
	
	push r16
	; Since we pushed r16, we can now use it.
	; We need to push the contents of SREG (since we don't know whether the code
	; that was running before this ISR was using SREG for something). SREG isn't
	; a normal register, so to access its contents we have to go to data memory.
	; (Note that the address in data memory can be found via AVR Studio or the
	;  definition file. It is set via .equ at the top of this file)
	lds r16, SREG ; Load the value of SREG into r16
	push r16 ; Push SREG onto the stack
	push r17
	push r20
	push r21
	
	; Increment the value of OVERFLOW_INTERRUPT_COUNTER
	lds r16, OVERFLOW_INTERRUPT_COUNTER
	
	; testing the speed
	cpi speed, 1
	breq speedup
	inc r16
	rjmp done_testing_speed
	
speedup:
	subi r16, -4
done_testing_speed:
	sts OVERFLOW_INTERRUPT_COUNTER, r16
	
	cpi r16, 61
	brlo timer0_isr_done
	
	subi r16, 61
	sts OVERFLOW_INTERRUPT_COUNTER, r16
	
	;testing whether to pause
	;this check will decide whether the select button is pressed and to pause by throwing the control flow
	;to the end of the interrupt service routine.
	cpi paused, 1
	breq timer0_isr_done
	
	; testing for direction
	cpi current, 0
	breq front
	cpi current, 5
	breq back
	rjmp set_current
front:
	ldi direction, 1
	rjmp set_current
back:
	ldi direction, -1
	rjmp set_current
	
set_current:
	add current, direction
	
timer0_isr_done:

	pop r21
	pop r20
	pop r17
	; The next stack value is the value of SREG
	pop r16 ; Pop SREG into r16
	sts SREG, r16 ; Store r16 into SREG
	; Now pop the original saved r16 value
	pop r16
	; Return from interrupt
	reti


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Data Section                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.dseg
.org 0x200

OVERFLOW_INTERRUPT_COUNTER: .byte 1 ; Counter for the number of times the overflow interrupt has been triggered.
; Put variables and data arrays here...