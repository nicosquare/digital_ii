/**
 * Primitive first stage bootloader 
 *
 */
#include "soc-hw.h"

int main(int argc, char **argv)
{
	for(;;)
	{
		timer_test();
	}
	
	//i2c_test();
	//spi_test();
	//gpio_test();
	//uart_test();
	//timer_test();
	
}

