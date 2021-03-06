#include "soc-hw.h"

spi_t   *spi0   = (spi_t *)    0x30000000;
gpio_t  *gpio0  = (gpio_t *)   0x40000000;
timer_t *timer0 = (timer_t *)  0x50000000;
uart_t  *uart0  = (uart_t *)   0x60000000;

isr_ptr_t isr_table[32];


uint32_t tic_msec;
uint32_t msec;


void prueba()
{	
	
	int i;
	
	   /*spi0->cs=1;	
	   volatile uint32_t miso = spi0->rxtx;
	   spi0->cs=0;	
	   spi0->rxtx=0xFF;*/
	   //uart_putstr(miso);//uart_putchar(miso);//miso;//Enviar solo el miso ;)

	   //spi0->divisor=4;
	   //spi0->nop2=5;

	   for(i=0; i<3; i++) 
	   {
	   uart_putstr("..\n");    
	   msleep(1000);
	   }
	
	   /*uart_putstr( "Timer Interrupt counter: " );
	   writeint( tic_msec ); 
	   uart_putchar('\n');   
	   gpio0->oe = 0x0000002f; 
	   gpio0->out = 0x0000002f; */

           		
	
}
void tic_isr();
/***************************************************************************
 * IRQ handling
 */
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

/***************************************************************************
 * TIMER Functions
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
	timer0->compare1 = FCPU*msec/1000000;
	timer0->counter1 = 0;
	timer0->tcr1 = TIMER_EN;

	do {
		//halt();
 		tcr = timer0->tcr1;
 	} while ( ! (tcr & TIMER_TRIG) );
}


void tic_isr() // INTERRUPCIÓN DE EL TIMER QUE SE ACTIVA CUANDO SE LLEGA A LA COMPARACIÓN  DE EK TIMER CERO
{
	tic_msec++;
    uart_putstr("tic_isr  \n");   
	timer0->tcr0     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

void tic_init() //Inicialización de el timer
{
	tic_msec = 0;

	// Setup timer0.0
	timer0->tcr0   = TIMER_EN | TIMER_AR | TIMER_IRQEN; //Configuración de los timer

	//Setup timer0.1
	timer0->tcr1     = TIMER_EN | TIMER_AR | TIMER_IRQEN;	

	isr_register(1, &tic_isr);
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

