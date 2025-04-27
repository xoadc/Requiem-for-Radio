/*

 */
 
import oscP5.*;
import netP5.*;
OscP5 oscP5;

char[] towers = {'C', 'D', 'E', 'F', 'H', 'I', 'J', 'K', 'M', 'N', 'O', 'P', 'Q'};
PImage[] images = new PImage[13];
float[] alphas = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
float volume = 1.0;
int imgWidth = 1024; // Change this to match the size of the images used.
int imgHeight = 768;

void setup() {
  //size(1024, 768);
  frameRate(30);
  fullScreen();
  for (int i = 0 ; i < towers.length ; i++) {
    String name = "RfrPd_" + towers[i] + "_" + str(imgWidth) + "x" + str(imgHeight) + ".jpg";
    //String name = "RfrPd_" + towers[i] + "_1920x1080" + ".jpg";
    images[i] = loadImage(name);
    println("Loaded: " + name);
  };
  /* start oscP5, listening for incoming messages at port 60120 */
  oscP5 = new OscP5(this,60120);
  oscP5.plug(this,"alphaChannels","/alphaChannels");
  oscP5.plug(this,"volume","/volume");
}


public void alphaChannels(float... transparencies) {
  alphas = transparencies;
}

public void volume(float vol) {
  volume = vol;
}

void draw() { 
  background(0);
  for (int i = 0 ; i < alphas.length ; i++ ) {
    if (alphas[i] > 0.01) {
      tint(255, alphas[i] * 255 * volume);
      image(images[i], (width-imgWidth)/2, (height-imgHeight)/2);
      //image(images[i], 0, 0);
    };
  };
}