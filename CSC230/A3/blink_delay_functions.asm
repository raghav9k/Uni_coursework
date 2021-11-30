; blink_delay_functions.asm
; CSC 230 - Summer 2018
; 
;
; B. Bird - 06/14/2018

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                        Constants and Definitions                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Stack pointer and SREG registers (in data space)
.equ SPH_DS = 0x5E
.equ SPL_DS = 0x5D
.equ SREG_DS = 0x5F

; Initial address (16-bit) for the stack pointer
.equ STACK_INIT = 0x21FF

; Port and data direction register definitions (taken from AVR Studio; note that m2560def.inc does not give the data space address of PORTB)
.equ DDRB_DS = 0x24
.equ PORTB_DS = 0x25
.equ DDRL_DS = 0x10A
.equ PORTL_DS = 0x10B



.equ DELAY_ITERATIONS = 2000000

.cseg

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Main Program                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.org 0x00
	; Initialize the stack
	ldi r16, high(STACK_INIT)
	sts SPH_DS, r16
	ldi r16, low(STACK_INIT)
	sts SPL_DS, r16
	
	
	; Set up data direction registers
	ldi r16, 0xff
	sts DDRL_DS, r16
	sts DDRB_DS, r16
	
	; Clear all LEDs
	call clear_leds
	
start:

	call set_led52
	
	; Wait for approximately one second
	call delay
	
	call clear_leds
	
	
	call set_led42
	
	; Now wait for another second
	call delay
	
	call clear_leds
	
	; Repeat
	rjmp start
	

	
; clear_leds()
; Set all LEDs on ports B and L to be off
clear_leds:
	push r16 ; This function will use r16 for temporary storage, so push its current value onto the stack
	
	clr r16
	sts PORTB_DS, r16
	sts PORTL_DS, r16
	
	pop r16
	ret

	
; set_led52()
; Light the LED on pin 52
set_led52:
	push r16
	
	; Instead of just setting PORTB, we should load its current value and
	; use bitwise-OR to set bit 1 (to leave all other bits as they were)
	lds r16, PORTB_DS
	ori r16, 0x02
	sts PORTB_DS, r16
	
	pop r16
	ret
	
; set_led42()
; Light the LED on pin 42
set_led42:
	push r16
	
	lds r16, PORTL_DS
	ori r16, 0x80
	sts PORTL_DS, r16
	
	pop r16
	ret
	
	
; delay()
; Waste time for approximately 1 second
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
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Data Section                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.dseg
.org 0x200
; Put variables and data arrays here...