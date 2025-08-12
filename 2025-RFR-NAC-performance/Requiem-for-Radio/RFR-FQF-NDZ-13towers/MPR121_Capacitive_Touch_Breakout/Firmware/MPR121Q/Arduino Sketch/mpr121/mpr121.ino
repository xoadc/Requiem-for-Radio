/*Copyright (c) 2010 bildr community

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
#include <OSCMessage.h>
#include <OSCBundle.h>
#include <OSCData.h>
 
const char* ssid     = "JAWifi-bgn";
const char* password = "#Narwhals<3";
 
const char* host = "192.168.0.7";
WiFiClient client;
const int port = 50101;

int irqpin = 13;
boolean touchStates[13]; //to keep track of the previous touch states

void setup(){
  pinMode(irqpin, INPUT);
  digitalWrite(irqpin, HIGH); //enable pullup resistor
  
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

  if (!client.connect(host, port)) {
    Serial.println("connection failed");
    return;
  }
}

void loop(){
  readTouchInputs();
  delay(500);
}


void readTouchInputs(){
  /*Wire.beginTransmission( (uint8_t) 0x5A );
  Wire.write( (uint8_t) 0x1C );
  Wire.endTransmission( false );
 
  Wire.requestFrom( (uint8_t) 0x5A, (uint8_t) 2 , (uint8_t) true );
 
  if ( Wire.available() >= 1 )
  {
    byte LSB = Wire.read() ;
    byte MSB = Wire.read() ;
    Serial.println( (MSB << 8) | LSB );
  }

  /*
  Wire.beginTransmission(0x5A);
  Wire.write(0x1C);
  Wire.requestFrom(0x5A,2);
  byte LSB = Wire.read();
  byte MSB = Wire.read();
  Wire.endTransmission();
  uint16_t prox = ((MSB << 8) | LSB);
  Serial.println(MSB);
  Serial.println(LSB);
  client.println(prox);
*/
  if(!checkInterrupt()){
    
    //read the touch state from the MPR121
    Wire.requestFrom(0x5A,2);
    
    byte LSB = Wire.read();
    byte MSB = Wire.read();

    client.print("MSB ");
    client.write(MSB);
    client.println();
    client.print("LSB ");
    client.write(LSB);
    client.println();
    
    uint16_t touched = ((MSB << 8) | LSB); //16bits that make up the touch states

    
    for (int i=0; i < 13; i++){  // Check what electrodes were pressed
      if(touched & (1<<i)){
      
        if(touchStates[i] == 0){
          //pin i was just touched
          Serial.print("pin ");
          Serial.print(i);
          Serial.println(" was just touched");
//          client.write((byte) i);
//          client.write((byte) 1);
        
        }else if(touchStates[i] == 1){
          //pin i is still being touched
        }  
      
        touchStates[i] = 1;      
      }else{
        if(touchStates[i] == 1){
          Serial.print("pin ");
          Serial.print(i);
          Serial.println(" is no longer being touched");
//          client.write((byte) i);
//          client.write((byte) 0);
          
          //pin i is no longer being touched
       }
        
        touchStates[i] = 0;
      }
    
    }
    
  }
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

  set_register(0x5A, ELEPROX_T, 0x02);
  set_register(0x5A, ELEPROX_R, 0x01);
  
  // Section D
  // Set the Filter Configuration
  // Set ESI2
  set_register(0x5A, FIL_CFG, 0x04);
  
  // Section E
  // Electrode Configuration
  // Set ELE_CFG to 0x00 to return to standby mode
  // set_register(0x5A, ELE_CFG, 0x0C);  // Enables all 12 Electrodes
  set_register(0x5A, ELE_CFG, 0x1C);  // Enables all 12 Electrodes and proximity (electrode 13)
  
  
  // Section F
  // Enable Auto Config and auto Reconfig
  /* set_register(0x5A, ATO_CFG0, 0x0B);
  set_register(0x5A, ATO_CFGU, 0xC9);  // USL = (Vdd-0.7)/vdd*256 = 0xC9 @3.3V   set_register(0x5A, ATO_CFGL, 0x82);  // LSL = 0.65*USL = 0x82 @3.3V
  set_register(0x5A, ATO_CFGT, 0xB5);*/  // Target = 0.9*USL = 0xB5 @3.3V
  
  // set_register(0x5A, ELE_CFG, 0x0C);
  
  // set_register(0x5A, ELE_CFG, 0x0C);
}


boolean checkInterrupt(void){
  return digitalRead(irqpin);
}


void set_register(int address, unsigned char r, unsigned char v){
    Wire.beginTransmission(address);
    Wire.write(r);
    Wire.write(v);
    Wire.endTransmission();
}
