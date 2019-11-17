ArrayList<Boundary> boundaries = new ArrayList<Boundary>();
Particle particle;
boolean DEBUG_NORMAL = false;
boolean DEBUG_GLASS = false;
boolean FRESNEL = true;
boolean HUD = true;
boolean NOISE = true;
int numWalls = 6;
int numGlasses = 8;
float prevMX, prevMY;
int traces = 100; //300
int traceCount = 0; 
int maxBounces = 7; //20
float brightness = 100; //500

void setup() {
  size(1400, 1000);
  colorMode(HSB, 330, 255, 255, 3000);
  frameRate(100);
  particle = new Particle(10);  //10

  if (brightness<1) brightness = 1;
  //if(DEBUG_GLASS) glass.add(new Glass(600, 500, 200, 100, 0, 6, true));

  generateGlass(numGlasses);
  generateWalls(numWalls);
  generateBorder();
}

void draw() {
  if (traceCount == 0) background(0);
  for (Boundary wall : boundaries) {
    wall.show();
  }
  if (traceCount<traces) {
    particle.update();
    particle.look(boundaries);
    traceCount++;
  }
  if (HUD) drawHUD();
}

void mousePressed() {
  if (mouseButton == LEFT) {
    particle.move(mouseX, mouseY);
    traceCount = 0;
  } else if (mouseButton == RIGHT) {
    particle.point(new PVector(mouseX, mouseY));
    traceCount = 0;
  }
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    particle.move(mouseX, mouseY);
    if (prevMX!=mouseX || prevMY!=mouseY) {
      prevMX = mouseX;
      prevMY = mouseY;
      traceCount = 0;
    }
  }
  if (mouseButton == RIGHT) {
    particle.point(new PVector(mouseX, mouseY));
    traceCount = 0;
  }
}

void keyPressed() {
  if (keyCode == UP) traces++;
  if (keyCode == DOWN) traces--;
  //Switch between point and spotlight
  if (key == 'C' || key == 'c') {
    traceCount = 0;
    boundaries.clear();
    generateBorder();
  }
  if (key == 'W' || key == 'w') generateWalls(1);
  if (key == 'G' || key == 'g') generateGlass(1);
  if (key == 'P' || key == 'p') {
    boundaries.clear();
    background(0);
    traceCount = 0;
    generateBorder();
    particle.pos.set(710, 31);
    particle.isSpot = true;
    for (int i = 0; i<particle.rays.size(); i++) {
      particle.rays.get(i).setDir(radians(i%20+random(-1, 1))+1.1446055);
    }
    FRESNEL = false;
    addPrism();
  }

  if (key == 'H' || key == 'h') HUD = !HUD;
  if (key == 'R' || key == 'r') traceCount = 0;
  if (key == 'T' || key == 't') particle.setSpot();
  if (key == 'F' || key == 'f') FRESNEL = !FRESNEL;
  if (key == 'N' || key == 'n') NOISE = !NOISE;
  if (key == '+') maxBounces++;
  if (key == '-') maxBounces--;
  if (key == ' ') {
    boundaries.clear();
    generateBorder();
    generateGlass(numGlasses);
    generateWalls(numWalls);
    background(0);
    traceCount = 0;
  }
}

public void generateWalls(int num) {
  for (int i = 0; i<num; i++) { 
    float x1 = random(width);
    float x2 = random(width);
    float y1 = random(height);
    float y2 = random(height);
    boundaries.add(new Boundary(x1, y1, x2, y2));
  }
}
public void generateBorder() {
  boundaries.add(new Boundary(0, 0, width, 0));
  boundaries.add(new Boundary(0, 0, 0, height));
  boundaries.add(new Boundary(width, height, width, 0));
  boundaries.add(new Boundary(width, height, 0, height));
}
public void generateGlass(int num) {
  for (int i = 0; i<num; i++) {
    float x = random(width);
    float y = random(height);
    float w = random(100);
    float h = random(100);
    float a = random(TWO_PI);
    boolean lens = random(1)<.5;
    Glass g = new Glass(x, y, w, h, a, (int)random(6, 150), lens);
    boundaries.addAll(g.boundaries);
  }
}

public void addPrism() {
  Glass g = new Glass(width/2, height/2, 200, 200, 0, 6, true);
  boundaries.addAll(g.boundaries);
}


public void drawHUD() {
  fill(0);
  rect(0, 0, 120, 110);
  rect(width-120, 0, width, 210);
  fill(255);
  text("FPS: "+(int)frameRate, 5, 20);
  text("FRESNEL: "+FRESNEL, 5, 40);
  text("NOISE: "+NOISE,5,60);
  text("BOUNCES: "+maxBounces, 5, 80);
  text("TRACES: "+traceCount+"/"+traces, 5, 100);
  text("LEFT CLICK: Move\nRIGHT CLICK: Point\nUP/DOWN: Traces\n+/-: Bounces\nC: Clear\nR: Reset Traces\nT: Point/Spot\nW: Generate Wall\nG: Generate Glass\nP: Load Prism\nF: Fresnel\nN: Noise\nH: HUD ON/OFF", width-115, 20);
}
