import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
OscMessage kick;
 
int r = 60;        // Width of the shape
float xpos, ypos;    // Starting position of shape    
float yspeed = 15;  // Speed of the shape
int ydirection = 1;  // Top to Bottom
float colorVar = 0;


void setup() 
{
  size(640, 360);
  noStroke();
  frameRate(60);
  // Set the starting position of the shape
  xpos = width/2;
  ypos = height/2;
  // Set OSC
  oscP5 = new OscP5(this,57120);
  myRemoteLocation = new NetAddress("127.0.0.1",57120);
  kick = new OscMessage("/kick"); //https://sccode.org/1-57g
}

void draw() 
{
  background(colorVar);
  // Update the position of the shape
  ypos = ypos + ( yspeed * ydirection );
  
  // Test to see if the shape exceeds the boundaries of the screen
  // If it does, reverse its direction by multiplying by -1
  if (ypos > height-r || ypos < r) {
    ydirection *= -1; // Change direction
    colorVar = random(255); // Change background
    oscP5.send(kick, myRemoteLocation); // Send OSC message    
  }

  // Draw the shape
  noStroke();
  fill(100,250,0);
  circle(xpos, ypos, 2*r);
}
