/**
 * Primitive first stage bootloader 
 *
 */
#include "soc-hw.h"

int main(int argc, char **argv)
{
	// Initialize TIC
	isr_init();
	tic_init();
	irq_enable();
	irq_set_mask(0xffffffff);
	
	//set_frecuency(100000000); 	
	//set_duty(10000000);
	for(;;)
	{
	}
	
	//i2c_test();
	//spi_test();
	//gpio_test();
	//uart_test();
	//timer_test();
	
}

