class Car {
  float [] pos;
  float speed;
  float angle;
  float radius = 10;
  float MaxSight = 100;
  float MaxSpeed = 8;
  int Nlasers = 7;
  float angle_err = PI/36;
  float[] weights;
  float MaxWeight = 5;
  Track track;
  float learning_step = 0.6;

  PVector pos_prev1;
  PVector pos_prev2;
  PVector vel_prev1;
  PVector vel_prev2;



  Car(Track t) {
    track = t;
    pos = new float [2];
    pos[0] = t.points[0].x;
    pos[1] = t.points[0].y;
    speed = 0;
    angle = 0;
    weights = new float[12*9+4*12];
    Randomize();
    //print("Costruisco car, con "+weights.length+" pesi\n");
    pos_prev1 = new PVector(0, 0);
    pos_prev2 = new PVector(0, 0);
    vel_prev1 = new PVector(0, 0);
    vel_prev2 = new PVector(0, 0);
  }

  void reset(Track t)
  {
    track = t;
    pos[0] = t.points[0].x;
    pos[1] = t.points[0].y;
    speed = 0;
    angle = 0;
  }

  void autopilot(char action)
  {
    switch(action)
    {
    case 'w': 
      speed += 0.4;
      break;
    case 's':
      speed -= 0.1;
      break;
    case 'a':
      angle -= 0.05;
      break;
    case 'd':        
      angle += 0.05;
      break;
    default:
    }
    speed = constrain(speed, 0, MaxSpeed);
  }

  float commands() {
    if (keyPressed) {
      if (key == 'd') {
        angle += 0.05;
        return angle;
      }
      if (key == 'a') {
        angle -= 0.05;
        return angle;
      }
      if (key == 'w') {
        speed += 0.4;
        speed = constrain(speed, 0, 8);
        return speed;
      }
      if (key == 's') {
        speed -= 0.1;
        speed = constrain(speed, 0, 8);
        return speed;
      }
    }
    return speed;
  }

  void Move() {
    pos_prev2.x = pos_prev1.x;
    pos_prev2.y = pos_prev1.y;
    pos_prev1.x = pos[0];
    pos_prev1.y = pos[1];
    vel_prev2.x = vel_prev1.x;
    vel_prev2.y = vel_prev1.y;
    vel_prev1.x = speed;
    vel_prev1.y = angle;


    pos[0] = pos[0] + speed * cos(angle);
    pos[1] = pos[1] + speed * sin(angle);
  }



  void Draw() {
    stroke(0, 255, 0);
    line(pos[0], pos[1], pos[0] + 10*speed * cos(angle), pos[1] + 10*speed * sin(angle));
    noStroke();
    fill(255, 0, 0);
    ellipse(pos[0], pos[1], 2*radius, 2*radius);
  }

  float distSq(float x1, float y1, float x2, float y2) {
    float distance = (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2);
    return distance;
  }


  boolean is_alive() {

    if (pos[0] == pos_prev1.x && pos[1] == pos_prev1.y)
    {
      if (speed == vel_prev1.x && angle == vel_prev1.y)
      {
        if (pos_prev1.x == pos_prev2.x && pos_prev1.y == pos_prev2.y)
        { 
          if (vel_prev1.x == vel_prev2.x && vel_prev1.y == vel_prev2.y)
          {
            return false;
          }
        }
      }
    }

    for (PVector v : track.pointsIn) {
      if ( dist(pos[0], pos[1], v.x, v.y) < radius) {
        return false;
      }
    }

    for (PVector v : track.pointsOut) {
      if ( dist(pos[0], pos[1], v.x, v.y) < radius) {
        return false;
      }
    }

    return true;
  }

  float[] getSight()
  {
    float[] lasers = new float[Nlasers];
    PVector carpos = new PVector(pos[0], pos[1]);

    for (int l=0; l<Nlasers; l++)
    {
      float langle = angle + 0.5*PI - l*(PI/(Nlasers-1));
      ArrayList<PVector> ps = new ArrayList<PVector>();
      for (int p=0; p<track.N; p++)
      {
        PVector pt = track.pointsIn[p];
        if (pt.dist(carpos) < MaxSight)
        {
          float thisangle = atan2(pt.y-pos[1], pt.x-pos[0]);
          if (abs((thisangle - langle + 2*PI)%(2*PI)) < angle_err)
            ps.add(pt);
        }
        pt = track.pointsOut[p];
        if (pt.dist(carpos) < MaxSight)
        {
          float thisangle = atan2(pt.y-pos[1], pt.x-pos[0]);
          if (abs((thisangle - langle + 2*PI)%(2*PI)) < angle_err)
            ps.add(pt);
        }
      }

      if (ps.size()>0)
      {
        float[] dists = new float[ps.size()];
        for (int i=0; i<ps.size(); i++)
        {
          dists[i] = carpos.dist(ps.get(i));
        }
        lasers[l] = min(dists);
      } else
      {
        lasers[l] = MaxSight;
      }
    }
    return lasers;
  }

  boolean check_cross(Checkpoint c)
  {
    float x1 = c.p1.x;
    float y1 = c.p1.y;
    float x2 = c.p2.x;
    float y2 = c.p2.y;

    float x3 = pos[0];
    float y3 = pos[1];
    float x4 = pos[0] + radius*cos(angle);
    float y4 = pos[1] + radius*sin(angle);

    float den = (x1-x2)*(y3-y4)-(y1-y2)*(x3-x4);
    if (den == 0) return false;

    float t = ((x1-x3)*(y3-y4)-(y1-y3)*(x3-x4))/den;
    float u = -((x1-x2)*(y1-y3)-(y1-y2)*(x1-x3))/den;

    return (t>=0 && t<=1 && u>=0 && u<=1);
  }

  int has_scored()
  {
    for (int i=0; i<track.NCheckpoints; i++)
    {
      if (track.checks[i].active)
      {
        if (check_cross(track.checks[i]))
        {
          track.checks[i].active = false;
          if (i<track.NCheckpoints-1)
            track.checks[i+1].active = true;

          if (i == track.NCheckpoints-1)
            return -1;

          return track.checks[i].score;
        }
      }
    }
    return 0;
  }

  float[] laser_normalized() {
    float[] laser_normalized_ = getSight();

    for (int i = 0; i< laser_normalized_.length; i++) {
      laser_normalized_[i] /= MaxSight;
    }
    return laser_normalized_;
  }


  void DrawSight()
  {
    float[] lasers = getSight();
    float[] angles = new float[Nlasers];
    for (int i=0; i<Nlasers; i++)
    {
      angles[i] = angle + 0.5*PI - i*(PI/(Nlasers-1));
      PVector dot = new PVector(pos[0]+lasers[i]*cos(angles[i]), pos[1]+lasers[i]*sin(angles[i]));
      stroke(0, 0, 255);
      line(pos[0], pos[1], dot.x, dot.y);
      fill(0, 255, 255);
      noStroke();
      ellipse(dot.x, dot.y, 6, 6);
    }
  }

  void CopyFrom(Car c)
  {
    for (int i=0; i<weights.length; i++)
      weights[i] = c.weights[i];
  }

  void LearnFrom(Car c)
  {
    for (int i=0; i<weights.length; i++)
      weights[i] += learning_step*(c.weights[i]-weights[i]);
  }

  void FuckWith(Car c)
  {
    int idx = floor(random(0, weights.length));
    for (int i = idx; i<weights.length; i++)
    {
      float temp = weights[i];
      weights[i] = c.weights[i];
      c.weights[i] = temp;
    }
  }

  void Randomize()
  {
    for (int i=0; i<weights.length; i++)
    {
      weights[i] = random(-MaxWeight, MaxWeight);
    }
  }
}
