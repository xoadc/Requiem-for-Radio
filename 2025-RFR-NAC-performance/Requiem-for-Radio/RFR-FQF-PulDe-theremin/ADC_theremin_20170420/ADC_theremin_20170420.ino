
/*
Analogue to digital conversion code for theremin CV output from pitch and volume antennae
*/
 
// which pins do what with the thermins
int pitchPin = 0;    
int pitchVal = 0;  
int volPin = 1;
int volVal = 0;

// used in the slip.write function to build slip packets of multiple bytes
int EOP = 192;
int ESC = 219;
int ESC_EOP = 220;
int ESC_ESC = 221;

void setup() {
  // this baud rate will make shit go fast yo! not really fast... but sorta faster.
  Serial.begin(115200);
}

void loop() {
  Serial.write(EOP);
  // pitch antenna control voltage
  pitchVal = analogRead(pitchPin);
  slipWrite(pitchVal >> 8);
  slipWrite(pitchVal & 255);
  // volume antenna control voltage
  volVal = analogRead(volPin);
  slipWrite(volVal >> 8);
  slipWrite(volVal & 255);
  Serial.write(EOP);
  delay(3);
}

  // to build slip packets that don't have values of 192 confused for the EOPs
void slipWrite (int value) {
  if(value == EOP) {
    Serial.write(ESC);
    Serial.write(ESC_EOP);
  } else if(value == ESC) {
    Serial.write(ESC);
    Serial.write(ESC_ESC);
  } else {
    Serial.write(value);
  }
}

