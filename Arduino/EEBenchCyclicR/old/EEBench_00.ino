/*
  Target board Arduino MKR WIFI 1010
  Communication via serial to node.js NEEBench
  Signal generator AWG
  Oscilloscope
*/

#define DAC          A0

#define ADC_OSC1          A1
#define ADC_OSC2          A2
#define ADC_OSC3          A3
#define ADC_OSC4          A4

// buffer for values

// Buffer size for acquisition
int bufSize = 2048 * 5;  // Number of values * 5 channels
uint16_t bufVal[2048 * 5];  // 2048*5 memory 70%
// lookup for DAC
// lookup for ADC

uint16_t sineWave[] = { 
 // Ramp
     0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
     16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,
     32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,
     48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,
     64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,
     80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,
     96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,
     112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,
     128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,
     144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,
     160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,
     176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,
     192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,
     208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,
     224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,
     240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,
// Sine 1 period
    128,131,134,137,140,143,146,149,152,155,158,162,165,167,170,173,
    176,179,182,185,188,190,193,196,198,201,203,206,208,211,213,215,
    218,220,222,224,226,228,230,232,234,235,237,238,240,241,243,244,
    245,246,248,249,250,250,251,252,253,253,254,254,254,255,255,255,
    255,255,255,255,254,254,254,253,253,252,251,250,250,249,248,246,
    245,244,243,241,240,238,237,235,234,232,230,228,226,224,222,220,
    218,215,213,211,208,206,203,201,198,196,193,190,188,185,182,179,
    176,173,170,167,165,162,158,155,152,149,146,143,140,137,134,131,  
    128,124,121,118,115,112,109,106,103,100,97,93,90,88,85,82,
    79,76,73,70,67,65,62,59,57,54,52,49,47,44,42,40,
    37,35,33,31,29,27,25,23,21,20,18,17,15,14,12,11,
    10,9,7,6,5,5,4,3,2,2,1,1,1,0,0,0,
    0,0,0,0,1,1,1,2,2,3,4,5,5,6,7,9,
    10,11,12,14,15,17,18,20,21,23,25,27,29,31,33,35,
    37,40,42,44,47,49,52,54,57,59,62,65,67,70,73,76,
    79,82,85,88,90,93,97,100,103,106,109,112,115,118,121,124,
/* 11 periods in 256 steps */
128,162,193,220,240,252,255,249,234,211,182,149,115,82,52,27,
10,1,1,11,29,54,85,118,152,185,213,235,250,255,251,238,
218,190,158,124,90,59,33,14,2,0,7,23,47,76,109,143,
176,206,230,246,254,253,243,224,198,167,134,100,67,40,18,5,
0,5,18,40,67,100,134,167,198,224,243,253,254,246,230,206,
176,143,109,76,47,23,7,0,2,14,33,59,90,124,158,190,
218,238,251,255,250,235,213,185,152,118,85,54,29,11,1,1,
10,27,52,82,115,149,182,211,234,249,255,252,240,220,193,162,
128,93,62,35,15,3,0,6,21,44,73,106,140,173,203,228,
245,254,254,244,226,201,170,137,103,70,42,20,5,0,4,17,
37,65,97,131,165,196,222,241,253,255,248,232,208,179,146,112,
79,49,25,9,1,2,12,31,57,88,121,155,188,215,237,250,
255,250,237,215,188,155,121,88,57,31,12,2,1,9,25,49,
79,112,146,179,208,232,248,255,253,241,222,196,165,131,97,65,
37,17,4,0,5,20,42,70,103,137,170,201,226,244,254,254,
245,228,203,173,140,106,73,44,21,6,0,3,15,35,62,93,

/* 51 periods in 256 steps */
    128,249,203,54,5,124,248,206,57,5,121,246,208,59,4,118,
245,211,62,3,115,244,213,65,2,112,243,215,67,2,109,241,
218,70,1,106,240,220,73,1,103,238,222,76,1,100,237,224,
79,0,97,235,226,82,0,93,234,228,85,0,90,232,230,88,
0,88,230,232,90,0,85,228,234,93,0,82,226,235,97,0,
79,224,237,100,1,76,222,238,103,1,73,220,240,106,1,70,
218,241,109,2,67,215,243,112,2,65,213,244,115,3,62,211,
245,118,4,59,208,246,121,5,57,206,248,124,5,54,203,249,
128,6,52,201,250,131,7,49,198,250,134,9,47,196,251,137,
10,44,193,252,140,11,42,190,253,143,12,40,188,253,146,14,
37,185,254,149,15,35,182,254,152,17,33,179,254,155,18,31,
176,255,158,20,29,173,255,162,21,27,170,255,165,23,25,167,
255,167,25,23,165,255,170,27,21,162,255,173,29,20,158,255,
176,31,18,155,254,179,33,17,152,254,182,35,15,149,254,185,
37,14,146,253,188,40,12,143,253,190,42,11,140,252,193,44,
10,137,251,196,47,9,134,250,198,49,7,131,250,201,52,6,

/* 101 periods in 256 steps */
    128,206,4,244,67,106,222,0,234,88,85,235,1,220,109,65,
    245,5,203,131,47,252,12,185,152,31,255,23,165,173,18,254,
    37,143,193,9,250,54,121,211,2,241,73,100,226,0,230,93,
    79,238,1,215,115,59,248,6,198,137,42,253,15,179,158,27,
    255,27,158,179,15,253,42,137,198,6,248,59,115,215,1,238,
    79,93,230,0,226,100,73,241,2,211,121,54,250,9,193,143,
    37,254,18,173,165,23,255,31,152,185,12,252,47,131,203,5,
    245,65,109,220,1,235,85,88,234,0,222,106,67,244,4,206,
    128,49,251,11,188,149,33,255,21,167,170,20,254,35,146,190,
    10,250,52,124,208,3,243,70,103,224,0,232,90,82,237,1,
    218,112,62,246,5,201,134,44,253,14,182,155,29,255,25,162,
    176,17,254,40,140,196,7,249,57,118,213,2,240,76,97,228,
    0,228,97,76,240,2,213,118,57,249,7,196,140,40,254,17,
    176,162,25,255,29,155,182,14,253,44,134,201,5,246,62,112,
    218,1,237,82,90,232,0,224,103,70,243,3,208,124,52,250,  
    10,190,146,35,254,20,170,167,21,255,33,149,188,11,251,49,
    128
};


void setup() {
  // put your setup code here, to run once:

 // initialize serial communication at 115200
 Serial.begin(115200);         // 230400 possible ??
 Serial.println("\r\nEEBench on Arduino Maker Wifi 1010");

 // Arduino DAC 
 analogWriteResolution(12);     // Arduino DAC Resolution Change     

 // Arduino ADC 
 analogReadResolution(12);     // Arduino ADC Resolution Change     
 
  
}

char inChar;        // incoming serial char
char myData[20];        // incoming string
int cntChar = 0;        // current string position
int expChar = 0;       // number of expected characters
int bufIndex = 0;
int freq = 1;          // fequency
// Triangle values
uint16_t startT = 0;   // awg Triangle Start Value
uint16_t stopT = 0;   // awg Triangle Stop Value
uint16_t stepT = 0;   // awg Triangle Step Value
unsigned long repeatT = 0;   // awg Triangle repeat Value
// Sine values
unsigned long stepS = 0;   // awg sine step Value
unsigned long amplitude = 0;   // awg sine amplitude Value
unsigned long offsetS = 0;   // awg sine offset Value
// Getting time base
unsigned long timeBegin = micros();  // measure time base
unsigned long timeEnd = micros();  // measure time base
uint16_t cntBuf = 0;   // number of buffer readings

void hex16(uint16_t data, uint8_t length) // prints 16-bit data in hex with leading zeroes
{
        char tmp[16];
          sprintf(tmp, "%.4X",data); 
          Serial.print(tmp);
}

// send all buffer values in Hex
void sendData() {
  // get current time
  timeEnd = micros();
  unsigned long totalDuration = (timeEnd - timeBegin)/cntBuf;
  bufVal[2] = bufIndex; // current position 
  bufVal[3] = (uint16_t)(totalDuration >> 16);     
  bufVal[4] = (uint16_t)totalDuration;     
  // send data
  Serial.print("U");
  for (int i1 = 0; i1 < (bufSize / 5) ; i1 += 1) {
    for (int i2 = 0; i2 < 5 ; i2 += 1) {
       hex16(bufVal[ i1 * 5 + 4 - i2],4);  // bring into right order
    }
    Serial.print("Y");
    if (i1 < (bufSize/5) -1) { Serial.print("X"); }
  }
}

void loop() {
  // put your main code here, to run repeatedly:
  uint16_t awgX = 0;   // waveform generator value
  uint16_t cntV = 0;   // number of oscilloscope readings
  uint16_t run = 1;   // number of oscilloscope readings
  bufSize = 256;
  while (run == 1) {
  // if we get a valid byte, read analog ins:
  if (Serial.available() > 0) {
    // get incoming byte:
    inChar = Serial.read();
    if (inChar == 'U') { sendData(); } // cmd 'U' send data
    
    cntV = 0;              // no sampled data available
    cntBuf = 0;
    bufIndex = 0;          // start at index 0
    timeBegin = micros();  // start measuring time 
  }
  // Generate Analog value
  // awgX = (int) ((4096 - 1)  * (1 + sin( TWO_PI * bufIndex / bufSize * freq)) / 2);
  awgX = sineWave[bufIndex + bufSize];
  // writing Analog
  analogWrite(DAC, awgX);
  bufVal[bufIndex] = awgX; // write val in bufVal
  bufIndex++;
  // read Analog in bufVal
  bufVal[bufIndex] = analogRead(ADC_OSC1);
  bufIndex++;
  bufVal[bufIndex] = analogRead(ADC_OSC2);
  bufIndex++;
  bufVal[bufIndex] = analogRead(ADC_OSC3);
  bufIndex++;
  bufVal[bufIndex] = analogRead(ADC_OSC4);
  bufIndex++;
  if (bufIndex >= bufSize) { bufIndex = 0; cntBuf++; } 
  cntV++;
  if (cntV > bufSize) { cntV = bufSize; }
  }
}
