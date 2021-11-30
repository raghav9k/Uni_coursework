; lab05_buttons.asm
; CSC 230 - Summer 2018
;
; Starter code for Lab 5
;
; B. Bird - 06/06/2018

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                        Constants and Definitions                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Port and data direction register definitions
.equ DDRB_DS	= 0x24
.equ PORTB_DS	= 0x25
.equ DDRL_DS	= 0x10A
.equ PORTL_DS	= 0x10B

; Definitions for the analog/digital converter (ADC)
.equ ADCSRA_DS	= 0x7A ; Control and Status Register A
.equ ADCSRB_DS	= 0x7B ; Control and Status Register B
.equ ADMUX_DS	= 0x7C ; Multiplexer Register
.equ ADCL_DS	= 0x78 ; Output register (high bits)
.equ ADCH_DS	= 0x79 ; Output register (low bits)

; Definitions for button values from the ADC
; Comment out one set of values.
; Option A (v 1.1)
; .equ ADC_BTN_RIGHT = 0x032
; .equ ADC_BTN_UP = 0x0FA
; .equ ADC_BTN_DOWN = 0x1C2
; .equ ADC_BTN_LEFT = 0x28A
; .equ ADC_BTN_SELECT = 0x352
; Option B (v 1.0)
.equ ADC_BTN_RIGHT	= 0x032
.equ ADC_BTN_UP	= 0x0C3
.equ ADC_BTN_DOWN	= 0x17C
.equ ADC_BTN_LEFT	= 0x22B
.equ ADC_BTN_SELECT	= 0x316


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                               Main Program                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.cseg

.org 0x00


	; Set up the data direction register for PORTB for output
	ldi	r16, 0xff
	sts	DDRB_DS, r16
	sts DDRL_DS, r16

	; Set PORTB = 0x08 (to light the LED at pin 50 but not the LED at pin 52)
	; ldi	r16, 0x08
	; sts PORTB_DS, r16
	
	; Set up the ADC
	
	; Set up ADCSRA (ADEN = 1, ADPS2:ADPS0 = 111 for divisor of 128)
	ldi	r16, 0x87
	sts	ADCSRA_DS, r16
	
	; Set up ADCSRB (all bits 0)
	ldi	r16, 0x00
	sts	ADCSRB_DS, r16
	
	; Set up ADMUX (MUX4:MUX0 = 00000, ADLAR = 0, REFS1:REFS0 = 1)
	ldi	r16, 0x40
	sts	ADMUX_DS, r16
	
	
	; Now, check the button values until something below the highest threshold
	; (ADC_BTN_SELECT) is returned from the ADC.
	
	; Store the threshold in r21:r20
	; ldi	r20, low(ADC_BTN_SELECT)
	; ldi	r21, high(ADC_BTN_SELECT)
	clr r21
	
button_test_loop:
	
	; Start an ADC conversion
	
	; Set the ADSC bit to 1 in the ADCSRA register to start a conversion
	lds	r16, ADCSRA_DS
	ori	r16, 0x40
	sts	ADCSRA_DS, r16
	
	; Wait for the conversion to finish
wait_for_adc:
	lds		r16, ADCSRA_DS
	andi	r16, 0x40
	brne	wait_for_adc
	
	; Load the ADC result into the X pair (XH:XL). Note that XH and XL are defined above.
	lds	XL, ADCL_DS
	lds	XH, ADCH_DS
	
	ldi r18, low(ADC_BTN_RIGHT)
	ldi r17, high(ADC_BTN_RIGHT)
	cp XL, r18
	cpc XH, R17
	brlo HANDLE_RIGHT	
	
	ldi r18, low(ADC_BTN_UP)
	ldi r17, high(ADC_BTN_UP)
	cp XL, r18
	cpc XH, R17
	brlo HANDLE_UP
	
	ldi r18, low(ADC_BTN_DOWN)
	ldi r17, high(ADC_BTN_DOWN)
	cp XL, r18
	cpc XH, R17
	brlo HANDLE_DOWN
	
	ldi r18, low(ADC_BTN_LEFT)
	ldi r17, high(ADC_BTN_LEFT)
	cp XL, r18
	cpc XH, R17
	brlo HANDLE_LEFT
	
	ldi r18, low(ADC_BTN_SELECT)
	ldi r17, high(ADC_BTN_SELECT)
	cp XL, r18
	cpc XH, R17
	brlo HANDLE_SELECT
	
	rjmp button_test_loop
HANDLE_RIGHT:

	sts PORTB_DS, r21
	ldi r20, 0x80
	sts PORTL_DS, r20
	rjmp button_test_loop
HANDLE_UP:

	sts PORTB_DS, r21
	ldi r20, 0x20
	sts PORTL_DS, r20
	rjmp button_test_loop
HANDLE_DOWN:

	sts PORTB_DS, r21
	ldi r20, 0x08
	sts PORTL_DS, r20
	rjmp button_test_loop
HANDLE_LEFT:

	sts PORTB_DS, r21
	ldi r20, 0x02
	sts PORTL_DS, r20
	rjmp button_test_loop
HANDLE_SELECT:
	
	sts PORTL_DS, r21
	ldi r20, 0x02
	sts PORTB_DS, r20
	rjmp button_test_loop		

	; Compare XH:XL with the threshold in r21:r20
	; cp	XL, r20 ; Low byte
	; cpc	XH, r21 ; High byte
	
	; brsh button_test_loop ; If the ADC value was above the threshold, no button was pressed (so try again)	
	
	; Set PORTB = 0x02 (to light the LED at pin 52)
	; ldi	r16, 0x02
	; sts PORTB_DS, r16
	
done:
	rjmp done
	