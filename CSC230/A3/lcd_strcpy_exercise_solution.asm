; lcd_strcpy_exercise_solution.asm
; CSC 230 - Summer 2018
; 
; B. Bird - 07/09/2018

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
	

	;;;;;;;;;;;;;;;; PART 1 ;;;;;;;;;;;;;;;;

	; Load the address of LINE_ONE into Y
	ldi YL, low(LINE_ONE)
	ldi YH, high(LINE_ONE)
	; Set the contents of the array to be "Hello World" with a sequence
	; of manual ldi/st instructions
	ldi r16, 'H'
	st Y+, r16
	ldi r16, 'e'
	st Y+, r16
	ldi r16, 'l'
	st Y+, r16
	ldi r16, 'l'
	st Y+, r16
	ldi r16, 'o'
	st Y+, r16
	ldi r16, ' '
	st Y+, r16
	ldi r16, 'W'
	st Y+, r16
	ldi r16, 'o'
	st Y+, r16
	ldi r16, 'r'
	st Y+, r16
	ldi r16, 'l'
	st Y+, r16
	ldi r16, 'd'
	st Y+, r16
	
	; Add a null terminator
	ldi r16, 0
	st Y+, r16
	
	; Now, we will display the string on the LCD. We need to first call lcd_setpos
	; to set the position of the cursor on the display. We will use the top row (row 0)
	; and third column from the left (column 2).
	
	; LCD functions expect their arguments to be pushed onto the stack before calling (in order)
	ldi r16, 0 ; Row number
	push r16
	ldi r16, 2 ; Column number
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
	
	
	;;;;;;;;;;;;;;;; PART 2 ;;;;;;;;;;;;;;;;
	
	
	; Exercise: The code below calls lcd_puts to display the LINE_TWO
	;           string onto the second row of the LCD. Before calling
	;           lcd_puts, the STRCPY_DM function is called to copy
	;           the contents of LINE_ONE into LINE_TWO. Implement
	;           the STRCPY_DM function.
	
	; Load the address of LINE_ONE into X
	ldi XL, low(LINE_ONE)
	ldi XH, high(LINE_ONE)
	; Load the address of LINE_TWO into Y
	ldi YL, low(LINE_TWO)
	ldi YH, high(LINE_TWO)
	; Call STRCPY_DM (which is in this file and does not use the stack for arguments)
	call STRCPY_DM
	

	; Position the cursor on row 1 (the second line), column 0
	
	ldi r16, 1 ; Row number
	push r16
	ldi r16, 0 ; Column number
	push r16
	call lcd_gotoxy
	pop r16
	pop r16
	
	; Display the string
	ldi r16, high(LINE_TWO)
	push r16
	ldi r16, low(LINE_TWO)
	push r16
	call lcd_puts
	pop r16
	pop r16
	
	
stop:
	rjmp stop
	
	
	
	
	
; STRCPY_DM( input_str: X, output_str: Y )
; Given the base address of a null terminated string (in X) and the base
; address of an output array (in Y), copy the input string to the output
; array (with its null terminator)
STRCPY_DM:
	push XL
	push XH
	push YL
	push YH
	push r16 ; Scratch register
	
strcpy_dm_loop:
	; Get the next character from the input array (and increment the pointer)
	ld r16, X+
	; Store it into the output array (and increment the pointer)
	st Y+, r16
	; If the character is not a null terminator, the string continues, so continue
	; the loop.
	cpi r16, 0
	brne strcpy_dm_loop
	
	pop r16
	pop YH
	pop YL
	pop XH
	pop XL
	ret
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

; Include the code for the LCD functions (we need to do this at the bottom of
; the code because otherwise the functions might conflict with things like interrupt
; vectors)
.include "lcd_function_code.asm"

.dseg
; Do not put a .org 0x200 directive here or the LCD library data might be displaced.

LINE_ONE: .byte 100
LINE_TWO: .byte 100
	