class AI
{
  int Ncars = 100;
  Car[] cars;
  float[] scores;
  Track track;
  Network net;
  int Maxtime = 600;
  int Nbest = 5;
  int Nsex = 40;
  int Npush = 40;

  AI()
  {
    track = new Track();
    cars = new Car[Ncars];
    scores = new float[Ncars];
    for (int i=0; i<Ncars; i++)
    {
      cars[i] = new Car(track);
      scores[i] = 0;
    }
    net = new Network();
  }

  void newTrack()
  {
    track.generateTrack(track.N);
    for (int i=0; i<Ncars; i++)
      cars[i].reset(track);
  }

  void Race()
  {
    for (int i=0; i<Ncars; i++)
    {
      print("Current competitor: car " + i + "\n");
      scores[i] = 1;
      net.getWeights(cars[i]);
      track.reset_checkpoints();

      float timer = 0;
      while (cars[i].is_alive() && timer < Maxtime)
      {
        net.getInput(cars[i]);
        net.propagate();
        net.drive(cars[i]);
        cars[i].Move();
        float check_score = cars[i].has_scored();
        if (check_score < 0)
        {
          scores[i] += 100;
          break;
        }
        scores[i] += check_score;
        timer++;
      }
      if(scores[i] >= 2)
      scores[i] -= timer/Maxtime;
    }
  }

  void Leaderboard()
  {
    int[] ranking = Sort(scores);

    Car[] car_copy = cars.clone();
    for (int i=0; i<Ncars; i++)
    {
      cars[i] = car_copy[ranking[i]];
    }
  }

  void Evolve()
  {
    for (int i=Nbest; i<Nbest+Npush; i++)
    {
      cars[i].LearnFrom(cars[i%Nbest]);
    }

    for (int i=Nbest+Npush; i<Nbest+Npush+Nsex; i++)
    {
      cars[i].CopyFrom(cars[i%Nbest]);
    }

    for (int i=Nbest+Npush; i<Nbest+Npush+Nsex; i+=2)
    {
      cars[i].FuckWith(cars[i+1]);
    }

    for (int i=Nbest+Npush+Nsex; i<Ncars; i++)
    {
      cars[i].Randomize();
    }
  }

  void Mutate()
  {
    for (int i=Nbest; i<Ncars; i++)
    {
      if (random(0, 1)<0.1)
      {
        cars[i].weights[floor(random(0, cars[i].weights.length))] = random(-1, 1);
      }
    }
  }

  void Draw()
  {
    pushMatrix();
    translate(Width_car/2, Height_car/2);
    translate(-cars[0].pos[0], -cars[0].pos[1]);
    //track.generateTrack(track.N);
    track.Draw();
    cars[0].DrawSight();
    cars[0].Draw();
    popMatrix();
    
    pushMatrix();
    translate(Width_car, 0);

    fill(200, 200, 200);
    rect(0, 0, Width_net, Height_net);

    net.Draw();
    popMatrix();
    
    //textSize(30);
    //text("Best score: " + scores[0], 100, height-100);
    
    
  }
}


int[] Sort(float[] scores_)
{
  float[] scores = new float[scores_.length];
  int[] indexes = new int[scores_.length];
  for (int i=0; i<scores_.length; i++)
  {
    indexes[i] = i;
    scores[i] = scores_[i];
  }

  for (int i=0; i<scores.length; i++)
  {
    int idx = find_max(scores, i, scores.length);

    float score_temp = scores[i];
    int index_temp = indexes[i];
    scores[i] = scores[idx];
    indexes[i] = indexes[idx];
    scores[idx] = score_temp;
    indexes[idx] = index_temp;
  }
  return indexes;
}

int find_max(float[] array, int i_from, int i_to)
{
  float max = -1000000;
  int max_index = 0;

  for (int i=i_from; i<i_to; i++)
  {
    if (array[i] > max)
    {
      max = array[i];
      max_index = i;
    }
  }
  return max_index;
}
