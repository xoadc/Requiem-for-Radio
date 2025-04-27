DigitalClock digitalClock;
final int utcHourOffset = 3; // Change depending on current timezone.  No offset for minutes, so it is impossible to perform in NFL. (For now.)
final int textSize = 400; // Change size of text.
final int blur = 8; // change bluriness.
PFont font;
// The font must be located in the sketch's 
// "data" directory to load successfully



void setup() {
  // size(240, 240 );
  fullScreen();
  digitalClock = new DigitalClock(textSize, width/2, height/2 + 100);
  font = createFont("digital-7 (mono italic).ttf", 32);
}

void draw() {
  background(0);
  digitalClock.getTime();
  digitalClock.display();
  filter(BLUR, blur);
}

class DigitalClock extends Clock {
  int fontSize;
  float x, y;
  
  DigitalClock(int _fontSize, float _x, float _y) {
    fontSize = _fontSize;
    x = _x;
    y = _y;
  }
  
  void getTime() {
    super.getTime();
  }
  
  void display() {
    // textSize(fontSize);
    textAlign(CENTER);
    fill(color(255,10,10,255));
    textFont(font, fontSize);
    text (h + ":" + nf(m, 2) + ":" + nf(s, 2), x, y);
  } 
}

class Clock {
  int h, m, s;
  Clock() {
  }
  
  void getTime() {
    h = hour() + utcHourOffset;
    m = minute();
    s = second();
  }
}