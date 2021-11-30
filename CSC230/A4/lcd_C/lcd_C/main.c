/* lab09_lcd_demo.c
   CSC 230 - Summer 2018
   
   A simple demonstration of the main features of the LCD
   library. 

   B. Bird - 07/21/2018
*/


#include "CSC230.h"



int main(){
	
	//Call LCD init (should only be called once)
	lcd_init();
	

	//Now, display the text "Hello World" on row 0
	//starting at column 2.
	//Note that we can use a literal string (in double
	//quotes) here.
	lcd_xy(2,0);
	lcd_puts("Hello World");

	//Display the text "CSC 230" on row 1 starting
	//at column 9.
	//For this example, we declare an array to store
	//the string and then pass the array to lcd_puts.
	lcd_xy(9,1);
	char str[100] = "CSC 230"; //(We don't actually need 100 bytes)
	lcd_puts(str);

	return 0;
	
}