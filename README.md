# NodeEEBench
# Oscilloscope and Waveform Generator

This project implements an oscilloscope, arbitrary waveform generator, power supply and digital IOs with a 
browser interface on different hardware platforms using JavaScript and NodeJS.

# Installation

Copy the contents of this repository to C:\temp\NodeEEBench on a Windows or Linux system.
On a Linux system install NodeJS and packages and start: 'node ServerEEBench.js'. 

Connect hardware and configure the hardware (see subdirectory Documentation/Installation.html) for instructions or use simulation.
(https://htmlpreview.github.io/?https://github.com/JVollrath/NodeEEBench/blob/master/Documentation/Installation.html)

Start: NodeEEBench.bat

Open the Browser: http:\localhost:3000

Play with waveform generator and oscilloscope.

# Status

The current non responsive GUI is shown here:
https://htmlpreview.github.io/?https://github.com/JVollrath/NodeEEBench/blob/master/Projekte/NEEBench.html

![System block diagram](ImagesS/System_V04.png "System Block diagram")

So far a BASYS3 board, Arduino Maker WIFI 1010 and a RaspberryPi Zero with Digilent AD2, DA2 PMODs are the target hardware systems.

![Arduino ADC DAC Setup](ImagesS/Arduino_MKR_WIFI_1010_ADCDAC.png "Arduino ADC DAC")

![BASYS3 ADC DAC Setup](ImagesS/BASYS3_V04.png "Basys3 ADC DAC")

![BASYS3 PMOD Setup](Documentation/ImagesS/BASYS3_V04_03.png "Basys3 PMODs")

![CMOD A7 PMOD Setup](Documentation/ImagesS/CMODA7EEBench.jpg "CMOD A7 PMODs")

![Raspberry Pi Zero 2 W PMOD Setup](Documentation/ImagesS/RaspiZero_01.jpg "Raspberry Pi ero PMOD")

![Browser User Interface](ImagesS/NodeEEBenchUI01.png "NodeEEBench User Interface")

Subdirectory Xilinx contains the bit file and all sources for the BASYS3 Board.

Subdirectory Arduino contains sketches for Arduino Maker WiFi 1010 and R2R DAC and Serial C DAC.

More documentation can be found at:
BASYS3 FPGA: [2023 Research Summary] 
(https://personalpages.hs-kempten.de/~vollratj/Projekte/2023_ResearchSummary.html).

Arduino: [2023 Interface Electronics Laboratory DAC Investigation] 
(https://personalpages.hs-kempten.de/~vollratj/InEl/2023_Lab_MKRWIFI1010_R2R.html)

