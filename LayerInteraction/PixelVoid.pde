class PixelVoid {
  
  int x, y, r;
  boolean isActive;

  PixelVoid(int _x, int _y) {
    x = _x;
    y = _y;
    
    r = 20;
    isActive = false;
  } 
  
  // Draw the agent
  void display() {
    fill(50);
    circle(x, y, 2*r);
  }
  
}
