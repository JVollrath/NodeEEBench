/*
  Target board Arduino MKR WIFI 1010
  Communication via serial to node.js NEEBench
  Signal generator AWG
  Oscilloscope
  2025.03.26 with NodeEEBench_V09.zip from
  https://personalpages.hs-kempten.de/~vollratj/GET2/EI_Projektpraktikum.html
*/
#include <SPI.h> // Include library
#include <Wire.h> // call library
#define AD7991_Adresse 0x28 // I2C adress of the Pmod AD2 module

#define CS A6           // CS pin for PMOD DA2 I2C, 8: MOSI, 9:SCK

#define DAC          A0 // Arduino MKR WIFI1010

// R2R DAC Arduino MKR WIFI1010
/* */
#define DAC_D0          0 
#define DAC_D1          1
#define DAC_D2          2
#define DAC_D3          3
#define DAC_D4          4
#define DAC_D5          5
#define DAC_D6          6
#define DAC_D7          13
/* */

// R2R DAC XMC4700
/*
#define DAC_D0          9 // P1.11 
#define DAC_D1          8 // P1.10
#define DAC_D2          7 // P1.9
#define DAC_D3          6 // P2.11
#define DAC_D4          5 // P2.12
#define DAC_D5          4 // P1.8
#define DAC_D6          3 // P1.1
#define DAC_D7          2 // P1.0
*/

// 4 channel Analog oscilloscope 
// XMC4700 A0 (P14.0),A1 (P14.1),A2 (P14.2),A3 (P14.3)
#define ADC_OSC1          A1
#define ADC_OSC2          A2
#define ADC_OSC3          A3
#define ADC_OSC4          A4  // A4 Arduino, A0 XMC4700

// XMC4700 https://github.com/Infineon/XMC-for-Arduino/wiki/XMC4700-Relax-Kit
// const int DAC = 48; // Analog output pin P14.8
// const int DAC1 = 53; // Analog output pin P14.9
// P0.13 I2C SCL, P3.15 I2C: SDA, P3.9 SPI: SCK, P3.8 SPI MOSI, P3.10 SPI: SS

// buffer for values

// Buffer size for acquisition
int bufSize = 2048 * 5;  // Number of values * 5 channels
uint16_t bufVal[2048 * 5];  // 2048*5 memory 70%
// lookup for DAC
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
// lookup for ADC


char inChar;               // incoming serial char
char myData[1040];          // incoming string Lookup table 256 values 4 hex each
int cntChar = 0;           // current string position

int expChar = 0;           // number of expected characters
int posChar = 0;

int bufIndex = 0;
int freq = 1;              // fequency
int timeBase = 1;
// Triangle values
uint16_t startT = 0;         // awg Triangle Start Value
uint16_t stopT = 0;          // awg Triangle Stop Value
uint16_t stepT = 0;          // awg Triangle Step Value
unsigned long repeatT = 0;   // awg Triangle repeat Value
// Sine values
unsigned long stepS = 0;    // awg sine step Value
unsigned long ampS = 0;     // awg sine amplitude Value
unsigned long offS = 0;     // awg sine offset Value
// Getting time base
unsigned long timeBegin = micros();  // measure time base
unsigned long timeEnd   = micros();  // measure time base
uint16_t cntBuf = 0;       // number of buffer readings

  uint16_t awgX = 0;   // waveform generator value
  uint16_t awgY = 0;   // waveform generator value
  uint16_t awgZ = 0;   // waveform generator value
  uint16_t cntV = 0;   // number of oscilloscope readings
  uint16_t runX = 1;    // number of oscilloscope readings

    uint16_t bitsX[] = {1,2,4,8,16,32,64,128};

static void ADCsync() {
  while (ADC->STATUS.bit.SYNCBUSY == 1);
}

void adc_init() {
  analogRead(ADC_OSC1);
  analogRead(ADC_OSC2);
  analogRead(ADC_OSC3);
  analogRead(ADC_OSC4);
  analogRead(ADC_OSC1);
  ADC->CTRLA.bit.ENABLE = 0;
  ADCsync();
  ADC->INPUTCTRL.bit.GAIN = ADC_INPUTCTRL_GAIN_1X;  // 1X, 2X, 4X, 8X, 16X, DIV2
  ADC->REFCTRL.bit.REFSEL = ADC_REFCTRL_REFSEL_INTVCC1;
  ADCsync();
  ADC->INPUTCTRL.bit.MUXPOS = g_APinDescription[ADC_OSC1].ulADCChannelNumber;
  ADCsync();
  ADC->AVGCTRL.reg = 0;
  ADC->SAMPCTRL.reg = 2;
  ADCsync();
  ADC->CTRLB.reg = ADC_CTRLB_PRESCALER_DIV32 | ADC_CTRLB_FREERUN | ADC_CTRLB_RESSEL_12BIT;
  ADCsync();
  ADC->CTRLA.bit.ENABLE = 1;
  ADCsync();
}

void setup() {
  // put your setup code here, to run once:

 // initialize serial communication at 115200
 Serial.begin(115200);         // 230400 possible ??
 Serial.println("\r\nEEBench on Arduino Maker Wifi 1010");

 // Arduino DAC 
 analogWriteResolution(12);     // Arduino DAC Resolution Change     

 // Arduino ADC 
 analogReadResolution(12);     // Arduino ADC Resolution Change     
 
 // initialize direct access
 adc_init(); 

  // ADC PMOD AD2
  Wire.begin(); // initialization of I2C communication
  Wire.setClock(1600000); // try (40000) 400 kHz 9.7.2025
 Init_AD7991(); // initialisation du module Pmod AD2

 // DAC PMOD DA2
 SPI.begin(); // initialization of SPI port
 SPI.setDataMode(SPI_MODE3); // configuration of SPI communication in mode 3
 SPI.setClockDivider(SPI_CLOCK_DIV16); // configuration of clock at 1MHz
 pinMode(CS, OUTPUT);

   // put your setup code here, to run once:
  pinMode(DAC_D0, OUTPUT);
  pinMode(DAC_D1, OUTPUT);
  pinMode(DAC_D2, OUTPUT);
  pinMode(DAC_D3, OUTPUT);
  pinMode(DAC_D4, OUTPUT);
  pinMode(DAC_D5, OUTPUT);
  pinMode(DAC_D6, OUTPUT);
  pinMode(DAC_D7, OUTPUT);

}


void hex16(uint16_t data) // prints 16-bit data in 4 hex chars with leading zeroes
{
          char tmp[16];
          sprintf(tmp, "%.4X",data); 
          Serial.print(tmp);
}

// Converting from Hex to Decimal:

// NOTE: This function can handle a positive hex value from 0 - 65,535 (a four digit hex string).
//       For larger/longer values, change "unsigned int" to "long" in both places.


unsigned int hexToDec(String hexString) {
  
  unsigned int decValue = 0;
  int nextInt;
  
  for (int i = 0; i < hexString.length(); i++) {
    
    nextInt = int(hexString.charAt(i));
    if (nextInt >= 48 && nextInt <= 57) nextInt = map(nextInt, 48, 57, 0, 9);
    if (nextInt >= 65 && nextInt <= 70) nextInt = map(nextInt, 65, 70, 10, 15);
    if (nextInt >= 97 && nextInt <= 102) nextInt = map(nextInt, 97, 102, 10, 15);
    nextInt = constrain(nextInt, 0, 15);
    
    decValue = (decValue * 16) + nextInt;
  }
  
  return decValue;
}


// send all buffer values in Hex
void sendData() {
  // get current time
  timeEnd = micros();
  unsigned long totalDuration = (timeEnd - timeBegin)/cntBuf;
  bufVal[1] = bufIndex; // current position * 5 
  bufVal[2] = cntV; // current position 
  bufVal[3] = (uint16_t)(totalDuration >> 16);     
  bufVal[4] = (uint16_t)totalDuration;     
  // send data
  Serial.print("U");
  for (int i1 = 0; i1 < (bufSize / 5) ; i1 += 1) {
    for (int i2 = 0; i2 < 5 ; i2 += 1) {
       hex16(bufVal[i1 * 5 + 4 - i2]);  // bring into right order
    }
    Serial.print("Y");
    if (i1 < (bufSize/5) -1) { Serial.print("X"); }
  }
}

void readAnalogX(){
    // read Analog in bufVal and scale up to 16 Bit
  bufVal[bufIndex] = analogRead(ADC_OSC1);
  bufIndex++;
  bufVal[bufIndex] = analogRead(ADC_OSC2);
  bufIndex++;
  bufVal[bufIndex] = analogRead(ADC_OSC3);
  bufIndex++;
  bufVal[bufIndex] = analogRead(ADC_OSC4);
  bufVal[bufIndex] = readADC();             // PMOD AD2

}

// Initialisation du module Pmod AD2
void Init_AD7991(void)
{
 Wire.beginTransmission(AD7991_Adresse);
 Wire.write(0x08); // configuration of the I2C communication in HIGH SPEED Mode
 Wire.write(0x10); // configuration of Pmod AD2 (read of V0)
 Wire.endTransmission();
}

// Write PMOD DA2 via SPI
void writeDAC(uint16_t sineValue){ // 0..32k 15 bit to 12 bit
 int upper_value = (sineValue>>8)&0XFF;   // order high get 4 high bits order
 int lower_value = (sineValue)&0XFF; // order low get 8 low bits order

 digitalWrite(CS, LOW); // activation of the CS line
 SPI.transfer(upper_value); // Send order
 SPI.transfer(lower_value);
 //delay(5);
 digitalWrite(CS, HIGH); // deactivation of CS line
}

// Read PMOD AD2 via I2C
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


int waitSend = 0;
int awgMode = 0;
int stepIndex = 0;
int mulTime = 1;  

void loop() {
  uint16_t sine8 = 0;

  // Serial Interface input
  if (Serial.available() > 0) {
    // get incoming byte:
    inChar = Serial.read();
    if (inChar == 'U') { // cmd 'U' send data 
      if (cntV == bufSize) { 
        sendData(); 
        posChar = 0; expChar = 0; myData[posChar] = 'Z'; 
        cntV = 0;
      } else {
        waitSend = 1;
      }
    } 
    if (inChar == 'X') { expChar = 1; posChar = 0; } // cmd 'O' set block size
    if (inChar == 'O') { expChar = 9; posChar = 0; } // cmd 'O' set block size
    if (inChar == 'T') { expChar = 21; posChar = 0; } // cmd 'T' triangle
    if (inChar == 'S') { expChar = 25; posChar = 0; } // cmd 'S' sine
    if (inChar == 'R') { expChar = 256*4 + 1; posChar = 0; } // cmd 'R' lookup table
    
    if (expChar > 0 ) {                              // gather command string
      myData[posChar] = inChar; // Add character
      posChar++;
      myData[posChar] = 0;
      expChar--;
      // Serial.print(":"); Serial.print(expChar); Serial.print(","); Serial.print(posChar);
      // Serial.print(","); Serial.println(String(myData));
      if (expChar == 0) {
        String myString(myData);     // make String
        if (myData[0] == 'O') {
          String partString = myString.substring(1,5); // 4 hex chars
          bufSize = hexToDec(partString) * 5; //  0x0200 is 512 values * 5 channels each
          partString = myString.substring(5,9);
          timeBase = hexToDec(partString);
          if (timeBase > 1 ) { timeBase -= 1; }
          Serial.print("Omd: "); Serial.print(bufSize); Serial.print(",");Serial.println(timeBase);
        }
        if (myData[0] == 'T') {
          String partString = myString.substring(1,5);
          startT = hexToDec(partString);                // start Value
          stopT = hexToDec((String)myString.substring(5,9));
          stepT = hexToDec((String)myString.substring(9,13));  
          repeatT = hexToDec((String)myString.substring(14,18)) * 256 * 16  + hexToDec((String)myString.substring(18,21)) ;
          if (repeatT == 0) { repeatT = 1; }
          Serial.print("Tmd: "); Serial.print(startT); Serial.print(",");Serial.print(stopT); Serial.print(",");
          Serial.print(stepT); Serial.print(","); Serial.println(repeatT);
          awgMode = 1;
        }
        if (myData[0] == 'S') {
          stepS = hexToDec(myString.substring(1,7)); // 24 bit, 6 hex; from 32 bit value, 8 hex 
          ampS = hexToDec(myString.substring(9,13))/8; // 12 bit, 3 hex; from 32 bit value, 8 hex    
          offS = hexToDec(myString.substring(17,21))/8; // 12 bit, 3 hex; from 32 bit value, 8 hex 
          Serial.print("Smd: "); Serial.print(stepS); Serial.print(",");Serial.print(ampS); Serial.print(",");
          Serial.println(offS);
          awgMode = 2;
        }
        if (myData[0] == 'R') {  // get lookup table 256 comma separated values
           for (int i3 = 0; i3 < 256; i3++ ) {
            lookup8[i3] = hexToDec(myString.substring(1 + i3 * 4, 4 + i3 * 4)); // char 1,2,3 8 bit only
           }
        }
        if (myData[0] == 'X') {
          awgMode = 0;
        }
        Serial.println(((String)myData).substring(0,60));  // limited check
        posChar = 0; expChar = 0;
        // Serial.print(bufSize);Serial.print(","); Serial.println(timeBase);
      }
    }  
    
    cntV = 0;              // no sampled data available
    cntBuf = 0;
    bufIndex = 0;          // start at index 0
    timeBegin = micros();  // start measuring time 
  }
  
  // Generate Analog value sine stepS range integer mapped to 0..1 by / 16 M
     awgX = (int)(offS) + (int)(ampS) * sin( TWO_PI * stepIndex * stepS / 1024 /1024 / 16 ); 
 // Generate Analog value Triangle
     int deltaX = (stopT - startT);
     int posY = ((int)(stepT) * (stepIndex / repeatT) ) % ( deltaX * 2); 
     if (posY > deltaX) posY = 2 * deltaX - posY;
     if ( deltaX == stepT){                            // Pulse
      posY = ((stepIndex * 2 / repeatT) % 2) * deltaX;
     }
     awgY = (int)(startT) + posY; // startT plus posY 
     
  // writing Analog
  // if (awgX > 1024) { awgX = 100; }
  // else { awgX = 1200; }
  if (awgMode == 0) { awgZ = 0;             // off
  } else if (awgMode == 1) { awgZ = awgY;      // Triangle
  } else if (awgMode == 2) { awgZ = awgX; }    // Sine
  
  analogWrite(DAC, awgZ);          // Write internal 12-Bit DAC
  
  writeDAC(awgZ);                  // Write PMOD DA2
  
  sine8 = lookup8[awgZ >> 4];
  digWrite(sine8);                  // 8 Bit
  
  bufVal[bufIndex] = awgZ;         // write val in bufVal as AWG1
  bufIndex++;

  readAnalogX();

  if (timeBase <= mulTime) {        // Lower sampling rate for long acquisition time
    bufIndex++;                     // next index
    mulTime = 1; 
    cntV++;
  } else {                          // same again for timeBase numbers
    mulTime +=1;
    bufIndex -=4;
  }
  stepIndex++;                        // next value for output
  // stepIndex = stepIndex % 4096;
 
  if (bufIndex >= bufSize) { bufIndex = 0; cntBuf++; } 
  if (cntV > bufSize) { 
    cntV = bufSize; 
    if (waitSend == 1) {
      sendData(); 
      waitSend = 0;
      stepIndex =0;
    } 
  }
 // }
}
