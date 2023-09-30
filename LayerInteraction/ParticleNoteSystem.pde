class ParticleNoteSystem {
  ArrayList<ParticleNote> particles;
  PVector pos;
  PImage[] notes;

  ParticleNoteSystem(PVector position) {
    pos = position.copy();
    particles = new ArrayList<ParticleNote>();
    notes = new PImage[4];
    for (int i = 1; i <= 4; i++) {
      // Use nf() to number format 'i' into four digits
      notes[i-1] = loadImage("note" + i + ".png");
    }
    notes[0].resize(8,25);
    notes[1].resize(8,25);
    notes[2].resize(20,25);
    notes[3].resize(15,25);
  }

  void addParticle() {
    particles.add(new ParticleNote(pos, notes[int(random(4))]));
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      ParticleNote p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}

class ParticleNote {
  PVector pos;
  PVector velocity;
  float lifespan;
  PImage note;

  ParticleNote(PVector l, PImage _note) {
    velocity = new PVector(random(-1, 1), random(-1, 1));
    pos = l.copy();
    lifespan = 120.0;
    note = _note;
  }

  void run() {
    update();
    display();
  }

  // Update particle position
  void update() {
    pos.add(velocity);
    lifespan -= 1.0;
  }

  // Draw particle
  void display() {
    stroke(255, lifespan);
    fill(255, lifespan);
    image(note, pos.x-note.width/2, pos.y-note.height/2);
  }

  // Delete particle
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
