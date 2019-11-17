class Boundary{
  PVector a, b;
  boolean isGlass = false;
  Boundary(float x1, float y1, float x2, float y2){
    a = new PVector(x1, y1);
    b = new PVector(x2, y2);
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
    stroke(150);
    line(a.x, a.y, b.x, b.y);
  }
}
