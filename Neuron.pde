class Neuron {

  Link [] link;
  float value;
  float [] pos;
  float diameter = 50;
  int nLinks;

  Neuron(int N, float pos_x, float pos_y)
  {
    nLinks = N;
    value = 0;
    link = new Link[nLinks];
    pos =  new float [2];
    pos[0] = pos_x;
    pos[1] = pos_y;
  }

  float sigmoid(float x) {
    float f_sigmoid = 1/(1+exp(-x));
    return f_sigmoid;
  };

  float sum_all(Link [] links) {

    float result = 0;

    for ( Link v : links) {
      result += v.getValue();
    }

    return result;
  };

  void update() {
    value = sigmoid(sum_all(link));
  }

  void updateOut() {
    value = 2*sigmoid(sum_all(link))-1;
  }

  void linkTo(Neuron[] neuronsIn)
  {
    for (int i = 0; i<nLinks; i++)
    {
      link[i] = new Link(neuronsIn[i]);
    }
  }

  void setWeights(float[] weights)
  {
    for (int i=0; i<nLinks; i++)
    {
      link[i].weight = weights[i];
    }
  }

  ///////////////////////////////////////////////////
  void Draw() {
    strokeWeight(2);
    fill(0, 0, 255);
    for (Link v : link) {
      float wv = v.getValue();
      if (wv >= 0)
        stroke(255, 255-255*wv, 255-255*wv);
      else
        stroke(255+255*wv,255+255*wv,255);
      line(pos[0], pos[1], v.in.pos[0], v.in.pos[1]);
    }
    
    stroke(0);
    if (value>=0.5)
      strokeWeight(3);
    else
      strokeWeight(1);
    fill(255,255,255-value*255);
    ellipse(pos[0], pos[1], diameter, diameter);
    textAlign(CENTER,CENTER);
    textSize(15);
    fill(0);
    text(value,pos[0],pos[1]);
  }
}
