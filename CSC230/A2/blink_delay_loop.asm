; blink_delay_loop.asm
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

	; Set up data direction registers
	ldi r16, 0xff
	sts DDRL_DS, r16
	sts DDRB_DS, r16
	
	; Clear all LEDs
	clr r16
	sts PORTL_DS, r16
	sts PORTB_DS, r16
	
start:

	; Set the LED on pin 52 (PORT B bit 1) to on
	ldi r16, 0x02
	sts PORTB_DS, r16
	
	; Wait for approximately one second
	; (The byte2, byte3, byte4 macros give the second, third and fourth bytes of a 32-bit value in little-endian encoding)
	ldi r16, low(DELAY_ITERATIONS)
	ldi r17, byte2(DELAY_ITERATIONS)
	ldi r18, byte3(DELAY_ITERATIONS)
	ldi r19, byte4(DELAY_ITERATIONS)
delay1:
	; Subtract 1 from r16:r19
	ldi r20, 0x01
	ldi r21, 0x00
	sub r16, r20
	sbc r17, r21
	sbc r18, r21
	sbc r19, r21
	; If the last sbc set the Z flag, then r16:r19 = 0, so terminate the loop.
	; Otherwise, continue.
	brne delay1
	
	; Now set the LED on pin 52 to off 
	ldi r16, 0x00
	sts PORTB_DS, r16
	
	; Set the LED on pin 42 (PORTL bit 7) to on
	ldi r16, 0x80
	sts PORTL_DS, r16
	
	; Now wait for another second
	ldi r16, low(DELAY_ITERATIONS)
	ldi r17, byte2(DELAY_ITERATIONS)
	ldi r18, byte3(DELAY_ITERATIONS)
	ldi r19, byte4(DELAY_ITERATIONS)
delay2:
	ldi r20, 0x01
	ldi r21, 0x00
	sub r16, r20
	sbc r17, r21
	sbc r18, r21
	sbc r19, r21
	brne delay2
	
	; Now set the LED on pin 42 to off 
	ldi r16, 0x00
	sts PORTL_DS, r16
	
;delay3:
;	ldi r20, 0x01
;	ldi r21, 0x00
;	sub r16, r20
;	sbc r17, r21
;	sbc r18, r21
;	sbc r19, r21
;	brne delay3
;	; Repeat
	rjmp start
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Data Section                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.dseg
.org 0x200
; Put variables and data arrays here...