class Ray{
  PVector pos, dir;
  color col;
  float alpha = brightness;
  float hue;
  float wavelength;
  float sat = 100;
  float b = 255;
  Ray(PVector pos, float angle){
    this.pos = pos;
    dir = PVector.fromAngle(angle);
    changeColor();
    alpha = 100;
  }
  
  Ray(PVector pos, float angle, float alpha, float hue){
    this.pos = pos;
    dir = PVector.fromAngle(angle);
    this.alpha = alpha;
    this.hue = hue;
    changeColor(hue);
  }
  
  public Ray copy(){
    return new Ray(pos, dir.heading(), alpha, hue);
  }
  
  public void setDir(float angle){
    dir = PVector.fromAngle(angle);
  }
  
  public void changeColor(){
    hue = random(316);
    changeColor(hue);
  }
  
  public void changeColor(float hue){
    col = color(hue, sat, b);
    if(hue<40){
      wavelength = map(hue, 0, 40, 780, 650);
      col = color(0, sat, b);  
    }
    else wavelength = map(hue, 40, 316, 650, 380);
    //Expand red side of the spectrum
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
}
