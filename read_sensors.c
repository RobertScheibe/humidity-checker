#include <wiringPi.h>  
#include <stdio.h>  
#include <stdlib.h>  
#include <stdint.h>  
#include <math.h>  
#define MAXTIMINGS 85  
int dht22_dat[5]={0,0,0,0,0};  

float tumgebung=0;
float twall=0;
float ttaupunkt=0;
float luftfeuchtigkeit=0;

static uint8_t sizecvt(const int read)
{
	/* digitalRead() and friends from wiringpi are defined as returning a value
	   < 256. However, they are returned as int() types. This is a safety function */

	if (read > 255 || read < 0)
	{
		printf("Invalid data from wiringPi library\n");
		exit(EXIT_FAILURE);
	}
	return (uint8_t)read;
}

//nach http://www.wetterochs.de/wetter/feuchte.html
double taupunkt(float t, float h) {

	double sdd = 6.1078 * pow(10 ,((7.5*t)/(237.3+t)));
	double dd = h/100 * sdd;
	double v = log10(dd/6.1078);
	double td = 237.3 * v / (7.5-v);
	return td;
}

int dht11_read_val(int pin)  
{  
	uint8_t laststate = HIGH;
	uint8_t counter = 0;
	uint8_t j = 0, i;

	dht22_dat[0] = dht22_dat[1] = dht22_dat[2] = dht22_dat[3] = dht22_dat[4] = 0;

	// pull pin down for 18 milliseconds
	pinMode(pin, OUTPUT);
	digitalWrite(pin, HIGH);
	delay(10);
	digitalWrite(pin, LOW);
	delay(18);
	// then pull it up for 40 microseconds
	digitalWrite(pin, HIGH);
	delayMicroseconds(40); 
	// prepare to read the pin
	pinMode(pin, INPUT);

	// detect change and read data
	for ( i=0; i< MAXTIMINGS; i++) {
		counter = 0;
		while (sizecvt(digitalRead(pin)) == laststate) {
			counter++;
			delayMicroseconds(1);
			if (counter == 255) {
				break;
			}
		}
		laststate = sizecvt(digitalRead(pin));

		if (counter == 255) break;

		// ignore first 3 transitions
		if ((i >= 4) && (i%2 == 0)) {
			// shove each bit into the storage bytes
			dht22_dat[j/8] <<= 1;
			if (counter > 16)
				dht22_dat[j/8] |= 1;
			j++;
		}
	}

	// check we read 40 bits (8bit x 5 ) + verify checksum in the last byte
	// print it out if data is good
	if ((j >= 40) && 
			(dht22_dat[4] == ((dht22_dat[0] + dht22_dat[1] + dht22_dat[2] + dht22_dat[3]) & 0xFF)) ) {
		float t, h;
		h = (float)dht22_dat[0] * 256 + (float)dht22_dat[1];
		h /= 10;
		t = (float)(dht22_dat[2] & 0x7F)* 256 + (float)dht22_dat[3];
		t /= 10.0;
		if ((dht22_dat[2] & 0x80) != 0)  t *= -1;

		//for safety reasons
		if (twall < -100 || t < -100 )
			return 0;

		if (pin == 7) {
			tumgebung=t;
			luftfeuchtigkeit=h;
			ttaupunkt=taupunkt(t, h);
			//printf("Umgebung: Humidity = %.2f %% Temperature = %.2f *C Taupunkt = %.2f *C | ", pin, h, t, taupunkt(t, h) );
			printf("T %.2f H %.2f TD %.2f ", t, h, taupunkt(t, h));
		} else  {
			twall=t;
			//printf("Wand: Humidity = %.2f %% Temperature = %.2f *C Taupunkt = %.2f *C | ", pin, h, t, taupunkt(t, h) );
			printf ("TW %.2f ", t);
		}

		return 1;
	}
	else
	{
		return 0;
	}
}
int main(void)  
{  
	if(wiringPiSetup()==-1)  
		exit(1);  

	while(dht11_read_val(7)==0);  
	while(dht11_read_val(0)==0);  
	return 0; 
}
