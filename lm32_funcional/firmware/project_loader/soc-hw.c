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
uint32_t pwm_d[] = {1, 1, 1, 1};

// PWM max period
// Time (in miliseconds) of duration of PWM cycle
// Max value 1 milisecond
uint32_t pwm_p = 1;

// Mode state
int mode = 0;

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
 void tic_isr_15();
 
/***************************************************************************
 * General utility functions
 */

void fade_led()
{	
   char i;
   /*for(i=0; i<11; i++) 
   {
		
		msleep(1000);
   }
   
   for(i=10; i>0; i--) 
   {

		
   }*/
   
   for(i=0; i<11; i++) 
   {
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

void tic_isr_0()
{
	uint32_t out_state = 0;
	
	//uart_putstr("Interruption Timer 0\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state | 0x01;
	
	timer0->counter0 = 0;
	timer0->tcr0   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	
	timer0->compare1 = set_duty(pwm_d[0]);
	timer0->counter1 = 0;
	timer0->tcr1   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

void tic_isr_1()
{
	uint32_t out_state = 0;
	
	//uart_putstr("Interruption Timer 1\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state & 0xFE;
	
	timer0->tcr1     = 0x00;
}

void tic_isr_2()
{
	uint32_t out_state = 0;
	
	//uart_putstr("Interruption Timer 2\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state | 0x02;
	
	timer0->counter2 = 0;
	timer0->tcr2   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	
	timer0->compare3 = set_duty(pwm_d[1]);
	timer0->counter3 = 0;
	timer0->tcr3   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

void tic_isr_3()
{
	uint32_t out_state = 0;
	
	//uart_putstr("Interruption Timer 3\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state & 0xFD;
	
	timer0->tcr3     = 0x00;
}

void tic_isr_4()
{
	uint32_t out_state = 0;
	
	//uart_putstr("Interruption Timer 4\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state | 0x04;
	
	timer0->counter4 = 0;
	timer0->tcr4   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	
	timer0->compare5 = set_duty(pwm_d[2]);
	timer0->counter5 = 0;
	timer0->tcr5   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

void tic_isr_5()
{
	uint32_t out_state = 0;
	
	//uart_putstr("Interruption Timer 5\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state & 0xFB;
	
	timer0->tcr5     = 0x00;
}

void tic_isr_6()
{
	uint32_t out_state = 0;
	
	//uart_putstr("Interruption Timer 6\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state | 0x08;
	
	timer0->counter6 = 0;
	timer0->tcr6   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
	
	timer0->compare7 = set_duty(pwm_d[3]);
	timer0->counter7 = 0;
	timer0->tcr7   = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}

void tic_isr_7()
{
	uint32_t out_state = 0;
	
	//uart_putstr("Interruption Timer 7\n");
	
	out_state = gpio0->out;
	gpio0->out = out_state & 0xF7;
	
	timer0->tcr7     = 0x00;
}

void tic_isr_15()
{
	uart_putstr("Interruption Mode\n");
	
	mode = mode +1;
	
		pwm_d[0] = mode;
		pwm_d[1] = mode;
		pwm_d[2] = mode;
		pwm_d[3] = mode;
		if(mode == 100)
			mode = 0;
}

/*****************************************************************
*I2C Functions
*/
void i2c_test()
{
	uint8_t whoiam = 0;
	
	i2c_read_register(MPU6050_DEFAULT_ADDRESS, MPU6050_RA_WHO_AM_I, &whoiam);
	
	uart_putchar(whoiam);
}

/**
 * Initialize the core and set the prescale register
 */
void i2c_core_init(uint8_t prerhi, uint8_t prerlo)
{
	// Set Prescale registers
	i2c0->prerlo = 0xC7;
	i2c0->prerhi = 0x00;
	// Enable the core
	i2c0->ctr = I2C_CR_CORE_EN;
}

/**
 * Check if a specific bit in Status register is Low
 */
 void i2c_check_value(uint8_t value)
 {
	uint8_t sr = 0xFF; 
	 
	while( sr != 0x00) 	
	{
		sr = (i2c0->csr & value) ^ value ;
	}
	
 }

void MPU6050_Initialize()
{
	// Configure Gyroscope
	i2c_write_register(MPU6050_DEFAULT_ADDRESS, MPU6050_RA_GYRO_CONFIG, 0x00);

	// Configure Accelerometer
	i2c_write_register(MPU6050_DEFAULT_ADDRESS, MPU6050_RA_ACCEL_CONFIG, 0x10);

    // Set clock source and disable sleep mode
	i2c_write_register(MPU6050_DEFAULT_ADDRESS, MPU6050_RA_ACCEL_CONFIG, 0x00);

}

/**
 * Read a register from a specific slave
 */
void i2c_read_register(uint8_t slaveAddr, uint8_t readAddr, uint8_t* pBuffer)
{

	/* While the bus is busy */
	i2c_check_value(I2C_SR_BUSY);
	
	/* Send slave address for write */
    i2c0->txrxr = slaveAddr << 1 + I2C_TR_W;
    i2c0->csr = I2C_CR_W | I2C_CR_STA;
    
	/* Check TIP bit */
	i2c_check_value((uint8_t) I2C_SR_TIP);
	
	/* Send the slave's internal address to write to */
    i2c0->txrxr = readAddr;
	i2c0->csr = I2C_CR_W;
	
	/* Check TIP bit */
	i2c_check_value((uint8_t) I2C_SR_TIP);  
	
	/* Send slave address for read */
    i2c0->txrxr = slaveAddr << 1 + I2C_TR_R;
    i2c0->csr = I2C_CR_W | I2C_CR_STA;

	/* Check TIP bit */
	i2c_check_value((uint8_t) I2C_SR_TIP);
	
	/* Read a byte from the slave */
	*pBuffer = i2c0->txrxr;

	/* Disable Acknowledgement and Enable STOP Condition*/
	i2c0->csr = I2C_CR_ACK | I2C_CR_STOP;	
	
}

/**
 * Write a register from a specific slave
 */
void i2c_write_register(uint8_t slaveAddr, uint8_t readAddr, uint8_t data)
{

	/* Send slave address for write */
    i2c0->txrxr = slaveAddr + I2C_TR_W;
    i2c0->csr = I2C_CR_W | I2C_CR_STA;
    
	/* Check TIP bit */
	i2c_check_value((uint8_t) I2C_SR_TIP);

	/* Send the slave's internal address to write to */
    i2c0->txrxr = readAddr;
	i2c0->csr = I2C_CR_W;
	
	/* Check TIP bit */
	i2c_check_value((uint8_t) I2C_SR_TIP);

	/* Send the slave's internal address to write to */
    i2c0->txrxr = data;
	i2c0->csr = I2C_CR_W;
	
	/* Check TIP bit */
	i2c_check_value((uint8_t) I2C_SR_TIP);

	/* Enable STOP Condition*/
	i2c0->csr = I2C_CR_STOP;	
	
}

/*****************************************************************
*SPI Functions
*/
void spi_test()
{
	uart_putstr("Begin SPI Test \n");
	//int i;
	int32_t aux_read;
	spi0->ssr=0;
	for(;;)
	{
	spi0->txr = 0x000AffAB; // Probado en el osciloscopio
	}

	
	//uart_putstr("Begin SPI Test \n");
	//int32_t aux_read;
	//int i; 
	//spi0->txr = 0x4B; //01001011 --> First 01: Read mode ! ---> 1011: Memoria ADXL  
	//Se debe enviar la direccion del registro que quiero leer.. 
	//NO LA DIRECCION DEL ESCLAVO. ESO ES I2C ! 
	//for(i = 0;i<100;i++){}
	//aux_read = spi0->rxr;
	//writeint(aux_read);
	//uart_putstr("\n End SPI Test \n");
		
	/*if(spi0->sr&20)// If TRDY (5 bit of Status register) 
	{
		uart_putstr("al IF \n");
		aux_read = spi0->rxr;
		writeint(aux_read);
	}
	else
	{
		uart_putstr("Else \n");
		aux_read = spi0->rxr;
		writeint(aux_read);
	}
	uart_putstr("End SPI Test \n");	
	*/
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

	// Use timer0.10
	timer0->compare10 = FCPU*msec/1000;
	timer0->counter10 = 0;
	timer0->tcr10 = TIMER_EN;

	do 
	{
		//halt();
 		tcr = timer0->tcr10;
 	} while ( ! (tcr & TIMER_TRIG) );
}

void nsleep(uint32_t nsec)
{
	uint32_t tcr;

	// Use timer0.11
	timer0->compare11 = FCPU*nsec/1000000;
	timer0->counter11 = 0;
	timer0->tcr11 = TIMER_EN;

	do {
		//halt();
 		tcr = timer0->tcr11;
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
	
	isr_register(15, &tic_isr_15);
}

// Set period of PWM
uint32_t set_period() 
{
	return (FCPU/1000)*pwm_p;
}

// Set duty cycle of PWM
uint32_t set_duty(uint32_t percentage) 
{
	return (FCPU/1000/100)*pwm_p*percentage;
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
