abstract class Light {
  ArrayList<Ray> rays = new ArrayList<Ray>();

  Light() {
    println("Creating Particle...");
    println("Particle Created");
  }

  public void update() {
  }

  public void setMovable(boolean b) {
  }

  public void mousePressed() {
  }
  public void mouseDragged() {
  }
  public void mouseReleased() {
  }

  public void look() {
    for (Ray ray : rays) {
      ray.changeColor();
      Point pt = null;
      float record = 9999999;
      ArrayList<Point> points = getPoints(ray.pos, ray.dir.heading()-PI);
      for (Point point : points) {
        //println(ray.pos);
        float d = PVector.dist(ray.pos, point.pos);
        if (d<record) {
          record = d;
          pt = point;
        }
      }
      stroke(ray.col, brightness);
      if (pt != null) {
        line(ray.pos.x, ray.pos.y, pt.pos.x, pt.pos.y);
        trace(ray, ray.pos, pt, maxBounces);
      }
    }
  }

  private void trace(Ray iRay, PVector prevPos, Point prevCollision, int bounces) {
    if (bounces<=0)return;

    //Generate Noise
    float noise = prevCollision.getMaterial()==WALL && NOISE?random(-.2, .2):0;

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
    float etai = AIR_IOR;
    //IOR calculated using ORT
    float IOR = GLASS_IOR;


    //GLASS CALCULATIONS
    if (prevCollision.b.material == GLASS) {
      float cosi = constrain(PVector.dot(N, I), -1, 1); //The cos of the angle between I and N
      float etat = IOR+((DP-iRay.wavelength)*C)/(ABBE_GLASS*DP*iRay.wavelength*iRay.wavelength);
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
      //Angle of refraction, If k is negative we are at our critical angle and the equation breaks down, just treat as reflection
      if(k>=0)refractionA = PVector.add(PVector.mult(I, eta), PVector.mult(n, (eta*cosi)-sqrt(k))).heading();
      
    }

    //Draw the normals
    if (DEBUG_NORMAL == true) {
      stroke(255, 255, 255, 1000);
      line(prevCollision.pos.x, prevCollision.pos.y, prevCollision.pos.x+cos(N.heading())*20, prevCollision.pos.y+sin(N.heading())*20);
    }
    //Should we split the ray due to fresnel
    int split = kr<1 && prevCollision.b.material == GLASS && FRESNEL ? 2 : 1;
    Ray[] rays = new Ray[split];
    float angle;

    for (int i = 0; i<split; i++) {
      rays[i] = iRay.copy();
      float record = 9999999;
      Point pt = null;
      
      //If we have 2 ray that means we have fresnel and need to treat the first one as reflection
      if (i==0 && kr<1 && FRESNEL)angle = B.heading(); 
      else angle = refractionA;
      
      ArrayList<Point> points = getPoints(prevCollision.pos, angle+noise);
      
      for (Point point : points) {
        //If we hit the same wall don't check it
        if (point.b.a.equals(prevCollision.b.a)&&point.b.b.equals(prevCollision.b.b)) continue;
        //Distance Check
        float d = PVector.dist(prevCollision.pos, point.pos);
        if (d<record) {
          record = d;
          pt = point;
        }
      }

      if (pt != null) {
        //Get our kr for fresnel reflection is kr refraction is 1-kr
        kr = i-kr;
        if(kr<0)kr=-kr;
        if (!FRESNEL) kr = 1;
        
        //Lower our light per bounce
        float alpha = rays[i].alpha/1.2;
        
        //Don't dim light that is transmitted
        if (pt.b.material==GLASS || kr<1) alpha = map(kr, 0, 1, 0, alpha);

        stroke(iRay.col, alpha);
        line(prevCollision.pos.x, prevCollision.pos.y, pt.pos.x, pt.pos.y);

        bounces--;
        rays[i].alpha = alpha;
        if (iRay.alpha<=1) {
          rays[i].alpha = 0;
          bounces = 0;
        }
        trace(rays[i], prevCollision.pos, pt, bounces);
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
