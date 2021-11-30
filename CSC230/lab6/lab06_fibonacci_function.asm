; lab06_fibonacci_function.asm
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
	
	; Diagnostic: Set registers r16 - r31 to the values 16, 17, 18, ...
	ldi r16, 16
	ldi r17, 17
	ldi r18, 18
	ldi r19, 19
	ldi r20, 20
	ldi r21, 21
	ldi r22, 22
	ldi r23, 23
	ldi r24, 24
	ldi r25, 25
	ldi r26, 26
	ldi r27, 27
	ldi r28, 28
	ldi r29, 29
	ldi r30, 30
	ldi r31, 31
	
	
	; Set r16 to the value of n
	ldi r16, 6
	
	; Call Fibonacci(6)
	call Fibonacci
	
	; Put a breakpoint here to verify that the result is correct (in r16)
	; and that every other register is still equal to its own number 
	; (to confirm that the function did not overwrite any of the register
	; values except r16)
	nop 
	
	; Set r16 again
	ldi r16, 10
	call Fibonacci
	
	; Put another breakpoint here to check the result for F(10) = 89
	nop
	
	
stop:
	rjmp stop
	
	
	
; Fibonacci(r16: n)
; Given a value n, compute the value F(n) and store
; the result back in r16 before returning. Remember to save
; any registers you use (besides r16) using push and pop.	
Fibonacci:	
	; Exercise: Before proceeding with your implementation, put a breakpoint
	; at the following line and run the code to verify that the call stack
	; contains the correct return address
	
	nop ; Your code here...
	
	
	; Return (remember to pop all relevant stored registers before ANY ret instruction)
	ret
