public class Applet4 extends PApplet {
  
  PVector sizeApplet = new PVector();

  public void settings() {
    fullScreen();
  }
  public void setup(){
    surface.setSize((int)sizeApplet.x, (int)sizeApplet.y);
    surface.setResizable(false);
    surface.setLocation(0, (int)sizeApplet.y);
  }
  public void draw() {
    background(100);
    strokeWeight(10);
    stroke(255, 0, 0);
    textSize(120);
    fill(255);
    text("4", (int)sizeApplet.x/2, (int)sizeApplet.y/2);
  }
}
