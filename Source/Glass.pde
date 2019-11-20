class Glass{
  
  ArrayList<Boundary> boundaries = new ArrayList<Boundary>();
  
  Glass(float cx, float cy, float w, float h, float angle, int sides, boolean isLense){
    //Make a copy of the number a sides to account for lenses in the div equation
    int aSides = sides;
    //Cut the glass in half if we are making a lense
    //TODO: add concave option
    if(isLense){
      sides = sides/2;
    }
    
    //Make sure our object has at least 3 sides
    if(sides<3)sides = 3;
    
    PVector p[] = new PVector[sides];
    //Rotate our points based on the input angle
    for(int i = 0; i<sides; i++){
      float div = map(i, 0, aSides, 0, TWO_PI);
      p[i] = rotate(sin(div)*w+cx, cos(div)*h+cy, cx, cy, angle);
    }
    for(int i = 1; i<sides; i++){
      boundaries.add(new Boundary(p[i].x, p[i].y, p[i-1].x, p[i-1].y, GLASS));
    }
    //Redo our last boundary to ensure the it follows the normals
    boundaries.add(new Boundary(p[0].x, p[0].y, p[sides-1].x, p[sides-1].y, GLASS));
    
  }
  private PVector rotate(float x, float y, float cx, float cy, float theta){
    // cx, cy - center of square coordinates
    // x, y - coordinates of a corner point of the square
    // theta is the angle of rotation
    
    // translate point to origin
    float tempX = x - cx;
    float tempY = y - cy;
    
    // now apply rotation
    float rotatedX = tempX*cos(theta) - tempY*sin(theta);
    float rotatedY = tempX*sin(theta) + tempY*cos(theta);
    
    // translate back
    x = rotatedX + cx;
    y = rotatedY + cy;
    
    return new PVector(x, y);
  }
    
  public void show(){
    for(Boundary b : boundaries){
      b.show();
    }
  }
}
