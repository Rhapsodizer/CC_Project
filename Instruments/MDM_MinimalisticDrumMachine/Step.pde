class Step
{
  int x,y,d;
  int id;
  float pitchKick;
  String type;
  boolean[] isActive;
  
  public Step(int _x, int _y, int _id, String _type, boolean[] _isActive)
  {
    x = _x;
    y = _y;
    d = 40;
    id = _id;
    type = _type;
    isActive = _isActive;
    pitchKick = 800;
  }
  
  public void draw()
  {
    if (isActive[id]) {
      fill(220);
      circle(x,y,d);
      fill(180);
      circle(x,y, 0.8*d);
    }
    else {
      fill(220);
      circle(x,y,d);
    }
    
    
  }
  
  public void mousePressed()
  {
    if ( mouseX >= x-d/2 && mouseX <= x+d/2 && mouseY >= y-d/2 && mouseY <= y+d/2 )
    {
      if (isActive[id]){
        // Manage balls [off]
        OscMessage msg2 = new OscMessage("/" + type + "/off");
        msg2.add(id);
        osc.send(msg2, oscLI);
      } else {
        // Manage balls [on]
        OscMessage msg1 = new OscMessage("/" + type + "/on");
        msg1.add(id);
        osc.send(msg1, oscLI);
      }
      
      isActive[id] = !isActive[id];
      sendOSC();
    }
  }
  
  public void sendOSC()
  {
    if (isActive[id]){
      // Trigger sound
      OscMessage msg0 = new OscMessage("/" + type);
      msg0.add(pitchKick);
      osc.send(msg0, oscSC);
    }
  }
  
}
