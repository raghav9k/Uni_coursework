; lcd_getdigit.asm
; CSC 230 - Summer 2018
;
; Demonstration of a technique for converting a 1-digit value
; (between 0 and 9, inclusive) to a character code for display.
; 
; B. Bird - 07/04/2018

.equ SPH_DS = 0x5E
.equ SPL_DS = 0x5D

.equ STACK_INIT = 0x21FF

; Include the LCD_specific definitions (we also have to include several
; functions which contain code for the LCD, but we will do that at the end
; of our .cseg)
.include "lcd_function_defs.inc"

.cseg

.org 0 ; Put everything at address 0 since we're not using interrupts.

	; Initialize the stack
	ldi r16, high(STACK_INIT)
	sts SPH_DS, r16
	ldi r16, low(STACK_INIT)
	sts SPL_DS, r16
	
	; Initialize the LCD
	call lcd_init
	
	
	; Load the base address of the LINE_ONE array
	ldi YL, low(LINE_ONE)
	ldi YH, high(LINE_ONE)
	; Manually set the string to contain the text "Digit: "
	
	ldi r16, 'D'
	st Y+, r16
	ldi r16, 'i'
	st Y+, r16
	ldi r16, 'g'
	st Y+, r16
	ldi r16, 'i'
	st Y+, r16
	ldi r16, 't'
	st Y+, r16
	ldi r16, ':'
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	
	; At this point, the Y register contains the address of the next
	; character in the array.
	
	; Call the GET_DIGIT function to get the character code for the
	; number 6.
	ldi r16, 6
	call GET_DIGIT
	st Y+, r16
	
	; Null terminator
	ldi r16, 0
	st Y+, r16
	


	; Set up the LCD to display starting on row 0, column 0
	ldi r16, 0 ; Row number
	push r16
	ldi r16, 0 ; Column number
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	

	; Display the string
	ldi r16, high(LINE_ONE)
	push r16
	ldi r16, low(LINE_ONE)
	push r16
	call lcd_puts
	pop r16
	pop r16
	
	
	
stop:
	rjmp stop
	

	
	
; GET_DIGIT( d: r16 )
; Given a value d in the range 0 - 9 (inclusive), return the ASCII character
; code for d. This function will produce undefined results if d is not in the
; required range.
; The return value (a character code) is stored back in r16
GET_DIGIT:
	push r17
	
	; The character '0' has ASCII value 48, and the character codes
	; for the other digits follow '0' consecutively, so we can obtain
	; the character code for an arbitrary single digit by simply
	; adding 48 (or just using the constant '0') to the digit.
	ldi r17, '0' ; Could also write "ldi r17, 48"
	add r16, r17
	
	pop r17
	ret
	
	
	
	

; Include the code for the LCD functions (we need to do this at the bottom of
; the code because otherwise the functions might conflict with things like interrupt
; vectors)
.include "lcd_function_code.asm"

.dseg
; Do not put a .org 0x200 directive here or the LCD library data might be displaced.

LINE_ONE: .byte 100
	