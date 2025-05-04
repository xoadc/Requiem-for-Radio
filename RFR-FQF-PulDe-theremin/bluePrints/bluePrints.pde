/*

 */
 
import oscP5.*;
import netP5.*;
OscP5 oscP5;

char[] towers = {'C', 'D', 'E', 'F', 'H', 'I', 'J', 'K', 'M', 'N', 'O', 'P', 'Q'};
PImage[] images = new PImage[13];
float[] alphas = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
float volume = 1.0;

int imgWidth, imgHeight;

int[][] availableResolutions = {
  {720, 480},
  {1024, 768},
  {1920, 1080},
  {1920, 1536}
};

void setup() 
{
  frameRate(30);
  fullScreen();
  
  selectResolution();
  
  // load the images with the biggest possible resolution
  for (int i = 0 ; i < towers.length ; i++) 
  {
    String name = "RfrPd_" + towers[i] + "_" + str(imgWidth) + "x" + str(imgHeight) + ".jpg";
    images[i] = loadImage(name);
    println("Loaded: " + name);
  };
  
  /* start oscP5, listening for incoming messages at port 60120 */
  oscP5 = new OscP5(this,60120);
  oscP5.plug(this,"alphaChannels","/alphaChannels");
  oscP5.plug(this,"volume","/volume");
}


public void alphaChannels(float... transparencies) 
{
  alphas = transparencies;
}

public void volume(float vol) 
{
  volume = vol;
}

void selectResolution()
{
  println("Detected display size: " + displayWidth + "x" + displayHeight);
  
  // start the at the smallest resolution
  imgWidth = availableResolutions[0][0];
  imgHeight = availableResolutions[0][1];
  
  // Find the best fit 
  for (int i = 0; i < availableResolutions.length; i++)
  {
    int w = availableResolutions[i][0];
    int h = availableResolutions[i][1];
    
    // if this resolution fits the display and is larger than then current selection
    if (w <= displayWidth && h <= displayHeight && (w * h > imgWidth * imgHeight))
    {
      imgWidth = w;
      imgHeight = h;
    }
  }
    
  // if all resolutions are larger than the display, use the smallest images
  if (imgWidth > displayWidth || imgHeight > displayHeight)
  {
    imgWidth = availableResolutions[0][0];
    imgHeight = availableResolutions[0][1];
  }
    
  println("Selected image resolution: " + imgWidth + "x" + imgHeight);
  
}

void draw() 
{ 
  background(0);
  
  // use the pitch and volume data to control the which image is displayed and the opacity of the image respectively.
  for (int i = 0 ; i < alphas.length ; i++ ) 
  {
    // small number to ensure there is actually alpha data to use that isn't noise.
    if (alphas[i] > 0.01) 
    {
      tint(255, alphas[i] * 255 * volume);
      image(images[i], (width-imgWidth)/2, (height-imgHeight)/2);
    };
  };
}
