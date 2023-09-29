class Agent {
  
  PVector pos;
  float r;
  float rInteraction;
  boolean isActive;

  Agent() {
    pos = new PVector(width/2, height/2);
    r = 20;
    rInteraction = 100;
    isActive = false;
  } 
  
  // Draw the agent
  void display() {
    fill(240);
    circle(pos.x, pos.y, 2*rInteraction);
    fill(0);
    circle(pos.x, pos.y, 2*r);
  }
  
}
