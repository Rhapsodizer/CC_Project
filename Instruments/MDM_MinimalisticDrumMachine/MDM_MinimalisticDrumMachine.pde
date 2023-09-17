import oscP5.*;
import netP5.*;
  
OscP5 osc;
NetAddress address;

// variables
ArrayList<Step> bHat = new ArrayList<Step>();
ArrayList<Step> bSnr = new ArrayList<Step>();
ArrayList<Step> bKik = new ArrayList<Step>();

boolean[] hatRow = new boolean[10];
boolean[] snrRow = new boolean[10];
boolean[] kikRow = new boolean[10];

int bpm = 120;
int curr;
int textHeight = 20;
int t;
boolean play = false;


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
      isActive[id] = !isActive[id];
      sendOSC();
    }
  }
  
  public void sendOSC()
  {
    if (isActive[id]){
      OscMessage msg = new OscMessage("/" + type);
      osc.send(msg, address);
    }
  }
  
}



void setup()
{
  size(600, 200);
  
  // Starting time
  t = millis();
  
  // OSC
  osc = new OscP5(this,12000);
  address = new NetAddress("127.0.0.1",57120);
  
  // construct grid
  for (int i = 0; i < 10; i++)
  {
    bHat.add( new Step(100+i*50, 50, i, "hat", hatRow) );
    bSnr.add( new Step(100+i*50, 100, i, "snare", snrRow ) );
    bKik.add( new Step(100+i*50, 150, i, "kick", kikRow ) );
  }
  
  curr = 0;
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
  
  for(int i = 0; i < 10; ++i)
  {
    bHat.get(i).draw();
    bSnr.get(i).draw();
    bKik.get(i).draw();
  }
  

  if ((millis()-t > 60000/bpm) && play){
    // Make sound
    bHat.get(curr).sendOSC();
    bSnr.get(curr).sendOSC();
    bKik.get(curr).sendOSC();
    // Move cursor one step
    curr++;
    if (curr == 10){curr = 0;}
    t=millis();
  }
    
  // beat marker
  fill(180);
  triangle(100 + curr*50, 20, 90 + curr*50, 10, 110 + curr*50, 10);
}

void mousePressed()
{
  for(int i = 0; i < 10; ++i)
  {
    bHat.get(i).mousePressed();
    bSnr.get(i).mousePressed();
    bKik.get(i).mousePressed();
  }
}

void oscEvent(OscMessage trigger) {
  if(trigger.checkAddrPattern("/play")) {
    play = true;
  }
  if(trigger.checkAddrPattern("/stop")) {
    play = false;
  }
  if(trigger.checkAddrPattern("/setBpm")) {
    bpm = trigger.get(0).intValue();
  }
}
