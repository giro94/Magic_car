class AI
{
  int Ncars = 500;
  Car[] cars;
  float[] scores;
  Track track;
  Network net;
  int Maxtime = 600;
  int Nbest = 25;
  int Nsex = 40;
  int Npush = 40;
  int gen = 0;
  int gens_per_track = 200;
  ArrayList<float[]> allscores;

  AI()
  {
    track = new Track();
    cars = new Car[Ncars];
    scores = new float[Ncars];
    allscores = new ArrayList<float[]>();
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

  void resetCars()
  {
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
        //scores[i] += 0.01*cars[i].speed;
        timer++;
      }      
      if (scores[i] >= 2)
        scores[i] -= timer/Maxtime;
    }
  }

  void Leaderboard()
  {
    int[] ranking = Sort(scores);

    Car[] car_copy = cars.clone();
    float[] scores_ord = new float [Ncars];
    for (int i=0; i<Ncars; i++)
    {
      cars[i] = car_copy[ranking[i]];
      scores_ord[i] = scores[ranking[i]];
    }

    allscores.add(scores_ord);
  }

  void Evolve()
  {
    /*
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
     */

    for (int i=Nbest; i<Ncars; i++)
    {
      cars[i].CopyFrom(cars[i%Nbest]);
    }
  }

  void Mutate()
  {
    for (int i=Nbest; i<Ncars; i++)
    {
      int n_weights = cars[i].weights.length;
      float percentage = map(i,Nbest,Ncars,0.01,1);
      for (int j=0; j<n_weights; j++)
      {
        if (random(0, 1) < percentage) //From 1% to 100%
        {
          cars[i].weights[j] = random(-cars[i].MaxWeight, cars[i].MaxWeight);
        }
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

    pushMatrix();
    translate(0, Height_car);
    DrawGraph();
    popMatrix();

    //textSize(30);
    //text("Best score: " + scores[0], 100, height-100);
  }

  void DrawGraph()
  {
    stroke(0);
    strokeWeight(1);
    fill(51);
    rect(0, 0, Width_graph, Height_graph);
    fill(101);
    rect(0.05*Width_graph, 0.05*Height_graph, 0.9*Width_graph, 0.9*Height_graph);
    float maxscore = allscores.get(gen-1)[0];
    float dx = 0.9*Width_graph/gen;
    float dy = 0.9*Height_graph/maxscore;
    int Ylines = 9;
    int Xlines = 10;

    //Draw Y axis
    for (int i=0; i<Ylines; i++)
    {
      stroke(51);
      float h = 0.95*Height_graph - i*0.9*Height_graph/(Ylines-1);
      line(0.05*Width_graph, h, 0.95*Width_graph, h);
      textSize(10);
      textAlign(CENTER, CENTER);
      fill(255);
      text(nf(i*maxscore/(Ylines-1), 3, 2), 0.025*Width_graph, h);
      fill(0, 255, 0);
      if (gen>0)
        text(allscores.get(gen-1)[0], 0.975*Width_graph, 0.95*Height_graph-dy*allscores.get(gen-1)[0]);
      fill(255, 0, 0);
      if (gen>0)
        text(allscores.get(gen-1)[5*((Ncars-1)/10)], 0.975*Width_graph, 0.95*Height_graph-dy*allscores.get(gen-1)[5*((Ncars-1)/10)]);
    }

    //Draw X axis
    for (int i=0; i<Xlines; i++)
    {
      stroke(51);
      float X = 0.05*Width_graph + i*0.9*Width_graph/(Xlines-1);
      line(X, 0.05*Height_graph, X, 0.95*Height_graph);
      textSize(10);
      textAlign(CENTER, CENTER);
      fill(255);
      text(round(i*gen/(Xlines-1)), X, 0.975*Height_graph);
    }

    //Draw graphs
    int Ngraphs = 101; //odd number here pls
    for (int i=0; i<Ngraphs; i++)
    {
      int index = i*((Ncars-1)/(Ngraphs-1));
      if (i==0)
        stroke(0, 255, 0);
      else if (i==(Ngraphs-1)/2)
        stroke(255, 0, 0);
      else 
      stroke(0, 0, 255);

      for (int j=0; j<gen; j++)
      {
        if (j==0)
          line(0.05*Width_graph, 0.95*Height_graph, 0.05*Width_graph+dx, 0.95*Height_graph-dy*allscores.get(j)[index]);
        else
          line(0.05*Width_graph + j*dx, 0.95*Height_graph-dy*allscores.get(j-1)[index], 0.05*Width_graph+(j+1)*dx, 0.95*Height_graph-dy*allscores.get(j)[index]);
      }
    }
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
