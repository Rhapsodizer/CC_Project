import oscP5.*;
import netP5.*;
  
OscP5 osc;
NetAddress oscSC, oscLI;

// variables
int bpm = 120;
int nStep = 10;
int curr, pos;
int textHeight = 20;
int t;
boolean play = false;

ArrayList<Step> bHat = new ArrayList<Step>();
ArrayList<Step> bSnr = new ArrayList<Step>();
ArrayList<Step> bKik = new ArrayList<Step>();

boolean[] hatRow = new boolean[nStep];
boolean[] snrRow = new boolean[nStep];
boolean[] kikRow = new boolean[nStep];


class Step
{
  int x,y,d;
  int id;
  String type;
  boolean[] isActive;
  
  public Step(int _x, int _y, int _id, String _type, boolean[] _isActive)
  {
    x = _x;
    y = _y;
    d = 40;
    id = _id;
    type = _type;
    isActive = _isActive;
  }
  
  public void draw()
  {
    if (isActive[id]) {
      fill(220);
      circle(x,y,d);
      fill(180);
      circle(x,y, 0.8*d);
    }
    else {
      fill(220);
      circle(x,y,d);
    }
    
    
  }
  
  public void mousePressed()
  {
    if ( mouseX >= x-d/2 && mouseX <= x+d/2 && mouseY >= y-d/2 && mouseY <= y+d/2 )
    {
      if (isActive[id]){
        // Manage balls [off]
        OscMessage msg2 = new OscMessage("/" + type + "/off");
        msg2.add(id);
        osc.send(msg2, oscLI);
      } else {
        // Manage balls [on]
        OscMessage msg1 = new OscMessage("/" + type + "/on");
        msg1.add(id);
        osc.send(msg1, oscLI);
      }
      
      isActive[id] = !isActive[id];
      sendOSC();
    }
  }
  
  public void sendOSC()
  {
    if (isActive[id]){
      // Trigger sound
      OscMessage msg0 = new OscMessage("/" + type);
      osc.send(msg0, oscSC);
    }
  }
  
}



void setup()
{
  size(600, 200);
  
  // Starting time
  t = millis();
  
  // OSC
  osc = new OscP5(this,12001);
  oscSC = new NetAddress("127.0.0.1",57120);
  oscLI = new NetAddress("127.0.0.1",12000);
  
  OscMessage numSteps = new OscMessage("/nStep");
  numSteps.add(nStep);
  osc.send(numSteps, oscLI);
  
  // construct grid
  for (int i = 0; i < nStep; i++)
  {
    bHat.add( new Step(100+i*50, 50, i, "hat", hatRow) );
    bSnr.add( new Step(100+i*50, 100, i, "snare", snrRow ) );
    bKik.add( new Step(100+i*50, 150, i, "kick", kikRow ) );
  }
  
  curr = 0;
  pos = curr;
}

void draw()
{
  background(220);
  fill(255);
  
  // Labels
  textSize(textHeight);
  fill(128);
  text("HAT", 20, 50 + textHeight/2);
  text("SNR", 20, 100 + textHeight/2);
  text("KIK", 20, 150 + textHeight/2);
  
  for(int i = 0; i < nStep; ++i)
  {
    bHat.get(i).draw();
    bSnr.get(i).draw();
    bKik.get(i).draw();
  }
  
  // Beat marker
  fill(180);
  triangle(100 + pos*50, 20, 90 + pos*50, 10, 110 + pos*50, 10);

  if ((millis()-t >= 60000/bpm) && play){
    // Make sound
    pos = curr;
    bHat.get(curr).sendOSC();
    bSnr.get(curr).sendOSC();
    bKik.get(curr).sendOSC();
    // Move cursor one step
    curr++;
    if (curr == nStep){curr = 0;}
    t=millis();
  }
    
}

// Toggle step
void mousePressed()
{
  for(int i = 0; i < nStep; ++i)
  {
    bHat.get(i).mousePressed();
    bSnr.get(i).mousePressed();
    bKik.get(i).mousePressed();
  }
}

// Receive OSC triggers
void oscEvent(OscMessage trigger)
{
  if(trigger.checkAddrPattern("/play")) {
    play = true;
  }
  else if(trigger.checkAddrPattern("/stop")) {
    play = false;
    curr = 0;
    pos = curr;
  }
  else if(trigger.checkAddrPattern("/pause")) {
    play = false;
  }
  else if(trigger.checkAddrPattern("/setBpm")) {
    bpm = trigger.get(0).intValue();
  }
}
