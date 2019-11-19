class PointLight extends Light {
  PVector pos;
  boolean isMovable = false;
  float rotation = 1.030001;
  PointLight(float resolution) {
    pos = new PVector(width/2, height/2);
    for (float i = 0; i < 360; i+=resolution) {
      rays.add(new Ray(pos, radians(i)));
    }
  }
  @Override
    public void setMovable(boolean b) {
    isMovable = b;
  }
  @Override
    public void update() {
    for (Ray ray : rays) {
      ray.offset(rotation);
    }
  }

  public void move(float x, float y) {
    pos.set(x, y);
  }
  @Override
    public void mousePressed() {
    if (mouseButton == LEFT && !keyPressed && isMovable) {
      move(mouseX, mouseY);
    }
  }
  @Override
    public void mouseDragged() {
    if (mouseButton == LEFT && !keyPressed && isMovable) {
      move(mouseX, mouseY);
    }
  }
}




class SpotLight extends Light {
  float radius;
  PVector pos;
  float jitter;
  boolean isMovable = false;


  SpotLight(float radius) {
    pos = new PVector(width/2, height/2);
    this.radius = radius;
    jitter = radius/40;
    println(jitter);
    for (float i = 0; i<radius; i+=radius/30) {
      rays.add(new Ray(pos, radians(i+random(-1, 1))));
    }
  }
  @Override
    public void setMovable(boolean b) {
    isMovable = b;
  }
  @Override
    public void update() {
    //Add jitter to avoid strong lines
    for (Ray ray : rays) {
      float j = random(-jitter, jitter);
      ray.offset(j);
    }
  }

  public void pointAt(float x, float y) {
    reset();
    float dir = atan2(y-rays.get(rays.size()/2).pos.y, x-rays.get(rays.size()/2).pos.x);
    for (int i = 0; i<rays.size(); i++) {
      rays.get(i).setDir(radians(i%radius+random(-1, 1))+dir);
    }
  }
  public void move(float x, float y) {
    pos.set(x, y);
  }
  //Reset the cone to avoid over jitter
  private void reset() {
    rays.clear();
    for (float i = 0; i<radius; i+=radius/30) {
      rays.add(new Ray(pos, radians(i+random(-1, 1))));
    }
  }
  @Override
    void mousePressed() {
    if (mouseButton == LEFT && !keyPressed && isMovable) {
      move(mouseX, mouseY);
    }
    if (mouseButton == RIGHT && !keyPressed && isMovable) {
      println("click");
      pointAt(mouseX, mouseY);
    }
  }
  @Override
    void mouseDragged() {
    if (mouseButton == LEFT && !keyPressed && isMovable) {
      move(mouseX, mouseY);
    }
    if (mouseButton == RIGHT && !keyPressed && isMovable) {
      println("click");
      pointAt(mouseX, mouseY);
    }
  }
}




class AreaLight extends Light {
  PVector a, b;
  boolean firstPoint = false;
  float normal;
  float angleAlongLine;
  float length;

  AreaLight(PVector a, PVector b) {
    this.a = a;
    this.b = b;
    angleAlongLine = atan2(b.y-a.y, b.x-a.x);
    normal = angleAlongLine+PI/2;
    length = PVector.dist(b, a);
    for (float i = 0; i<length; i+=length/30) {
      rays.add(new Ray(new PVector(i*cos(angleAlongLine)+a.x, i*sin(angleAlongLine)+a.y), normal));
    }
  }
  AreaLight(float x1, float y1, float x2, float y2) {
    this(new PVector(x1, y1), new PVector(x2, y2));
  }
  @Override
    public void update() {
    for (Ray ray : rays) {
      float c = random(0, 1);
      ray.pos = new PVector(c*cos(angleAlongLine)*length+a.x, c*sin(angleAlongLine)*length+a.y);
      ray.setDir(normal);
    }
  }

  @Override
    public void mouseDragged() {
    if (mouseButton == LEFT && !keyPressed) {
      if(firstPoint == false){
        firstPoint = true;
        a.set(mouseX, mouseY);
      }else b.set(mouseX, mouseY);
      length = PVector.dist(b,a);
      angleAlongLine = atan2(b.y-a.y,b.x-a.x);
      normal = angleAlongLine+PI/2;
    }
  }
  public void mouseReleased(){
    firstPoint = false;
  }
}
