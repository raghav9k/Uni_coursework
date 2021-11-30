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
int step = 0;

char portb_values[10] = {0b00000010,0b00001000,0b00000010,0b00001000,0b00100000,0b10000000};
/* set_led(i)
   Given a value i between 0 and 6, set the corresponding LED to be lit (and all other LEDs to be unlit).
   Use the following mapping from indices to LEDs on the board:
	   0: No LEDs lit
	   1: Pin 52 (Port B bit 1)
	   2: Pin 50 (Port B bit 3)
	   3: Pin 48 (Port L bit 1)
	   4: Pin 46 (Port L bit 3)
	   5: Pin 44 (Port L bit 5)
	   6: Pin 42 (Port L bit 7)
*/
void set_led(int i){
	int count = 1;
	while(1){
		if((i ==0) || ( i == 1)){
			PORTL = 0x00;
			PORTB = portb_values[i];
		}
		else{
			PORTL = portb_values[i];
			PORTB = 0x00;
		}
		if(i == 5){
			count = -1;
		}
		if(i == 0){
		count = 1;}
		i = i + count;
		_delay_ms(1000);
		}
}

int main(){

	DDRL = 0xff;
	DDRB = 0xff;


	set_led(step);

	
	//Note that in an AVR program, we never want main to return.

	return 0;

}



