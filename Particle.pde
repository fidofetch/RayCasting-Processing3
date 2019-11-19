class Particle {
  PVector pos;
  float resolution;
  float jitter;
  float rotation = 1.030001;
  boolean isSpot = false;
  ArrayList<Ray> rays = new ArrayList<Ray>();
  Particle(float resolution) {
    this.resolution = resolution;
    println("Creating Particle...");

    pos = new PVector(width/2, height/2);
    for (float i = 0; i < 360; i+=resolution) {
      rays.add(new Ray(pos, radians(i)));
    }

    println("Particle Created");
  }

  Particle() {
    this(10);
  }

  public void update() {
    jitter = random(-.5, .5);
    if (!isSpot) {
      for (Ray ray : rays) {
        ray.offset(rotation);
      }
    } else {
      for (Ray ray : rays) {
        ray.offset(jitter);
      }
    }
  }

  public void move(float x, float y) {
    pos.x = x;
    pos.y = y;
  }

  public void setSpot() {
    isSpot = !isSpot;
    if (isSpot) {
      for (int i = 0; i<rays.size(); i++) {
        rays.get(i).setDir(radians(i%20+random(-1, 1)));
      }
    } else {
      for (int i = 0; i<rays.size(); i++) {
        rays.get(i).setDir(radians(i*resolution));
      }
    }
  }

  public void pointAt(PVector pt) {
    isSpot = true;
    float dir = atan2(pt.y-rays.get(rays.size()/2).pos.y, pt.x-rays.get(rays.size()/2).pos.x);
    for (int i = 0; i<rays.size(); i++) {
      rays.get(i).setDir(radians(i%10+random(-1, 1))+dir);
    }
  }

  public void look() {
    for (Ray ray : rays) {
      ray.changeColor();
      Point pt = null;
      float record = 9999999;

      ArrayList<Point> points = getPoints(ray.pos, ray.dir.heading()-PI);
      for (Point point : points) {
        float d = PVector.dist(pos, point.pos);
        if (d<record) {
          record = d;
          pt = point;
        }
      }
      stroke(ray.col, brightness);
      if (pt != null) {
        line(pos.x, pos.y, pt.pos.x, pt.pos.y);
        trace(ray, ray.pos, pt, maxBounces);
      }
    }
  }

  private void trace(Ray ray, PVector prevPos, Point prevCollision, int bounces) {
    if (bounces<=0)return;

    ///////////////////////////////////////////////////////////////////
    // REFLECTION EQUATION
    //////////////////////////////////////////////////////////////////
    float iAngle = atan2(prevPos.y-prevCollision.pos.y, prevPos.x - prevCollision.pos.x); //Get the incident angle
    PVector N = prevCollision.getNormal().copy();
    PVector n = prevCollision.getNormal().copy();
    PVector I = PVector.fromAngle(iAngle); //Incident Vector
    PVector B = PVector.sub(I, PVector.mult(N, PVector.dot(I, N)*2)); //Our Reflection angle
    float refractionA = B.heading();
    float kr = 1;
    float k = -1;
    //IOR of air
    float etai = 1;
    //IOR calculated using ORT
    float IOR = 1.62;
    
    
    //GLASS CALCULATIONS
    if (prevCollision.b.material == GLASS) {
      float cosi = constrain(PVector.dot(N, I), -1, 1); //The cos of the angle between I and N
      float etat = IOR+((DP-ray.wavelength)*C)/(ABBE_GLASS*DP*ray.wavelength*ray.wavelength);
      /////////////////////////////////////////////////////////////////
      //FRESNEL EQUATION
      /////////////////////////////////////////////////////////////////
      //We are inside and need to flip our normal and swap our IORs 
      if (cosi>0) {
        n = PVector.fromAngle(N.heading()+PI);
        float temp = etai;
        etai = etat;
        etat = temp;
      }

      float sint = (etai/etat)*sqrt(max(0, 1-cosi*cosi));
      if (sint >= 1)kr=1;
      else {
        float cost = sqrt(max(0, 1-sint*sint));
        cosi = abs(cosi);
        float Rs = ((etat*cosi)-(etai*cost))/((etat*cosi) + (etai * cost));
        float Rp = ((etai*cosi)-(etat*cost))/((etai*cosi) + (etat * cost));
        kr = (Rs*Rs+Rp*Rp)/2;
      }

      /////////////////////////////////////////////////////////////////
      // REFRACTION EQUATION
      ////////////////////////////////////////////////////////////////
      //If cosi is negative we are outside the object and need to have a positive value
      if (cosi<0) {
        cosi = -cosi;
      }
      //Snell's Law
      float eta = (etat/etai);
      //Calculate our critical angle for total internal reflection
      k = 1-eta*eta*(1-cosi*cosi);
      //Angle of refraction
      refractionA = PVector.add(PVector.mult(I, eta), PVector.mult(n, (eta*cosi)-sqrt(k))).heading();
      //If k is negative we are at our critical angle and the equation breaks down, just treat as reflection
      if (k<0) refractionA = B.heading();
    }
    //Generate Noise
    float noise = prevCollision.getMaterial()==WALL && NOISE?random(-.2,.2):0;

    //Draw the normals
    if (DEBUG_NORMAL == true) {
      stroke(255, 255, 255, 1000);
      line(prevCollision.pos.x, prevCollision.pos.y, prevCollision.pos.x+cos(N.heading())*20, prevCollision.pos.y+sin(N.heading())*20);
    }
    //Should we split the ray due to fresnel
    int split = kr<1 && prevCollision.b.material == GLASS && FRESNEL ? 2 : 1;
    Ray[] rays = new Ray[split];

    for (int i = 0; i<split; i++) {
      rays[i] = ray.copy();
      float record = 9999999;
      float angle = refractionA;
      Point pt = null;
      if (i==0 && kr<1 && FRESNEL)angle = B.heading(); 
      ArrayList<Point> points = getPoints(prevCollision.pos, angle+noise);
      for (Point point : points) {
        //If we hit the same wall again don't bounce off of it
        if (point.b.a.equals(prevCollision.b.a)&&point.b.b.equals(prevCollision.b.b)) continue;
        float d = PVector.dist(prevCollision.pos, point.pos);
        if (d<record) {
          println(d);
          record = d;
          pt = point;
        }
      }

      if (pt != null) {
        kr = i-kr;
        if (kr<0)kr=-kr;
        if (!FRESNEL) kr = 1;
        //Lower our light per bounce
        float alpha = rays[i].alpha/1.2;
        //Don't dim light that is transmitted
        if (pt.b.material==GLASS || kr<1) alpha = map(kr, 0, 1, 0, alpha);

        stroke(ray.col, alpha);
        line(prevCollision.pos.x, prevCollision.pos.y, pt.pos.x, pt.pos.y);

        bounces--;
        int krBounces = bounces;
        rays[i].alpha = alpha;
        if (ray.alpha<=1) {
          rays[i].alpha = 0;
          krBounces = 0;
        }
        trace(rays[i], prevCollision.pos, pt, krBounces);
      }
    }
    return;
  }

  private ArrayList<Point> getPoints(PVector pos, float dir) {
    float px = abs(pos.x + cos(dir));
    float py = abs(pos.y + sin(dir));
    return qTree.query(new Line(abs(px), abs(py), pos.x, pos.y));
  }
}
