class Line {
  float x1, y1, x2, y2;
  Boundary b;
  Line(Boundary b) {
    this.x1 = b.a.x;
    this.y1 = b.a.y;
    this.x2 = b.b.x;
    this.y2 = b.b.y;
    this.b = b;
  }
  Line(float x1, float y1, float x2, float y2) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
    this.b = new Boundary(0,0,0,0,NOTHING);
  }

  public Point intersectsLine(Line line) {
    float angle = atan2(y2-y1, x2-x1);
    PVector dir = PVector.fromAngle(angle);
    float lX1 = line.x1;
    float lY1 = line.y1;
    float lX2 = line.x2;
    float lY2 = line.y2;

    float x3 = x1;
    float y3 = y1;
    float x4 = x1 + dir.x;
    float y4 = y1 + dir.y;

    float den = (lX1 - lX2) * (y3 - y4)  - (lY1 - lY2) * (x3 - x4);
    if (den == 0) return null;

    float t = ((lX1 - x3) * (y3 - y4) - (lY1-y3) * (x3-x4))/den;
    float u = -((lX1 - lX2) * (lY1 - y3) - (lY1-lY2) * (lX1-x3))/den;
    if (t>0 && t<1 && u > 0) {
      PVector pt = new PVector();
      pt.x = lX1 + t * (lX2 - lX1);
      pt.y = lY1 + t * (lY2 - lY1);
      return new Point(pt, line.b);
    }
    return null;
  }
}

class Rectangle {
  float cx, cy;
  float h, w;
  //Takes half width and half height
  Rectangle(float cx, float cy, float w, float h) {
    this.cx = cx;
    this.cy = cy;
    this.h = h;
    this.w = w;
  }
  
  public boolean containsLine(Line line) {
    float minX = cx-w;
    float maxX = cx+w;
    float minY = cy-h;
    float maxY = cy+h;
    if ((line.x1<=minX && line.x2<=minX)||(line.x1>=maxX&&line.x2>=maxX)||
      (line.y1<=minY && line.y2<=minY)||(line.y1>=maxY&&line.y2>=maxY)) return false;
    float m = (line.y2-line.y1)/(line.x2-line.x1);

    float y = m*(minX-line.x1)+line.y1;
    if (y>minY && y<maxY)return true;

    y = m*(maxX-line.x1)+line.y1;
    if (y>minY && y<maxY)return true;

    float x = (minY-line.y1)/m+line.x1;
    if (x>minX && x<maxX)return true;

    x = (maxY-line.y1)/m+line.x1;
    if (x>minX && x<maxX)return true;

    return false;
  }

  public boolean intersects(Line line) {
    if((line.intersectsLine(new Line(cx-w, cy-h, cx+w, cy-h))!=null||
      line.intersectsLine(new Line(cx+w, cy-h, cx+w, cy+h))!=null||
      line.intersectsLine(new Line(cx+w, cy+h, cx-w, cy+h))!=null||
      line.intersectsLine(new Line(cx-w, cy+h, cx-w, cy-h))!=null)) return true;
    return false;
  }
}

class QuadTree {
  boolean intersect = false;
  int cap;
  Rectangle boundary;
  QuadTree northWest, northEast, southWest, southEast;
  ArrayList<Line> lines = new ArrayList<Line>();

  QuadTree(Rectangle boundary, int capacity) {
    this.boundary = boundary;
    this.cap = capacity;
  }

  public boolean insert(Line l) {
    if (!boundary.containsLine(l)) {
      return false;
    }

    if (lines.size() < cap && northWest == null) {
      lines.add(l);
      return true;
    }

    if (northWest == null)
      subdivide();

    boolean inserted = false;
    if (northWest.insert(l))inserted = true;
    if (northEast.insert(l))inserted = true;
    if (southWest.insert(l))inserted = true;
    if (southEast.insert(l))inserted = true;

    return inserted;
  }

  public void subdivide() {
    float cx = boundary.cx;
    float cy = boundary.cy;
    float h = boundary.h;
    float w = boundary.w;
    northWest = new QuadTree(new Rectangle(cx-w/2, cy-h/2, w/2, h/2), cap);
    northEast = new QuadTree(new Rectangle(cx+w/2, cy-h/2, w/2, h/2), cap);
    southWest = new QuadTree(new Rectangle(cx-w/2, cy+h/2, w/2, h/2), cap);
    southEast = new QuadTree(new Rectangle(cx+w/2, cy+h/2, w/2, h/2), cap);
  }

  public ArrayList<Point> query(Line line) {
    ArrayList<Point> linesInRange = new ArrayList<Point>();
    if (!boundary.intersects(line)) return linesInRange; //empty array
    intersect = true;
    for (Line l : lines) {
      //if (line.containsLine(l)) {
      //  linesInRange.add(l.b);
      //}
      Point pt = line.intersectsLine(l);
      if(!(pt == null)) linesInRange.add(pt);
    }

    if (northWest==null)
      return linesInRange;

    linesInRange.addAll(northWest.query(line));
    linesInRange.addAll(northEast.query(line));
    linesInRange.addAll(southWest.query(line));
    linesInRange.addAll(southEast.query(line));

    return linesInRange;
  }

  public void show() {
    if (!intersect)stroke(255);
    else stroke(150, 255, 255);
    noFill();
    rectMode(RADIUS);
    rect(boundary.cx, boundary.cy, boundary.w, boundary.h);
    if (northWest!=null) {
      northWest.show();
      northEast.show();
      southWest.show();
      southEast.show();
    }
    intersect = false;
    rectMode(CORNER);
  }

  public void clear() {
    lines.clear();
    northWest = null;
    northEast = null;
    southWest = null;
    southEast = null;
  }
}
