ArrayList<Boundary> boundaries = new ArrayList<Boundary>();
ArrayList<PVector> bPoints = new ArrayList<PVector>();
PVector lastBPoint;
PVector firstBPoint;
float prevX, prevY;
Particle particle;
QuadTree qTree;

boolean DEBUG_NORMAL = false;
boolean DEBUG_QUADTREE = false;
int DEBUG = 0;
boolean FRESNEL = true;
boolean HUD = true;
boolean NOISE = true;
boolean QUADTREE = true;
int building = 0;

int numWalls = 0;
int numGlasses = 0;

float prevMX, prevMY;

int traces = 300; //300
int traceCount = 0; 
int maxBounces = 7; //7
float brightness = 200; //200

float renderTime = 0;
float lastTime = 0;

void setup() {
  size(1400, 1000);
  colorMode(HSB, 330, 255, 255, 3000);
  frameRate(100);
  particle = new Particle(10);  //10
  qTree = new QuadTree(new Rectangle(width/2, height/2, width/2+50, height/2+50), 1);

  if (brightness<1) brightness = 1;

  generateGlass(numGlasses);
  generateWalls(numWalls);
  generateBorder();
}

void draw() {
  if (traceCount == 0) {
    background(0);
    renderTime = 0;
    lastTime = millis();
  }
  for (Boundary wall : boundaries) {
    wall.show();
  }
  if (traceCount<traces) {
    particle.update();
    particle.look();
    traceCount++;
    if (DEBUG_QUADTREE)qTree.show();
    renderTime+=millis()-lastTime;
    lastTime = millis();
  }

  if (HUD) drawHUD();
}

void mousePressed() {
  if (mouseButton == LEFT) {
    if (keyPressed && keyCode == CONTROL) {
      building = GLASS;
      buildGlass(mouseX, mouseY);
    } else if (keyPressed && keyCode == SHIFT) {
      building = WALL;
      buildWall(mouseX, mouseY);
    } else {
      particle.move(mouseX, mouseY);
      traceCount = 0;
      if (building>0) {
        buildGlass(-1, -1);
        buildWall(-1, -1);
        building = NOTHING;
      }
    }
  } else if (mouseButton == RIGHT) {
    particle.pointAt(new PVector(mouseX, mouseY));
    traceCount = 0;
  }
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    if (keyPressed && keyCode == CONTROL) {
      building = GLASS;
      buildGlass(mouseX, mouseY);
    } else if (keyPressed && keyCode == SHIFT) {
      building = WALL;
      buildWall(mouseX, mouseY);
    } else {
      particle.move(mouseX, mouseY);
      traceCount = 0;
      if (building>0) {
        buildGlass(-1, -1);
        buildWall(-1, -1);
        building = NOTHING;
      }
    }
  }
  if (mouseButton == RIGHT) {
    particle.pointAt(new PVector(mouseX, mouseY));
    traceCount = 0;
  }
}

void keyPressed() {
  if (keyCode == UP) traces++;
  if (keyCode == DOWN){
    traces--;
    if(traces<1)traces = 1;
  }
  if (keyCode == LEFT) qTree.cap--;
  if (keyCode == RIGHT) qTree.cap++;
  //Switch between point and spotlight
  if (key == 'C' || key == 'c') {
    traceCount = 0;
    clearScreen();
    generateBorder();
  }
  if (key == 'W' || key == 'w') generateWalls(1);
  if (key == 'G' || key == 'g') generateGlass(1);
  if (key == 'P' || key == 'p') {
    clearScreen();
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
  if (key == 'Q' || key == 'q') QUADTREE = !QUADTREE;
  if (key == 'D' || key == 'd') {
    traceCount = 0;
    if(DEBUG == 0){
      DEBUG=1;
      DEBUG_NORMAL = true;
      DEBUG_QUADTREE = false;
    }else if(DEBUG == 1){
      DEBUG = 2;
      DEBUG_NORMAL = false;
      DEBUG_QUADTREE = true;
    }else if(DEBUG == 2){
      DEBUG = 0;
      DEBUG_NORMAL = false;
      DEBUG_QUADTREE = false;
    }
  }
  if (key == '+') maxBounces++;
  if (key == '-') {
    maxBounces--;
    if(maxBounces<0) maxBounces = 0;
  }
  if (key == ' ') {
    clearScreen();
    generateBorder();
    generateGlass(numGlasses);
    generateWalls(numWalls);
    background(0);
    traceCount = 0;
  }
}

public void clearScreen() {
  boundaries.clear();
  qTree.clear();
}

public void generateWalls(int num) {
  for (int i = 0; i<num; i++) { 
    float x1 = random(width);
    float x2 = random(width);
    float y1 = random(height);
    float y2 = random(height);
    Boundary b = new Boundary(x1, y1, x2, y2, WALL);
    boundaries.add(b);
    qTree.insert(new Line(b));
  }
}
public void generateBorder() {
  Boundary b1 = new Boundary(5, 5, width-5, 5, WALL);
  Boundary b2 = new Boundary(5, 5, 5, height-5, WALL);
  Boundary b3 = new Boundary(width-5, height-5, width-5, 5,WALL);
  Boundary b4 = new Boundary(width-5, height-5, 5, height-5, WALL);
  qTree.insert(new Line(b1));
  qTree.insert(new Line(b2));
  qTree.insert(new Line(b3));
  qTree.insert(new Line(b4));
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
    for (Boundary b : g.boundaries) {
      qTree.insert(new Line(b));
    }
  }
}

public void addPrism() {
  Boundary b1 = new Boundary(width/2-200, height/2-200, width/2+200, height/2-200, GLASS);
  Boundary b2 = new Boundary(width/2+200, height/2-200, width/2, height/2+200, GLASS);
  Boundary b3 = new Boundary(width/2, height/2+200, width/2-200, height/2-200, GLASS);
  boundaries.add(b1);
  boundaries.add(b2);
  boundaries.add(b3);
  qTree.insert(new Line(b1));
  qTree.insert(new Line(b2));
  qTree.insert(new Line(b3));
}

public void buildGlass(float x, float y) {
  if (building==GLASS && x>=0 && y>=0) {
    if (x>prevX+10 || x<prevX-10 || y>prevY+10 ||y<prevY-10) {
      prevX = x;
      prevY = y;
      bPoints.add(new PVector(x, y));
      if (firstBPoint == null) firstBPoint = new PVector(x, y);
      if (bPoints.size()>=2) {
        Boundary b = new Boundary(lastBPoint, new PVector(x, y), GLASS);
        qTree.insert(new Line(b));
        boundaries.add(b);
      }
      lastBPoint = new PVector(x, y);
    }
  } else if (building==GLASS) {
    if (firstBPoint != null && lastBPoint != null)
      boundaries.add(new Boundary(lastBPoint, firstBPoint, GLASS));
    lastBPoint = null;
    firstBPoint = null;
    bPoints.clear();
  }
}
public void buildWall(float x, float y) {
  if (building==WALL && x>=0 && y>=0) {
    if (x>prevX+10 || x<prevX-10 || y>prevY+10 ||y<prevY-10) {
      prevX = x;
      prevY = y;
      bPoints.add(new PVector(x, y));
      if (bPoints.size()>=2) {
        Boundary b = new Boundary(lastBPoint, new PVector(x, y));
        qTree.insert(new Line(b));
        boundaries.add(b);
      }
      lastBPoint = new PVector(x, y);
    }
  } else if (building==WALL) {
    lastBPoint = null;
    firstBPoint = null;
    bPoints.clear();
  }
}


public void drawHUD() {
  fill(0);
  rect(0, 0, 120, 130);//Stats
  rect(width/2-100, 0, 200, 30);//RenderTime
  rect(width-180, 0, width, 240);//Controls
  fill(255);
  text("Render Time: "+(int)(renderTime/1000)+"s", width/2-50, 20);
  text("FPS: "+(int)frameRate, 5, 20);
  text("FRESNEL: "+FRESNEL, 5, 40);
  text("NOISE: "+NOISE, 5, 60);
  text("QUADTREE: "+QUADTREE, 5, 80);
  text("BOUNCES: "+maxBounces, 5, 100);
  text("TRACES: "+traceCount+"/"+traces, 5, 120);
  text("LEFT CLICK: Move\nRIGHT CLICK: Point\nCTRL+LCLICK: Add Glass\nSHIFT+RCLICK: Add Wall\nUP/DOWN: Traces\n+/-: Bounces\nC: Clear\nR: Reset Traces\nT: Point/Spot\nW: Generate Wall\nG: Generate Glass\nP: Load Prism\nF: Fresnel"+
    "\nN: Noise\nQ: Quadtree\nH: HUD ON/OFF", width-175, 20);
}
