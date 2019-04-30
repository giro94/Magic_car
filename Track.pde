int sign(float f) {
  if (f >= 0) return 1;
  if (f < 0) return -1;
  return 0;
} 

class Track
{
  PVector[] points;
  PVector[] pointsIn;
  PVector[] pointsOut;
  float size;
  float radius;
  int N;


  Track()
  {
    N = 2000;
    radius = 400;
    size = 40;
    generateTrack(N);
  }

  void generateTrack(int n)
  {
    points = new PVector[n];
    pointsIn = new PVector[n];
    pointsOut = new PVector[n];
    float nx = random(10, 1000);
    float ny = random(10, 1000);
    for (int i=0; i<n; i++)
    {
      float theta = map(i, 0, n, 0, 2*PI);
      float r = 1;
      float Ain = 200;
      float Aout = 100;
      float rn = noise(nx+r*cos(theta), ny+r*sin(theta));
      float d = map(sin(PI*rn*rn)*sin(PI*rn*rn), 0, 1, radius-Ain, radius+Aout);
      points[i] = new PVector(d*sin(theta), d*cos(theta));
      pointsIn[i] = new PVector((d-size)*sin(theta), (d-size)*cos(theta));
      pointsOut[i] = new PVector((d+size)*sin(theta), (d+size)*cos(theta));
      
    }
  }

  void Draw()
  {
    strokeWeight(3);
    stroke(255, 0, 0);
    fill(0);
    beginShape();
    for (PVector p : pointsOut)
      vertex(p.x, p.y);
    endShape(CLOSE);

    fill(255);
    beginShape();
    for (PVector p : pointsIn)
      vertex(p.x, p.y);
    endShape(CLOSE);

    stroke(255);
    strokeCap(SQUARE);
    noFill();
    beginShape(LINES);
    for (int i=0; i<N; i+=3)
      vertex(points[i].x, points[i].y);
    endShape(CLOSE);
    strokeCap(ROUND);

  }
}
