import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress address;

//PVector sizeApplet = new PVector(1000, 1000);
  
int numBalls;
PVector pos;
PVector vel;
PVector acc;
float r = 25;
float spring = 0.05;
float gravity = 0.0;
float friction = -0.9;
Ball[] balls;
int time;

OscMessage collision = new OscMessage("/collision");
  
//void settings() {  
//  fullScreen();
//}

void setup(){
//  surface.setSize((int)sizeApplet.x, (int)sizeApplet.y);
//  surface.setResizable(false);
//  surface.setLocation(0, 2*(int)sizeApplet.y);
  numBalls = int(args[0]) * 4;
  balls = new Ball[numBalls];
  for (int i=0; i<numBalls; i++) {
    balls[i] = new Ball(i, false, balls);
  }
  
  size(800, 800);
  frameRate(60);
  textSize(20);
  strokeWeight(2);
  
  // Define OSC clients and server
  oscP5 = new OscP5(this, 12000);
  address = new NetAddress("127.0.0.1", 57120);
}

void draw() {
  // Update variables
  time = millis();
  background(220);
  
  // Update balls
  for (Ball ball : balls) {
    if (ball.status == true){
      ball.collide();
      ball.move();
      ball.display();
      for (int i=0; i<ball.animStart.length; i++) {
        if(time-ball.animStart[i]<1000){
          fill(255, 255-(time-ball.animStart[i]));
          circle(ball.pos.x, ball.pos.y, 2*r+20);
        }
      }
    }
  }
}

class Ball {
  
  PVector pos;
  PVector vel;
  PVector acc;
  PVector de;
  float r;
  int id;
  boolean lastStatus = false;
  boolean status;
  boolean lastCollided[] = new boolean[numBalls];
  boolean collided[] = new boolean[numBalls];
  int animStart[] = new int[numBalls];
  Ball[] others;
  
  
  Ball(int _id, boolean _status, Ball[] _others) {
    r = 25;
    id = _id;
    status = _status;
    others = _others;
    } 
  
  // Manage collisions
  void collide() {
    for (int i = 0; i < numBalls; i++) {
      if (others[i].status == true && i!=id){
        de = new PVector(others[i].pos.x - pos.x, others[i].pos.y - pos.y);
        float distance = sqrt(de.x*de.x + de.y*de.y);
        if (distance < 2*r) {
          float angle = atan2(de.y, de.x);
          float targetX = pos.x + cos(angle) * 2*r;
          float targetY = pos.y + sin(angle) * 2*r;
          acc = new PVector((targetX - others[i].pos.x) * spring, (targetY - others[i].pos.y) * spring);
          vel.sub(acc);
          others[i].vel.add(acc);
          // Make event non-repetitive
          collided[i] = true;
          if (lastCollided[i]==false && collided[i]==true) {
            collision_event();
            animStart[i] = millis();
            lastCollided[i] = true;
          }
        } else {
          collided[i] = false;
          lastCollided[i] = false;
        }
      } 
    }
  }
  
  // Manage movement of each ball
  void move() {
    vel.y += gravity;
    pos.add(vel);
    if (pos.x + r > width) {
      pos.x = width - r;
      vel.x *= friction;
    }
    else if (pos.x - r < 0) {
      pos.x = r;
      vel.x *= friction;
    }
    if (pos.y + r > height) {
      pos.y = height - r;
      vel.y *= friction; 
    } 
    else if (pos.y - r < 0) {
      pos.y = r;
      vel.y *= friction;
    }
  }
  
  // Draw the single ball
  void display() {
    fill(220);
    stroke(180);
    circle(pos.x, pos.y, 2*r);
    fill(128);
    if (id < numBalls/3) {
      text("HA",pos.x-10,pos.y+5);
    }
    else if ((id >= numBalls/3) && (id < 2*numBalls/3)) {
      text("SN",pos.x-10,pos.y+5);
    }
    else if (id >= 2*numBalls/3 && (id < 3*numBalls/3)) {
      text("KC",pos.x-10,pos.y+5);
    }
    noStroke();
  }
  
  // Collision triggers
  void collision_event() {
    oscP5.send(collision, address);
  }
}


// OSC events listener
void oscEvent(OscMessage theOscMessage) {
  println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  theOscMessage.print();
  
  // Create ball trigger
  if(theOscMessage.checkAddrPattern("/kick/on") || theOscMessage.checkAddrPattern("/hat/on") || theOscMessage.checkAddrPattern("/snare/on")){
    int id = theOscMessage.get(0).intValue();
    if (theOscMessage.checkAddrPattern("/snare/on")) {
      id = id + 1*(numBalls/3);
    } else if (theOscMessage.checkAddrPattern("/kick/on")) {
      id = id + 2*(numBalls/3);
    }
    balls[id].lastStatus = balls[id].status;
    balls[id].status = true;
    balls[id].pos = new PVector(random(width), random(height));
    balls[id].vel = new PVector(random(1,3), random(1,3));
  }
  // Delete ball trigger
  if(theOscMessage.checkAddrPattern("/hat/off")) {
    int id = theOscMessage.get(0).intValue();
    balls[id].lastStatus = balls[id].status;
    balls[id].status = false;
  } else if(theOscMessage.checkAddrPattern("/snare/off")) {
    int id = theOscMessage.get(0).intValue() + 1*numBalls/3;
    balls[id].lastStatus = balls[id].status;
    balls[id].status = false;
  } else if(theOscMessage.checkAddrPattern("/kick/off")) {
    int id = theOscMessage.get(0).intValue() + 2*numBalls/3;
    balls[id].lastStatus = balls[id].status;
    balls[id].status = false;
  }
}
