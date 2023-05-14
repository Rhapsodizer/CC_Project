public class Applet6 extends PApplet {
  
  PVector sizeApplet = new PVector();
  
  Amplitude amp;
  AudioIn in;
  
  int nLayer = 4;
  float intensity; // value in range 0 to 1
  PVector loc;
  PVector vel;
  PVector acc;
  float spring = 0.05;
  float gravity = 0.0;
  float friction = -0.8;
  Layer[] layers = new Layer[nLayer];
  
  

  public void settings() {
    fullScreen();
  }
  public void setup(){
    surface.setSize((int)sizeApplet.x, (int)sizeApplet.y);
    surface.setResizable(false);
    surface.setLocation(0, 2*(int)sizeApplet.y);
    
    
    
    
    frameRate(60);
    noStroke();
    
    for (int i = 0; i < nLayer; i++) {
      loc = new PVector(random(width), random(height));
      vel = new PVector(random(1,3), random(1,3));
      layers[i] = new Layer(loc, vel, 20, i, layers);
    }
    
    // Create an Input stream which is routed into the Amplitude analyzer
    amp = new Amplitude(this);
    in = new AudioIn(this, 0);
    in.start();
    amp.input(in);
    
    intensity = 0;
  }
  
  
  
  
  public void draw() {
    background(0);
  
    intensity = amp.analyze();
    
    for (Layer ball : layers) {
      ball.r = 20 + height*intensity;
      ball.collide();
      ball.move();
      ball.display();  
    }
  }
  
  
  
  
  
  
  class Layer {
  
    PVector loc;
    PVector vel;
    PVector acc;
    PVector de;
    float r;
    float vx = 0;
    float vy = 0;
    int id;
    Layer[] others;
   
    Layer(PVector locInit, PVector velInit, float rin, int idin, Layer[] oin) {
      loc = locInit;
      vel = velInit;
      r = rin;
      id = idin;
      others = oin;
    } 
    
    void collide() {
      for (int i = id + 1; i < nLayer; i++) {
        de = new PVector(others[i].loc.x - loc.x, others[i].loc.y - loc.y);
        float distance = sqrt(de.x*de.x + de.y*de.y);
        float minDist = others[i].r + r;
        if (distance < minDist) {
          // Produces sound
          
          // Deviation
          float angle = atan2(de.y, de.x);
          float targetX = loc.x + cos(angle) * minDist;
          float targetY = loc.y + sin(angle) * minDist;
          acc = new PVector((targetX - others[i].loc.x) * spring, (targetY - others[i].loc.y) * spring);
          vel.sub(acc);
          others[i].vel.add(acc);
        }
      }   
    }
    
    void move() {
      vel.y += gravity;
      loc.add(vel);
      if (loc.x + r > width) {
        loc.x = width - r;
        vel.x *= friction;
      }
      else if (loc.x - r < 0) {
        loc.x = r;
        vel.x *= friction;
      }
      if (loc.y + r > height) {
        loc.y = height - r;
        vel.y *= friction; 
      } 
      else if (loc.y - r < 0) {
        loc.y = r;
        vel.y *= friction;
      }
    }
    
    void display() {
      fill(255,40);
      circle(loc.x, loc.y, 2*r);
      fill(255);
      circle(loc.x, loc.y, 40);
    }
  }
}
