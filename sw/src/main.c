#include "xgpiops.h"
#include "xgpio.h"
#include "xparameters.h"
#include "sleep.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef union {
	u32 gpio;
	struct {
		u8 led1;
		u8 led2;
		u8 led3;
		u8 led4;
	};
} pmod8LDCH;

typedef union {
	u32 gpio;
	struct {
		u8 red;
		u8 green;
		u8 blue;
		u8 idk;
	};
} plRGB;

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
	// initialize gpioJB channels 1 & 2.
	XGpio gpioJB;
	XGpio_Initialize(&gpioJB, XPAR_GPIOJB_DEVICE_ID);
	XGpio_SetDataDirection(&gpioJB, 1, 0);
	XGpio_DiscreteWrite(&gpioJB, 1, 0);
	XGpio_SetDataDirection(&gpioJB, 2, 0);
	XGpio_DiscreteWrite(&gpioJB, 2, 0);
	// initialize gpioJC channels 1 & 2.
	XGpio gpioJC;
	XGpio_Initialize(&gpioJC, XPAR_GPIOJC_DEVICE_ID);
	XGpio_SetDataDirection(&gpioJC, 1, 0);
	XGpio_DiscreteWrite(&gpioJC, 1, 0);
	XGpio_SetDataDirection(&gpioJC, 2, 0);
	XGpio_DiscreteWrite(&gpioJC, 2, 0);
	// initialize gpioJD channels 1 & 2.
	XGpio gpioJD;
	XGpio_Initialize(&gpioJD, XPAR_GPIOJD_DEVICE_ID);
	XGpio_SetDataDirection(&gpioJD, 1, 0);
	XGpio_DiscreteWrite(&gpioJD, 1, 0);
	XGpio_SetDataDirection(&gpioJD, 2, 0);
	XGpio_DiscreteWrite(&gpioJD, 2, 0);
	// initialize gpioJD channels 1 & 2.
	XGpio gpioJE;
	XGpio_Initialize(&gpioJE, XPAR_GPIOJE_DEVICE_ID);
	XGpio_SetDataDirection(&gpioJE, 1, 0);
	XGpio_DiscreteWrite(&gpioJE, 1, 0);
	XGpio_SetDataDirection(&gpioJE, 2, 0);
	XGpio_DiscreteWrite(&gpioJE, 2, 0);
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
	pmod8LDCH jbCH1 = {0};
	pmod8LDCH jbCH2 = {0};
	pmod8LDCH jcCH1 = {0};
	pmod8LDCH jcCH2 = {0};
	pmod8LDCH jdCH1 = {0};
	pmod8LDCH jdCH2 = {0};
	pmod8LDCH jeCH1 = {0};
	pmod8LDCH jeCH2 = {0};
	
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
			jbCH1.led1 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jbCH1.led2 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jbCH1.led3 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jbCH1.led4 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jbCH2.led1 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jbCH2.led2 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jbCH2.led3 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jbCH2.led4 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			//
			jcCH1.led1 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jcCH1.led2 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jcCH1.led3 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jcCH1.led4 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jcCH2.led1 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jcCH2.led2 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jcCH2.led3 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jcCH2.led4 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			//
			jdCH1.led1 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jdCH1.led2 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jdCH1.led3 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jdCH1.led4 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jdCH2.led1 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jdCH2.led2 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jdCH2.led3 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jdCH2.led4 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			//
			jeCH1.led1 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jeCH1.led2 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jeCH1.led3 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jeCH1.led4 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jeCH2.led1 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jeCH2.led2 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jeCH2.led3 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			jeCH2.led4 = (rand() % (randMAX - randMIN + 1)) + randMIN;
			//
			XGpio_DiscreteWrite(&gpioJB, 1, jbCH1.gpio);
			XGpio_DiscreteWrite(&gpioJB, 2, jbCH2.gpio);
			XGpio_DiscreteWrite(&gpioJC, 1, jcCH1.gpio);
			XGpio_DiscreteWrite(&gpioJC, 2, jcCH2.gpio);			
			XGpio_DiscreteWrite(&gpioJD, 1, jdCH1.gpio);
			XGpio_DiscreteWrite(&gpioJD, 2, jdCH2.gpio);			
			XGpio_DiscreteWrite(&gpioJE, 1, jeCH1.gpio);
			XGpio_DiscreteWrite(&gpioJE, 2, jeCH2.gpio);
			plIncrTrig = (rand() % (plIncrMAX - plIncrMIN + 1)) + plIncrMIN; 
			plIncr = 0;
		}
		//
		if(rgbIncr==rgbIncrTrig){
			rgb5.red = 0;
			rgb5.green = 0;
			rgb5.blue = (rand() % (rgbBRandMAX - rgbBRandMIN + 1)) + rgbBRandMIN;
			XGpio_DiscreteWrite(&gpioRGB, 1, rgb5.gpio);
			//
			static u8 rando;
			rando = (rand() % (rgbRRandMAX - rgbRRandMIN + 1)) + rgbRRandMIN;
			rgb6.red = rando;
			rgb6.green = 0;
			rgb6.blue = 0;
			XGpio_DiscreteWrite(&gpioRGB, 2, rgb6.gpio);
			//
			rgbIncrTrig = (rand() % (rgbIncrMAX - rgbIncrMIN + 1)) + rgbIncrMIN; 
			rgbIncr = 0;
		}
		//
		psIncr++;
		plIncr++;
		rgbIncr++;
		usleep(1000); // 1 ms
	}
}
