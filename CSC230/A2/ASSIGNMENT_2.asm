
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
	ldi r16,5
	sts COUNT_LED,r16
	;STS COUNTER,R16
	ldi r16,-1
	sts DIRECTION,r16
	CALL ARRAY
	
start:
	call clear_leds
	LDS R20,COUNT_LED
	LDS R21,DIRECTION
	CPI R21,0
	BRLT NEG_DIR
	call SET_LED_POS
	
BACK_TO_START:
	CALL DELAY
	ADD R20,R21
	STS COUNT_LED,R20
	
	CPI R20,0
	BRNE SET1
	call SET_LED_NEG
	call negate
SET1:
	CPI R20,5
	BRNE SET2
	CALL SET_LED_POS
	call negate
SET2:	


		rjmp start
	; Wait for approximately one second
NEG_DIR:
	CALL SET_LED_NEG
	RJMP BACK_TO_START
	
	
ARRAY:
		PUSH R16
		LDI ZL,LOW(ARR)
		LDI ZH, HIGH(ARR)
		LDI R16, 0X02
		ST Z,R16
		STD Z+2,R16
		LDI R16,0X08
		STD Z+1,R16
		STD Z+3,R16
		LDI R16, 0X20
		STD Z+4,R16
		LDI R16, 0X80
		STD Z+5, R16
		POP R16
		RET
	
	; Repeat

	

;conversion:
;		LDS R22,COUNT_LED
;		CPI R22,0
;		BREQ set_led42
;		CPI R22,1
;		BREQ set_led44
;		CPI R22,2
;		BREQ set_led46
;		CPI R22,3
;		breq set_led48
;		CPI R22,4
	;	breq set_led50
;		CPI R22,5
;		breq set_led52
JUMPBACK:		
	;	ret
		
NEGATE:
		PUSH R23
		LDS R23,DIRECTION
		NEG R23
		STS DIRECTION,R23
		POP R23
		RET
		


clear_leds:
	push r16 
	
	clr r16
	sts PORTB_DS, r16
	sts PORTL_DS, r16
	
	pop r16
	ret

	

SET_LED_POS:
		PUSH R16
		PUSH R17
		LDS R17,COUNT_LED
		LD R16,-Z
		CPI R17,4
		BRGE MORE
		STS PORTL_DS, R16
BACK:			
		POP R16
		POP R17
		RET
	
MORE:	
		STS PORTB_DS,R16
		RJMP BACK

SET_LED_NEG:
			PUSH R16
			PUSH R17
			LDS R17,COUNT_LED
			LD R16,Z+
			CPI R17,4
			BRGE MOREE
			STS PORTL_DS, R16
BACKA:		
			POP R16
			POP R17
			RET
MOREE:		
			STS PORTB_DS, R16
			RJMP BACKA


delay:
	
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

	ldi r20, 0x01
	ldi r21, 0x00
	sub r16, r20
	sbc r17, r21
	sbc r18, r21
	sbc r19, r21

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
ARR: .BYTE 6
COUNT_LED: .byte 1
DIRECTION: .byte 1
COUNTER: .BYTE 1
; Put variables and data arrays here...