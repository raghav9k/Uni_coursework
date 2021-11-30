.cseg  ;Begin a code segment
.org 0 ;Position the code segment at program memory address 0

	ldi r16, 6
loop:   
	dec r16
	cpi r16, 0
	brne loop
	
end:
	rjmp end