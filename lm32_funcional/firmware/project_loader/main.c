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
	irq_set_mask(0x0000FFFF);
	irq_enable();
				
	// Initialize I2C Core			
//	i2c_core_init(0x00, 0xC7);
	//MPU6050_Initialize();
	
	/*for(;;)
	{
		spi_test();
	}
	*/
	//i2c_test();
	//spi_test();
	//gpio_test();
	//uart_test();
	//timer_test();
	
}

inline void writeint(uint32_t val)
{
	uint32_t i, digit;

	for (i=0; i<8; i++) 
	{
		digit = (val & 0xf0000000) >> 28;
		if (digit >= 0xA) uart_putchar('A'+digit-10);
		else uart_putchar('0'+digit);
		val <<= 4;
	}
}


