// todo

// Save and load into propery set 

// Get property sets as strings

// Load as string from json

// 1,2,3,4,5

// Transform property set tweening library 
// Save different transitions
// Have 10 different ways to animate

import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import controlP5.*;
import java.time.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;

OpenSimplexNoise noise;
ControlP5 cp5;

// Recording
String recordingName;
boolean recording = false;
boolean pRecording = false;
int numFrames = 60;
int startFrame = 0;

// Video export does not work with resolutions that widths are not divisible by 2
/*
  360 degrees
 Diameter: 8 m
 Resolution 180:  4500 x 1080 – 4.16
 Resolution 360: 11000 x 2000 – 5.5
 
 Resolution thing 7680 x 1440 – 5.3
 
 */

// vid.avi -s 800x800 -sws_flags neighbor -sws_dither none -vcodec rawvideo vid2.avi

final int instagramMinW = 500;
final int instagramMinH = 888;

final int instagramW = 1080;
final int instagramH = 1920;

//final int circularScreenW = 4500;
//final int circularScreenH = 1080;

final int circularScreenW = 7680;
final int circularScreenH = 1440;

//float ratio = 1;
//int W = instagramMinW;
//int H = instagramMinH;

float ratio = 0.15;
int W = circularScreenW;
int H = circularScreenH;

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

boolean periodicFuncDebug = false;
float offScl = 0.15;
float periodicFuncScale = 1;
float dotSizePct = 0.01;

// Animation
// Has 10 slots for states
// Change - load next one and transition with anki

int animIndex;

void keyPressed() {
  println(keyCode);
  
  int numCode = keyCode - 48;
  if (numCode >= 0 && numCode < 10) {
    animIndex = numCode;
    // Load the json file if exists
    println("Load params");
    var fn = String.format("data/%d.json", animIndex);
    println(fn);
    //cp5.loadProperties(fn);
  }
  
  if (keyCode == 76) // l 
  {
    println("Load current data");
    var fn = String.format("data/%d.json", animIndex);
    println("Load data from " + fn);
    cp5.loadProperties(fn);
    
    JSONObject json = loadJSONObject(fn);
    println(json);
    
    var properties = (String[]) json.keys().toArray(new String[json.size()]);
    for (int i = 0; i < properties.length; i++) {
      String k = properties[i];
      float f = json.getObject(k).getFloat("value");
      
      println(k);
      println(f);
      println("----");
    }
    println(properties);
    // Get all the keys
    
    /*
    int id = json.getInt("id");
    String species = json.getString("species");
    String name = json.getString("name");
    */
    //println(id + ", " + species + ", " + name);
  }
  
  if (keyCode == 83) // s
  {
    println("Save current data");
    var fn = String.format("data/%d.json", animIndex);
    println("Save data to " + fn);
    cp5.saveProperties(fn);
  }
  
  // transition
  // ---
  // Load the json from file
  
}

void setupCP5() {
  cp5 = new ControlP5(this);
  
  int pl = 10; // padding left
  int pt = 10; // padding top
  int w = 100;
  int h = 14;
  int gap = 4;
  
  ArrayList<controlP5.Controller> sliders = new ArrayList<controlP5.Controller>();
  controllers = new ArrayList<controlP5.Controller>();
    
  Slider scaleSlider = cp5.addSlider("scl", 0.001, 0.099);
  scaleSlider.setDefaultValue(0.018);
  controllers.add(scaleSlider);
  sliders.add(scaleSlider);
  
  Slider seedSlider = cp5.addSlider("sliderSeed", 10000, 99999);
  seedSlider.setDefaultValue(12345);
  controllers.add(seedSlider);
  sliders.add(seedSlider);
  
  Slider radSlider = cp5.addSlider("rad", 0.01, 1.5);
  radSlider.setDefaultValue(1.3);
  controllers.add(radSlider);
  sliders.add(radSlider);  
  
  Slider periodicFuncScaleSlider = cp5.addSlider("periodicFuncScale", 0.01, 10);
  periodicFuncScaleSlider.setDefaultValue(0.5);
  controllers.add(periodicFuncScaleSlider);
  sliders.add(periodicFuncScaleSlider);  
  
  Slider dotSizePctSlider = cp5.addSlider("dotSizePct", 0, 2);
  dotSizePctSlider.setDefaultValue(0.1);
  controllers.add(dotSizePctSlider);
  sliders.add(dotSizePctSlider);  
  
  Slider colsSlider = cp5.addSlider("cols", 1, 10);
  colsSlider.setDefaultValue(5);
  controllers.add(colsSlider);
  sliders.add(colsSlider);  
  
  Slider rowsSlider = cp5.addSlider("rows", 1, 10);
  rowsSlider.setDefaultValue(5);
  controllers.add(rowsSlider);
  sliders.add(rowsSlider);  
  
  Slider mxSlider = cp5.addSlider("mx", 0.01, 1.0);
  mxSlider.setDefaultValue(0.5);
  controllers.add(mxSlider);
  sliders.add(mxSlider); 
  
  Slider mySlider = cp5.addSlider("my", 0.01, 1.0);
  mySlider.setDefaultValue(0.5);
  controllers.add(mySlider);
  sliders.add(mySlider); 
  
  
  Slider offsetScaleSlider = cp5.addSlider("offScl", 0.001, 0.015);
  rowsSlider.setDefaultValue(1);
  controllers.add(offsetScaleSlider);
  sliders.add(offsetScaleSlider); 
  
  
  var sameParamsButton = cp5.addButton("saveParamsDefault");
  controllers.add(sameParamsButton);
  sliders.add(sameParamsButton);

  var loadParamsButton = cp5.addButton("loadParams");
  controllers.add(loadParamsButton);
  sliders.add(loadParamsButton);

  var recordSketchButton = cp5.addButton("recordSketch");
  controllers.add(recordSketchButton);
  sliders.add(recordSketchButton);

/*
  var debugRadio = cp5.addRadioButton("radioDebug");
  debugRadio.addItem("debug", 1);
  debugRadio.setPosition(pl, pt + (h + gap) * controllers.size());
  debugRadio.setSize(w, h);
  */
  /*
  var resolutionRadio = cp5.addRadioButton("resolutionPreset");
  resolutionRadio.addItem("IG vs 360", 1);
  resolutionRadio.setPosition(pl, pt + (h + gap) * (controllers.size() + 1));
  resolutionRadio.setSize(w, h);
  */
  
  for (int i = 0; i < sliders.size(); i++) {
    controlP5.Controller c = sliders.get(i);
  }

  for (int i = 0; i < controllers.size(); i++) {
    controlP5.Controller c = controllers.get(i);
    c.setSize(w, h);
    c.setPosition(pl, pt + h * i + gap * i);
  }  
}

class CustomWaveForm implements Waveform {
  float value(float v) {
    //return sin(TAU * v);
    /*
    println(v);
     println(res);*/
    float res = periodicFunction(v, 0, 0, 0);
    return res;
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
  return  periodicFuncScale * (float)noise.eval(seed+rad*cos(TAU*p), rad*sin(TAU*p), scl*x, scl*y);
}

void drawDots() {
  float sw2screen = 1.0 / ratio;

  b.beginDraw();

  float t = 1.0 * frameCount/numFrames;

  b.fill(0);
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

      float dx = 20.0 * periodicFunction(t + offset(x, y), 0, x, y);
      float dy = 20.0 * periodicFunction(t + offset(x, y), 123, x, y);

      //dx = 0;
      //dy = 0;
      b.point((int)x+dx, (int)y+dy);
    }
  }

  b.endDraw();

  drawRecording();
}

void setup() {
  //surface.setResizable(true);

  frameRate(60);
  b = createGraphics(W, H, P2D);
  b.smooth(8);

  noise = new OpenSimplexNoise(12345);
  Ani.init(this);

  minim = new Minim(this);
  out = minim.getLineOut();

  CustomWaveForm customWaveForm = new CustomWaveForm();

  wave = new Oscil( 44, 1f, customWaveForm );
  wave.patch(out);

  setupCP5();
  
  
  var test = cp5.getProperties();
  
  // Get all the names of all the properties
  var s = "";
  var t = test.get();
  for ( ControllerProperty c : test.get().keySet( ) ) {
      s += "\t" + c + "\t"  + "\n";
    } //<>//
    
   for ( var c : test.get().values( ) ) {
      s += "\t" + c + "\t"  + "\n";
    }
    
    /*
  for ( ControllerProperty c : test.get().keySet( ) ) {
      s += "\t" + c + "\t"  + "\n";
    }*/
  println(s); //<>//
    
  println("---  Done --- "); //<>//
  println(test.toString());
  //exit();

  //Ani.to(this, 3, "scl:0.06", Ani.SINE_IN_OUT);
}

void settings() {
  size(displayW, displayH, P2D);

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
  
  
  if (periodicFuncDebug) {
    drawPeriodicFunction();
  }
}

void drawRecording() {
  if (!recording) return;

  int currentFrame = frameCount - startFrame;

  if (currentFrame < numFrames)
  {
    b.save(recordingName + "_" + String.format("%03d", currentFrame) + ".png");
  }
  if (currentFrame >= numFrames)
  {
    println("All frames have been saved");
    VideoExporter.generateVideo(this, recordingName);
    VideoExporter.cleanupImages(this, recordingName);

    launch("%s/%s.mov".formatted(sketchPath(), recordingName));

    recording = false;
    // launch terminal things
  }
}

void drawNoise() {
  b.loadPixels();

  for (int x = 0; x < W; x++) {
    for (int y = 0; y < H; y++) {
      float val = (float)periodicFunction(0f, 0f, (float)x, (float)y);
      color c = color(map(val, -1, 1, 0, 1) * 255);

      b.pixels[y * W + x] = c;
    }
  }

  b.updatePixels();
}

// This draws only one line, not everything
void drawPeriodicFunction() {
  stroke(0, 255, 0);
  strokeWeight(1);
  for (int i = 0; i < displayW; i++) {
    float val1 = (float)periodicFunction((float)(i + 0) / displayW, 0f, 1f, 1f);
    float val2 = (float)periodicFunction(((float)i + 1) / displayW, 0f, 1f, 1f);
    val1 = map(val1, -1, 1, 0, 1);
    val2 = map(val2, -1, 1, 0, 1);

    // draw line between them
    line(i, val1 * displayH, i+1, val2 * displayH);
  }
}

float getValue(int x) {
  float delta = 1.0 / W;
  float t = delta * x;
  float samplingX = cos(t * TAU) * rad + W * 0.5;
  float samplingY = sin(t * TAU) * rad + H * 0.5;
  float val = (float)noise.eval(scl * samplingX, scl * samplingY);
  float normalized = (val + 1) / 2;
  return normalized;
}

// --- Control P5 ---

/*
void scl(float v){
 //scl=v;
 println("update");
 Ani.to(this, 3, "scl:"+v, Ani.SINE_IN_OUT);
 //s.setValue(scl);
 }
 */

void setScl(float v) {
  println(v);
}

void resolutionPreset(int is360) {
  return;
  /*
  if (is360 > 0) {
    ratio = 0.3;
    W = circularScreenW;
    H = circularScreenH;
  } else if ( is360 < 0) {
    ratio = 1;
    W = instagramMinW;
    H = instagramMinH;
  }

  displayW = (int)(W * ratio);
  displayH = (int)(H * ratio);
  
  b = createGraphics(W, H, P2D);
  b.smooth(8);
  surface.setSize(displayW, displayH);*/
}

void recordSketch() {
  println("Record sketch");
  String fn = VideoExporter.defaultFileName(this);
  recordingName = fn;

  startFrame = frameCount + 1;
  recording = true;
  saveParamsDefault();
}

void saveParamsDefault() {
  String fn = VideoExporter.defaultFileName(this);
  saveParams(fn);
  
  var fnAnim = String.format("data/%d.json", animIndex);
  saveParams(fnAnim);
}

void saveParams(String fn) {
  println("Save params");

  cp5.saveProperties();
  cp5.saveProperties(fn);
}

void loadParams() {
  println("Load params");
  cp5.loadProperties();
}

public void sliderSeed(int value) {
  noise = new OpenSimplexNoise(value);
}

void radioDebug(int val) {
  periodicFuncDebug = val > 0;
}
