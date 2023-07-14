import processing.opengl.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

boolean[] hatRow = new boolean[16];
boolean[] snrRow = new boolean[16];
boolean[] kikRow = new boolean[16];

ArrayList<Rect> buttons; 

int beat;

class DrumMachine extends AnInstrument{
  
  int w, h;
  PApplet parent;
  ControlP5 cp5;
  String name;
  Minim minim;
  AudioOutput out;
  Sampler kick;
  Sampler snare;
  Sampler hat;
  int bpm;
  
  public DrumMachine(PApplet _parent, int _w, int _h, String _name, Minim _minim, AudioOutput _out,
                      Sampler _kick, Sampler _snare, Sampler _hat, int _bpm){
    super();
    parent = _parent;
    w=_w;
    h=_h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
    name = _name;
    minim = _minim;
    out = _out;
    kick = _kick;
    snare = _snare;
    hat = _hat;
    bpm = _bpm;
    
  }
  
  public void settings() {
    size(w, h);
  }
  
  public void setup() {
    
    buttons = new ArrayList<Rect>();
    
    for(int i = 0; i < 16; i++){
      buttons.add( new Rect(10+i*24, 50, hatRow, i ) );
      buttons.add( new Rect(10+i*24, 100, snrRow, i ) );
      buttons.add( new Rect(10+i*24, 150, kikRow, i ) );
    }
    
    println(buttons.size());
    
    beat = 0;
    
    // start the sequencer
    out.setTempo(bpm);
    out.playNote(0, 0.25f, new Tick());   
  }
  
  void draw(){
    background(100);
    
    
    for(int i = 0; i < buttons.size(); ++i){
      //println(i);
      buttons.get(i).show();
    }
    
    stroke(128);
    if ( beat % 4 == 0 ){
      fill(200, 0, 0);
    }
    else{
      fill(0, 200, 0);
    }
    // beat marker    
    rect(10+beat*24, 35, 14, 9);
  }
    
  void mousePressed(){
    for(int i = 0; i < buttons.size(); ++i){
      buttons.get(i).mousePressed();
    }
  }
    
}





class Tick implements Instrument
{
  void noteOn( float dur )
  {
    if ( hatRow[beat] ) hat.trigger();
    if ( snrRow[beat] ) snare.trigger();
    if ( kikRow[beat] ) kick.trigger();
  }
  
  void noteOff()
  {
    // next beat
    beat = (beat+1)%16;
    // set the new tempo
    out.setTempo( bpm );
    // play this again right now, with a sixteenth note duration
    out.playNote( 0, 0.25f, this );
  }
}



class Rect {
  int x, y, w, h;
  boolean[] steps;
  int stepId;
  
  public Rect(int _x, int _y, boolean[] _steps, int _id)
  {
    x = _x;
    y = _y;
    w = 14;
    h = 30;
    steps = _steps;
    stepId = _id;
  }
  
  public void show(){
    if ( steps[stepId] ){
      fill(0,255,0);
    }
    else{
      fill(255,0,0);
    }
    
    rect(x,y,w,h);
  }
  
  public void mousePressed()
  {
    if ( mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h )
    {
      steps[stepId] = !steps[stepId];
    }
  }
}
