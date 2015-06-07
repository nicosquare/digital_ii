/**
 * Primitive first stage bootloader 
 *
 */
#include "soc-hw.h"

int main(int argc, char **argv)
{
	for(;;)
	{
<<<<<<< HEAD
		tic_isr();
=======
		i2c_test();
>>>>>>> 527a8f05b15880dc250b959d3e657e6ae0abb0ad
	}
	
	//i2c_test();
	//spi_test();
	//gpio_test();
	//uart_test();
	//timer_test();
	
}

