import ddf.minim.*;
import ddf.minim.analysis.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import oscP5.*;
import netP5.*;

// Audio
Minim minim;
AudioInput in;
FFT fft;
int fftPortionLen;
// Video
Capture cam;
OpenCV opencv;
PVector avgFlowLeft, avgFlowRight;
int flowScale = 150;
// OSC messages
OscP5 osc;
NetAddress addressLI;
OscMessage right = new OscMessage("/right");
OscMessage left = new OscMessage("/left");
OscMessage up = new OscMessage("/up");
OscMessage down = new OscMessage("/down");
OscMessage triggerAgent = new OscMessage("/triggerAgent");

void setup()
{
  size(640, 480, P3D);

  // Audio
  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT( in.bufferSize(), in.sampleRate() );
  fftPortionLen = round(fft.specSize()/10 - 5);
  // Video
  cam = new Capture(this, "pipeline:autovideosrc");
  opencv = new OpenCV(this, 640, 480);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  cam.start();
  // OSC messages
  osc = new OscP5(this,12004);
  addressLI = new NetAddress("127.0.0.1",12000);
  
  osc.send(triggerAgent, addressLI);
  
  println(fftPortionLen);
}

void draw()
{
  // OpenCV
  opencv.loadImage(cam);
  opencv.flip(1);
  opencv.calculateOpticalFlow();
  
  // Show video
  pushMatrix();
  scale(-1, 1);
  image(cam, -cam.width, 0);
  popMatrix();
  
  // Show HUD
  
  //opencv.drawOpticalFlow();
  
  avgFlowLeft = opencv.getAverageFlowInRegion(1,1,width/2-1, height-1);
  avgFlowRight = opencv.getAverageFlowInRegion(width/2+1,1,width/2-1, height-1);
  // Send movement messages from video
  if(avgFlowLeft.mag()*flowScale >= 40){
    println("L");
    osc.send(left, addressLI);
  }
  if (avgFlowRight.mag()*flowScale >= 40){
    println("R");
    osc.send(right, addressLI);
  }
  
  // Show flow averaged with line
  stroke(255);
  strokeWeight(1);
  line(cam.width/4, cam.height/2, cam.width/4 + avgFlowLeft.x*flowScale, cam.height/2 + avgFlowLeft.y*flowScale);
  line(cam.width*3/4, cam.height/2, cam.width*3/4 + avgFlowRight.x*flowScale, cam.height/2 + avgFlowRight.y*flowScale);
  
  //-----------------------------------------------------------------------------------------------------
  // perform a forward FFT on the samples in jingle's mix buffer,
  // which contains the mix of both the left and right channels of the file
  fft.forward(in.left);
  
  // draw the waveforms so we can see what we are monitoring
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    line( i, 50 + in.left.get(i)*100, i+1, 50 + in.left.get(i+1)*100 );
    //line( i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50 );
  }
  
  float maxVal = fft.getBand(5);
  int id = 5;
  for(int i = 5; i < fftPortionLen; i++)
  {
    
    if (fft.getBand(i) > maxVal){
      maxVal = fft.getBand(i);
      id = i;
    }
    // draw the line for frequency band i, scaling it up a bit so we can see it
    line( i*width/fftPortionLen, height, i*width/fftPortionLen, height - fft.getBand(i)*8 );
  }
  
  // Triggger up or down
  if(id < fftPortionLen/2 && maxVal >= 10) {
    osc.send(down, addressLI);
  } else if (id > fftPortionLen/2 && maxVal >= 10) {
    osc.send(up, addressLI);
  }
  
  
  line( width/2, height, width/2, 0); // draw separator
}

void captureEvent(Capture c) {
  c.read();
}

// Receive OSC triggers
void oscEvent(OscMessage trigger)
{
  // Exit applet
  if(trigger.checkAddrPattern("/terminate")) {
    osc.send(triggerAgent, addressLI);
    exit();
  }
}
