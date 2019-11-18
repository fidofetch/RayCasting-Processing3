class Boundary{
  PVector a, b;
  boolean isGlass = false;
  Boundary(float x1, float y1, float x2, float y2){
    a = new PVector(x1, y1);
    b = new PVector(x2, y2);
  }
  
  Boundary(PVector a, PVector b, Boolean isGlass){
    this.a = a;
    this.b = b;
    this.isGlass = isGlass;
  }
  
  Boundary(PVector a, PVector b){
    this(a,b,false);
  }
  Boundary(float x1, float y1, float x2, float y2, Boolean isGlass){
    a = new PVector(x1, y1);
    b = new PVector(x2, y2);
    this.isGlass = isGlass;
  }
  
  public Boundary copy(){
    return new Boundary(a.x, a.y, b.x, b.y, isGlass);
  }
  
  public void setGlass(boolean b){ isGlass = b;}
  public boolean isGlass(){return isGlass;}
  
  public void show(){
    
    if(!isGlass)stroke(150);
    else stroke(150, 100, 255);
    line(a.x, a.y, b.x, b.y);
  }
}
