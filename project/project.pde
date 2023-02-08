OpenSimplexNoise noise; //<>// //<>//
ControlP5 cp5;

float numFrames = 600;
float ratio = 1;

final int instagramMinW = 500;
final int instagramMinH = 888;

int W = instagramMinW;
int H = instagramMinH;

int displayW = (int)(W * ratio);
int displayH = (int)(H * ratio);

PGraphics b; // b for buffer

// Audio
Minim minim;
AudioOutput out;
Oscil wave;
AudioRecorder audioRecorder;

ArrayList<controlP5.Controller> controllers;

int seed = 12345;
float scl = 0.018;
float rad = 1.3;

int cols = 1;
int rows = 1;

float mx = 0.5;
float my = 0.5;

boolean periodicFuncDebug = true;
float offScl = 0.15;
float periodicFuncScale = 1;
float dotSizePct = 0.01;

boolean cp5Visible = true;

// Animation
// Has 10 slots for states
// Change - load next one and transition with anki

int animIndex;

float offMultX = 20;
float offMultY = 20;
float bgFill = 50;

int lastLoad = 0;

AniSequence seq;
int sequenceCount = 9;
float delayHack = 0;

float gAccu = 0;

class CustomWaveForm implements Waveform {
  float value(float v) {
    
    
    //return periodicFunction(v, 0, 1, 1);
    //return sin(TAU * v);
    
    //float res = periodicFunction(v, 0, 1, 1);
  
    float accu = 0;
    float tot = rows + cols;
    
      float _mx = W * mx;
  float _my = H * my;
    
    for (int i=0, j=0; i<cols && j<rows; i++, j++)
    {
      
      float x = map(i, 0, max(cols-1, 1), _mx, W-_mx);
      float y = map(j, 0, max(rows-1, 1), _my, H-_my);

      float dx = offMultX * periodicFunction(v + offset(x, y), 0, x, y);
      float dy = offMultY * periodicFunction(v + offset(x, y), 123, x, y);

      accu += (( abs(dx  / W)) +  abs(dy  / H) ) ;
    
    }
    gAccu = accu;
    return accu;
  }
}

float offset(float x, float y)
{
  //return offScl*dist(x, y, W/2, H/2);
  // radial offset
  //return offScl * dist(x, y, W/2, H/2) / max(W, H) * 100;

  // min distance to corner
  //return offScl * dist(x, y, max(x, W/2), max(y, H/2)) / max(W, H) * 100;

  return offScl * x % 2 * 100;

  //return offScl * max(W/2, x) * 100;
}

float periodicFunction(float p, float seed, float x, float y)
{
  return periodicFuncScale * (float)noise.eval(seed+rad*cos(TAU*p), rad*sin(TAU*p), scl*x, scl*y);
}

void drawDots() {
  float sw2screen = 1.0 / ratio;

  b.beginDraw();

  float t = 1.0 * frameCount/numFrames;

  b.fill(0, bgFill);
  b.noStroke();
  b.rect(0, 0, W, H);

  b.strokeCap(SQUARE);

  b.stroke(255);
  b.strokeWeight(10 * sw2screen * dotSizePct * min(displayW, displayH) );
  b.strokeCap(ROUND);

  //b.strokeWeight(6);

  float _mx = W * mx;
  float _my = H * my;

  for (int i=0; i<cols; i++)
  {
    for (int j=0; j<rows; j++)
    {
      float x = map(i, 0, max(cols-1, 1), _mx, W-_mx);
      float y = map(j, 0, max(rows-1, 1), _my, H-_my);

      float dx = offMultX * periodicFunction(t + offset(x, y), 0, x, y);
      float dy = offMultY * periodicFunction(t + offset(x, y), 123, x, y);

      //dx = 0;
      //dy = 0;
      float s = 10 * sw2screen * dotSizePct * min(displayW, displayH);
      //b.strokeWeight( 1 / ( dx + dy)  * 10 * sw2screen * dotSizePct * min(displayW, displayH) );
      b.stroke(gAccu * gAccu * (abs(dx) + abs(dy)));
      b.point((int)x+dx, (int)y+dy);
    }
  }

  b.endDraw();

  drawRecording();
}

void setup() {
  //surface.setResizable(true);

  b = createGraphics(W, H, P2D);
  b.smooth(8);

  noise = new OpenSimplexNoise(12345);
  Ani.init(this);

  minim = new Minim(this);
  out = minim.getLineOut();

  CustomWaveForm customWaveForm = new CustomWaveForm();

  wave = new Oscil( 10, 1f, customWaveForm );
  //dotSizePct
  //wave = new Oscil( map(), 1f, customWaveForm );
  wave.patch(out);

  setupCP5();
  //frameRate(60);
  //sequence();
}

void settings() {
  size(displayW, displayH, P2D);
  //fullScreen(P2D, SPAN);
  noSmooth();

  //smooth(8);
  //fullScreen(2);
  //noSmooth();
  //pixelDensity(2);
};

void draw() {
  drawDots();
  image(b, 0, 0, width, height);

  // HACK
  //s.changeValue(scl);

  wave.setFrequency(constrain(map(dotSizePct, 0.0, 0.01, 22, 10), 10, 22));
  if (periodicFuncDebug) {
    drawPeriodicFunction();
  }
}

/*
float getValue(int x) {
 float delta = 1.0 / W;
 float t = delta * x;
 float samplingX = cos(t * TAU) * rad + W * 0.5;
 float samplingY = sin(t * TAU) * rad + H * 0.5;
 float val = (float)noise.eval(scl * samplingX, scl * samplingY);
 float normalized = (val + 1) / 2;
 return normalized;
 }*/
