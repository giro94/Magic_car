Car car_;
Network net;
Track track;

int Width_car = 800;
int Height_car = 1000;
int Width_net = 800;
int Height_net = 1000;

void setup()
{
  size(1600, 1000);
  track = new Track();
  net = new Network();
  car_ = new Car(track);
}

void draw()
{
  background(255);

  //TRACK + CAR
  pushMatrix();
  translate(Width_car/2, Height_car/2);
  translate(-car_.pos[0], -car_.pos[1]);
  //track.generateTrack(track.N);
  track.Draw();
  car_.DrawSight();
  car_.Draw();
  popMatrix();


  pushMatrix();
  translate(Width_car, 0);

  fill(200, 200, 200);
  rect(0, 0, Width_net, Height_net);

  net.Draw();
  popMatrix();
  //////
  car_.Move();
  car_.commands();
  net.getInput(car_);
  net.propagate();
  net.drive(car_);
  car_.has_scored();

  fill(0);
  if (!car_.is_alive())
  {
    track.generateTrack(track.N);
    //float speed_temp = car_.speed;
    car_ = new Car(track);
    //car_.speed = speed_temp;
    net.getWeights(car_);
  }
}

void mousePressed()
{
  track.generateTrack(track.N);
  car_ = new Car(track);
  ellipse(10, 10, 10, 10);
}
