//Constants
int ABBE_GLASS = 45;
float DP = 589.3;
int C = 500000;

//Line intersection

public int orientation(PVector p, PVector q, PVector r) {
  double val = (q.y - p.y) * (r.x - q.x)
    - (q.x - p.x) * (r.y - q.y);

  if (val == 0.0)
    return 0; // colinear
  return (val > 0) ? 1 : 2; // clock or counterclock wise
}

public boolean intersect(PVector p1, PVector q1, PVector p2, PVector q2) {

  int o1 = orientation(p1, q1, p2);
  int o2 = orientation(p1, q1, q2);
  int o3 = orientation(p2, q2, p1);
  int o4 = orientation(p2, q2, q1);

  if (o1 != o2 && o3 != o4)
    return true;

  return false;
}
