; lab06_fibonacci.asm
; CSC 230 - Summer 2018
; 
; Code for Lab 6.
;
; The program below takes a value n and computes the nth
; Fibonacci number F(n), where
;
; n    |  0 |  1 |  2 |  3 |  4 |  5 |  6 |  ...
; F(n) |  1 |  1 |  2 |  3 |  5 |  8 | 13 |  ...
;
; B. Bird - 06/14/2018

; Stack pointer and SREG registers (in data space)
.equ SPH_DS = 0x5E
.equ SPL_DS = 0x5D
.equ SREG_DS = 0x5F

; Initial address (16-bit) for the stack pointer
.equ STACK_INIT = 0x21FF


.cseg 
.org 0

	; Initialize the stack
	ldi r16, high(STACK_INIT)
	sts SPH_DS, r16
	ldi r16, low(STACK_INIT)
	sts SPL_DS, r16
	
	
	; Set r16 to the value of n
	ldi r16, 6
	
	;;; BEGINNING OF FIBONACCI COMPUTATION ;;;
	
	; Now compute the nth Fibonacci number, using
	; the value of n in r16, then store the
	; result back in r16
.def current = r17
.def prev = r18
.def next = r19

	; Use r16 as a count variable and decrement it until
	; it reaches zero (at which point whatever is in
	; the value "current" will be our desired value)
	
	ldi current, 1
	ldi prev, 1
	cpi r16, 0 
	breq fib_done ; If we've been asked for F(0), we're done
	dec r16
	breq fib_done ; If we've been asked for F(1), we're done
	
fib_loop:
	; Compute next = current + prev
	mov next, current
	add next, prev
	
	; Now set prev = current, current = next
	mov prev, current
	mov current, next
	
	dec r16
	brne fib_loop ; If we still have terms to generate, continue the loop

fib_done:
	mov r16, current
	
	;;; END OF FIBONACCI COMPUTATION ;;;
	
	
stop:
	rjmp stop
	
