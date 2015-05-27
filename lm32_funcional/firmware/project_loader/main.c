/**
 * Primitive first stage bootloader 
 *
 */
#include "soc-hw.h"

int main(int argc, char **argv)
{
	for(;;)
	{
		i2c_test();
		msleep(1000);
	}
	//spi_test();
	//gpio_test();
	//uart_test();
	//timer_test();
	
}

