class Boundary{
  PVector a, b;
  private PVector normal;
  private int material = WALL;
  Boundary(float x1, float y1, float x2, float y2){
     this(x1, y1, x2, y2, WALL);
  }
  
  Boundary(PVector a, PVector b, int material){
    this.a = a;
    this.b = b;
    this.normal = PVector.fromAngle(atan2(b.y-a.y,b.x-a.x)-PI/2);
    this.material = material;
  }
  
  Boundary(PVector a, PVector b){
    this(a,b,WALL);
  }
  Boundary(float x1, float y1, float x2, float y2, int material){
    a = new PVector(x1, y1);
    b = new PVector(x2, y2);
    normal= PVector.fromAngle(atan2(b.y-a.y,b.x-a.x)-PI/2);
    this.material = material;
  }
  
  public Boundary copy(){
    return new Boundary(a.x, a.y, b.x, b.y, material);
  }
  
  public void setGlass(int m){ material = m;}
  public int isGlass(){return material;}
  
  public void show(){
    if(material == NOTHING) return;
    if(material == WALL)stroke(150);
    else stroke(150, 100, 255);
    line(a.x, a.y, b.x, b.y);
  }
}
