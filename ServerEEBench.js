/*
    write following command to run the server 
    npm install express(only required first time)
    
	node ServerEEBench.js

    Details:
    - Express = framework for server (in place of http)
    - path = gives you static path from root of the server
    - public folder =  contains all files that can be accessed from the website
    - Express app by default run on localhost:3000
*/

    //Importing the core modules
//    var fs = require('fs');
//    var util = require('util');
    var path = require('path');

// opening application
//    var open = require('open');
     
    var express = require('express');
//    var jsonfile = require('jsonfile');
//    var sleep = require('sleep');
//    var csv = require('fast-csv');
    var SerialPort = require('serialport').SerialPort;

    //Importing child Process 
    var app = express();
    var http = require('http').Server(app);
    var spawnSync = require('child_process').spawnSync;
    var execSync = require('child_process').execSync;
    var execFileSync = require('child_process').execFileSync;
    var io = require('socket.io')(http);
    var dataMax = 512;
	
 var SerialPort = require('serialport').SerialPort;
 var serialPort;	
 var devMan ="Simulation";
 // port.path manufacturer, pnpId locationId, friendlyName, vendorId, productId	
    SerialPort.list().then(
 //    console.log	   
       ports => ports.forEach(port => {
           console.log("path: " + port.path + " manufacturer: " + port.manufacturer + " productId: " + port.productId + " productId: " + port.vendorId);
           // console.log(port.manufacturer.includes('arduino'));
           var manu = port.manufacturer || "";
		   manu = manu.toLowerCase();
           if (manu.includes('arduino') || ((port.productId == 8054) & (port.vendorId == 2341))) {
		     devMan = "Arduino";
			 serialPort = new SerialPort({  //"\\.\COM22"
                path: port.path,
	            baudRate: 115200      //  Baud rate befor 19200, 52 us per bit
             });
			 // console.log("Arduino detected.");
           }			 
           if (manu.includes('segger')) { // Infineon XMC4700
		     devMan = "XMC4700";                
			 serialPort = new SerialPort({  //"\\.\COM22"
                path: port.path,
	            baudRate: 115200      //  Baud rate befor 19200, 52 us per bit
             });
			 // console.log("XMC4700 detected.");
           };			 
           if (manu.includes('ftdi') || manu.includes('digilent')) {
		     devMan = "FPGA FTDI";
			 serialPort = new SerialPort({  //"\\.\COM22"
                path: port.path,
	            baudRate: 230400      //  Baud rate befor 19200, 52 us per bit
             });
			 // console.log("FPGA FTDI detected.");
           }			 
       }),
       err => console.error(err)
    );
   
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

// Simulator ==================================================================
function decToHex(x) {
   var hexN = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"];
   var hex = "";
   var x1 = x;
   for (var i = 0; i < 4; i++) {    //  4 hex digits
      hex = hexN[x1 % 16] + hex;
	  x1 = Math.trunc(x1 / 16); 
   }
   return hex;
}

 var awg1Type = "S";    // Current Waveform1 type S (sine),T (rest)
 var blockSize = 512;
 var dacTimeBase = 1E-6;      // DAC time base 
 var absTimeBase = 1E-6;     // Absolute ADC time base 
 var ratio = Math.round(absTimeBase/dacTimeBase); // 
 var currTimeBase = 1E-6;    // Current time base modified with averaging O cmd
 var mulTime = 1;            // Multiplication of time Base (averaging case, large osc time base)
 // AWG1 sine
 var step = 1;               // Step waveform
 var amplitude = 1024;       // amplitude waveform
 var offset = 4096;          // offset
 // AWG1 triangle
 var startT = 0;               // Step waveform
 var stopT = 0;               // Step waveform
 var stepT = 0;               // Step waveform
 var repeatT = 1;               // Step waveform
 //
 var oscData = [];           // sampled data
 var dataReady = 0;          // data Ready to send?
 var dataBufX ="";

 function limitData(valX)  {
    var limitData = Math.round(valX);
	if (valX < 0 ) limitData = 0;
 	if (valX > (64 * 1024 - 1) ) limitData = 64 * 1024 - 1;
	return limitData;
 } 

 function genSine(){
 // Sampling time 1us, mulTime = 1, max step = 2^32,  
	   oscData = [];
	   console.log('genSine: ' + offset + "," + amplitude + "," + step + "," + mulTime + "," + blockSize);
       for (var i = 0; i < blockSize; i ++) {   // only sampling
	     for (var j = 0; j < ratio * mulTime; j ++) { // generate all points for DAC
           var timeX = 2 * Math.PI * (i * ratio * mulTime + j) * step / 1024 / 1024 / 1024 / 4 ;
		   oscData[i * 5] = Math.round(offset + amplitude * Math.sin(timeX)); // Osc4  
		   oscData[i * 5] = limitData(oscData[i * 5]);
 	       oscData[i * 5 + 1] = Math.round(offset +  amplitude * Math.sin(8 * timeX )); // Osc3  
		   oscData[i * 5 + 1] = limitData(oscData[i * 5 + 1]);
 	       oscData[i * 5 + 2] = Math.round(offset + amplitude * Math.sin(4 * timeX )); // Osc2  
		   oscData[i * 5 + 2] = limitData(oscData[i * 5 + 2]);
 	       oscData[i * 5 + 3] = Math.round(offset + amplitude * Math.sin(timeX * 2)); // Osc1  
		   oscData[i * 5 + 3] = limitData(oscData[i * 5 + 3]);
 	       oscData[i * 5 + 4] = Math.round(offset + amplitude * Math.sin(timeX));// AWG
		   oscData[i * 5 + 4] = limitData(oscData[i * 5 + 4]);
		 } 
	   }
	   // Set dummy index information
	   oscData[0] = 2; oscData[1] = 2; oscData[2] = 2;oscData[3] = 2;oscData[4] = 2;
 }

 function genTri(){ // triangle
	   oscData = [];
	   console.log('genTriangle: ' + startT + "," + stopT + "," + stepT + "," + repeatT + "," + mulTime);
	   var deltaX = (stopT - startT);
	   for (var i = 0; i < blockSize; i ++) {
	     for (var j = 0; j < mulTime * ratio; j ++) {
	       var posY = (Math.trunc( stepT * 1/ 1  * (i * mulTime * ratio + j) / repeatT)) % (deltaX * 2); // limit to 2 * deltaX; 1/16 old 16 values per step  
		   if (posY > deltaX) { posY = 2 * deltaX - posY; }           // rising or falling
	       if ( deltaX == stepT) { // pulse
		      posY = (Math.trunc( (i * mulTime * ratio + j) / 8 / repeatT) % 2) * deltaX; // factor 8 ??
		   }
		   posY = Math.round(startT + posY); // 
 	       oscData[i * 5] = 5 * posY; // Osc4  
		   oscData[i * 5] = limitData(oscData[i * 5]);
 	       oscData[i * 5 + 1] = 4 * posY; // Osc3  
		   oscData[i * 5 + 1] = limitData(oscData[i * 5 + 1]);
 	       oscData[i * 5 + 2] = 3 * posY; // Osc2  
		   oscData[i * 5 + 2] = limitData(oscData[i * 5 + 2]);
 	       oscData[i * 5 + 3] = 2 * posY; // Osc1  
		   oscData[i * 5 + 3] = limitData(oscData[i * 5 + 3]);
 	       oscData[i * 5 + 4] = posY;// AWG
		   oscData[i * 5 + 4] = limitData(oscData[i * 5 + 4]);
	       // console.log(j + "," + oscData[i * 5] + ","+ oscData[i * 5 + 1] + " stepT " 
		   //              + stepT + " deltaX " + deltaX);
		 }
	   }
	   // Set dummy index information
	   oscData[0] = 2; oscData[1] = 2; oscData[2] = 2;oscData[3] = 2;oscData[4] = 2;
 }
 
 function simX(cmdName){
    // X Command
	// S Command sine function
	if (cmdName[0]=="S") {
	   var tT = cmdName.substring(1,9);
	   awg1Type = "S";
	   step = hexToDec(tT) ;        // Step
	   tT = cmdName.substring(9,17);
       amplitude = Math.round(hexToDec(tT)/256/256);   // amplitude 32 bit to 16
	   tT = cmdName.substring(17,25);   
       offset =	Math.round(hexToDec(tT)/256/256);      // offset  32 bit to 16
	   genSine();
	}
	// T Command triangle waveform
 	if (cmdName[0]=="T") {
	   awg1Type = "T";
	   startT = Math.round(hexToDec(cmdName.substring(1,5)));
	   stopT = Math.round(hexToDec(cmdName.substring(5,9)));
	   stepT = Math.round(hexToDec(cmdName.substring(9,13)));
	   repeatT = Math.round(hexToDec(cmdName.substring(13,17))) * 256 *16 +
	             Math.round(hexToDec(cmdName.substring(17,21)));
	   if (repeatT == 0) { repeatT = 1; }
	   genTri();
	}
   // U Command      send data
	if (cmdName[0]== "U") {  
      if (!serialPort) {
	    console.log("Write dataBufX");
	    dataBufX ="";
	    // get oscData and convert to string 
	    for (var i = 0; i < blockSize; i ++) {
 	      if (i == 0) dataBufX += "U"
		  else dataBufX += "X";
		  dataBufX += decToHex(oscData[i * 5]);
		  dataBufX += decToHex(oscData[i * 5 + 1]);
		  dataBufX += decToHex(oscData[i * 5 + 2]);
		  dataBufX += decToHex(oscData[i * 5 + 3]);
		  dataBufX += decToHex(oscData[i * 5 + 4]);
		  dataBufX += "Y";
	    }
	    dataReady = 1;
	  }	
	}
    // V Command
    // O Command setup acquisition mode
	if (cmdName[0]=="O") {
	   console.log(cmdName);
	   var tT =cmdName.substring(1,5);
	   blockSize = hexToDec(tT);
	   tT = cmdName.substring(5,9);
	   mulTime = hexToDec(tT);
	   if (mulTime > 1) { mulTime -= 1; }
	   currTimeBase = absTimeBase * mulTime;
       console.log('Sim block size: ' + blockSize + "x" + mulTime + "x"); 		   
	   if (awg1Type == "S") {   // update signals
	     genSine();
	   }
	}
    // R Command
    // Q Command
}
// End Simulator ==============================================================

    app.get('/', function(req,res){
   		res.sendFile(path.join(__dirname,"/Projekte/NEEBench.html"));
		// fs.readFile(__dirname + '/Projekte/NEEBench.html', 'binary', function(err, data) {
        //       if (err) data = "No such file";
    	//       res.send(data);
        //    });
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
			   socket.emit('device',{value: devMan});
			}
    	    if (cmdName[0] == "O"){   // oscilloscope block size next 4 hex values 
               dataMax = hexToDec(cmdName.substring(1,5)); 
			   console.log('Block size: ' + dataMax + "x" + cmdName.substring(1,5) + "x"); 		   
			}
	        if (serialPort) {
    	       serialPort.write(cmdName);           // hex(cmdName)
			} else {                                // Simulation
			   simX(cmdName);
	           // console.log("Simulation: " + dataReady);
			   if (dataReady == 1) {                 // send data
	             // emit string	   
	             console.log("SimX " + dataBufX.length/22 + "," + dataBufX.length + "," + dataBufX.substring(0,50));     // dataBufX
		         socket.emit('newData',{value: dataBufX});
                 dataReady = 0;
	          }
			}
			// insert server action commands
			// var data= "Test Data:" + cmdName;
    		// socket.emit('newData',{value: data });  // send data to client
        });

	   
	   if (serialPort) {
        console.log(devMan + " serial Device detected!");
	    serialPort.on('data',
		  function (data) {
		    // get buffered data and parse it to an utf-8 string
			var data1 = data.toString('utf-8');
			// only U command to client
			var position = data1.search("U");
			if (position > -1) dataBuf = data1.substring(position);
			else dataBuf += data1;
			// you could for example, send this data now to the the client via socket.io
			// io.emit('emit_data', data);
			// send only data starting  
			if ((dataBuf.length >= 22 * dataMax ) && (con)) {   // complete set
			 console.log("Ser " + dataBuf.length/22 + "," + dataBuf.length + "," + dataBuf.substring(0,50));     // dataBuf
		     socket.emit('newData',{value: dataBuf});  // send data to client
			 dataBuf = "";
			};
			console.log(data1);
 		 } );
	} else {
           console.log("No serial Device detected! Simulation activated! ");
    }	
 
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
    	  console.log('Sever running at http://localhost:3000 ');
		  // ready to open browser
//		  var add = 'http://localhost:3000';
//		  setTimeout(open, 2000, add);  // problems connecting 
        }
    });
