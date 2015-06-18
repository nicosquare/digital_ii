#include "soc-hw.h"


i2c_t   *i2c0  = (i2c_t *)   0x20000000;
spi_t   *spi0  = (spi_t *)   0x30000000;
gpio_t   *gpio0  = (gpio_t *)   0x40000000;
timer_t  *timer0 = (timer_t *)  0x50000000;
uart_t   *uart0  = (uart_t *)   0x60000000;


/***************************************************************************
 * Variables
 */
 
// Interruption vector pointer 
isr_ptr_t isr_table[32];

// Duty cycle array
// Each position stores de current duty cycle for each motor in percentages
// [ M1 %| M2 %| M3 %| M4 %]
uint8_t pwm_d[] = {10, 10, 10, 10};

// PWM max period
// Time (in seconds) of duration of PWM cycle
// Max value 1 second
uint8_t pwm_p = 1;

/***************************************************************************
 * Functions
 */
 
 void tic_isr_0();
 void tic_isr_1();
 void tic_isr_2();
 void tic_isr_3();
 void tic_isr_4();
 void tic_isr_5();
 void tic_isr_6();
 void tic_isr_7();
 
/***************************************************************************
 * General utility functions
 */

void fade_led()
{	
	   char i;
	   for(i=0; i<3; i++) 
       {
	   uart_putstr("..\n");    
	   msleep(1000);
	   }
	   
}
 
/***************************************************************************
 * IRQ Handling
 */

void tic_isr();
 
void isr_null()
{
}

void irq_handler(uint32_t pending)
{
	int i;

	for(i=0; i<32; i++) {
		if (pending & 0x01) (*isr_table[i])();
		pending >>= 1;
	}
}

void isr_init()
{
	int i;
	for(i=0; i<32; i++)
		isr_table[i] = &isr_null;
}

void isr_register(int irq, isr_ptr_t isr)
{
	isr_table[irq] = isr;
}

void isr_unregister(int irq)
{
	isr_table[irq] = &isr_null;
}

/*****************************************************************
*I2C Functions
*/
void i2c_test()
{
	uint8_t sr = 0;
	uint8_t rx = 0;
	uint8_t slave_add = 0xAA;
	uint8_t memory_add = 0x55;
	
	uart_putstr("Begin I2C Test \n");
	
	// Set Prescale registers
	i2c0->prerlo = 0x32;
	i2c0->prerhi = 0x00;
	// Enable the core
	i2c0->ctr = 0x80;
	
	// Drive slave address
	i2c0->txrxr = (slave_add << 1) + 0;
	i2c0->csr = 0x90;
	
	// Check tip bit
	do 	
	{
		sr = i2c0->csr;
		uart_putchar(sr);
		uart_putstr("\n");
 	} while ( sr & 0x20 );
 	
 	// Send memory address
 	i2c0->txrxr = memory_add;
	i2c0->csr = 0x10;
	
	// Check tip bit
	do 	
	{
		sr = i2c0->csr;	
		uart_putchar(sr);
		uart_putstr("\n");
 	} while ( sr & 0x20 );
	
	// Drive slave address
	i2c0->txrxr = (slave_add << 1) + 1;
	i2c0->csr = 0x90;
	
	// Check tip bit
	do 	
	{
		sr = i2c0->csr;	
		uart_putchar(sr);
		uart_putstr("\n");
 	} while ( sr & 0x20 );
	
	// Read data from slave
	i2c0->csr = 0x20;
	
	// Check tip bit
	do 	
	{
		sr = i2c0->csr;
		uart_putchar(sr);
		uart_putstr("\n");
 	} while ( sr & 0x20 );
	
	// Check data just received
	rx = i2c0->txrxr;
		
 	uart_putstr("--- Rx Register\n");
	uart_putchar(rx);
	uart_putstr("\n");
	
	do 	
	{
		sr = i2c0->csr;
		uart_putchar(sr);
		uart_putstr("\n");
 	} while ( sr & 0x20 );	
 
	i2c0->csr = 0x28;
	
	uart_putstr("End I2C Test  \n");
}

/*****************************************************************
*SPI Functions
*/
void spi_test()
{
	int32_t aux_read;
	int i = 0;
	spi0->txr = 0xAA;
	
	for(i;i<10;i++){};
		
	aux_read = spi0->rxr;
	
	writeint(aux_read);
}

/*****************************************************************
*GPIO
*/
void gpio_test()
{
 gpio0->out=0xA;
}

void gpio_output(char output)
{
 gpio0->out=output;
}

/*
void pwm_out(char out) // Select output pin for GPIO
{
	return gpio_out = out;
}
*/

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

void timer_test()
{
	// Put your test here ;)
}

void tic_init() //Inicialización de el timer
{
	// Set high M1,M2,M3 and M4
	gpio0->out=0x0F;
	
	// Setup timer0.0 
	timer0->compare0 = set_period();
	timer0->counter0 = 0;
	timer0->tcr0   = TIMER_EN | TIMER_AR | TIMER_IRQEN;

	// Setup timer0.1 
	timer0->compare1 = set_duty(pwm_d[0]);
	timer0->counter1 = 0;	
	timer0->tcr1     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	
	// Setup timer0.2 
	timer0->compare2 = set_period();
	timer0->counter2 = 0;
	timer0->tcr2   = TIMER_EN | TIMER_AR | TIMER_IRQEN;

	// Setup timer0.3 
	timer0->compare3 = set_duty(pwm_d[1]);
	timer0->counter3 = 0;	
	timer0->tcr3     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	
	// Setup timer0.4 
	timer0->compare4 = set_period();
	timer0->counter4 = 0;
	timer0->tcr4   = TIMER_EN | TIMER_AR | TIMER_IRQEN;

	// Setup timer0.5 
	timer0->compare5 = set_duty(pwm_d[2]);
	timer0->counter5 = 0;	
	timer0->tcr5     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	
	// Setup timer0.6 
	timer0->compare6 = set_period();
	timer0->counter6 = 0;
	timer0->tcr6   = TIMER_EN | TIMER_AR | TIMER_IRQEN;

	// Setup timer0.7 
	timer0->compare7 = set_duty(pwm_d[3]);
	timer0->counter7 = 0;	
	timer0->tcr7     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	
	isr_register(3, &tic_isr_0);
	isr_register(4, &tic_isr_1);
	isr_register(5, &tic_isr_2);
	isr_register(6, &tic_isr_3);
	isr_register(7, &tic_isr_4);
	isr_register(8, &tic_isr_5);
	isr_register(9, &tic_isr_6);
	isr_register(10, &tic_isr_7);
}

void tic_isr_0()
{
	uint32_t out_state = 0;
	
	uart_putstr("Interruption Timer 0\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state | 0x01;
	
	timer0->counter0 = 0;
	timer0->tcr0   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	
	timer0->counter1 = 0;
	timer0->tcr1   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

void tic_isr_1()
{
	uint32_t out_state = 0;
	
	uart_putstr("Interruption Timer 1\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state & 0xFE;
	
	timer0->tcr1     = 0x00;
}

void tic_isr_2()
{
	uint32_t out_state = 0;
	
	uart_putstr("Interruption Timer 2\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state | 0x02;
	
	timer0->counter2 = 0;
	timer0->tcr2   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	
	timer0->counter3 = 0;
	timer0->tcr3   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

void tic_isr_3()
{
	uint32_t out_state = 0;
	
	uart_putstr("Interruption Timer 3\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state & 0xFD;
	
	timer0->tcr3     = 0x00;
}

void tic_isr_4()
{
	uint32_t out_state = 0;
	
	uart_putstr("Interruption Timer 4\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state | 0x04;
	
	timer0->counter4 = 0;
	timer0->tcr4   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	
	timer0->counter5 = 0;
	timer0->tcr5   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

void tic_isr_5()
{
	uint32_t out_state = 0;
	
	uart_putstr("Interruption Timer 5\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state & 0xFB;
	
	timer0->tcr5     = 0x00;
}

void tic_isr_6()
{
	uint32_t out_state = 0;
	
	uart_putstr("Interruption Timer 6\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state | 0x08;
	
	timer0->counter6 = 0;
	timer0->tcr6   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	
	timer0->counter7 = 0;
	timer0->tcr7   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

void tic_isr_7()
{
	uint32_t out_state = 0;
	
	uart_putstr("Interruption Timer 7\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state & 0xF7;
	
	timer0->tcr7     = 0x00;
}

// Set period of PWM
uint32_t set_period() 
{
	return FCPU*pwm_p;
}

// Set duty cycle of PWM
uint32_t set_duty(uint32_t percentage) 
{
	return (FCPU*pwm_p*percentage)/100;
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

