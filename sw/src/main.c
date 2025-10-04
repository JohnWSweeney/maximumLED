#include "xgpiops.h"
#include "xgpio.h"
#include "xparameters.h"
#include "sleep.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef struct{
	XGpio gpioID;
	u16 deviceID;
} gpioDevice;

typedef struct{
	union{
		struct{
			u8 led1;
			u8 led2;
			u8 led3;
			u8 led4;
		} leds;
		u32 led1234;
	} ch1;
	union{
		struct{
			u8 led5;
			u8 led6;
			u8 led7;
			u8 led8;
		} leds;
		u32 led5678;
	} ch2;
} psGPIO;

typedef union {
	u32 gpio;
	struct {
		u8 red;
		u8 green;
		u8 blue;
		u8 idk;
	};
} plRGB;

static inline u8 getRandNum(u8 MIN, u8 MAX){
	return (rand() % (MAX - MIN + 1)) + MIN;
}

int main(void){
	static const u32 mioLED = 7;
	static const u32 mioPmod[8] = {13, 10, 11, 12, 0, 9, 14, 15};

	XGpioPs gpioPS;
	XGpioPs_Config *cfg = XGpioPs_LookupConfig(XPAR_PS7_GPIO_0_DEVICE_ID);
	XGpioPs_CfgInitialize(&gpioPS, cfg, cfg->BaseAddr);
	XGpioPs_SetDirectionPin(&gpioPS, mioLED, 1);
	XGpioPs_SetOutputEnablePin(&gpioPS, mioLED, 1);
	XGpioPs_WritePin(&gpioPS, mioLED, 0);

	// initialize MIO Pmod J4 pins as outputs, set low. Pmod 8LD connected.
	for(int i=0;i<8;i++){
		XGpioPs_SetDirectionPin(&gpioPS, mioPmod[i], 1);
		XGpioPs_SetOutputEnablePin(&gpioPS, mioPmod[i], 1);
		XGpioPs_WritePin(&gpioPS, mioPmod[i], 0);
	}
	// initialize gpios for pmod connectors JA-JE.
	gpioDevice gpio[5] = {0};
	gpio[0].deviceID = XPAR_GPIOJA_DEVICE_ID;
	gpio[1].deviceID = XPAR_GPIOJB_DEVICE_ID;
	gpio[2].deviceID = XPAR_GPIOJC_DEVICE_ID;
	gpio[3].deviceID = XPAR_GPIOJD_DEVICE_ID;
	gpio[4].deviceID = XPAR_GPIOJE_DEVICE_ID;
	
	for(int i=0;i<5;i++){
		XGpio_Initialize(&gpio[i].gpioID, gpio[i].deviceID);
		XGpio_SetDataDirection(&gpio[i].gpioID, 1, 0);
		XGpio_DiscreteWrite(&gpio[i].gpioID, 1, 0);
		XGpio_SetDataDirection(&gpio[i].gpioID, 2, 0);
		XGpio_DiscreteWrite(&gpio[i].gpioID, 2, 0);
	}
	// initialize PL RGB channels 1 & 2.
	XGpio gpioRGB;
	XGpio_Initialize(&gpioRGB, XPAR_RGB_DEVICE_ID);
	XGpio_SetDataDirection(&gpioRGB, 1, 0);
	XGpio_DiscreteWrite(&gpioRGB, 1, 0);
	XGpio_SetDataDirection(&gpioRGB, 2, 0);
	XGpio_DiscreteWrite(&gpioRGB, 2, 0);
	//
	static u32 psIncr = 0;
	static u32 plIncr = 0;
	static u32 mioLEDstatus = 0;
	psGPIO pmod8LD[5] = {0};
	plRGB rgb5 = {0};
	plRGB rgb6 = {0};
	
	static u8 randMIN = 0;
	static u8 randMAX = 100;
	static u8 plIncrTrig = 10;
	static u8 plIncrMIN = 10;
	static u8 plIncrMAX = 100;
	
	static u32 rgbIncr = 0;
	static u8 rgbRRandMIN = 1;
	static u8 rgbRRandMAX = 10;
	static u8 rgbBRandMIN = 1;
	static u8 rgbBRandMAX = 10;
	static u8 rgbIncrTrig = 10;
	static u8 rgbIncrMIN = 10;
	static u8 rgbIncrMAX = 200;
	
	srand(666);
	printf("entering while loop.\n");

	while(1){
		if(psIncr==500){
			mioLEDstatus ^= 1;
			XGpioPs_WritePin(&gpioPS, mioLED, mioLEDstatus);
			psIncr = 0;
		}
		//
		if(plIncr==plIncrTrig){
			for(int i=0;i<5;i++){
				pmod8LD[i].ch1.leds.led1 = getRandNum(randMIN, randMAX);
				pmod8LD[i].ch1.leds.led2 = getRandNum(randMIN, randMAX);
				pmod8LD[i].ch1.leds.led3 = getRandNum(randMIN, randMAX);
				pmod8LD[i].ch1.leds.led4 = getRandNum(randMIN, randMAX);
				pmod8LD[i].ch2.leds.led5 = getRandNum(randMIN, randMAX);
				pmod8LD[i].ch2.leds.led6 = getRandNum(randMIN, randMAX);
				pmod8LD[i].ch2.leds.led7 = getRandNum(randMIN, randMAX);
				pmod8LD[i].ch2.leds.led8 = getRandNum(randMIN, randMAX);
				XGpio_DiscreteWrite(&gpio[i].gpioID, 1, pmod8LD[i].ch1.led1234);
				XGpio_DiscreteWrite(&gpio[i].gpioID, 2, pmod8LD[i].ch2.led5678);
			}
			plIncrTrig = getRandNum(plIncrMIN, plIncrMAX);
			plIncr = 0;
		}
		//
		if(rgbIncr==rgbIncrTrig){
			rgb5.red = 0;
			rgb5.green = 0;
			rgb5.blue = getRandNum(rgbBRandMIN, rgbBRandMAX);
			XGpio_DiscreteWrite(&gpioRGB, 1, rgb5.gpio);
			//
			rgb6.red = getRandNum(rgbRRandMIN, rgbRRandMAX);
			rgb6.green = 0;
			rgb6.blue = 0;
			XGpio_DiscreteWrite(&gpioRGB, 2, rgb6.gpio);
			//
			rgbIncrTrig = getRandNum(rgbIncrMIN, rgbIncrMAX);
			rgbIncr = 0;
		}
		//
		psIncr++;
		plIncr++;
		rgbIncr++;
		usleep(1000); // 1 ms
	}
}
