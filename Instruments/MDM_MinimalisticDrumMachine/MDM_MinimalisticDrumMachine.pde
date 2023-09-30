import oscP5.*;
import netP5.*;
  
OscP5 osc;
NetAddress oscSC, oscLI;

// variables
int nSteps;
int curr, pos;
int textHeight = 20;
int t;
boolean play = false;

ArrayList<Step> bHat = new ArrayList<Step>();
ArrayList<Step> bSnr = new ArrayList<Step>();
ArrayList<Step> bKik = new ArrayList<Step>();

PImage img;


void setup()
{
  size(900, 200);
  nSteps = int(args[0]);
  
  boolean[] hatRow = new boolean[nSteps];
  boolean[] snrRow = new boolean[nSteps];
  boolean[] kikRow = new boolean[nSteps];
  
  // OSC
  osc = new OscP5(this,12001);
  oscSC = new NetAddress("127.0.0.1",57120);
  oscLI = new NetAddress("127.0.0.1",12000);
  
  OscMessage numSteps = new OscMessage("/nStep");
  numSteps.add(nSteps);
  osc.send(numSteps, oscLI);
  
  // construct grid
  for (int i = 0; i < nSteps; i++)
  {
    bHat.add( new Step(100+i*50, 50, i, "hat", hatRow) );
    bSnr.add( new Step(100+i*50, 100, i, "snare", snrRow ) );
    bKik.add( new Step(100+i*50, 150, i, "kick", kikRow ) );
  }
  
  // Set initial step and marker position
  curr = 0;
  pos = curr;
  
  // Load image
  img = loadImage("elvis.png");
}

void draw()
{
  background(220);
  fill(255);
  
  // Draw image
  image(img,717,0,186,200);
  
  // Labels
  textSize(textHeight);
  fill(80);
  text("HAT", 20, 50 + textHeight/2);
  text("SNR", 20, 100 + textHeight/2);
  text("KIK", 20, 150 + textHeight/2);
  
  for(int i = 0; i < nSteps; ++i)
  {
    bHat.get(i).draw();
    bSnr.get(i).draw();
    bKik.get(i).draw();
  }
  
  // Beat marker
  fill(180);
  triangle(100 + pos*50, 20, 90 + pos*50, 10, 110 + pos*50, 10);
  
}

// Toggle step
void mousePressed()
{
  for(int i = 0; i < nSteps; ++i)
  {
    bHat.get(i).mousePressed();
    bSnr.get(i).mousePressed();
    bKik.get(i).mousePressed();
  }
}

// Receive OSC triggers
void oscEvent(OscMessage trigger)
{
  if(trigger.checkAddrPattern("/stop")) {
    curr = 0;
    pos = curr;
  }
  else if(trigger.checkAddrPattern("/playStep")) {
    // Sync marker
    pos = curr;
    // Play Sound
    bHat.get(curr).sendOSC();
    bSnr.get(curr).sendOSC();
    bKik.get(curr).sendOSC();
    // Move one step forward
    curr++;
    // Return to first step
    if (curr == nSteps){
      curr = 0;
    }
    
  }
  else if(trigger.checkAddrPattern("/setSteps")) {
    nSteps = trigger.get(0).intValue();
  }
  // Collisions
  else if(trigger.checkAddrPattern("/collision/kk")) {
    bKik.get(trigger.get(0).intValue()).pitchKick = trigger.get(2).floatValue();
    bKik.get(trigger.get(1).intValue()).pitchKick = trigger.get(2).floatValue();
  }
  // Exit applet
  else if(trigger.checkAddrPattern("/terminate")) {
    for (int i=0; i<nSteps; i++){
        // Manage balls [off]
        OscMessage terminateHat = new OscMessage("/hat/off");
        terminateHat.add(i);
        osc.send(terminateHat, oscLI);
        
        OscMessage terminateSnare = new OscMessage("/snare/off");
        terminateSnare.add(i);
        osc.send(terminateSnare, oscLI);
        
        OscMessage terminateKick = new OscMessage("/kick/off");
        terminateKick.add(i);
        osc.send(terminateKick, oscLI);
    }
    exit();
  }
}
