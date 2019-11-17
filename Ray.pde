class Ray{
  PVector pos, dir;
  color col;
  float wavelength;
  float sat = 100;
  float b = 255;
  Ray(PVector pos, float angle){
    this.pos = pos;
    dir = PVector.fromAngle(angle);
    changeColor();
  }
  
  public void setDir(float angle){
    dir = PVector.fromAngle(angle);
  }
  
  public void changeColor(){
    float hue = random(316);
    col = color(hue, sat, b);
    wavelength = map(hue, 0, 316, 740, 380);
    //Expand red side of the spectrum
    if(hue<40){
      wavelength = map(hue, 0, 40, 780, 650);
      col = color(0, sat, b);  
    }
    else wavelength+=40;
  }
  
  public void offset(float angle){
    dir = getOffset(angle);
  }
  public PVector getOffset(float angle){
    float theta = radians(angle);
    float cs = cos(theta);
    float sn = sin(theta);
    
    float x = dir.x * cs - dir.y * sn;
    float y = dir.x * sn + dir.y * cs;
    return new PVector(x, y);
  }
  
  public PVector cast(Boundary b){
    float x1 = b.a.x;
    float y1 = b.a.y;
    float x2 = b.b.x;
    float y2 = b.b.y;
    
    float x3 = pos.x;
    float y3 = pos.y;
    float x4 = pos.x + dir.x;
    float y4 = pos.y + dir.y;
    
    float den = (x1 - x2) * (y3 - y4)  - (y1 - y2) * (x3 - x4);
    if(den == 0) return null;
    
    float t = ((x1 - x3) * (y3 - y4) - (y1-y3) * (x3-x4))/den;
    float u = -((x1 - x2) * (y1 - y3) - (y1-y2) * (x1-x3))/den;
    
    if(t>0 && t<1 && u > 0) 
    {
      PVector pt = new PVector();
      pt.x = x1 + t * (x2 - x1);
      pt.y = y1 + t * (y2 - y1);
      return pt;
    }
    return null;
  }
  public PVector bounce(PVector cPT, float iAngle, Boundary b){
    PVector dir = PVector.fromAngle(iAngle);
    float x1 = b.a.x;
    float y1 = b.a.y;
    float x2 = b.b.x;
    float y2 = b.b.y;
    
    float x3 = cPT.x;
    float y3 = cPT.y;
    float x4 = cPT.x + dir.x;
    float y4 = cPT.y + dir.y;
    
    float den = (x1 - x2) * (y3 - y4)  - (y1 - y2) * (x3 - x4);
    if(den == 0) return null;
    
    float t = ((x1 - x3) * (y3 - y4) - (y1-y3) * (x3-x4))/den;
    float u = -((x1 - x2) * (y1 - y3) - (y1-y2) * (x1-x3))/den;
    
    if(t>0 && t<1 && u > 0) 
    {
      PVector pt = new PVector();
      pt.x = x1 + t * (x2 - x1);
      pt.y = y1 + t * (y2 - y1);
      return pt;
    }
    return null;
  }
}
