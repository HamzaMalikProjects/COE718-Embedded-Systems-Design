#include "LPC17xx.h"
#include <stdio.h>
#include "Board_LED.h"
#include "GLCD.h"

#define __FI 1 /* font index 16x24 */
#define __USE_LCD 1 /* Set to 1 to use the LCD */



//------- ITM Stimulus Port definitions for printf ------------------- //

#define ITM_Port8(n) (*((volatile unsigned char *)(0xE0000000 + 4 * n)))
#define ITM_Port16(n) (*((volatile unsigned short *)(0xE0000000 + 4 * n)))
#define ITM_Port32(n) (*((volatile unsigned long *)(0xE0000000 + 4 * n)))
#define DEMCR (*((volatile unsigned long *)(0xE000EDFC)))
#define TRCENA 0x01000000



struct __FILE { int handle; };
FILE __stdout;
FILE __stdin;

int fputc(int ch, FILE *f) {
    if (DEMCR & TRCENA) {
			
        while (ITM_Port32(0) == 0);
        ITM_Port8(0) = ch;
    }
    return ch;
}

// Bit Band Macros used to calculate the alias address at run time
#define ADDRESS(x) (*((volatile unsigned long *)(x)))
#define bitband(x, y) ADDRESS(((unsigned long)(x) & 0xF0000000) | 0x02000000 | \
                             (((unsigned long)(x) & 0x000FFFFF) << 5) | ((y) << 2))

														 
volatile unsigned long *bit1; //*****
volatile unsigned long *bit2; //*****

														 
#define port1_28 (*((volatile unsigned long *)0x233806F0))
#define port2_2 (*((volatile unsigned long *)0x23380A88))


void delay(unsigned int delay_time_ms);


// Setting LED1 using mask method
void setLED_Mask(int on) {
    if (on) {
        LPC_GPIO1->FIOPIN |= (1 << 28); // Set LED on Port 1
        LPC_GPIO2->FIOPIN |= (1 << 2);  // Set LED on Port 2
			}else{
					LPC_GPIO1->FIOPIN &= ~(1 << 28); // Clear LED on Port 1
					LPC_GPIO2->FIOPIN &= ~(1 << 2);  // Clear LED on Port 2
    }
}



// Setting LEDs using function method
void setLED_Func(int on) {
    bit1 = &bitband(&LPC_GPIO1->FIODIR, 31);
    bit2 = &bitband(&LPC_GPIO2->FIODIR, 3);
	
	
    if (on) {
        *bit1 = 0;
        *bit2 = 1;
			}else{
        *bit1 = 1;
        *bit2 = 0;
    }
    if (on == 3) {
        *bit1 = 1;
        *bit2 = 1;
    }
}

// Setting LEDs using bit banding
void setLEDs_bitband(int on) {
    if (on) {
        port1_28 = 1;
        port2_2 = 1;
    } else {
        port1_28 = 0;
        port2_2 = 0;
    }
}

char text[20];

int main(void) {
    LPC_SC->PCONP 		|= (1 << 15); /* enable power to GPIO & IOCON */
    LPC_GPIO1->FIODIR |= 0xB0000000; /* LEDs on PORT1 are output */
    LPC_GPIO2->FIODIR |= 0x0000007C; /* LEDs on PORT2 are output */

    #ifdef __USE_LCD
    GLCD_Init();
    GLCD_Clear(White); 
    GLCD_SetBackColor(Red );
    GLCD_SetTextColor(Black);
    GLCD_DisplayString(0, 0, __FI, (unsigned char *)"COE718Lab2 by Hamza");
    GLCD_SetBackColor(Red);
    GLCD_SetTextColor(Black);
    #endif

    while (1) {
        int r1 = 1, r2 = 0, r3 = 2; // Reset r1, r2, r3 for each loop iteration

        // Mask mode (method 1)
        sprintf(text, "%s", "Masking Method ");
        GLCD_DisplayString(5, 0, __FI, (unsigned char *)text);
			
        setLED_Mask(1); // Turn on LEDs for indication
        while (r2 <= 0x07) { 
            if ((r1 - r2) > 0) {
                r1 += 2;
									r2 = r1 + (r3 * 4);
										r3 /= 2;
											delay(2500); 
			
            }else{
                r2++;
									setLED_Mask(0); 
										delay(2500); 
            }
        }
			
        setLED_Mask(0); 
		/*	
        // Function method with barrel shift (method 2)
        sprintf(text, "%s", "Bitband Function ");
        GLCD_DisplayString(5, 0, __FI, (unsigned char *)text);
				
        r1 = 1; r2 = 0;
        setLED_Func(1); // Turn on LEDs for indication
        while (r1 <= 0x03) {
            if ((r1 - r2) > 0) {
                r2 += 2;
									delay(2500); 
            }else{
                r1++;
									setLED_Func(0);
										delay(2500); 
            }
        }
        setLED_Func(3); 

       // Bitband method
				
				sprintf(text, "%s", "Direct Bitbanding ");
        GLCD_DisplayString(5, 0, __FI, (unsigned char *)text);
				
				setLEDs_bitband(1);
        delay(2500);
				
        setLEDs_bitband(0);
        delay(2500); 
				
			*/
    }
		
}

void delay(unsigned int delay_time_ms) { // delay function
    for (int i = 0; i < delay_time_ms; i++) {
        for (volatile int j = 0; j < 2500; j++) {
            // Empty loop for delay
        }
    }
}
