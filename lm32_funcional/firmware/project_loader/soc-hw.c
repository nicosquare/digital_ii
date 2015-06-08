#include "soc-hw.h"


i2c_t   *i2c0  = (i2c_t *)   0x20000000;
spi_t   *spi0  = (spi_t *)   0x30000000;
gpio_t   *gpio0  = (gpio_t *)   0x40000000;
timer_t  *timer0 = (timer_t *)  0x50000000;
uart_t   *uart0  = (uart_t *)   0x60000000;

uint32_t msec = 0;
uint32_t compare0Aux;
uint32_t compare1Aux;
isr_ptr_t isr_table[32];
//uint32_t tic_msec;
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

		//uart_putstr( "Timer Interrupt counter: " );
		//writeint( tic_msec ); 	
	}
}


inline void writeint(uint32_t val)
{
	uint32_t i, digit;

	for (i=0; i<8; i++) {
		digit = (val & 0xf0000000) >> 28;
		if (digit >= 0xA) 
			uart_putchar('A'+digit-10);
		else
			uart_putchar('0'+digit);
		val <<= 4;
	}
	uart_putchar('\n');
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
/*void tic_init()
{
	// Setup timer0.0
	timer0->compare0 = (FCPU/1000);
	timer0->counter0 = 0;
	timer0->tcr0     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}
*/

void timer_test()
{
	uint32_t nsec = 1000000;
	
	// Use timer0.0
	timer0->compare0 = FCPU*nsec/1000000;
	timer0->counter0 = 0;
	
	// Use timer0.1
	timer0->compare1 = FCPU*nsec/1000000;
	timer0->counter1 = 0;
	
	// Use timer0.2
	timer0->compare2 = FCPU*nsec/1000000;
	timer0->counter2 = 0;
	
	// Use timer0.3
	timer0->compare3 = FCPU*nsec/1000000;
	timer0->counter3 = 0;
	
	// Use timer0.4
	timer0->compare4 = FCPU*nsec/1000000;
	timer0->counter4 = 0;
	
	// Use timer0.5
	timer0->compare5 = FCPU*nsec/1000000;
	timer0->counter5 = 0;
	
	// Use timer0.6
	timer0->compare6 = FCPU*nsec/1000000;
	timer0->counter6 = 0;
	
	// Use timer0.7
	timer0->compare7 = FCPU*nsec/1000000;
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

void tic_isr();
/***************************************************************************
 * IRQ handling
 */
void isr_null()	
{
}

/*SELECCIONA EL PIN DE SALIDA PARA GPIO
void pwm_out(char out)
{
	return gpio_out = out;
}
*/

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


//AJUSTA FRECUENCIA DEL PWM
uint32_t set_frecuency(uint32_t x)
{
	compare0Aux = FCPU/x;//
	return compare0Aux;
}
//AJUSTA CICLO UTIL DEL PWM
uint32_t set_duty(uint32_t y)
{
	compare1Aux = FCPU/y;//
	return compare1Aux;
}


void tic_init() //Inicialización de el timer
{
	//uint32_t compare0Aux = set_frecuency(100000000);
	//uint32_t compare1Aux = set_frecuency(10000000);
	//tic_msec = 0;
	//gpio_output(0xf);
	
	gpio0->out=0xf;
	// Setup timer0.0 , Define frecuencia de la señal pwm
	timer0->tcr0   = TIMER_EN | TIMER_AR | TIMER_IRQEN; //Configuración de los timer
	timer0->compare0 = compare0Aux;
	timer0->counter0 = 0;
	//Setup timer0.1 , ajusta el ciclo util de la señal pwm
	timer0->tcr1     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	timer0->compare1 = compare1Aux;
	timer0->counter1 = 0;	
	uart_putstr("init\n");
	isr_register(1, &tic_isr);
}


/*void tic_init() //Inicialización de el timer
{
	tic_msec = 0;

	// Setup timer0.0
	timer0->tcr0   = TIMER_EN | TIMER_AR | TIMER_IRQEN; //Configuración de los timer

	//Setup timer0.1
	timer0->tcr1     = TIMER_EN | TIMER_AR | TIMER_IRQEN;	

	isr_register(1, &tic_isr);
}
*/
 
 

void tic_isr() //ENTRA ACÁ CADA VEZ QUE EL TIMER CUENTA
{
	uart_putstr("tic_isr \n"); 		
	//tic_msec++;
	//uint32_t compare0Aux = set_frecuency(100000000);
	//uint32_t compare1Aux = set_frecuency(10000000);
	
	if(timer0->tcr1 & TIMER_TRIG)
	{
		uart_putstr("IF 2 \n"); 
		gpio0->out=0x0;
		timer0->tcr1     = TIMER_AR | TIMER_IRQEN;
	}
	
	if(timer0->tcr0 & TIMER_TRIG)
	{
		gpio0->out=0xf;
		timer0->compare0 = compare0Aux ;//(1000000);
		timer0->compare1 = compare1Aux;//(100000);
		timer0->counter0 = 0;
		timer0->counter1 = 0;
		timer0->tcr0     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
		timer0->tcr1     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	    uart_putstr("IF 2 \n"); 
	}
	//writeint(tic_msec);
	//uart_putstr("\n"); 		
	
}


 /*
void tic_isr() // INTERRUPCIÓN DE EL TIMER QUE SE ACTIVA CUANDO SE LLEGA A LA COMPARACIÓN  DE EK TIMER CERO
{
	tic_msec++;
	timer0->tcr0     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	timer0->tcr1     = TIMER_EN | TIMER_AR | TIMER_IRQEN;	
}

*/


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

