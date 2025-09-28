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
	//
	static u32 psIncr = 0;
	static u32 plIncr = 0;
	static u32 mioLEDstatus = 0;
	pmod8LDCH jbCH1 = {0};
	pmod8LDCH jbCH2 = {0};
	static u8 randMIN = 0;
	static u8 randMAX = 100;
	static u8 plIncrTrig = 10;
	static u8 plIncrMIN = 10;
	static u8 plIncrMAX = 100;
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
			XGpio_DiscreteWrite(&gpioJB, 1, jbCH1.gpio);
			XGpio_DiscreteWrite(&gpioJB, 2, jbCH2.gpio);
			plIncrTrig = (rand() % (plIncrMAX - plIncrMIN + 1)) + plIncrMIN; 
			plIncr = 0;
		}
		//
		psIncr++;
		plIncr++;
		usleep(1000); // 1 ms
	}
}
