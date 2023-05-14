public class Applet extends PApplet {
  
  PVector posApplet = new PVector();

  public void settings() {
    fullScreen();
    Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
    int screenHeight = screenSize.height;
    int screenWidth = screenSize.width;
  }
  public void setup(){
    surface.setSize(600, 300);
    surface.setResizable(false);
    surface.setLocation((int)posApplet.x,(int)posApplet.y);
  }
  public void draw() {
    background(0);
    strokeWeight(10);
    stroke(255, 0, 0);
    line(0, 0, width, height);
  }
}
