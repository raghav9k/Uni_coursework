;pins.asm
;learn which port is mapped to which pin and how to turn it on/off
.equ PORTL = 0x10B
.equ DDRL  = 0x10A

	;configure PORTL as output by setting DDRL to 1
	ldi r16, 0xff
	sts DDRL, r16

	;set LED at pin 48 on
	ldi r19, 0x02
	sts PORTL, r19

done:jmp done
