class Car {
  float [] pos;
  float speed;
  float angle;
  float radius = 15;
  float MaxSight = 600;
  float MaxSpeed = 8;
  int Nlasers = 7;
  float angle_err = PI/36;
  float[] weights;

  Car(float X, float Y) {
    pos = new float [2];
    pos[0] = X;
    pos[1] = Y;
    speed = 0;
    angle = 0;
    weights = new float[12*9+4*12];
    for (int i=0; i<weights.length; i++)
    {
      weights[i] = random(-1, 1);
    }
    //print("Costruisco car, con "+weights.length+" pesi\n");
  }

  Car(PVector v) {
    pos = new float [2];
    pos[0] = v.x;
    pos[1] = v.y;
    speed = 0;
    angle = 0;
    weights = new float[12*9+4*12];
    for (int i=0; i<weights.length; i++)
    {
      weights[i] = random(-1, 1);
    }
    
    print("SONO STATO INVOCATOO\n ");
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


  boolean is_alive(Track track) {
    for (PVector v : track.points) {
      if ( dist(pos[0], pos[1], v.x, v.y) - track.size < - radius) {
        return true;
      }
    }
    return false;
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
        lasers[l] = track.size;
      }
    }
    return lasers;
  }


  float[] laser_normalized() {
    float[]laser_normalized_ = getSight();

    for (int i = 0; i< getSight().length; i++) {
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
}
