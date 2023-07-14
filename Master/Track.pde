class Track {
  
  int px, py;
  int w, h;
  String name;
  
  public Track(int posx, int posy, int _w, int _h, String _name){
    px = posx;
    py = posy;
    w = _w;
    h = _h;
    name = _name;
  }
  
  public void show(){
    fill(127, 255, 212);
    rect(px, py, w, h, 10);
    textSize(20);
    fill(0);
    text(name, px+20, py+20);
  }
}
