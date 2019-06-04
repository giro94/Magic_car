AI ai;
boolean replay;
float timer;
float score;
int Width_car = 800;
int Height_car = 700;
int Width_net = 800;
int Height_net = 700;
int Width_graph = 1600;
int Height_graph = 200;



void setup()
{
  size(1600, 900);
  ai = new AI();
  replay = false;
}

void draw()
{
  if (!replay) {
    if (ai.gen % ai.gens_per_track == 0)
      ai.newTrack();
      
    ai.resetCars();
    ai.Race();
    ai.Leaderboard();
    ai.Evolve();
    ai.Mutate();
    ai.gen++;

    replay = true;
    score = 1;
    ai.net.getWeights(ai.cars[0]);
    ai.track.reset_checkpoints();
    ai.cars[0].reset(ai.track);
    timer = 0;
  } else {

    if (!(ai.cars[0].is_alive() && timer < ai.Maxtime)) {
      replay = false;
      return;
    } 
    ai.net.getInput(ai.cars[0]);
    ai.net.propagate();
    ai.net.drive(ai.cars[0]);
    ai.cars[0].Move();
    background(255);
    ai.Draw();
    fill(0);
    textSize(30);
    textAlign(RIGHT);
    text("Score: " + nf(score - timer/ai.Maxtime, 0,2), Width_car, Height_car - 100);
    text("Time: " + timer, Width_car, Height_car - 50);
    text("FPS " + int(frameRate), Width_car, 50);
    textAlign(LEFT);
    text("Generation " + ai.gen, 0, Height_car - 50);
    
    float check_score = ai.cars[0].has_scored();
    if (check_score < 0)
    {
      score += 100;
      replay = false;
    }
    score += check_score;
    timer++;
  }
}
