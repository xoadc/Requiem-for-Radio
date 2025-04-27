/*Copyright (c) 2016 bildr community

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

#include "mpr121.h"
#include <Wire.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <OSCMessage.h>
#include <OSCBundle.h>
#include <OSCData.h>
 
const char* ssid     = "ndz";
const char* password = "requiemforradionewdeadzones";
 
WiFiUDP udp; // A UDP instance to let us send and receive packets over UDP
const IPAddress outIp(192,168,0,100); // remote IP of your computer
const unsigned int outPort = 50101; // remote port to receive OSC
const unsigned int localPort = 50202; // local port to listen for OSC packets

// int irqpin = 13; // No irq in this version.
// boolean touchStates[13]; //to keep track of the previous touch states

OSCErrorCode error;

void setup(){
  Serial.begin(115200);

  Wire.begin();

  mpr121_setup();

  delay(100);
 
  // We start by connecting to a WiFi network
 
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
 
  Serial.println("");
  Serial.println("WiFi connected");  
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  Serial.println("Starting UDP");
  udp.begin(localPort);
  Serial.print("Local port: ");
  Serial.println(udp.localPort());
}

void loop(){
  // readTouchInputs();
  OSCMessage message;
  int size = udp.parsePacket();

  if (size > 0) {
    while (size--) {
      message.fill(udp.read());
    }
    if (!message.hasError()) {
      message.dispatch("/set_register", osc_set_register);
    } else {
      error = message.getError();
      Serial.print("error: ");
      Serial.println(error);
    }
  }

  // Read touch input at registers 0x00 and 0x01 and send touch OSC message.
  Wire.requestFrom(0x5A,2);
  if ( Wire.available() >= 1 ) {
    byte LSB = Wire.read();
    byte MSB = Wire.read();
    uint32_t touched = ((MSB << 8) | LSB); //16bits that make up the touch states
    OSCMessage msg("/touch");
    msg.add(touched);
    udp.beginPacket(outIp, outPort);
    msg.send(udp);
    udp.endPacket();
    msg.empty();
  }

  // Move register pointer to 0x04 to get raw electrode values and baselines.
  move_pointer_to_and_request(0x5A, 0x04, 26);
  // Get raw values and send OSC message.
  if ( Wire.available() >= 1 ) {
    OSCMessage msgRaw("/raw");
    for (int i=0; i<13; i++) {
      byte LSB = Wire.read() ;
      byte MSB = Wire.read() ;
      uint32_t rawValue = ((MSB << 8) | LSB);
      msgRaw.add(rawValue);
    }

    move_pointer_to_and_request(0x5A, 0x1E, 13);
    // Get baseline values (8 bits out of 10).
    for (int i=0; i<13; i++) {
      uint32_t baseline = Wire.read() << 2;
      msgRaw.add(baseline);
    }

    udp.beginPacket(outIp, outPort);
    msgRaw.send(udp);
    udp.endPacket();
    msgRaw.empty();
  }

  // wait a bit.
  delay(10);
}

void osc_set_register(OSCMessage &msg) {
  // expects 2 ints : register and value
  int reg = msg.getInt(0);
  int val = msg.getInt(1);
  set_register(0x5A, (unsigned char) reg, (unsigned char) val);
  Serial.print("Register ");
  Serial.print(reg, HEX);
  Serial.print(" set to ");
  Serial.println(val, HEX);
}


void mpr121_setup(void){

  set_register(0x5A, ELE_CFG, 0x00); 
  
  // Section A - Controls filtering when data is > baseline.
  set_register(0x5A, MHD_R, 0x01);
  set_register(0x5A, NHD_R, 0x01);
  set_register(0x5A, NCL_R, 0x00);
  set_register(0x5A, FDL_R, 0x00);

  // Section B - Controls filtering when data is < baseline.
  set_register(0x5A, MHD_F, 0x01);
  set_register(0x5A, NHD_F, 0x01);
  set_register(0x5A, NCL_F, 0xFF);
  set_register(0x5A, FDL_F, 0x02);
  
  // Section C - Sets touch and release thresholds for each electrode
  set_register(0x5A, ELE0_T, TOU_THRESH);
  set_register(0x5A, ELE0_R, REL_THRESH);
 
  set_register(0x5A, ELE1_T, TOU_THRESH);
  set_register(0x5A, ELE1_R, REL_THRESH);
  
  set_register(0x5A, ELE2_T, TOU_THRESH);
  set_register(0x5A, ELE2_R, REL_THRESH);
  
  set_register(0x5A, ELE3_T, TOU_THRESH);
  set_register(0x5A, ELE3_R, REL_THRESH);
  
  set_register(0x5A, ELE4_T, TOU_THRESH);
  set_register(0x5A, ELE4_R, REL_THRESH);
  
  set_register(0x5A, ELE5_T, TOU_THRESH);
  set_register(0x5A, ELE5_R, REL_THRESH);
  
  set_register(0x5A, ELE6_T, TOU_THRESH);
  set_register(0x5A, ELE6_R, REL_THRESH);
  
  set_register(0x5A, ELE7_T, TOU_THRESH);
  set_register(0x5A, ELE7_R, REL_THRESH);
  
  set_register(0x5A, ELE8_T, TOU_THRESH);
  set_register(0x5A, ELE8_R, REL_THRESH);
  
  set_register(0x5A, ELE9_T, TOU_THRESH);
  set_register(0x5A, ELE9_R, REL_THRESH);
  
  set_register(0x5A, ELE10_T, TOU_THRESH);
  set_register(0x5A, ELE10_R, REL_THRESH);
  
  set_register(0x5A, ELE11_T, TOU_THRESH);
  set_register(0x5A, ELE11_R, REL_THRESH);

  set_register(0x5A, ELEPROX_T, 0x00);
  set_register(0x5A, ELEPROX_R, 0x00);
  
  // Section D
  // Set the Filter Configuration
  // Set ESI2
  // set_register(0x5A, FIL_CFG, 0x04);
  
  // Section E
  // Electrode Configuration
  // Set ELE_CFG to 0x00 to return to standby mode
  // set_register(0x5A, ELE_CFG, 0x0C);  // Enables all 12 Electrodes

  // Enables all 12 Electrodes and proximity (electrode 13) with all
  // electrodes together.
  set_register(0x5A, ELE_CFG, 0x2C);

  // set charge current to max
  set_register(0x5A, 0x5C, 0x3F);
  
  
  // Section F
  // Enable Auto Config and auto Reconfig
  /* set_register(0x5A, ATO_CFG0, 0x0B);
  set_register(0x5A, ATO_CFGU, 0xC9);  // USL = (Vdd-0.7)/vdd*256 = 0xC9 @3.3V   set_register(0x5A, ATO_CFGL, 0x82);  // LSL = 0.65*USL = 0x82 @3.3V
  set_register(0x5A, ATO_CFGT, 0xB5);*/  // Target = 0.9*USL = 0xB5 @3.3V
  
}


void set_register(int address, unsigned char r, unsigned char v){
    Wire.beginTransmission(address);
    Wire.write(r);
    Wire.write(v);
    Wire.endTransmission();
}

void move_pointer_to_and_request(int address, int reg, int numToRequest){
  // Move register pointer to 0x1C to get prox
  Wire.beginTransmission( (uint8_t) address );
  Wire.write( (uint8_t) reg );
  Wire.endTransmission( false );
  Wire.requestFrom( (uint8_t) address, (uint8_t) numToRequest, (uint8_t) true );
}

