/*
 * assignment4.c
 *
 * Created: 8/4/2018 8:52:38 PM
 * Author : raghavkhurana
 */ 

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <avr/io.h>
#include "CSC230.h"
#define  ADC_BTN_RIGHT 0x032
#define  ADC_BTN_UP 0x0C3
#define  ADC_BTN_DOWN 0x17C
#define  ADC_BTN_LEFT 0x22B
#define  ADC_BTN_SELECT 0x316
int interrupt_count = 0;
int tenths = 0;
int sec_l = 0;
int sec_h = 0;
int min_l = 0;
int min_h = 0;
char ignore = 0;
char paused = 0;
char lapped = 0;
char curr_lap[7];
char last_lap[7];

void increment(){
	tenths++;
	if(tenths==9){
		sec_l++;
		tenths = 0;
	}
	if(sec_l==9){
		sec_h++;
		sec_l=0;
	}
	if(sec_h==6){
		min_l++;
		sec_h=0;
	}
	if(min_l==9){
		min_h++;
		min_l=0;
		}
}


void display_lcd(int min_h,int min_l,int sec_h,int sec_l,int tenths){
	char str[14];
	sprintf(str, "Time: %d%d:%d%d:%d",min_h,min_l,sec_h,sec_l,tenths);
	lcd_xy(0,0);
	lcd_puts(str);
}

ISR(TIMER0_COMPA_vect){

	interrupt_count++;
	//Every 200 interrupts is 1/10th of a second
	if (interrupt_count >= 200){
		interrupt_count -= 200;
		increment();
		display_lcd(min_h,min_l,sec_h,sec_l,tenths);
	
		
		//Flip the value of LED_state
	}
}
void timer0_setup(){
	//You can also enable output compare mode or use other
	//timers (as you would do in assembly).

	TIMSK0 = 0x02;
	TCNT0 = 0x00;
	TIFR0 = 0x01;
	
	TCCR0A = 0x02;
	TCCR0B = 0x03; //Prescaler of 64
	OCR0A = 124;
}

//Taken from lab 9 of the course as provided to us
unsigned short poll_adc(){
	unsigned short adc_result = 0; //16 bits
	
	ADCSRA |= 0x40;
	while((ADCSRA & 0x40) == 0x40); //Busy-wait
	
	unsigned short result_low = ADCL;
	unsigned short result_high = ADCH;
	
	adc_result = (result_high<<8)|result_low;
	return adc_result;
}

//handles select button implementation
void select(){
	if(ignore==0){
		ignore = 1;
	if(paused==0){
		sei();
		paused = 1;
		}
	else if(paused==1){
		cli();
		paused = 0;
		}
	}
	_delay_ms(100);
}

void clear_timer(){
	tenths = min_h = min_l = sec_h = sec_l = 0;
	display_lcd(min_h,min_l,sec_h,sec_l,tenths);
	cli();
	paused = 0;
}

void set_lap(){
	if(ignore==0){
		ignore = 1;
		lcd_xy(0,1);
		lcd_puts(last_lap);
		sprintf(curr_lap, "%d%d:%d%d.%d",min_h,min_l,sec_h,sec_l,tenths);
		lcd_xy(9,1);
		lcd_puts(curr_lap);
		strncpy(last_lap,curr_lap,7);
	}
}

void init_laps(){
	sprintf(curr_lap,"%d%d:%d%d.%d",0,0,0,0,0);
	sprintf(last_lap,"%d%d:%d%d.%d",0,0,0,0,0);
}

void down(){
	if(ignore==0){
	ignore = 1;	
	init_laps();
	lcd_xy(0,1);
	lcd_puts("                ");
	}
}

void buttons(){
	
	short adc_result = poll_adc();
	if (adc_result >= ADC_BTN_RIGHT && adc_result < ADC_BTN_UP){
		//Up button pressed
		set_lap();
		//display_lap();
		_delay_ms(250);
		ignore = 0;
	}
	else if (adc_result >= ADC_BTN_UP && adc_result < ADC_BTN_DOWN){
		//down button pressed
		down();
		_delay_ms(250);
		ignore =0;
	}
	else if (adc_result >= ADC_BTN_DOWN && adc_result < ADC_BTN_LEFT){
		//LEFT button pressed
		clear_timer();
		
	}
	else if (adc_result >= ADC_BTN_LEFT && adc_result < ADC_BTN_SELECT){
		select();
		_delay_ms(100);	
		ignore = 0;
	 }

}


int main(void)
{	
	ADCSRA = 0x87;
	ADMUX = 0x40;
	lcd_init();
	timer0_setup();
	display_lcd(min_h,min_l,sec_h,sec_l,tenths);
	init_laps();
    while (1) 
    {	
		
		buttons();
		
    }
}

