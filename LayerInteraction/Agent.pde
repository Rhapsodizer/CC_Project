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
    if (pos.x + r > width) {
      pos.x = width - r;
    }
    else if (pos.x - r < 0) {
      pos.x = r;
    }
    if (pos.y + r > height) {
      pos.y = height - r;
    } 
    else if (pos.y - r < 0) {
      pos.y = r;
    }
    noStroke();
    fill(240);
    circle(pos.x, pos.y, 2*rInteraction);
    fill(0);
    circle(pos.x, pos.y, 2*r);
  }
  
}
