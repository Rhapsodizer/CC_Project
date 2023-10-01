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
PixelVoid agentVoid;
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
  //nSteps = int(args[0]);
  nSteps = 16;
  nLayers = 4;
  noteNames = new String[nSteps];
  numBalls = nSteps * nLayers;
  // Create objects
  balls = new Ball[numBalls];
  ship = new Agent();
  agentVoid = new PixelVoid(0,0);
  
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
  
  // Pixel sonification update
  if (agentVoid.isActive){
    agentVoid.display();
  }
  
  // Display link
  for (Ball ball : balls) {
    if (ball.status == true){
      if (ball.popup){
        ball.drawLink();
      }
    }
  }
  
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
      
       // Collision animation
      for (int i=0; i<ball.animStart.length; i++) {
        if(time-ball.animStart[i]<1000){
          fill(255, 255-(time-ball.animStart[i]));
          circle(ball.pos.x, ball.pos.y, 2*ball.r+20);
        }
      }
    }
  }
  // Display popup over all layers
  for (Ball ball : balls) {
    if (ball.status == true){
      if (ball.popup){
        ball.drawPopup();
      }
    }
  }
  
}

// Toggle popup
void mouseClicked(){
  for (Ball ball : balls) {
    if (ball.status == true){
      if ( (dist(ball.pos.x, ball.pos.y, mouseX, mouseY) < ball.r) ){
        ball.popup = true;
        println("Clicked: " +  ball.id + " " + ball.type);
      } else {
        ball.popup = false;
      }
    }
  }
}
      
// Collision triggers
void collision_event(int self_id, int other_id, String self_type, String other_type) {
  //oscP5.send(collision, addressSC); //for debugging
  
  // Collision kick-kick
  if (self_type == "kick" && other_type == "kick") {
    OscMessage collisionKK = new OscMessage("/collision/kk");
    collisionKK.add(self_id);
    collisionKK.add(other_id);
    collisionKK.add(random(100, 4000));
    oscP5.send(collisionKK, addressDM);
  }
  // Collision hat-hat
  if (self_type == "hat" && other_type == "hat") {
    OscMessage collisionHH = new OscMessage("/collision/hh");
    collisionHH.add(self_id);
    collisionHH.add(other_id);
    collisionHH.add(random(1000, 10000));
    oscP5.send(collisionHH, addressDM);
  }
  // Collision snare-snare
  if (self_type == "snare" && other_type == "snare") {
    OscMessage collisionSS = new OscMessage("/collision/ss");
    collisionSS.add(self_id);
    collisionSS.add(other_id);
    collisionSS.add(random(1, 100));
    oscP5.send(collisionSS, addressDM);
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
  }
  if(theOscMessage.checkAddrPattern("/snare/off")) {
    int id = theOscMessage.get(0).intValue() + 1*nSteps;
    balls[id].lastStatus = balls[id].status;
    balls[id].status = false;
  }
  if(theOscMessage.checkAddrPattern("/kick/off")) {
    int id = theOscMessage.get(0).intValue() + 2*nSteps;
    balls[id].lastStatus = balls[id].status;
    balls[id].status = false;
  }
  if(theOscMessage.checkAddrPattern("/melodyClear")) {
    for (int i=0; i<nSteps; i++) {
      balls[i + 3*nSteps].status = false;
    }
  }
  // Activate/deactivate agent
  if(theOscMessage.checkAddrPattern("/triggerAgent")) {
    if(ship.isActive){
      ship.isActive = false;
    } else {
      ship.isActive = true;
    }
  }
  // Receive pixel coordinate from image sonification
  if(theOscMessage.checkAddrPattern("/notePixelCoord")) {
    agentVoid.isActive = true;
    agentVoid.x = theOscMessage.get(0).intValue();
    agentVoid.y = theOscMessage.get(1).intValue();
  }
  if(theOscMessage.checkAddrPattern("/notePixelCoord/off")) {
    agentVoid.isActive = false;
  }
  // Move agent
  if (theOscMessage.checkAddrPattern("/right")){
    ship.pos.x+=10;
  }
  if (theOscMessage.checkAddrPattern("/left")){
    ship.pos.x-=10;
  }
  if (theOscMessage.checkAddrPattern("/up")){
    ship.pos.y-=10;
  }
  if (theOscMessage.checkAddrPattern("/down")){
    ship.pos.y+=10;
  }
  // Exit applet
  if(theOscMessage.checkAddrPattern("/terminate")) {
    exit();
  }
}
