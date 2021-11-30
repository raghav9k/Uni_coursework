.cseg 
.org 0

	ldi r16, 205 ; First input value
	ldi r17, 35; Second input value
	
	.def d = r19
	clr r19
	.def r = r18
	ldi r18, 205
	
the_loop:
	CP r17,r
	BRSH end
	inc d
	SUB r,r17
	; Store the result into data memory
	sts OUTPUT, d
	rjmp the_loop
	
end:
	rjmp end

.dseg
.org 0x200
OUTPUT: .byte 1
