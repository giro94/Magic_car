class Checkpoint
{
  PVector p1;
  PVector p2;
  boolean active;
  int score;
  
  Checkpoint(PVector p, PVector q)
  {
    p1 = p;
    p2 = q;
  }
  
  void Draw()
  {
    if (!active) return;
    
    stroke(0,255,0);
    strokeWeight(4);
    line(p1.x,p1.y,p2.x,p2.y);
    
    fill(0);
    ellipse(p1.x,p1.y,3,3);
    ellipse(p2.x,p2.y,3,3);
  }
}
