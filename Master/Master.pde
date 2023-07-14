import controlP5.*;
import java.util.*;
import processing.opengl.*;
import ddf.minim.*;
import ddf.minim.ugens.*;


ControlP5 cp5;
Minim minim;
AudioOutput out;

Track t1, t2;
DrumMachine dm1;
Sampler kick;
Sampler snare;
Sampler hat;

List instruments = Arrays.asList("DrumMachine", "Microphone");
int bpm = 60;






void settings() {
  size(400, 600);
}

void setup() {
  cp5 = new ControlP5(this);
  minim = new Minim(this);
  out   = minim.getLineOut();
  
  t1 = new Track(50, 200, 300, 50, "Drum Machine");
  
    

  
  cp5.addButton("addNewTrack")
     .setLabel("Add New Track")
     .setPosition(50,50)
     .setSize(200,50)
     ;
     
     
  

}

void draw() {
  
}











// this function is triggered when an interaction
// with the button "addNewTrack" happens
void addNewTrack(){
  
    cp5.addScrollableList("instrList")
     .setLabel("Choose an instrument")
     .setPosition(50, 100)
     .setSize(200, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(instruments)
     ;
}

void instrList(int n){
  //println(n, cp5.get(ScrollableList.class, "instrList").getItem(n));
  if(n == 0){
    kick  = new Sampler( "BD.wav", 4, minim );
    snare = new Sampler( "SD.wav", 4, minim );
    hat   = new Sampler( "CHH.wav", 4, minim );
    
    // patch samplers to the output
    kick.patch( out );
    snare.patch( out );
    hat.patch( out );
    
    dm1 = new DrumMachine(this, 395, 200, "dm1", minim, out, kick, snare, hat, bpm);
    t1.show();
  }
}
