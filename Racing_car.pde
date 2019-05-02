Track track;
Car car_;
Network net;

void setup()
{
  size(1500, 1000);
  track = new Track();
  car_ = new Car(track.points[0]);
  net = new Network();
  net.getWeights(car_);
}

void draw()
{
  background(255);

  pushMatrix();
  translate(width/2, height/2);
  translate(-car_.pos[0],-car_.pos[1]);
  //track.generateTrack(track.N);
  track.Draw();
  car_.DrawSight();
  car_.Draw();

  popMatrix();
  car_.Move();
  car_.commands();
  net.getInput(car_);
  net.propagate();
  net.drive(car_);

  fill(0);
  if (!car_.is_alive(track))
  {
    track.generateTrack(track.N);
    float speed_temp = car_.speed;
    car_ = new Car(track.points[0]);
    //car_.speed = speed_temp;
  }
}

void mousePressed()
{
  track.generateTrack(track.N);
  car_ = new Car(track.points[0]);
  ellipse(10, 10, 10, 10);
}
