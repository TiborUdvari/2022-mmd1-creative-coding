// https://bleuje.com/tutorial3/

// Noise propagation

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

int seed = 12345;
float scl = 0.018;
float rad = 1.3;
int m = 80;
boolean periodicFuncDebug = false;
float offScl = 0.15;

// Recording
String recordingName;
boolean recording = false;
boolean pRecording = false;
int numFrames = 30;
int startFrame = 0;

// todo
// Add way to save as a movie
// Add slider for second seed value change

void setup() {

  println(sketchPath());
  String path = sketchPath();

  ProcessBuilder processBuilder = new ProcessBuilder();
  processBuilder.directory(new File(path));
  //processBuilder.command("/usr/bin/say", "welcome to the command line");

  processBuilder.command("/bin/zsh", "mkdir", "hello-folder");

  try {

    Process process = processBuilder.start();

    BufferedReader reader =
      new BufferedReader(new InputStreamReader(process.getInputStream()));

    String line;
    while ((line = reader.readLine()) != null) {
      System.out.println(line);
    }

    int exitCode = process.waitFor();
    System.out.println("\nExited with error code : " + exitCode);
  }
  catch (IOException e) {
    e.printStackTrace();
  }
  catch (InterruptedException e) {
    e.printStackTrace();
  }




  //exec(["/bin/zsh", "mkdir hello-tibor-test"], sketchPath());


  // IG reels sizes
  // with external screen
  fullScreen(2);
  noSmooth();

  //size(1080, 1920);
  //size(540, 810, P2D);
  pixelDensity(2);

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

  cp5.addButton("recordSketch")
    .setPosition(10, 14 + 10 * 7 + 8 * 7)
    .setSize(100, 14);

  cp5.addRadioButton("radioDebug")
    .setPosition(10, 14 + 10 * 8 + 8 * 8)
    .addItem("debug", 1);

  // exec("/usr/bin/say", "welcome to the command line");
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

  strokeCap(PROJECT);

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

  drawRecording();
}

void drawRecording() {
  if (!recording) return;

  println("save");

  int currentFrame = frameCount - startFrame;

  if (currentFrame <= numFrames)
  {
    save(recordingName + "_" + String.format("%03d", currentFrame) + ".png");
  }
  if (currentFrame >= numFrames)
  {
    println("All frames have been saved");
    recording = false;
    // launch terminal things
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

void recordSketch() {
  println("Record sketch");
  DateTimeFormatter dtf = DateTimeFormatter.ofPattern("uuuu-MM-dd_HH-mm-ss");
  LocalDateTime now = LocalDateTime.now();
  String fn = dtf.format(now);
  recordingName = fn;

  startFrame = frameCount + 1;
  recording = true;
}

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
