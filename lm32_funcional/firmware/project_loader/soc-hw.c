#include "soc-hw.h"


i2c_t   *i2c0  = (i2c_t *)   0x20000000;
spi_t   *spi0  = (spi_t *)   0x30000000;
gpio_t   *gpio0  = (gpio_t *)   0x40000000;
timer_t  *timer0 = (timer_t *)  0x50000000;
uart_t   *uart0  = (uart_t *)   0x60000000;

uint32_t msec = 0;

/***************************************************************************
 * General utility functions
 */


/*****************************************************************
*I2C Functions
*/
void i2c_test()
{
	i2c0->txr = 0x4B + 1;
	i2c0->cr = 0x90;
	while(!(i2c0->sr & 0x01));
	i2c0->txr = 0x00;
	i2c0->cr = 0x10;
	while(!(i2c0->sr & 0x01));
	i2c0->txr = 0x4B;
	i2c0->cr = 0x90;
	while(!(i2c0->sr & 0x01));
	i2c0->cr = 0x20;
	while(!(i2c0->sr & 0x01));
	i2c0->cr = 0x28;
}

/*****************************************************************
*SPI Functions
*/
void spi_test()
{
 spi0->ssr=0xAAAA;
}

/*****************************************************************
*GPIO Functions
*/
void gpio_test()
{
 gpio0->out=0xA;
}

/*****************************************************************
*Timer Functions
*/
void sleep(int msec)
{
	uint32_t tcr;

	// Use timer0.1
	timer0->compare1 = (FCPU/1000)*msec;
	timer0->counter1 = 0;
	timer0->tcr1 = TIMER_EN | TIMER_IRQEN;

	do {
		//halt();
 		tcr = timer0->tcr1;
 	} while ( ! (tcr & TIMER_TRIG) );
}

void tic_init()
{
	// Setup timer0.0
	timer0->compare0 = (FCPU/1000);
	timer0->counter0 = 0;
	timer0->tcr0     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}


void timer_test()
{
	sleep(1000);
}

/***************************************************************************
 * UART Functions
 */
void uart_init()
{
	//uart0->ier = 0x00;  // Interrupt Enable Register
	//uart0->lcr = 0x03;  // Line Control Register:    8N1
	//uart0->mcr = 0x00;  // Modem Control Register

	// Setup Divisor register (Fclk / Baud)
	//uart0->div = (FCPU/(57600*16));
}

char uart_getchar()
{   
	while (! (uart0->ucr & UART_DR)) ;
	return uart0->rxtx;
}

void uart_putchar(char c)
{
	while (uart0->ucr & UART_BUSY) ;
	uart0->rxtx = c;
}

void uart_putstr(char *str)
{
	char *c = str;
	while(*c) {
		uart_putchar(*c);
		c++;
	}
}

void uart_test()
{
	uart_putstr("Hola_prueba_uart_test\r\n");
}

