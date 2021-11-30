; lab04_LEDs.asm
;
; A test of the LEDs on pins 42, 44, 46, 48, 50 and 52
;
;
; B. Bird - 06/01/2018

.cseg
.org 0

; The port addresses below were obtained from the I/O view of the simulator.
; We use the "data address" of each register (given in brackets in the simulator).

.equ PORTB_DS = 0x0025 ; Data space address of the PORTB register
.equ DDRB_DS  = 0x0024 ; Data space address of the data direction register for port B

.equ PORTL_DS = 0x010B ; Data space address of the PORTL register
.equ DDRL_DS = 0x010A ; Data space address of the data direction register for port L


	; From the pinout diagram: 
	; Pin 42 - Port L, bit 7
	; Pin 44 - Port L, bit 5
	; Pin 46 - Port L, bit 3
	; Pin 48 - Port L, bit 1
	; Pin 50 - Port B, bit 3
	; Pin 52 - Port B, bit 1

	
	; Set the data direction of both ports to "output" on all pins
	; A 1 bit means "output" and a 0 bit means "input", so setting the DDR to
	; 0xff sets all pins to output
	ldi	r16, 0xff
	sts	DDRL_DS, r16
	sts DDRB_DS, r16

	; Set pin 50 to high
	; Pin 50 is bit 3 of PORTB

	ldi r16, 0x08 ; 0x08 has a 1 in bit 3
	sts PORTB_DS, r16

	; Set pins 44 and 46 to high
	ldi r16, 0x28 ; 0x28 has a 1 in bits 3 and 5
	sts PORTL_DS, r16
	
	
done:
	rjmp done
