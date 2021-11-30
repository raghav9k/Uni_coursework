/* lab08_blink_one.c
   CSC 230 - Summer 2018
   
   A C program to blink the LED on pin 52 at 0.5 second intervals.

   B. Bird - 07/15/2018
*/

/* The util/delay.h header file defines the _delay_ms() function, which uses a delay loop.
   The code in delay.h expects a constant called F_CPU to be defined giving the number of
   clock cycles per second, so we define that here.
*/

#define F_CPU 16000000UL //The UL suffix directs the compiler to parse the constant as an unsigned long int

#include <avr/io.h>
#include <util/delay.h>


int main(){

	DDRL = 0xff;
	DDRB = 0xff;


	while(1){
		PORTB = 0x02; //Set PORTB to 00000010 (to light the LED on pin 52)
		PORTL = 0x00; //Turn off all LEDs on Port L
		_delay_ms(500);
		
		//Set both PORTB and PORTL to 0
		PORTB = 0;
		PORTL = 0;
		_delay_ms(500);
	}

	
	//Note that in an AVR program, we never want main to return.

	return 0;

}
