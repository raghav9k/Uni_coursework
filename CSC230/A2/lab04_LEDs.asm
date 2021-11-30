
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

.equ GTCCR_DS = 0x43
.equ OCR0A_DS = 0x47
.equ OCR0B_DS = 0x48
.equ TCCR0A_DS = 0x44
.equ TCCR0B_DS = 0x45
.equ TCNT0_DS  = 0x46
.equ TIFR0_DS  = 0x35
.equ TIMSK0_DS = 0x6E

.equ DELAY_ITERATIONS = 2000000

.cseg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                          Reset/Interrupt Vectors                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.org 0x0000 ; RESET vector
	jmp main_begin
	
	
; According to the datasheet, the interrupt vector for timer 0 overflow is located
; at 0x002e
.org 0x002e
	jmp TIMER0_OVERFLOW_ISR ; Questions: Would rjmp work here? Why do we need a jmp instead of putting the entire ISR here?
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Main Program                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.org 0x0074
MAIN_BEGIN:
	; Initialize the stack
	ldi r16, high(STACK_INIT)
	sts SPH_DS, r16
	ldi r16, low(STACK_INIT)
	sts SPL_DS, r16
	
	
	; Set up data direction registers
	ldi r16, 0xff
	sts DDRL_DS, r16
	sts DDRB_DS, r16
	
	call TIMER0_SETUP ; Set up timer 0 control registers (function below)
	
	ldi r16, 0
	sts OVERFLOW_INTERRUPT_COUNTER, r16
	sei
	; Clear all LEDs
	ldi r16,5
	sts COUNT_LED,r16
	;STS COUNTER,R16
	ldi r16,-1
	sts DIRECTION,r16
	CALL ARRAY
	
start:

	LDS R20,COUNT_LED
	LDS R21,DIRECTION
	CPI R20,0
	BRLT NEG_DIR
	call SET_LED_POS
BACK_TO_START:
		RJMP START
	; Wait for approximately one second

NEG_DIR:
	CALL SET_LED_NEG
	JMP BACK_TO_START
	
	
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
		SBIW ZH:ZL,1
		LD R16,Z
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
			LD R16,Z
			ADIW ZH:ZL, 1
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


; TIMER0_SETUP()
; Set up the control registers for timer 0
; In this version, the timer is set up for overflow interrupt mode
; (which triggers an interrupt every time the timer's counter overflows
;  from 255 to 0)
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
	call clear_leds
	LDS R20,DIRECTION
	LDS R21,COUNT_LED
	ADD R21,R20
	STS COUNT_LED,R21
	CPI R21,0
	BRNE SET1
	;call SET_LED_NEG
	LDI R16,1
	STS DIRECTION,R16
SET1:
	CPI R20,5
	BRNE SET2
	;CALL SET_LED_POS
	LDI R16,-1
	STS DIRECTION,R16
SET2:	
	

timer0_isr_done:
	
	pop r17
	; The next stack value is the value of SREG
	pop r16 ; Pop SREG into r16
	sts SREG_DS, r16 ; Store r16 into SREG
	; Now pop the original saved r16 value
	pop r16
	
	reti ; Return from interrupt







;delay:
;	
 ;	push r16
	;push r17
;	push r18
;	push r19
;	push r20
;	push r21
;	ldi r16, low(DELAY_ITERATIONS)
;	ldi r17, byte2(DELAY_ITERATIONS)
;	ldi r18, byte3(DELAY_ITERATIONS)
;	ldi r19, byte4(DELAY_ITERATIONS)
;delay_loop:
;
;	ldi r20, 0x01
;	ldi r21, 0x00
;	sub r16, r20
;	sbc r17, r21
;	sbc r18, r21
;	sbc r19, r21
;
;;	brne delay_loop
	
;	pop r21
;	pop r20
;	pop r19
;	pop r18
;	pop r17
;	pop r16
;	ret
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Data Section                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.dseg
.org 0x200
ARR: .BYTE 6
COUNT_LED: .byte 1
DIRECTION: .byte 1
OVERFLOW_INTERRUPT_COUNTER: .byte 1
TEMP_DIR: .BYTE 1
; Put variables and data arrays here...