import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress addressSC;
NetAddress addressDM;

//PVector sizeApplet = new PVector(1000, 1000);

int nSteps;
int nLayers;
int numBalls;
PVector pos;
PVector vel;
PVector acc;
float spring = 0.05;
float springShip = 0.001;
float gravity = 0.0;
float friction = -0.7;
Ball[] balls;
Agent ship;
int time;

String[] noteNames;
String[] types = {"hat", "snare", "kick", "melody"};

//OscMessage collision = new OscMessage("/collision");
  
//void settings() {  
//  fullScreen();
//}

void setup(){
//  surface.setSize((int)sizeApplet.x, (int)sizeApplet.y);
//  surface.setResizable(false);
//  surface.setLocation(0, 2*(int)sizeApplet.y);
  nSteps = int(args[0]);
  nLayers = 4;
  noteNames = new String[nSteps];
  numBalls = nSteps * nLayers;
  // Create objects
  balls = new Ball[numBalls];
  ship = new Agent();
  
  // Initialize ball object array
  for (int i=0; i<nSteps; i++) {
    balls[i]            = new Ball(i, types[0], false, balls);
    balls[i + 1*nSteps] = new Ball(i, types[1], false, balls);
    balls[i + 2*nSteps] = new Ball(i, types[2], false, balls);
    balls[i + 3*nSteps] = new Ball(i, types[3], false, balls);
  }
  
  // Applet parameters
  size(800, 800);
  frameRate(60);
  textSize(20);
  strokeWeight(2);
  
  // Define OSC clients and server
  oscP5 = new OscP5(this, 12000);
  addressSC = new NetAddress("127.0.0.1", 57120);
  addressDM = new NetAddress("127.0.0.1", 12001);
}

void draw() {
  // Update variables
  time = millis();
  background(220);
  
  // Update agent
  if (ship.isActive){
    ship.display();
  }
  
  // Update balls
  for (Ball ball : balls) {
    if (ball.status == true){
      ball.collide();
      ball.move();
      ball.display();
      for (int i=0; i<ball.animStart.length; i++) {
        if(time-ball.animStart[i]<1000){
          fill(255, 255-(time-ball.animStart[i]));
          circle(ball.pos.x, ball.pos.y, 2*ball.r+20);
        }
      }
    }
  }
}

// Collision triggers
void collision_event(int id, int other_id, String type, String other_type) {
  //oscP5.send(collision, addressSC);
  // Collision kick-kick
  if (type == "kick" && other_type == "kick") {
    OscMessage collisionKK = new OscMessage("/collision/kk");
    collisionKK.add(id);
    collisionKK.add(other_id);
    collisionKK.add(random(500, 8000));
    oscP5.send(collisionKK, addressDM);
  }
    
}


// OSC events listener
void oscEvent(OscMessage theOscMessage) {
  //println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  //theOscMessage.print();
  
  // Create ball trigger
  if(theOscMessage.checkAddrPattern("/kick/on") || theOscMessage.checkAddrPattern("/hat/on") || theOscMessage.checkAddrPattern("/snare/on")){
    int id = theOscMessage.get(0).intValue();
    if (theOscMessage.checkAddrPattern("/snare/on")) {
      id = id + 1*nSteps;
    } else if (theOscMessage.checkAddrPattern("/kick/on")) {
      id = id + 2*nSteps;
    }
    balls[id].lastStatus = balls[id].status;
    balls[id].status = true;
    balls[id].pos = new PVector(random(width), random(height));
    balls[id].vel = new PVector(random(1,3), random(1,3));
  }
  if(theOscMessage.checkAddrPattern("/noteChars")){  
    for (int i = 0; i<nSteps; i++){
      int id = i + 3*nSteps;
      noteNames[i] = theOscMessage.get(i).stringValue();
      println(noteNames[i]);
      balls[id].status = true;
      balls[id].pos = new PVector(random(width), random(height));
      balls[id].vel = new PVector(random(1,3), random(1,3));
    }
  }
  // Delete ball trigger
  if(theOscMessage.checkAddrPattern("/hat/off")) {
    int id = theOscMessage.get(0).intValue();
    balls[id].lastStatus = balls[id].status;
    balls[id].status = false;
  } else if(theOscMessage.checkAddrPattern("/snare/off")) {
    int id = theOscMessage.get(0).intValue() + 1*nSteps;
    balls[id].lastStatus = balls[id].status;
    balls[id].status = false;
  } else if(theOscMessage.checkAddrPattern("/kick/off")) {
    int id = theOscMessage.get(0).intValue() + 2*nSteps;
    balls[id].lastStatus = balls[id].status;
    balls[id].status = false;
  }
  // Activate/deactivate agent
  if(theOscMessage.checkAddrPattern("/triggerAgent")) {
    if(ship.isActive){
      ship.isActive = false;
    } else {
      ship.isActive = true;
    }
  }
  // Move agent
  if (theOscMessage.checkAddrPattern("/right")){
    ship.pos.x+=10;
  }
  if (theOscMessage.checkAddrPattern("/left")){
    ship.pos.x-=10;
  }
  // Exit applet
  if(theOscMessage.checkAddrPattern("/terminate")) {
    exit();
  }
}
