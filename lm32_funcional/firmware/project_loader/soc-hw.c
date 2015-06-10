#include "soc-hw.h"


i2c_t   *i2c0  = (i2c_t *)   0x20000000;
spi_t   *spi0  = (spi_t *)   0x30000000;
gpio_t   *gpio0  = (gpio_t *)   0x40000000;
timer_t  *timer0 = (timer_t *)  0x50000000;
uart_t   *uart0  = (uart_t *)   0x60000000;


/***************************************************************************
 * Variables
 */
 
isr_ptr_t isr_table[32];

uint32_t compare0Aux;
uint32_t compare1Aux;
uint32_t tic_msec;

/***************************************************************************
 * Functions
 */
 
 void tic_isr_0();
 void tic_isr_1();
 
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

void hello_world()
{
	for(;;)
	{
		char i;
		for(i=0; i<3; i++) 
		{
			uart_putstr("..\n");  
			gpio_test(i);
			msleep(100000);
		}

		uart_putstr( "Timer Interrupt counter: " );
		writeint( tic_msec ); 	
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
	uint8_t add = 0x08;
	
	uart_putstr("Begin I2C Test \n");
	
	// Set Prescale registers
	i2c0->prerlo = 0x43;
	i2c0->prerhi = 0x00;
	// Enable the core
	i2c0->ctr = 0x80;
	
	// 1. Set the Transmit Register TXR with a value of Slave address + Write bit.
	i2c0->txrxr = (add << 1) + 0;
	// 2. Set the Command Register CR to 8’h90 to enable the START and WRITE. This starts the transmission on the I2C bus.
	i2c0->csr = 0x90;
	// 3. Check the Transfer In Progress (TIP) bit of the Status Register, SR, to make sure the command is done.
	do 	
	{
		sr = i2c0->csr;
 	} while ( sr & 0x20 );
 	// 4. Set TRX with the slave memory address, where the data is to be read from.
	i2c0->txrxr = add << 1;
	// 5. Set CR with 8’h10 to enable a WRITE to send to the slave memory address.
	i2c0->csr = 0x10;
	// 6. Check the TIP bit of SR, to make sure the command is done.
	do 	
	{
		sr = i2c0->csr;
 	} while ( sr & 0x20 );
	// 7. Set TRX with a value of Slave address + READ bit.
	i2c0->txrxr = (add << 1) + 1;
	// 8. Set CR with the 8’h90 to enable the START (repeated START in this case) and WRITE the value in TXR to the slave device.
	i2c0->csr = 0x90;
	// 9. Check the TIP bit of SR, to make sure the command is done.
	do 	
	{
		sr = i2c0->csr;
 	} while ( sr & 0x20 );
	// 10. Set CR with 8’h20 to issue a READ command and then an ACK command. This enables the reading of data from the slave device.
	i2c0->csr = 0x20;
	
	rx = i2c0->txrxr;
		
	uart_putchar(rx);
	uart_putstr("\n");
	
	// 11. Check the TIP bit of SR, to make sure the command is done.
	do 	
	{
		sr = i2c0->csr;
 	} while ( sr & 0x20 );	
 
	// 12. Repeat steps 10 and 11 to continue to read data from the slave device.
	// 13. When the Master is ready to stop reading from the Slave, set CR to 8’h28. This will read the last byte of data and then issue a NACK.	
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
	set_frecuency(1);
	set_duty(2);
	
	gpio0->out=0x0F;
	
	// Setup timer0.0 , Define frecuencia de la señal pwm
	timer0->compare0 = compare0Aux;
	timer0->counter0 = 0;
	timer0->tcr0   = TIMER_EN | TIMER_AR | TIMER_IRQEN; //Configuración de los timer

	//Setup timer0.1 , ajusta el ciclo util de la señal pwm
	timer0->compare1 = compare1Aux;
	timer0->counter1 = 0;	
	timer0->tcr1     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
		
	uart_putstr("Timer 0 and 1 running\n");
	
	isr_register(3, &tic_isr_0);
	isr_register(4, &tic_isr_1);
}

void tic_isr_0()
{
	uart_putstr("Interruption Timer 0\n");
	gpio0->out=0x0F;
	timer0->tcr0     = 0x00; //TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

void tic_isr_1()
{
	uart_putstr("Interruption Timer 1\n");
	gpio0->out=0x00;
	timer0->tcr1     = 0x00; //TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

uint32_t set_frecuency(uint32_t x) // Adjust frequency of PWM
{
	compare0Aux = FCPU/x;
	return compare0Aux;
}

uint32_t set_duty(uint32_t y) // Adjust duty cycle of PWM
{
	compare1Aux = FCPU/y;
	return compare1Aux;
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

