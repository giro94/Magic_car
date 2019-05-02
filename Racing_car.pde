Track track;
Car car;

void setup()
{
  size(1500,1000);
  track = new Track();
  car = new Car(track.points[0]);
}

void draw()
{
  background(255);

  pushMatrix();
    translate(width/2,height/2);
    //track.generateTrack(track.N);
    track.Draw();
    car.Draw();
    car.DrawSight();
      text(frameRate,0,0);

  popMatrix();
  car.Move();
  car.commands();
  
  fill(0);
  if (!car.is_alive(track))
  {
    textSize(100);
    textAlign(CENTER,CENTER);
    fill(random(255),random(255),random(255));
    text("MORTO",width/2,height/2);
    
    track.generateTrack(track.N);
    float speed_temp = car.speed;
    car = new Car(track.points[0]);
    car.speed = speed_temp;
  }
  
}

void mousePressed()
{
  track.generateTrack(track.N);
  car = new Car(track.points[0]);
  ellipse(10,10,10,10);
  
}
