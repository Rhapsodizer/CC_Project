/**
 * oscP5broadcastClient by andreas schlegel
 * an osc broadcast client.
 * an example for broadcast server is located in the oscP5broadcaster exmaple.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;

OscP5 oscP5;
float d = 0;

void setup() {
  size(400,400);
  frameRate(60);
  
  oscP5 = new OscP5(this,9000);
}


void draw() {
  background(0);
  fill(255);
  circle(width/2, height/2, 2*d);
}

void oscEvent(OscMessage message) {
  if (message.checkAddrPattern("/table/number")==true) {
    print(message);
    d = message.get(0).floatValue();
  }
}
