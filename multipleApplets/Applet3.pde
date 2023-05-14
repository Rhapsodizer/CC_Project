public class Applet3 extends PApplet {
  
  PVector sizeApplet = new PVector();

  public void settings() {
    fullScreen();
  }
  public void setup(){
    surface.setSize((int)sizeApplet.x, (int)sizeApplet.y);
    surface.setResizable(false);
    surface.setLocation(2*(int)sizeApplet.x,0);
  }
  public void draw() {
    background(70);
    strokeWeight(10);
    stroke(255, 0, 0);
    textSize(120);
    fill(255);
    text("3", (int)sizeApplet.x/2, (int)sizeApplet.y/2);
  }
}
