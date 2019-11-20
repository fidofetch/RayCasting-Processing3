class Point{
  PVector pos;
  Boundary b;
  Point(PVector pos, Boundary b){
    this.pos = pos;
    this.b = b;
  }
  
  public PVector getNormal(){
    return b.normal;
  }
  public PVector getPos(){
    return pos;
  }
  public float getMaterial(){
    return b.material;
  }
}
