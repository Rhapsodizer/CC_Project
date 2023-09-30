class Ball {
  
  PVector pos;
  PVector vel;
  PVector acc;
  PVector de;
  float r;
  int id;
  String type;
  boolean lastStatus = false;
  boolean status;
  boolean lastCollided[] = new boolean[numBalls];
  boolean collided[] = new boolean[numBalls];
  int animStart[] = new int[numBalls];
  Ball[] others;
  boolean popup;
  
  
  Ball(int _id, String _type, boolean _status, Ball[] _others) {
    r = 25;
    popup = false;
    id = _id;
    status = _status;
    others = _others;
    type = _type;
  } 
  
  // Manage collisions
  void collide() {
    for (int i = 0; i < numBalls; i++) {
      if (others[i].status == true && !(others[i].id == id && others[i].type == type)){
        de = new PVector(others[i].pos.x - pos.x, others[i].pos.y - pos.y);
        float distance = sqrt(de.x*de.x + de.y*de.y);
        if (distance < 2*r) {
          float angle = atan2(de.y, de.x);
          float targetX = pos.x + cos(angle) * 2*r;
          float targetY = pos.y + sin(angle) * 2*r;
          acc = new PVector((targetX - others[i].pos.x) * spring, (targetY - others[i].pos.y) * spring);
          vel.sub(acc);
          others[i].vel.add(acc);
          // Make event non-repetitive
          collided[i] = true;
          if (lastCollided[i]==false && collided[i]==true) {
            collision_event(id, others[i].id, type, others[i].type);
            animStart[i] = millis();
            lastCollided[i] = true;
          }
        } else {
          collided[i] = false;
          lastCollided[i] = false;
        }
      } 
      // Collision with ship
      if (ship.isActive == true){
        de = new PVector(ship.pos.x - pos.x, ship.pos.y - pos.y);
        float distance = sqrt(de.x*de.x + de.y*de.y);
        if (distance < (r+ship.rInteraction)) {
          float angle = atan2(de.y, de.x);
          float targetX = pos.x + cos(angle) * (r+ship.rInteraction);
          float targetY = pos.y + sin(angle) * (r+ship.rInteraction);
          acc = new PVector((targetX - ship.pos.x) * springShip, (targetY - ship.pos.y) * springShip);
          vel.sub(acc);
          // Make event non-repetitive
          collided[i] = true;
          if (lastCollided[i]==false && collided[i]==true) {
            lastCollided[i] = true;
          }
        } else {
          collided[i] = false;
          lastCollided[i] = false;
        }
      }
    }
  }
  
  // Manage movement of each ball
  void move() {
    vel.y += gravity;
    pos.add(vel);
    if (pos.x + r > width) {
      pos.x = width - r;
      vel.x *= friction;
    }
    else if (pos.x - r < 0) {
      pos.x = r;
      vel.x *= friction;
    }
    if (pos.y + r > height) {
      pos.y = height - r;
      vel.y *= friction; 
    } 
    else if (pos.y - r < 0) {
      pos.y = r;
      vel.y *= friction;
    }
  }
  
  // Draw the single ball
  void display() {
    fill(220);
    stroke(180);
    circle(pos.x, pos.y, 2*r);
    fill(128);
    if (type == "hat") {
      text("HA",pos.x-10,pos.y+5);
    }
    else if (type == "snare") {
      text("SN",pos.x-10,pos.y+5);
    }
    else if (type == "kick") {
      text("KC",pos.x-10,pos.y+5);
    }
    else if (type == "melody") {
      fill(240);
      stroke(180);
      circle(pos.x, pos.y, 2*r);
      fill(128);
      text(noteNames[id], pos.x-10,pos.y+5);
    }
    noStroke();
  }
  
  void drawPopup() {
    fill(200);
    rect(width-220, 20, 200, 200);
    stroke(180);
    rect(width-215, 25, 190, 190);
    noStroke();
    fill(128);
    text("Type: " + type, width-200, 60);
    text("ID: " + id, width-200, 90);
    text("Pos: [" + int(pos.x) + ", " + int(pos.y) + "]", width-200, 120);
    text("Vel: " + vel.mag(), width-200, 150);
    if (type == "melody") {
      text("Note: " + noteNames[id], width-200, 180);
    }
  }
  void drawLink() {
    stroke(180);
    line(pos.x, pos.y, width-120, 220);
  }
  
  
}
