// todo - set time code to frames for ani //<>//
// loop from 0 to 1 at 0.25 - 0.75
// add settings for this
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;

import java.util.Map;
import java.util.function.Function;

public class Memoizer4Floats {
  private final Map<String, Float> cache = new ConcurrentHashMap<>();
  private final Function<Float, Function<Float, Function<Float, Function<Float, Float>>>> function;

  public Memoizer4Floats(Function<Float, Function<Float, Function<Float, Function<Float, Float>>>> function) {
    this.function = function;
  }

  public Float apply(Float f1, Float f2, Float f3, Float f4) {
    String key = String.format("%f,%f,%f,%f", f1, f2, f3, f4);
    return cache.computeIfAbsent(key, k -> function.apply(f1).apply(f2).apply(f3).apply(f4));
  }
}

OpenSimplexNoise noise;
ControlP5 cp5;

float numFrames = 60;
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
Pan panPatch;

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
float aFillMix = 0.5;
int lastLoad = 0;

AniSequence seq;
int sequenceCount = 9;
float delayHack = 0;

// Set ani transitions to frames
// 1 - 2
// 1 - 2 dur
// 2 - 1
// 2 - 1 dur

boolean aniLooping = false;

float ani1Start = 0.;
float ani1Dur = 0.2;

float ani2Start = 0.5;
float ani2Dur = 0.2;


float gAccu = 0;

//int audioFreq = 180;
int audioFreq = 720;
float[] waveTable;

float gpan = 0f; // global pan

class CustomWaveForm implements Waveform {
  int loopCounter = 0;

  float value(float v) {
    float t = 1.0 * frameCount/numFrames;
    //v = (v + (t * audioFreq ) % 1) % 1;
    v = fract(t) + 1. * loopCounter/audioFreq;
    float pv = t + 1. * ((loopCounter * 2. - 1) % loopCounter)/audioFreq;

    float accu = 0;
    float tot = rows + cols;

    float _mx = W * mx;
    float _my = H * my;

    float pan = 0;

    int maxSamples = 8;
    int maxSamplesRecording = 80;

    int inc = !recording ? cols * rows / maxSamples  : cols * rows / maxSamplesRecording;
    inc = (int)max(1, (float)inc);
    //println(inc);

    for (int i=0; i < cols; i+=inc) {
      for (int j = 0; j < rows; j+=inc) {
        float x = map(i, 0, max(cols-1, 1), _mx, W-_mx);
        float y = map(j, 0, max(rows-1, 1), _my, H-_my);

        float dx = offMultX * periodicFunction(v, 0, x, y);
        float dy = offMultY * periodicFunction(v + offset(x, y), 123, x, y);

        float pdx = offMultX * periodicFunction(pv, 0, x, y);
        float pdy = offMultY * periodicFunction(pv + offset(x, y), 123, x, y);

        // Result should go between -1 and 1. Just using the x to keep it simple
        //accu += (( abs(dx  / W)) +  abs(dy  / H) );
        // It should be the speed, it would make more sense auditively

        //accu += dx / W;
        float val = ((dx - pdx) / W + (dy - pdy) / H) / max(1, (cols * rows / inc));
        accu += val * 100 ;

        pan += 1. * (x + dx) / W * 2. - 1.;
        //accu = dx / W;
      }
    }
    accu = constrain(accu, -.9, .9);

    waveTable[loopCounter] = accu;
    loopCounter = (loopCounter + 1) % audioFreq;
    gpan = pan;
    gpan = constrain(gpan, -.9, .9);
    panPatch.setPan(gpan);
    gAccu = accu;
    return accu;
  }
}

float offset(float x, float y)
{
  //return offScl*dist(x, y, W/2, H/2);
  // radial offset
  return offScl * dist(x, y, W/2, H/2) / max(W, H) * 100;

  // min distance to corner
  //return offScl * dist(x, y, max(x, W/2), max(y, H/2)) / max(W, H) * 100;

  //return offScl * x % 2 * 100;

  //return offScl * max(W/2, x) * 100;
}

Function<Float, Function<Float, Function<Float, Function<Float, Float>>>> myFunction = p -> seed -> x -> y -> {
  // compute result here
  return periodicFuncScale * (float)noise.eval(seed+rad*cos(TAU*p), rad*sin(TAU*p), scl*x, scl*y);
};

Memoizer4Floats memoizedFunction = new Memoizer4Floats(myFunction);




float periodicFunction(float p, float seed, float x, float y)
{
  return periodicFuncScale * (float)noise.eval(seed+rad*cos(TAU*p), rad*sin(TAU*p), scl*x, scl*y);
  /*
  float result = memoizedFunction.apply(p, seed, x, y);
   return result;
   */
}


void drawDots() {
  float sw2screen = 1.0 / ratio;

  b.beginDraw();

  float pt = 1.0 * ((frameCount + numFrames - 1) % 2)/numFrames;
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

  for (int i=0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      float x = map(i, 0, max(cols-1, 1), _mx, W-_mx);
      float y = map(j, 0, max(rows-1, 1), _my, H-_my);

      float dx = offMultX * periodicFunction(t + offset(x, y), 0, x, y);
      float dy = offMultY * periodicFunction(t + offset(x, y), 123, x, y);

      float pdx = offMultX * periodicFunction(pt + offset(x, y), 0, x, y);
      float pdy = offMultY * periodicFunction(pt + offset(x, y), 123, x, y);

      float deltaPos = (abs(dx) / W + abs(dy) / H) / 2. ;
      float deltaPosFactor = map(deltaPos, 0, 1, 1, 0.6);
      //dx = 0;
      //dy = 0;
      //float dMovement = (dx - pdx) + (dy );
      float s = 10 * sw2screen * dotSizePct * min(displayW, displayH) * deltaPosFactor;
      //b.strokeWeight( 1 / ( dx + dy)  * 10 * sw2screen * dotSizePct * min(displayW, displayH) );
      // is not affected by the audio wave
      //println(gAccu);
      //b.stroke(255, 255, 255, constrain(abs(gAccu * 10000), 0.5, 1.0 ) * 255);

      // Add some params
      float stokeVal = lerp(255., periodicFunction(t / 60 * 44000 + offset(x, y), 24, x, y) * 255., aFillMix);
      b.stroke(255, 255, 255, stokeVal );

      //b.stroke((abs(dx) + abs(dy)));
      b.strokeWeight(10 * sw2screen * dotSizePct * min(displayW, displayH) * deltaPosFactor );

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
  waveTable = new float[audioFreq];
  noise = new OpenSimplexNoise(12345);
  Ani.init(this);

  minim = new Minim(this);
  out = minim.getLineOut();

  CustomWaveForm customWaveForm = new CustomWaveForm();

  // 10 - frequency, 1f - amplitude
  wave = new Oscil( audioFreq, 1f, customWaveForm );
  // debug the addition of the waveform
  panPatch = new Pan(0.);
  //dotSizePct
  //wave = new Oscil( map(), 1f, customWaveForm );
  wave.patch(panPatch).patch(out);

  setupCP5();
  frameRate(60);
  //sequence();
  //Ani.timeMode = Ani.FRAMES;
  Ani.setDefaultTimeMode(Ani.FRAMES);

  // Do a sequence, repeat infinitely
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

  //wave.setFrequency(constrain(map(dotSizePct, 0.0, 0.01, 22, 10), 10, 22));
  fpsLabel.setText(String.format("%.2f", frameRate) + "FPS");
  if (periodicFuncDebug) {
    drawPeriodicFunction();
    drawWaveTable();
  }

  // get the t
  float pt = fract(1.0 * (frameCount - 1)/numFrames);
  float t = fract(1.0 * frameCount/numFrames);

  if (aniLooping && pt > t) {
    println("Started loop");
    ArrayList<String> sequences = new ArrayList<String>();

    for (int i = 0; i < sequenceCount; i++) {
      var fn = String.format("data/%d.json", i);
      String pl = jsonFileToPropertyList(fn);
      sequences.add(pl);
    }
    //println(sequences.get(0));
    //Ani.to(this, ani1Start * numFrames, 1.0 * numFrames * ani1Dur, sequences.get(0));
    //Ani.to(this, ani2Start * numFrames, 1.0 * numFrames * ani2Dur, sequences.get(1));
    loopSequence = new AniSequence(this);
    loopSequence.beginSequence();

    loopSequence.add(Ani.to(this, 0.2 * numFrames, 0.2 * numFrames, "mx:0.9"));
    loopSequence.add(Ani.to(this, 0.2 * numFrames, 0.2 * numFrames, "mx:0.1"));

    loopSequence.endSequence();
    loopSequence.start();
    //Ani.to(this, ani2Start * numFrames, 1.0 * numFrames * ani2Dur, sequences.get(1));
  }
}

void drawWaveTable() {
  stroke(255, 0, 0);
  strokeWeight(1);
  float step = 1. * displayW / audioFreq;
  for (int i = 0; i < audioFreq - 1; i++) {
    float val1 = waveTable[i];
    float val2 = waveTable[i+1];

    val1 = map(val1, -1, 1, 0, 1);
    val2 = map(val2, -1, 1, 0, 1);

    // draw line between them
    line(i * step, val1 * displayH, (i+1) * step, val2 * displayH);
  }
  line(0, H / 2, W, H / 2);
  stroke(255, 255, 255);
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
