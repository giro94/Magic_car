AI ai;

int Width_car = 800;
int Height_car = 1000;
int Width_net = 800;
int Height_net = 1000;

void setup()
{
  size(1600, 1000);
  ai = new AI();
}

void draw()
{
  background(255);
  ai.newTrack();
  ai.Race();
  ai.Leaderboard();
  ai.Evolve();
  ai.Mutate();



  float score = 1;
  ai.net.getWeights(ai.cars[0]);
  ai.track.reset_checkpoints();

  float timer = 0;
  while (ai.cars[0].is_alive() && timer < ai.Maxtime)
  {
    ai.net.getInput(ai.cars[0]);
    ai.net.propagate();
    ai.net.drive(ai.cars[0]);
    ai.cars[0].Move();
    ai.Draw();
    fill(0);
    textSize(30);
    text("Score: " + (score - timer/ai.Maxtime), Width_car - 100, Height_car - 100);
    text("Time: " + timer, Width_car - 50, Height_car - 50);
    float check_score = ai.cars[0].has_scored();
    if (check_score < 0)
    {
      score += 100;
      break;
    }
    score += check_score;
    timer++;
  }
 

  
}
