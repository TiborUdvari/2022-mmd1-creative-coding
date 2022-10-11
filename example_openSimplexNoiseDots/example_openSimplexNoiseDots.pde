// https://bleuje.com/tutorial3/

// Noise propagation

import controlP5.*;
import java.time.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

OpenSimplexNoise noise;
ControlP5 cp5;

int seed = 12345;
float scl = 0.018;

float rad = 1.3;

int m = 80;
boolean periodicFuncDebug = false;
float offScl = 0.15;

void setup() {
  
  // IG reels sizes
  //size(1080, 1920);
  size(540, 810, P2D);
  //size(270, 405);

  noise = new OpenSimplexNoise(12345);

  cp5 = new ControlP5(this);

  cp5.addSlider("sliderScl", 0.001, 0.099, 0.018, 10, 10, 100, 14);
  cp5.addSlider("sliderSeed", 10000, 99999, 12345, 10, 14 + 10 + 8, 100, 14);
  cp5.addSlider("sliderRad", 0.1, 3.0, 1.3, 10, 14 + 10 * 2 + 8 * 2, 100, 14);
  cp5.addSlider("sliderN", 10, 200, 80, 10, 14 + 10 * 3 + 8 * 3, 100, 14);
  cp5.addSlider("sliderOffScl", 0.001, 0.015, 1, 10, 14 + 10 * 4 + 8 * 4, 100, 14);
  
  cp5.addButton("saveParams")
    .setPosition(10, 14 + 10 * 5 + 8 * 5)
    .setSize(100, 14);
    
  cp5.addButton("loadParams")
    .setPosition(10, 14 + 10 * 6 + 8 * 6)
    .setSize(100, 14);

  cp5.addRadioButton("radioDebug")
    .setPosition(10, 14 + 10 * 7 + 8 * 7)
    .addItem("debug", 1);
}

void draw() {
  background(0);
  drawDots();

  if (periodicFuncDebug) {
    drawPeriodicFunction();
  }
}

float offset(float x, float y)
{
  return offScl*dist(x, y, width/2, height/2);
}

float periodicFunction(float p, float seed, float x, float y)
{
  return (float)noise.eval(seed+rad*cos(TAU*p), rad*sin(TAU*p), scl*x, scl*y);
}

void drawDots() {
  int numFrames = 30;
  float t = 1.0*frameCount/numFrames;

  stroke(255);
  strokeWeight(1.5);

  for (int i=0; i<m; i++)
  {
    for (int j=0; j<m; j++)
    {
      float margin = 50;
      float x = map(i, 0, m-1, margin, width-margin);
      float y = map(j, 0, m-1, margin, height-margin);

      float dx = 20.0 * periodicFunction(t + offset(x, y), 0, x, y);
      float dy = 20.0 * periodicFunction(t + offset(x, y), 123, x, y);

      //dx = 0;
      //dy = 0;
      point(x+dx, y+dy);
    }
  }
}

void drawNoise() {
  loadPixels();

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float val = (float)periodicFunction(0f, 0f, (float)x, (float)y);
      color c = color(map(val, -1, 1, 0, 1) * 255);
      pixels[y * width + x] = c;
    }
  }

  updatePixels();
}

// This draws only one line, not everything
void drawPeriodicFunction() {
  stroke(0, 255, 0);

  for (int i = 0; i < width; i++) {
    float val1 = (float)periodicFunction(0f, 0f, (float)i, 0) ;
    float val2 = (float)periodicFunction(0f, 0f, (float)i + 1, 0);
    val1 = map(val1, -1, 1, 0, 1);
    val2 = map(val2, -1, 1, 0, 1);
    point(i, val1 * height);

    // draw line between them
    line(i, val1 * height, i+1, val2 * height);
  }
}

float getValue(int x) {
  float delta = 1.0 / width;
  float t = delta * x;
  float samplingX = cos(t * TAU) * rad + width * 0.5;
  float samplingY = sin(t * TAU) * rad + height * 0.5;
  float val = (float)noise.eval(scl * samplingX, scl * samplingY);
  float normalized = (val + 1) / 2;
  return normalized;
}

// --- Control P5 ---

void saveParams() {
  println("Save params");

  DateTimeFormatter dtf = DateTimeFormatter.ofPattern("uuuu-MM-dd_HH-mm-ss");
  LocalDateTime now = LocalDateTime.now();
  String fn = dtf.format(now);
  
  cp5.saveProperties();
  cp5.saveProperties(fn);
}

void loadParams() {
  println("Load params");
  cp5.loadProperties();
}

public void sliderScl(float value) {
  scl = value;
  //drawNoise();
  //drawPeriodicFunction();
}

public void sliderSeed(int value) {
  noise = new OpenSimplexNoise(value);
  //drawNoise();
  //drawPeriodicFunction();
}

public void sliderRad(float value) {
  rad = value;
  //drawNoise();
  //drawPeriodicFunction();
}

void radioDebug(int val) {
  periodicFuncDebug = val > 0;
}

void sliderN(float val) {
  m = (int) val;
}

void sliderOffScl(float val) {
  offScl = val;
}
