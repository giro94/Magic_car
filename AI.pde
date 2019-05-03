class AI
{
  int Ncars = 100;
  Car[] cars;
  float[] scores;
  Track track;
  Network net;
  int Maxtime = 600;

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
      scores[i] -= timer/Maxtime;
    }
  }

  void Leaderboard()
  {
    float[] ranking = Sort(scores);
  }

  void Draw()
  {
  }
}


float[] Sort(float[] scores_)
{
  float[] scores = new float[scores_.length];
  float[] indexes = new float[scores_.length];
  for (int i=0; i<scores_.length; i++)
  {
    indexes[i] = i;
    scores[i] = scores_[i];
  }

  for (int i=0; i<scores.length; i++)
  {
    int idx = find_max(scores, i, scores.length);

    float score_temp = scores[i];
    float index_temp = indexes[i];
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
