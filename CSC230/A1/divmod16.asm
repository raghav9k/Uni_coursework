; divmod16.asm
; CSC 230 - Summer 2018
;
; Starter code for assignment 1
;
; B. Bird - 05/13/2018

.cseg
.org 0

	; Initialization code
	; Do not move or change these instructions or the registers they refer to. 
	; You may change the data values being loaded.
	; The default values set A = 0x3412 and B = 0x0003
	ldi r16, 0x12 ; Low byte of operand A
	ldi r17, 0x34 ; High byte of operand A
	ldi r18, 0x03 ; Low byte of operand B
	ldi r19, 0x00 ; High byte of operand B
	
	; Your task: Perform the integer division operation A/B and store the result in data memory. 
	; Store the 2 byte quotient in DIV1:DIV0 and store the 2 byte remainder in MOD1:MOD0.
	.DEF QUOL = R20
	.DEF QUOH = R21
	.DEF REML = R24
	.DEF REMH = R25
	.DEF ONE = R22
	.DEF ZERO = R23
	ldi one,1
	ldi zero,0
	CLR QUOL
	CLR QUOH
	MOV REML,R16
	MOV REMH,R17

DIV_LOOP:  ;REPEATED SUBTRACTION FOR DIVISION
	CP r18,Reml		;COMPARES 16BIT VALUES
	cpc r19,remh
	BRsh STOP
	ADD QUOL,ONE	;INCREMENTS QUOTIENT
	adc quoh,zero
	SUB REMl,R18
	SBC REMh,R19
	sts DIV0,QUOL	;STORES EM
	STS DIV1,QUOH
	STS MOD0,REML
	STS MOD1,REMH
	RJMP DIV_LOOP
	; ... Your code here ...
	
	; End of program (do not change the next two lines)
stop:
	rjmp stop

; Do not move or modify any code below this line. You may add extra variables if needed.
; The .dseg directive indicates that the following directives should apply to data memory
.dseg 
.org 0x200 ; Start assembling at address 0x200 of data memory (addresses less than 0x200 refer to registers and ports)

DIV0:	.byte 1 ; Bits  7...0 of the quotient
DIV1:	.byte 1 ; Bits 15...8 of the quotient
MOD0:	.byte 1 ; Bits  7...0 of the remainder
MOD1:	.byte 1 ; Bits 15...8 of the remainder
