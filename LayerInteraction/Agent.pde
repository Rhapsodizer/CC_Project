class Agent {
  
  PVector pos;
  float r;
  float rInteraction;
  boolean isActive;
  PImage elvis;
  ParticleNoteSystem pns;

  Agent() {
    pos = new PVector(width/2, height/2);
    r = 20;
    rInteraction = 100;
    isActive = false;
    elvis = loadImage("elvis.png");
    elvis.resize(100,140);
    pns = new ParticleNoteSystem(pos);
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
    pns.pos = pos;
    pns.addParticle();
    pns.run();

    image(elvis, pos.x-elvis.width/2, pos.y-elvis.height/2);
  }
  
}
