; timer0_oc.asm
; CSC 230 - Summer 2018
; 
; This code uses timer 0 (see datasheet) to blink the LED on pin 52 (port B bit 1)
; at regular intervals. In this version, instead of the "overflow mode", in which
; the ISR is called every time the 8-bit counter overflows, we use one of the
; "output compare" modes (specifically CTC or "clear timer on compare" mode)
; to trigger an interrupt every time the counter reaches a particular preset
; value.
;
; Note: You might find this code helpful for the assignment, but you MUST become
; familiar with the documentation for timers (in the datasheet) if you want to 
; properly understand the mechanics of the timer features.
;
; B. Bird - 06/28/2018

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
	
	
; According to the datasheet, the interrupt vector for timer 0 output compare A is located
; at 0x002a. Note that up to two output compare interrupts (A and B) can be enabled
; simultaneously (the interrupt vector for output compare B is 0x002c)
.org 0x002a
	jmp TIMER0_OC_ISR
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Main Program                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; According to the datasheet, the last interrupt vector has address 0x0072, so the first
; "unreserved" location is 0x0074
.org 0x0074
main_begin:

	; Initialize the stack
	ldi r16, high(STACK_INIT)
	sts SPH_DS, r16
	ldi r16, low(STACK_INIT)
	sts SPL_DS, r16
	
	; Set DDRB and DDRL
	ldi r16, 0xff
	sts DDRL_DS, r16
	sts DDRB_DS, r16
	
	
	call TIMER0_SETUP ; Set up timer 0 control registers (function below)
	
	ldi r16, 0
	sts OC_INTERRUPT_COUNTER, r16
	sts LED_STATE, r16
	
	sei ; Set the I flag in SREG to enable interrupt processing
	
	
	; Now enter an infinite loop which repeatedly
	; sets the LED based on the current value of LED_STATE.
	
main_loop:
	
	call CLEAR_LEDS
	
	lds r16, LED_STATE
	; If the LED_STATE is 1, then set the LED to be lit
	cpi r16, 1
	brne main_loop_done
	
	; Set up argument for SET_LED
	ldi r16, 0
	call SET_LED

main_loop_done:
	rjmp main_loop
	
	
; stop:			; This loop is unnecessary (Question: why?)
; 	rjmp stop

; End of main program



; TIMER0_SETUP()
; Set up the control registers for timer 0
; In this version, the timer is set up for overflow interrupt mode
; (which triggers an interrupt every time the timer's counter overflows
;  from 255 to 0)
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
	ldi r16, 0x05 
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



; TIMER0_OC_ISR()
; ISR for the timer 0 output compare A interrupt.
TIMER0_OC_ISR:
	push r16
	lds r16, SREG_DS ; Load the value of SREG into r16
	push r16 ; Push SREG onto the stack
	push r17
	
	; Increment the value of OVERFLOW_INTERRUPT_COUNTER
	lds r16, OC_INTERRUPT_COUNTER
	inc r16
	sts OC_INTERRUPT_COUNTER, r16
	
	; If the incrementation did not cause an overflow,
	; we're done.
	brne timer0_isr_done
	
	; Otherwise, 256 interrupts have occurred since the last
	; time we flipped the state, so load the LED_STATE value
	; and flip it
	lds r16, LED_STATE
	
	; We can flip 0 to 1 and 1 to 0 by using XOR
	ldi r17, 1
	eor r16, r17
	
	sts LED_STATE, r16
	
timer0_isr_done:
	
	pop r17
	; The next stack value is the value of SREG
	pop r16 ; Pop SREG into r16
	sts SREG_DS, r16 ; Store r16 into SREG
	; Now pop the original saved r16 value
	pop r16

	reti ; Return from interrupt









; Everything below this line is review from a previous example



; The function below was taken from delay_loop_functions.asm from Week 6
; CLEAR_LEDS()
; Turn off all LEDs on Ports B and L
CLEAR_LEDS:
	; This function uses r16, so we will save it onto the stack
	; to preserve whatever value it already has.
	push r16
	
	
	; Set PORTL and PORTB to 0x00
	ldi r16, 0x00
	sts PORTL_DS, r16
	sts PORTB_DS, r16
	
	; Load the saved value of r16
	pop r16
	
	; Return 
	ret


; The function below was taken from delay_loop_functions.asm from Week 6
; SET_LED(r16: index)
; This function takes an argument in r16. The argument will
; be an index between 0 and 2, giving the LED to light:
;   r16 = 0 - Light the LED on Pin 52 (Port B Bit 1)
;   r16 = 1 - Light the LED on Pin 46 (Port L Bit 3)
;   r16 = 2 - Light the LED on Pin 42 (Port L Bit 7)
SET_LED:
	; This function uses r16, and even though r16 is the argument value,
	; we should save it to memory (since maybe the caller wants to continue
	; using it when the function ends).
	push r16
	
	; A 3-case if-statement for the different index values
	; (Try re-implementing this with an array instead of a cascading if-else)
	cpi r16, 0
	breq SET_LED_idx0
	cpi r16, 1
	breq SET_LED_idx1
	cpi r16, 2
	breq SET_LED_idx2
	rjmp SET_LED_done
	
SET_LED_idx0:
	; Set Port B, Bit 1
	; Load the existing value of PORTB
	lds r16, PORTB_DS
	; Use Bitwise OR to set bit 1 to 1
	; (Note that bit 1 is the second bit from the right)
	ori r16, 0x02
	sts PORTB_DS, r16
	rjmp SET_LED_done
SET_LED_idx1:
	; Set Port L, Bit 3
	; Load the existing value of PORTL
	lds r16, PORTL_DS
	; Use Bitwise OR to set bit 3 to 1	
	ori r16, 0x08
	sts PORTL_DS, r16
	rjmp SET_LED_done
SET_LED_idx2:	
	; Set Port L, Bit 7
	; Load the existing value of PORTL
	lds r16, PORTL_DS
	; Use Bitwise OR to set bit 7 to 1	
	ori r16, 0x80
	sts PORTL_DS, r16
SET_LED_done:	

	; Load the saved value of r16 and return	
	pop r16
	ret
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Data Section                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.dseg
.org 0x200
LED_STATE: .byte 1 ; The current state of the LED (1 = on, 0 = off)

OC_INTERRUPT_COUNTER: .byte 1 ; Counter for the number of times the overflow interrupt has been triggered.
