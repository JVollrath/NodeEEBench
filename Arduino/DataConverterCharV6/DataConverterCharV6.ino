#include <LiquidCrystal.h>

/*
  Target board Arduino MKR WIFI 1010
  This sketch generates a sine signal with 
     DAC: DAC0, AIN[0], PA02, A0, D15
     PWL: AIN[7],PA07,A6,D21
     Digital: PA22,23,10,11,PB10,11,PA20, PA21
     PMOD DA2 Digilent
  This sketch samples:
    OSC1: AIN[10], PB02, A1, D16 
    OSC2: AIN[11], PB03, A2, D17
    OSC3: AIN[4], PA04, A3, D18 
    OSC4: AIN[5], PA05, A4, D19  
    OSC5: PMOD AD2 Digilent
  Transfers 16k values to serial port.
      
  This example code is in the public domain.

  Written 9 Sep 2020 by Joerg Vollrath
*/
#include <SPI.h> // Include library
#include <Wire.h> // call library
#define AD7991_Adresse 0x28 // I2C adress of the Pmod AD2 module

#define DAC          A0
#define CS A6           // CS pin for PMOD DA2 I2C, 8: MOSI, 9:SCK

#define DAC_D0          0
#define DAC_D1          1
#define DAC_D2          2
#define DAC_D3          3
#define DAC_D4          4
#define DAC_D5          5
#define DAC_D6          6
#define DAC_D7          13

/* C serial  */
#define DAC_INH          0
#define DAC_C12          1
#define DAC_Dx           2
#define DAC_C3           3
/* C serial end */

#define DAC_PWM          7

#define ADC_OSC1          A1
#define ADC_OSC2          A2
#define ADC_OSC3          A3
#define ADC_OSC4          A4
#define ADC_FREQ          A5


// Sine wave lookup table 0..255 Sinbe.xlsx
/* One period in 256 steps */
/* displayInt = pgm_read_word_near(sineWave + k);  */
const uint16_t sineWave[] = { 

 /* Ramp 512 values 15-bit no overflow */

0,128,256,384,512,640,768,896,1024,1152,1280,1408,1536,1664,1792,1920,
2048,2176,2304,2432,2560,2688,2816,2944,3072,3200,3328,3456,3584,3712,3840,3968,
4096,4224,4352,4480,4608,4736,4864,4992,5120,5248,5376,5504,5632,5760,5888,6016,
6144,6272,6400,6528,6656,6784,6912,7040,7168,7296,7424,7552,7680,7808,7936,8064,
8192,8320,8448,8576,8704,8832,8960,9088,9216,9344,9472,9600,9728,9856,9984,10112,
10240,10368,10496,10624,10752,10880,11008,11136,11264,11392,11520,11648,11776,11904,12032,12160,
12288,12416,12544,12672,12800,12928,13056,13184,13312,13440,13568,13696,13824,13952,14080,14208,
14336,14464,14592,14720,14848,14976,15104,15232,15360,15488,15616,15744,15872,16000,16128,16256,
16384,16512,16640,16768,16896,17024,17152,17280,17408,17536,17664,17792,17920,18048,18176,18304,
18432,18560,18688,18816,18944,19072,19200,19328,19456,19584,19712,19840,19968,20096,20224,20352,
20480,20608,20736,20864,20992,21120,21248,21376,21504,21632,21760,21888,22016,22144,22272,22400,
22528,22656,22784,22912,23040,23168,23296,23424,23552,23680,23808,23936,24064,24192,24320,24448,
24576,24704,24832,24960,25088,25216,25344,25472,25600,25728,25856,25984,26112,26240,26368,26496,
26624,26752,26880,27008,27136,27264,27392,27520,27648,27776,27904,28032,28160,28288,28416,28544,
28672,28800,28928,29056,29184,29312,29440,29568,29696,29824,29952,30080,30208,30336,30464,30592,
30720,30848,30976,31104,31232,31360,31488,31616,31744,31872,32000,32128,32256,32384,32512,32640,
32767,32639,32511,32383,32255,32127,31999,31871,31743,31615,31487,31359,31231,31103,30975,30847,
30719,30591,30463,30335,30207,30079,29951,29823,29695,29567,29439,29311,29183,29055,28927,28799,
28671,28543,28415,28287,28159,28031,27903,27775,27647,27519,27391,27263,27135,27007,26879,26751,
26623,26495,26367,26239,26111,25983,25855,25727,25599,25471,25343,25215,25087,24959,24831,24703,
24575,24447,24319,24191,24063,23935,23807,23679,23551,23423,23295,23167,23039,22911,22783,22655,
22527,22399,22271,22143,22015,21887,21759,21631,21503,21375,21247,21119,20991,20863,20735,20607,
20479,20351,20223,20095,19967,19839,19711,19583,19455,19327,19199,19071,18943,18815,18687,18559,
18431,18303,18175,18047,17919,17791,17663,17535,17407,17279,17151,17023,16895,16767,16639,16511,
16383,16255,16127,15999,15871,15743,15615,15487,15359,15231,15103,14975,14847,14719,14591,14463,
14335,14207,14079,13951,13823,13695,13567,13439,13311,13183,13055,12927,12799,12671,12543,12415,
12287,12159,12031,11903,11775,11647,11519,11391,11263,11135,11007,10879,10751,10623,10495,10367,
10239,10111,9983,9855,9727,9599,9471,9343,9215,9087,8959,8831,8703,8575,8447,8319,
8191,8063,7935,7807,7679,7551,7423,7295,7167,7039,6911,6783,6655,6527,6399,6271,
6143,6015,5887,5759,5631,5503,5375,5247,5119,4991,4863,4735,4607,4479,4351,4223,
4095,3967,3839,3711,3583,3455,3327,3199,3071,2943,2815,2687,2559,2431,2303,2175,
2047,1919,1791,1663,1535,1407,1279,1151,1023,895,767,639,511,383,255,127,
0,
     
// Sine start index 513
16384,16786,17187,17589,17989,18389,18787,19184,19580,19973,20364,20753,21139,21523,21903,22280,
22653,23023,23388,23750,24107,24459,24806,25149,25486,25817,26143,26463,26777,27085,27386,27681,
27968,28249,28523,28789,29048,29299,29543,29778,30006,30225,30436,30639,30832,31018,31194,31361,
31520,31669,31809,31940,32062,32174,32276,32369,32452,32526,32590,32644,32688,32723,32747,32762,
32767,32762,32747,32723,32688,32644,32590,32526,32452,32369,32276,32174,32062,31940,31809,31669,
31520,31361,31194,31018,30832,30639,30436,30225,30006,29778,29543,29299,29048,28789,28523,28249,
27968,27681,27386,27085,26777,26463,26143,25817,25486,25149,24806,24459,24107,23750,23388,23023,
22653,22280,21903,21523,21139,20753,20364,19973,19580,19184,18787,18389,17989,17589,17187,16786,
16384,15981,15580,15178,14778,14378,13980,13583,13187,12794,12403,12014,11628,11244,10864,10487,
10114,9744,9379,9017,8660,8308,7961,7618,7281,6950,6624,6304,5990,5682,5381,5086,
4799,4518,4244,3978,3719,3468,3224,2989,2761,2542,2331,2128,1935,1749,1573,1406,
1247,1098,958,827,705,593,491,398,315,241,177,123,79,44,20,5,
0,5,20,44,79,123,177,241,315,398,491,593,705,827,958,1098,
1247,1406,1573,1749,1935,2128,2331,2542,2761,2989,3224,3468,3719,3978,4244,4518,
4799,5086,5381,5682,5990,6304,6624,6950,7281,7618,7961,8308,8660,9017,9379,9744,
10114,10487,10864,11244,11628,12014,12403,12794,13187,13583,13980,14378,14778,15178,15580,15981,
16383,16786,17187,17589,17989,18389,18787,19184,19580,19973,20364,20753,21139,21523,21903,22280,
22653,23023,23388,23750,24107,24459,24806,25149,25486,25817,26143,26463,26777,27085,27386,27681,
27968,28249,28523,28789,29048,29299,29543,29778,30006,30225,30436,30639,30832,31018,31194,31361,
31520,31669,31809,31940,32062,32174,32276,32369,32452,32526,32590,32644,32688,32723,32747,32762,
32767,32762,32747,32723,32688,32644,32590,32526,32452,32369,32276,32174,32062,31940,31809,31669,
31520,31361,31194,31018,30832,30639,30436,30225,30006,29778,29543,29299,29048,28789,28523,28249,
27968,27681,27386,27085,26777,26463,26143,25817,25486,25149,24806,24459,24107,23750,23388,23023,
22653,22280,21903,21523,21139,20753,20364,19973,19580,19184,18787,18389,17989,17589,17187,16786,
16384,15981,15580,15178,14778,14378,13980,13583,13187,12794,12403,12014,11628,11244,10864,10487,
10114,9744,9379,9017,8660,8308,7961,7618,7281,6950,6624,6304,5990,5682,5381,5086,
4799,4518,4244,3978,3719,3468,3224,2989,2761,2542,2331,2128,1935,1749,1573,1406,
1247,1098,958,827,705,593,491,398,315,241,177,123,79,44,20,5,
0,5,20,44,79,123,177,241,315,398,491,593,705,827,958,1098,
1247,1406,1573,1749,1935,2128,2331,2542,2761,2989,3224,3468,3719,3978,4244,4518,
4799,5086,5381,5682,5990,6304,6624,6950,7281,7618,7961,8308,8660,9017,9379,9744,
10114,10487,10864,11244,11628,12014,12403,12794,13187,13583,13980,14378,14778,15178,15580,15981,
16383
};
uint16_t lookup8[] = {
  0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,
  32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,
  64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,
  96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,
  128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,
  160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,
  192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,
  224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255 
};
uint16_t bCal[] = {0,0,0,0,0,0,0,0,0,0,0,0};

  //  uint16_t osc[10*1024] ;
    
    uint16_t bitsX[] = {1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768};
    uint16_t sineX =0;

    int baseFreq = 0;        // ramp or sine
    int nPeriod = 1;         // number of sine periods
    int oscConfig = 1;       // serial data output 
        // oscConfig  4     3   2        1 
        // operation  OSC1  AD2 AD2,OSC1 AD2,OSC1,OSC2,OSC3,OSC4
    /*   oscConfig 
     *    1     2k 4 channels, PMODAD2, Arduino 1,2,3  
     *    2     4k 2 channels: PMODA AD2 and Arduino channel 1 
     *    3    8k Arduino ADC channel1 
     *    4    8k PMOD AD2
     */
    int bufSize = 2048 * 8;   // 
    int range = 4096;         // range for output value

  char myData[20];        // incoming string
  char myVal[20];        // incoming Value 256 * 4 digits 
  char testVal[2];        // One digit 
  char inChar;
  int posChar = 0;
  int startCmd = -1;     // position of start Cmd
  uint16_t freq = 150;
  int dacType[8] = {0,0,0,0,0,0,0,0};       // osc1, osc2, osc3, osc4, awg10, awg11, awg20, awg22 

void setup() {
  // put your setup code here, to run once:
  pinMode(DAC_D0, OUTPUT);
  pinMode(DAC_D1, OUTPUT);
  pinMode(DAC_D2, OUTPUT);
  pinMode(DAC_D3, OUTPUT);
  pinMode(DAC_D4, OUTPUT);
  pinMode(DAC_D5, OUTPUT);
  pinMode(DAC_D6, OUTPUT);
  pinMode(DAC_D7, OUTPUT);
 
 // initialize serial communication at 115200
 Serial.begin(115200);
 Serial.println("\r\nData Converter Sine Test");

 myData[0] = 0;
 
 // ADC PMOD AD2
  Wire.begin(); // initialization of I2C communication
 Init_AD7991(); // initialisation du module Pmod AD2

 // DAC PMOD DA2
 SPI.begin(); // initialization of SPI port
 SPI.setDataMode(SPI_MODE3); // configuration of SPI communication in mode 3
 SPI.setClockDivider(SPI_CLOCK_DIV16); // configuration of clock at 1MHz
 pinMode(CS, OUTPUT);

/*  C serial control lines */
    pinMode(DAC_INH, OUTPUT);
    pinMode(DAC_C12, OUTPUT);
    pinMode(DAC_Dx, OUTPUT);
    pinMode(DAC_C3, OUTPUT);

 if (dacType[4] == 1) {
    digitalWrite(DAC_INH, LOW); // INH low activates switches
    digitalWrite(DAC_C12, LOW); // CLK12 coonnects Dx with C3
    digitalWrite(DAC_Dx, LOW); // Data line low
    digitalWrite(DAC_C3, HIGH); // output disconnected from Voutx1
 }

 // Initialize osc
 //    for (int i = 0; i < 16*1024; i++) {
 //   osc[i] = 0;
 //  }
}

void writeDAC(uint16_t sineValue){ // 0..32k 15 bit to 12 bit
 int upper_value = (sineValue>>8)&0XFF;   // order high get 4 high bits order
 int lower_value = (sineValue)&0XFF; // order low get 8 low bits order

 digitalWrite(CS, LOW); // activation of the CS line
 SPI.transfer(upper_value); // Send order
 SPI.transfer(lower_value);
 //delay(5);
 digitalWrite(CS, HIGH); // deactivation of CS line
}

uint16_t interpolate(uint16_t sineValue1, uint16_t sineValue2, int steps, int n){ // Interpolation
 uint16_t sineValue;
 if (sineValue1 > sineValue2) {
    sineValue = (sineValue1 - sineValue2)/steps * (steps - n) + sineValue2; 
 } else {
    sineValue = (sineValue2 - sineValue1)/steps * n + sineValue1;   
 }
 return sineValue;   
}

void digWrite(uint16_t sineValue){
  if ((sineValue & bitsX[0]) == bitsX[0] ) {
    digitalWrite(DAC_D0, HIGH);
  } else {
    digitalWrite(DAC_D0, LOW);    
  }
  if ((sineValue & bitsX[1]) == bitsX[1] ) {
    digitalWrite(DAC_D1, HIGH);
  } else {
    digitalWrite(DAC_D1, LOW);    
  }
  if ((sineValue & bitsX[2]) == bitsX[2] ) {
    digitalWrite(DAC_D2, HIGH);
  } else {
    digitalWrite(DAC_D2, LOW);    
  }
  if ((sineValue & bitsX[3]) == bitsX[3] ) {
    digitalWrite(DAC_D3, HIGH);
  } else {
    digitalWrite(DAC_D3, LOW);    
  }
  if ((sineValue & bitsX[4]) == bitsX[4] ) {
    digitalWrite(DAC_D4, HIGH);
  } else {
    digitalWrite(DAC_D4, LOW);    
  }
  if ((sineValue & bitsX[5]) == bitsX[5] ) {
    digitalWrite(DAC_D5, HIGH);
  } else {
    digitalWrite(DAC_D5, LOW);    
  }
  if ((sineValue & bitsX[6]) == bitsX[6] ) {
    digitalWrite(DAC_D6, HIGH);
  } else {
    digitalWrite(DAC_D6, LOW);    
  }
  if ((sineValue & bitsX[7]) == bitsX[7] ) {
    digitalWrite(DAC_D7, HIGH);
  } else {
    digitalWrite(DAC_D7, LOW);    
  }
  
}


/* C serial digital write */
int activeS   =      80; // 1 tested Time switches are closed for charge redistribution 1 makes 30/2048 error at 10 pF 
int nBits = 13;     // number of send bits
void digWriteS(uint16_t sineValue){

  digitalWrite(DAC_C12, LOW);
  digitalWrite(DAC_C3, HIGH);
  digitalWrite(DAC_Dx, LOW);
  delayMicroseconds(activeS*5);
  // write zero
  for (int i3 = 0; i3 < nBits; i3++) {
        digitalWrite(DAC_C12, HIGH);    
        delayMicroseconds(activeS*5);   
        digitalWrite(DAC_C12, LOW);    
        delayMicroseconds(activeS*5);   
  }   
    // shift nBits bits in  18ms??
  for (int i3 = 0; i3 < nBits; i3++) {
     if ((sineValue & bitsX[i3]) == bitsX[i3] ) {
        digitalWrite(DAC_Dx, HIGH);
     } else {
        digitalWrite(DAC_Dx, LOW);    
     }
     digitalWrite(DAC_C12, HIGH);    
     delayMicroseconds(activeS*5);   
     digitalWrite(DAC_C12, LOW);         
     delayMicroseconds(activeS*5);   
  }  
  // transfer to output
  digitalWrite(DAC_C3, LOW);
  delayMicroseconds(activeS*5);
  digitalWrite(DAC_C3, HIGH);
   
}

int repeatX = 1; // Make multiple measurements and average 

void loop() {
  // put your main code here, to run repeatedly:
  uint16_t sine15 = 0;
  uint16_t sine12 = 0;
  uint16_t sine8 = 0;
  int bufIndex = 0;
  uint16_t oscX = 0;
  int indexL = 0;
  
        // oscConfig  4     3   2        1 
        // operation  OSC1  AD2 AD2,OSC1 AD2,OSC1,OSC2,OSC3,OSC4

  if (Serial.available() > 0) {
      // get incoming byte:
      while (Serial.available() > 0) {
        inChar = Serial.read();
        myData[posChar] = inChar; // Add character
        posChar++;
        myData[posChar] = 0; // New end
        if ((posChar > 18) || (inChar == '_') || (inChar == ',') ) { // end of command or comma
          if (startCmd > -1) {  // probably end of command
             if (myData[startCmd] == 'f') { // frequency command
               for (int i3 = 0 ; i3 < posChar - 2 - startCmd; i3++) { // copy string
                 myVal[i3] = myData[i3+startCmd + 1];
               }
               myVal[posChar - 2 -startCmd] = 0; // end of string
               freq = atol(myVal);
               Serial.print("f value: ");
               Serial.println(freq);
             } if (myData[startCmd] == 'r') {  // range
               for (int i3 = 0 ; i3 < posChar - 2 - startCmd; i3++) { // copy string
                 myVal[i3] = myData[i3+startCmd + 1];
               }
               myVal[posChar - 2 -startCmd] = 0; // end of string
               range = atol(myVal);
               Serial.print("range value: ");
               Serial.println(range);
             } if (myData[startCmd] == 'a') {  // averaging
               for (int i3 = 0 ; i3 < posChar - 2 - startCmd; i3++) { // copy string
                 myVal[i3] = myData[i3+startCmd + 1];
               }
               myVal[posChar - 2 -startCmd] = 0; // end of string
               repeatX = atol(myVal);
               Serial.print("Averaging value: ");
               Serial.println(range);
             } if (myData[startCmd] == 'c') {  // Configuration
               for (int i3 = 0 ; i3 < posChar - 2 - startCmd; i3++) { // copy string
                 myVal[i3] = myData[i3+startCmd + 1];
               }
               myVal[posChar - 2 -startCmd] = 0; // end of string
               for (int i3 = 0 ; i3 < 8; i3++) { // copy into channels
                 testVal[0] = myVal[i3]; testVal[1] = 0;
                 dacType[i3] = atol(testVal);
               }
                if (dacType[4] == 1) {digitalWrite(DAC_INH, LOW);} // INH low activates switches
               Serial.print("configuration: ");
               Serial.println(range);
             } if (myData[startCmd] == 'b') {  // get binary correct table
               for (int i3 = 0 ; i3 < posChar - 2 - startCmd; i3++) { // copy string
                 myVal[i3] = myData[i3+startCmd + 1];
               }
               myVal[posChar - 2 -startCmd] = 0; // end of string with 
               posChar = startCmd+1;     // 
               bCal[indexL] = atol(myVal);
               indexL += 1;
               Serial.print(indexL);
               Serial.print(", ");
               Serial.println(atol(myVal));
             } if (myData[startCmd] == 't') {  // get lookup table 256 comma separated values
               for (int i3 = 0 ; i3 < posChar - 2 - startCmd; i3++) { // copy string
                 myVal[i3] = myData[i3+startCmd + 1];
               }
               myVal[posChar - 2 -startCmd] = 0; // end of string with 
               posChar = startCmd+1;     // 
               lookup8[indexL] = atol(myVal);
               indexL += 1;
               Serial.print(indexL);
               Serial.print(", ");
               Serial.println(atol(myVal));
             }
             if (inChar == '_') { // if really end of command
               posChar = 0;     // clear command buffer
               myData[0] = 0;
               startCmd = -1;
               indexL = 0;      // lookup table command finished
             }  
          } else {               // start of command
            startCmd = posChar;  //
          }
       }
     }   
  }  


    // uint16_t freq = analogRead(ADC_FREQ);
    /* No Potentiometer read, but set freq  */
    // Sine frequency nPeriod: 1, 3, 11, 31, 101, 301, 1001, 4001 
    // freq 100  300   500    700     900 
    // op   ramp 1sine 11sine 101sine 1001sine
    // freq = 900;
    if (freq <100) {
       baseFreq = -1;          // rectangle
       nPeriod = 2;  
    } else if (freq < 200) {
       baseFreq = 0;          // ramp
       nPeriod = 2;  
    } else  if (freq < 400) { // sine 1 period
       baseFreq = 513;
       nPeriod = 1;
    } else if (freq < 600) {
       baseFreq = 513;
       nPeriod = 11;
    } else if (freq < 800) {
       baseFreq = 513;
       nPeriod = 101;
    } else if (freq < 950) {
       baseFreq = 513;
       nPeriod = 1001;
    } else if (freq < 1001) {
       baseFreq = 513;
       nPeriod = 1001;
    } else {
       baseFreq = 513;
       nPeriod = freq - 1000;
    }

    for (int i2 = 0; i2 < 1; i2++) { // Four times new block
        Serial.print("New block: ");
        Serial.println(i2);
        Serial.print("Number of periods: ");
        Serial.println(nPeriod);
      for (int i1 = 0; i1 < bufSize; i1 += 1) { // bufSize Number of values 12-bit * 4 = 16k
       if (Serial.available() == 0) { // no new command
        Serial.print(i2);
        Serial.print(",");
        if (bufIndex >= bufSize) { bufIndex = bufIndex - bufSize; } // Size of lookup table
               
        if (baseFreq == 0) {                                 // Ramp
          if (bufIndex >= bufSize / 2 ) {
             sine12 = (bufSize - bufIndex -1) / 2;
          } else {
             sine12 = bufIndex / 2;
          }
        } else if (baseFreq == -1) {                                 // Square 12 Bit
          if (bufIndex >= bufSize / 2 ) {
             sine12 = 0;
          } else {
             sine12 = range-1;
          }
        } else {
          sine12 = (int) ((range -1)  * (1 + sin( TWO_PI * bufIndex / bufSize)) / 2);
        }
        sine8 = (sine12>>4)&0XFF;
        sine8 = lookup8[sine8];
        
          // writing Analog
          analogWrite(DAC, sine8 );
          // writing PWM
          analogWrite(DAC_PWM, sine8);
          // writing digital  
          writeDAC(sine12);          
          // if (dacType[4] == 1) {
          //  digWriteS(sine12);
          //} else {
          //  digWrite(sine8);       
          //}
          Serial.print(i1);             // print index
          if (baseFreq == -1) {           // print waveform type
            Serial.print(" , Rectangle = ");  
          } else if (baseFreq == 0) {           // print waveform type
            Serial.print(" , Ramp = ");  
          } else {
            Serial.print(" , Sine");
            Serial.print(nPeriod);
            Serial.print(" =");
          }
        Serial.print(sine12);
        // reading analog 
        // oscConfig  4     3   2        1 
        // operation  OSC1  AD2 AD2,OSC1 AD2,OSC1,OSC2,OSC3,OSC4
        if (oscConfig == 4) { // 16k samples Arduino ADC_OSC1
           oscX = analogRead(ADC_OSC1);
           Serial.print(" , ADC(OSC1) = ");
           Serial.print(oscX);
        } else if (oscConfig == 3) { // 16k samples PMOD AD2 
           oscX = readADC();
           Serial.print(" , ADC(AD2) = ");
           Serial.print(oscX);
        } else if (oscConfig == 2) { // 8k samples ADC_OSC1, PMOD AD2 
           oscX = readADC();
           Serial.print(" , ADC(AD2) = ");
           Serial.print(oscX);
           oscX = analogRead(ADC_OSC1);
           Serial.print(" , ADC(OSC1) = ");
           Serial.print(oscX);
        } else if (oscConfig == 1) { // 4k samples ADC_OSC1, ADC_OSC2, ADC:OSC3, PMOD AD2 
           uint16_t oscX1 = 0;
           for (int ii = 0; ii< repeatX; ii++) {
               if (dacType[4] == 1) {
                 digWriteS(sine12);
               } else {
                 digWrite(sine8);       
               }
               oscX1 += readADC();
           }
           oscX = oscX1/repeatX;
           Serial.print(" , ADC(AD2) = ");
           Serial.print(oscX);
           oscX = analogRead(ADC_OSC1);
           Serial.print(" , ADC(OSC1) = ");
           Serial.print(oscX);
           oscX = analogRead(ADC_OSC2);
           Serial.print(" , ADC(OSC2) = ");
           Serial.print(oscX);
           oscX = analogRead(ADC_OSC3);
           Serial.print(" , ADC(OSC3) = ");
           Serial.print(oscX);
           oscX = analogRead(ADC_OSC4);
           Serial.print(" , ADC(OSC4) = ");
           Serial.print(oscX);
        }
        Serial.println();
        bufIndex = bufIndex + nPeriod;
      }
     }
    }

    
    delay(2);

}

int readADC(void){
  // ADC Variables
  int MSB;
  int LSB;
  int valeur;
    Wire.beginTransmission(AD7991_Adresse); // Launch of the measure
    Wire.endTransmission();
    // delay(10);
    Wire.requestFrom(AD7991_Adresse, 2); // Recovery of the two bytes MSB and LSB
    if(Wire.available() <=2)
    {
      MSB = Wire.read();
      LSB = Wire.read();
    }
    valeur = MSB<< 8 |LSB ;
  return valeur;
}

// Initialisation du module Pmod AD2
void Init_AD7991(void)
{
 Wire.beginTransmission(AD7991_Adresse);
 Wire.write(0x08); // configuration of the I2C communication in HIGH SPEED Mode
 Wire.write(0x10); // configuration of Pmod AD2 (read of V0)
 Wire.endTransmission();
}
