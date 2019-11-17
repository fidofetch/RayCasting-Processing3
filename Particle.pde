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
      rays.get(i).setDir(radians(i%20+random(-1, 1))+dir);
    }
  }

  public void look(ArrayList<Boundary> walls) {
    for (Ray ray : rays) {
      ray.changeColor();
      PVector closest = null;
      Boundary iWall = null;
      float record = 9999999;

      for (Boundary wall : walls) {
        PVector pt = ray.cast(wall);
        if (pt!=null) {
          float d = PVector.dist(pos, pt);
          if (d<record) {
            record = d;
            closest = pt;
            iWall = wall.copy();
          }
        }
      }
      stroke(ray.col, brightness);
      if (closest != null) {
        line(pos.x, pos.y, closest.x, closest.y);
        trace(ray, walls, ray.pos, iWall, closest, maxBounces);
      }
    }
  }

  private void trace(Ray ray, ArrayList<Boundary> walls, PVector prevPos, Boundary iWall, PVector prevCollision, int bounces) {
    if(bounces<=0)return;
    Boundary nWall = null; //what wall do we need to pass to the next iteration

    float noise = NOISE?random(-.01, .01):0;

    ///////////////////////////////////////////////////////////////////
    // REFLECTION EQUATION
    //////////////////////////////////////////////////////////////////
    float nAngle = atan2(iWall.b.y - iWall.a.y, iWall.b.x - iWall.a.x)-PI/2; //Calculate the angle of the wall and rotate the normal by 90
    float iAngle = atan2(prevPos.y-prevCollision.y, prevPos.x - prevCollision.x); //Get the incident angle
    PVector N = PVector.fromAngle(nAngle); //Normal Vector
    PVector n = PVector.fromAngle(nAngle); //Second Normal Vector for Refraction
    PVector I = PVector.fromAngle(iAngle); //Incident Vector
    float cosi = constrain(PVector.dot(N, I), -1, 1); //The cos of the angle between I and N
    PVector B = PVector.sub(I, PVector.mult(N, PVector.dot(I, N)*2)); //Our Reflection angle
    float refractionA = B.heading();
    float kr = 1;
    float k = -1;
    //IOR of air
    float etai = 1;
    //IOR calculated using ORT
    float IOR = 1.5;
    float etat = IOR+((DP-ray.wavelength)*C)/(ABBE_GLASS*DP*ray.wavelength*ray.wavelength);
    if (iWall.isGlass) {
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
    //Draw the normals
    if (DEBUG_NORMAL == true) {
      stroke(255, 255, 255, 1000);
      line(prevCollision.x, prevCollision.y, prevCollision.x+cos(N.heading())*20, prevCollision.y+sin(N.heading())*20);
    }
    //Should we split the ray due to fresnel
    int split = kr<1 && iWall.isGlass() && FRESNEL ? 2 : 1;
    
    for (int i = 0; i<split; i++) {
      PVector closest = null;
      float record = 9999999;
      float angle = refractionA;
      if (i==0 && kr<1 && FRESNEL)angle = B.heading(); 
      ArrayList<Boundary> w = walls;
      if(QUADTREE) w = getWalls(prevCollision, angle);
      for (Boundary wall : w) {
        PVector pt = null;
        //If we hit the same wall twice just ignore it
        if (wall.a.x == iWall.a.x && wall.a.y == iWall.a.y && wall.b.x == iWall.b.x && wall.b.y == iWall.b.y) continue;

        pt = ray.bounce(prevCollision, angle+PI+noise, wall);


        //If we hit something do a depth check
        if (pt!=null) {
          float d = PVector.dist(prevCollision, pt);
          if (d<record) {
            record = d;
            closest = pt;
            nWall = wall.copy();
          }
        }
      }

      if (closest != null && nWall != null) {
        kr = i-kr;
        if (kr<0)kr=-kr;
        if (!FRESNEL) kr = 1;
        //Lower our light per bounce
        float alpha = map(bounces, 0, maxBounces, 1, brightness/1.5);
        //Don't dim light that is transmitted
        if (nWall.isGlass() || kr<1) alpha = map(bounces+1, 0, maxBounces, 1, brightness)*kr;
        
        stroke(ray.col, alpha);
        line(prevCollision.x, prevCollision.y, closest.x, closest.y);
        
        bounces--;
        int krBounces = bounces;
        if (alpha<=1) {
          alpha = 0;
          krBounces = 0;
        }
        trace(ray, walls, prevCollision, nWall, closest, krBounces);
      }
    }
    return;
  }
  
  private ArrayList<Boundary> getWalls(PVector pos, float dir){
    float cx = abs(pos.x + cos(dir));
    float cy = abs(pos.y + sin(dir));
    return qTree.query(new Line(abs(cx), abs(cy), pos.x, pos.y));
  }
}
