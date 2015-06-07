/**
 * Primitive first stage bootloader 
 *
 */
#include "soc-hw.h"

int main(int argc, char **argv)
{
	tic_init();
	set_frecuency(100000000);
	set_duty(10000000);
	tic_isr();
	for(;;)
	{
	}
	
	//i2c_test();
	//spi_test();
	//gpio_test();
	//uart_test();
	//timer_test();
	
}

