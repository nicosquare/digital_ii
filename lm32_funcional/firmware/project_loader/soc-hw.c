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
	uint8_t sr;
	
	//uart_putstr("Begin I2C Test");
	
	// Set Prescale registers
	i2c0->prerlo = 0x43;
	i2c0->prerhi = 0x00;
	// Enable the core
	i2c0->cr = 0x80;
	// Read from register
	i2c0->txr = 0x0B << 1 + 1;
	i2c0->cr = 0x90;
	
	do 
	{
		sr = i2c0->sr;
 	} while ( !(i2c0->sr & 0x01) );

	i2c0->txr = 0x0B << 1;
	i2c0->cr = 0x10;
	
	do 
	{
		sr = i2c0->sr;
 	} while ( !(i2c0->sr & 0x01) );

	i2c0->txr = 0x0B << 1;
	i2c0->cr = 0x90;

	do 
	{
		sr = i2c0->sr;
 	} while ( !(i2c0->sr & 0x01) );	
	
	i2c0->cr = 0x20;
	
	do 
	{
		sr = i2c0->sr;
 	} while ( !(i2c0->sr & 0x01) );
	
	i2c0->cr = 0x28;
	
	//uart_putstr("End I2C Test");
	
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

void msleep(uint32_t msec)
{
	uint32_t tcr;

	// Use timer0.0
	timer0->compare0 = FCPU*msec/1000;
	timer0->counter0 = 0;
	timer0->tcr0 = TIMER_EN;

	do 
	{
		//halt();
 		tcr = timer0->tcr0;
 	} while ( ! (tcr & TIMER_TRIG) );
}

void nsleep(uint32_t nsec)
{
	uint32_t tcr;

	// Use timer0.1
	timer0->compare1 = FCPU*nsec/1000000;
	timer0->counter1 = 0;
	timer0->tcr1 = TIMER_EN;

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
	uint32_t nsec = 1000000;
	uint32_t timerValue = (FCPU/nsec)*1000000;
	
	
	// Use timer0.0
	timer0->compare0 = timerValue;
	timer0->counter0 = 0;
	
	// Use timer0.1
	timer0->compare1 = timerValue;
	timer0->counter1 = 0;
	
	// Use timer0.2
	timer0->compare2 = timerValue;
	timer0->counter2 = 0;
	
	// Use timer0.3
	timer0->compare3 = timerValue;
	timer0->counter3 = 0;
	
	// Use timer0.4
	timer0->compare4 = timerValue;
	timer0->counter4 = 0;
	
	// Use timer0.5
	timer0->compare5 = timerValue;
	timer0->counter5 = 0;
	
	// Use timer0.6
	timer0->compare6 = timerValue;
	timer0->counter6 = 0;
	
	// Use timer0.7
	timer0->compare7 = timerValue;
	timer0->counter7 = 0;
	
	// Enable timers
	timer0->tcr1 = TIMER_EN;
	timer0->tcr2 = TIMER_EN;
	timer0->tcr3 = TIMER_EN;
	timer0->tcr4 = TIMER_EN;
	timer0->tcr5 = TIMER_EN;
	timer0->tcr6 = TIMER_EN;
	timer0->tcr7 = TIMER_EN;
	
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

