#ifndef SPIKEHW_H
#define SPIKEHW_H

#define PROMSTART 0x00000000
#define RAMSTART  0x00000800
#define RAMSIZE   0x400
#define RAMEND    (RAMSTART + RAMSIZE)

#define RAM_START 0x40000000
#define RAM_SIZE  0x04000000

#define FCPU      100000000

#define UART_RXBUFSIZE 32

/****************************************************************************
 * Types
 ****************************************************************************/

typedef unsigned int  uint32_t;    // 32 Bit
typedef signed   int   int32_t;    // 32 Bit

typedef unsigned char  uint8_t;    // 8 Bit
typedef signed   char   int8_t;    // 8 Bit

/****************************************************************************
 * Interrupt handling
 ****************************************************************************/

typedef void(*isr_ptr_t)(void);

void     irq_enable();
void     irq_disable();
void     irq_set_mask(uint32_t mask);
uint32_t irq_get_mak();

void     isr_init();
void     isr_register(int irq, isr_ptr_t isr);
void     isr_unregister(int irq);

/****************************************************************************
 * General Stuff
 ****************************************************************************/
 
void     halt();
void     jump(uint32_t addr);

inline void writeint(uint32_t val);

/****************************************************************************
 * Peripherals
 ****************************************************************************/

/****************************************************************************
 * I2C
 ****************************************************************************/
 
#include "MPU6050.h"

#define I2C_CR_CORE_EN   0x80
#define I2C_CR_CORE_ISR  0x40

#define I2C_TR_R		 0x01
#define I2C_TR_W		 0x00

#define I2C_SR_RACK		 0x80
#define I2C_SR_BUSY		 0x40
#define I2C_SR_AL		 0x20
#define I2C_SR_TIP		 0x02
#define I2C_SR_IF		 0x01

#define I2C_CR_STA		 0x80
#define I2C_CR_STOP		 0x40
#define I2C_CR_R		 0x20
#define I2C_CR_W		 0x10
#define I2C_CR_ACK		 0x08
#define I2C_CR_IACK		 0x01

typedef struct {
   volatile uint8_t prerlo;
   volatile uint8_t prerhi;
   volatile uint8_t ctr;
   volatile uint8_t txrxr;
   volatile uint8_t csr;
} i2c_t;


void i2c_test();
void i2c_core_init(uint8_t prerhi, uint8_t prerlo);
void i2c_check_value(uint8_t value);
void i2c_read_register(uint8_t slaveAddr, uint8_t readAddr, uint8_t* pBuffer);
void i2c_write_register(uint8_t slaveAddr, uint8_t readAddr, uint8_t data);

/****************************************************************************
 * SPI
 ****************************************************************************/

typedef struct {
   volatile uint32_t rxr;
   volatile uint32_t txr;
   volatile uint32_t sr;
   volatile uint32_t cr;
   volatile uint32_t ssr;
} spi_t;

void spi_test();

/****************************************************************************
 * GPIO
 ****************************************************************************/

void gpio_test();
void gpio_output(char output);

typedef struct {
   volatile uint32_t in;
   volatile uint32_t out;
   volatile uint32_t oe;
   volatile uint32_t int_e;
   volatile uint32_t ptrig;
   volatile uint32_t aux;
   volatile uint32_t ctrl;
   volatile uint32_t int_s;
   volatile uint32_t eclk;
   volatile uint32_t nec;
} gpio_t;

/****************************************************************************
 * Timer
 ****************************************************************************/
#define TIMER_EN     0x08    // Enable Timer
#define TIMER_AR     0x04    // Auto-Reload
#define TIMER_IRQEN  0x02    // IRQ Enable
#define TIMER_TRIG   0x01    // Triggered (reset when writing to TCR)

typedef struct {
	volatile uint32_t tcr0;
	volatile uint32_t compare0;
	volatile uint32_t counter0;
	volatile uint32_t tcr1;
	volatile uint32_t compare1;
	volatile uint32_t counter1;
	volatile uint32_t tcr2;
	volatile uint32_t compare2;
	volatile uint32_t counter2;
	volatile uint32_t tcr3;
	volatile uint32_t compare3;
	volatile uint32_t counter3;
	volatile uint32_t tcr4;
	volatile uint32_t compare4;
	volatile uint32_t counter4;
	volatile uint32_t tcr5;
	volatile uint32_t compare5;
	volatile uint32_t counter5;
	volatile uint32_t tcr6;
	volatile uint32_t compare6;
	volatile uint32_t counter6;
	volatile uint32_t tcr7;
	volatile uint32_t compare7;
	volatile uint32_t counter7;
	volatile uint32_t tcr8;
	volatile uint32_t compare8;
	volatile uint32_t counter8;
	volatile uint32_t tcr9;
	volatile uint32_t compare9;
	volatile uint32_t counter9;
	volatile uint32_t tcr10;
	volatile uint32_t compare10;
	volatile uint32_t counter10;
	volatile uint32_t tcr11;
	volatile uint32_t compare11;
	volatile uint32_t counter11;
} timer_t;

void msleep(uint32_t msec);
void nsleep(uint32_t nsec);
uint32_t set_duty(uint32_t percentage);
uint32_t set_period();
void tic_init();

/***************************************************************************
 * UART0
 ****************************************************************************/
#define UART_DR   0x01                    // RX Data Ready
#define UART_ERR  0x02                    // RX Error
#define UART_BUSY 0x10                    // TX Busy

typedef struct {
   volatile uint32_t ucr;
   volatile uint32_t rxtx;
} uart_t;

void uart_init();
void uart_putchar(char c);
void uart_putstr(char *str);
char uart_getchar();


/***************************************************************************
 * Pointer to actual components
 */
  
extern i2c_t   *i2c0;
extern spi_t   *spi0;
extern gpio_t   *gpio0;
extern timer_t   *timer0;
extern uart_t   *uart0;


#endif // SPIKEHW_H
