.cseg 
.org 0

	ldi r16, 6  ; First input value
	ldi r17, 10 ; Second input value
	

	; Perform the computation (in this case, add the values together)
	add r16, r17
	 
	; Store the result into data memory
	sts OUTPUT, r16
	
end:
	rjmp end

.dseg
.org 0x200
OUTPUT: .byte 1
