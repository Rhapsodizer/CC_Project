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
  
//void settings() {  
//  fullScreen();
//}

void setup(){
//  surface.setSize((int)sizeApplet.x, (int)sizeApplet.y);
//  surface.setResizable(false);
//  surface.setLocation(0, 2*(int)sizeApplet.y);
  numBalls = int(args[0]) * 3;
  balls = new Ball[numBalls];
  for (int i=0; i<numBalls; i++) {
    balls[i] = new Ball(i, false, balls);
  }
  
  size(800, 800);
  frameRate(60);
  
  oscP5 = new OscP5(this, 12000);
  address = new NetAddress("127.0.0.2", 12000);
  
  noStroke();
}

void draw() {
  background(0);
  
  for (Ball ball : balls) {
    if (ball.status == true){
      ball.collide();
      ball.move();
      ball.display();  
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
  boolean lastStatus;
  boolean status;
  Ball[] others;
  
  Ball(int idin, boolean statusin, Ball[] oin) {
    r = 25;
    id = idin;
    lastStatus = false;
    status = statusin;
    others = oin;
    } 
  
  void collide() {
    for (int i = id + 1; i < numBalls; i++) {
      if (others[i].status == true){
        de = new PVector(others[i].pos.x - pos.x, others[i].pos.y - pos.y);
        float distance = sqrt(de.x*de.x + de.y*de.y);
        if (distance < 2*r) {
          float angle = atan2(de.y, de.x);
          float targetX = pos.x + cos(angle) * 2*r;
          float targetY = pos.y + sin(angle) * 2*r;
          acc = new PVector((targetX - others[i].pos.x) * spring, (targetY - others[i].pos.y) * spring);
          vel.sub(acc);
          others[i].vel.add(acc);
        }
      }
    }   
  }
  
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
  
  void display() {
    if (id < numBalls/3) {
      fill(255,0,0);
    }
    else if ((id >= numBalls/3) && (id < 2*numBalls/3)) {
      fill(0,255,0);
    }
    else if (id >= 2*numBalls/3) {
      fill(0,0,255);
    }
    
    circle(pos.x, pos.y, 2*r);
  }
}

void oscEvent(OscMessage theOscMessage) {
  println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  theOscMessage.print();
  
  if(theOscMessage.checkAddrPattern("/kick/on") || theOscMessage.checkAddrPattern("/hat/on") || theOscMessage.checkAddrPattern("/snare/on")){
    int id = theOscMessage.get(0).intValue();
    balls[id].lastStatus = balls[id].status;
    balls[id].status = true;
    balls[id].pos = new PVector(random(width), random(height));
    balls[id].vel = new PVector(random(1,3), random(1,3));
  }
  if(theOscMessage.checkAddrPattern("/kick/off") || theOscMessage.checkAddrPattern("/hat/off") || theOscMessage.checkAddrPattern("/snare/off")){
    int id = theOscMessage.get(0).intValue();
    balls[id].lastStatus = balls[id].status;
    balls[id].status = false;
  }
}
