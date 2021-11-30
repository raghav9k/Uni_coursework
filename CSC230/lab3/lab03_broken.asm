; lab03_broken.asm
;
; Some incorrect code for debugging practice.
;
;
; B. Bird - 05/25/2018

.cseg
.org 0

.def sum_high = r17
.def sum_low  = r16
.def x_high   = r19
.def x_low    = r18
.def count    = r20

	; Set sum = 0
	ldi sum_high, 0
	ldi sum_low, 0
	
	; Set x = 0x0262 = dec(610)
	ldi x_high, 0x02
	ldi x_low, 0x62

	; Set count = 5
	ldi count, 5
	
loop:	
	cpi count, 0
	breq done
	
	; Add x to sum (16-bit addition)
	adD	sum_low, x_low
	adC sum_high, x_high

	dec count
	rjmp loop
	
	
done:
	rjmp done
