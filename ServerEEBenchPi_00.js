/*
    write following command to run the server 
    npm install express(only required first time)
    
	node ServerEEBench.js

    Details:
    - Espress = framework for server (in place of http)
    - path = gives you static path from root of the server
    - public folder =  contains all files that can be accessed from the website
    - Express app by default run on localhost:3000
*/

    //Importing the core modules
    var fs = require('fs');
//    var util = require('util');
    var path = require('path');

// raspberryPi rpio library
    var rpio = require('rpio');

// opening application
//    var open = require('open');
     
    var express = require('express');
//    var jsonfile = require('jsonfile');
//    var sleep = require('sleep');
//    var csv = require('fast-csv');

    //Importing child Process 
    var app = express();
    var http = require('http').Server(app);
    var spawnSync = require('child_process').spawnSync;
    var execSync = require('child_process').execSync;
    var execFileSync = require('child_process').execFileSync;
    var io = require('socket.io')(http);
    var dataMax = 512;
	
 var devMan ="RaspberryPi";
   
    function hex(str) {
        var arr = [];
        for (var i = 0, l = str.length; i < l; i ++) {
                var ascii = str.charCodeAt(i);
                arr.push(ascii);
        }
        arr.push(255);
        arr.push(255);
        arr.push(255);
        return new Buffer(arr);
    }

function DecHexValue(x) {
 if (x=="A") { return 10; } else if (x=="B") {  return 11;
 } else if (x=="C") { return 12; } else if (x=="D") {  return 13;
 } else if (x=="E") {return 14; } else if (x=="F") {  return 15;
 } else { return parseInt(x); }
}

function hexToDec(x) {
   var hexN = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"];
   var dec = 0;
   for (var i = 0; i < x.length; i++) {    //  8 hex digits
      dec = dec * 16 + DecHexValue(x[i]); 
   }
   return dec;
}

function writeDigital(x){ // Write 8-bit digital value to pins
 var bitsX = [1,2,4,8,16,32,64,128];
   if ( (x & bitsX[0]) == bitsX[0]) { rpio.write(11, rpio.HIGH); } 
   else { rpio.write(11, rpio.LOW); }
   if ( (x & bitsX[1]) == bitsX[1]) { rpio.write(12, rpio.HIGH); } 
   else { rpio.write(12, rpio.LOW); }
   if ( (x & bitsX[2]) == bitsX[2]) { rpio.write(13, rpio.HIGH); } 
   else { rpio.write(13, rpio.LOW); }
   if ( (x & bitsX[3]) == bitsX[3]) { rpio.write(15, rpio.HIGH); } 
   else { rpio.write(15, rpio.LOW); }
   if ( (x & bitsX[4]) == bitsX[4]) { rpio.write(16, rpio.HIGH); } 
   else { rpio.write(16, rpio.LOW); }
   if ( (x & bitsX[5]) == bitsX[5]) { rpio.write(18, rpio.HIGH); } 
   else { rpio.write(18, rpio.LOW); }
   if ( (x & bitsX[6]) == bitsX[6]) { rpio.write(22, rpio.HIGH); } 
   else { rpio.write(22, rpio.LOW); }
   if ( (x & bitsX[7]) == bitsX[7]) { rpio.write(7, rpio.HIGH); } 
   else { rpio.write(7, rpio.LOW); }
}

function pinsInit(){ // Initialization
  // GPIO 8 digital pins
  // GPIO 7  6  5  4  3  2  1  0
  // Zero 7 22 18 16 15 13 12 11
  // https://www.npmjs.com/package/rpio Example
  rpio.init({gpiomem: false});    /* Use /dev/mem for i²c/PWM/SPI */
  rpio.init({mapping: 'physical'});       // physical, gpio
  rpio.open(7, rpio.OUTPUT, rpio.LOW);    // HIGH LOW
  rpio.open(22, rpio.OUTPUT, rpio.LOW);
  rpio.open(18, rpio.OUTPUT, rpio.LOW);
  rpio.open(16, rpio.OUTPUT, rpio.LOW);
  rpio.open(15, rpio.OUTPUT, rpio.LOW);
  rpio.open(13, rpio.OUTPUT, rpio.LOW);
  rpio.open(12, rpio.OUTPUT, rpio.LOW);
  rpio.open(11, rpio.OUTPUT, rpio.LOW);
  
  // ADC PMOD AD2 I2C
  // Standard 100 kHz, Fast 400 kHz, High speed 100pF 3.4 MHz, 400 pF 1.7 MHz 
var txbuf = new Buffer([0x10]); // Read V0
  rpio.i2cBegin();
  rpio.i2cSetClockDivider(148);   // 250 MHz / 148 = 1.7 MHz  (73 3.4 MHz) even number 
  rpio.i2cSetSlaveAddress(0x28);  // I2C Address of AD7991
  // rpio.i2cSetBaudRate(100000);    /* 100kHz */
  rpio.i2cWrite(txbuf);
 
   // DAC PMOD DA2 SPI Interface  Texas Instruments DAC121S101
   rpio.spiBegin(); 
   rpio.spiChipSelect(0); // CE0 Pin 24 Active low
   // rpio.spiSetCSPolarity(0, rpio.HIGH);    /* Set CE0 high to activate */
   rpio.spiSetClockDivider(250);  // 250 MHz / 256 = 1 MHz 
   rpio.spiSetDataMode(3);    // Mode 0,1,2,3 CPOL 0,0,1,1 CPHA 0,1,0,1
   
   
}

var countX = 0;

function loopData () {
  // Write digital pins
  writeDigital(countX);
  
  // PMOD DA2 write
  var txbuf = new Buffer([0x3, 0x0]);
  txbuf[0] = (countX>>8)&0xFF;  
  txbuf[1] = (countX)&0xFF;  
  rpio.spiWrite(txbuf, txbuf.length);
  
  // PMOD AD2 read AD7991
  rpio.i2cSetSlaveAddress(0x28);
  // var txbuf = new Buffer([0x10]); // Read V0
  // rpio.i2cWrite(txbuf);
  var rxbuf = new Buffer(2);  
  rpio.i2cRead(rxbuf, 2);  
  adcVal = rxbuf[0] + 256 * rxbuf[1]; 
  
  if (countX % 16 == 0) console.log('Step: ' + countX + " ADC: " + adcVal + ".");
  countX = countX + 1;
  if (countX > 1024 * 4 - 1) countX = 0; // 12 Bit
}
	
pinsInit();	
var loopFun = setInterval(loopData, 20);

    app.get('/', function(req,res){
   		fs.readFile(__dirname + '/Projekte/NEEBench.html', 'binary', function(err, data) {
               if (err) data = "No such file";
    	       res.send(data);
            });
   	  // res.sendFile(path.join(__dirname + '/WebEditor/WebEditor.html'));
    });
     
    // Serve Static Directories
    app.use(express.static(path.join(__dirname)));
       
    //    
    io.on('connection', function(socket){ 
		var con = true;                             // connection still valid?
        console.log('An user is connected')
     
        // get data from connected device via serial port
		var dataBuf="";
         
         socket.on('cmd', function(data){     // get client event
        	var cmdName = data.value;        // cmd passed from client
        	console.log('cmd: ' + cmdName);
			if (cmdName[0] == "X"){
               dataBuf = "";
			}
    	    if (cmdName[0] == "O"){   // oscilloscope block size next 4 hex values 
               dataMax = hexToDec(cmdName.substring(1,5)); 
			   console.log('Block size: ' + dataMax + "x" + cmdName.substring(1,5) + "x"); 		   
			}
    	    // serialPort.write(cmdName);           // hex(cmdName)
			// insert server action commands
			var data= "Test Data:" + cmdName;
    		socket.emit('newData',{value: data });  // send data to client
        });
 
        socket.on('disconnect', function(data){
    	    console.log('An user is disconnected');
			con = false;
        });   
    }); 	
     
    // Server Starting
    // Listening on port 3000
    http.listen(3000, function(err){
        if(err){
    	  console.log('Error starting http server');
        } else{
    	  console.log('Sever running at ipAddress:3000');  // at http://localhost:3000 ' 
		  // ready to open browser
//		  var add = 'http://localhost:3000';
//		  setTimeout(open, 2000, add);  // problems connecting 
        }
    });
