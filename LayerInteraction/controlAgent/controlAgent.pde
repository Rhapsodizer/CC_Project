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
// Video
Capture cam;
OpenCV opencv;
// OSC messages
OscP5 osc;
NetAddress addressLI;
OscMessage right = new OscMessage("/right");
OscMessage left = new OscMessage("/left");

void setup()
{
  size(640, 480, P3D);

  // Audio
  minim = new Minim(this);
  in = minim.getLineIn();
  fft = new FFT( in.bufferSize(), in.sampleRate() );
  // Video
  cam = new Capture(this, "pipeline:autovideosrc");
  opencv = new OpenCV(this, 640, 480);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  cam.start();
  // OSC messages
  osc = new OscP5(this,12004);
  addressLI = new NetAddress("127.0.0.1",12000);
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
  stroke(255);
  //opencv.drawOpticalFlow();
  
  PVector aveFlow = opencv.getAverageFlow();
  int flowScale = 150;
  
  // Send movement messages from video
  if(aveFlow.x*flowScale>=10){
    println("RIGHT");
    osc.send(right, addressLI);
  } else if (aveFlow.x*flowScale<=-10){
    println("LEFT");
    osc.send(left, addressLI);
  }
  
  // Show flow averaged with line
  strokeWeight(1);
  line(cam.width/2, cam.height/2, cam.width/2 + aveFlow.x*flowScale, cam.height/2);
  
  //-----------------------------------------------------------------------------------------------------
  // perform a forward FFT on the samples in jingle's mix buffer,
  // which contains the mix of both the left and right channels of the file
  fft.forward(in.mix);
  
  // draw the waveforms so we can see what we are monitoring
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    line( i, 50 + in.left.get(i)*100, i+1, 50 + in.left.get(i+1)*100 );
    //line( i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50 );
  }
  for(int i = 0; i < fft.specSize()/3; i++)
  {
    // draw the line for frequency band i, scaling it up a bit so we can see it
    line( i*10, height, i*10, height - fft.getBand(i)*8 );
  }
}

void captureEvent(Capture c) {
  c.read();
}
