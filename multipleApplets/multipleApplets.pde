import processing.sound.*;

import javax.swing.*; // multiple windows
//import java.lang.*;

//String sketchFolderPath = dataPath("H:/Documenti/POLIMI/2_1/CC/Project/layer_interact_1/");

import java.awt.*; // window type
int screenHeight;
int screenWidth;
String[] args = {""};

//Process a;

Applet6 sixthApplet;
boolean status6 = false;

void setup() {

  fullScreen();
  Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
  screenHeight = screenSize.height/3;
  screenWidth = screenSize.width/3;
  surface.setSize(screenWidth, screenHeight);
  surface.setResizable(false);
  surface.setLocation(screenWidth, screenHeight);
  
  //a = launch("H:/Software/processing/processing-java --sketch=" + sketchFolderPath + " --run");
  //print(a);
  
  //Applet firstWindow = new Applet();
  //Applet.runSketch(args, firstWindow);
  
  Applet1 firstApplet = new Applet1();
  firstApplet.sizeApplet = new PVector(screenWidth,screenHeight);
  Applet1.runSketch(args, firstApplet);
  
  Applet2 secondApplet = new Applet2();
  secondApplet.sizeApplet = new PVector(screenWidth,screenHeight);
  Applet2.runSketch(args, secondApplet);
  
  Applet3 thirdApplet = new Applet3();
  thirdApplet.sizeApplet = new PVector(screenWidth,screenHeight);
  Applet3.runSketch(args, thirdApplet);
  
  Applet4 fourthApplet = new Applet4();
  fourthApplet.sizeApplet = new PVector(screenWidth,screenHeight);
  Applet4.runSketch(args, fourthApplet);
  
  Applet5 fifthApplet = new Applet5();
  fifthApplet.sizeApplet = new PVector(screenWidth,screenHeight);
  Applet5.runSketch(args, fifthApplet);
  
  
}

void draw() {
  strokeWeight(10);
  stroke(255, 0, 0);
  textSize(120);
  fill(255);
  text("MAIN", 200, 200);
}

void keyPressed() {
  if (key == '6') {
    if (status6 == true) {
      sixthApplet.stop();
      sixthApplet.dispose();
      sixthApplet.getSurface().setVisible(false);
      status6 = false;
    } else {
      sixthApplet = new Applet6();
      sixthApplet.sizeApplet = new PVector(screenWidth,screenHeight);
      Applet6.runSketch(args, sixthApplet);
      status6 = true;
    }
  }
}
//void mousePressed() {
//  exec("cmd /c taskkill /pid " + a.pid());
//}
