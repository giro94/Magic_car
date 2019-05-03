class Network {
  int ni = 9;
  int nh = 12;
  int no = 4;
  Neuron[] neuronIn;
  Neuron[] neuronOut;
  Neuron[] neuronHid;

  Network()
  {
    neuronIn = new Neuron[ni];
    neuronOut = new Neuron[no];
    neuronHid = new Neuron[nh];

    for (int i=0; i<neuronIn.length; i++)
    {
      neuronIn[i] = new Neuron(0, Width_net/4, (i+1)*Height_net/(ni+1));
    }

    for (int i=0; i<neuronHid.length; i++)
    {
      neuronHid[i] = new Neuron(ni, 2*Width_net/4, (i+1)*Height_net/(nh+1));
      neuronHid[i].linkTo(neuronIn);
    } 

    for (int i=0; i<neuronOut.length; i++)
    {
      neuronOut[i] = new Neuron(nh, 3*Width_net/4, (i+1)*Height_net/(no+1));
      neuronOut[i].linkTo(neuronHid);
    }
    
    
  }

  void getWeights(Car car)
  {
    //print(car.weights.length);
    //print("getWeights, car has "+car.weights.length+" weights\n");
    for (int i=0; i<nh; i++)
    {
      float[] ws = new float[ni];
      for (int j=0; j<ni; j++)
      {
        ws[j] = car.weights[i*ni +j];
      }
      neuronHid[i].setWeights(ws);
    }
    
    for (int i=0; i<no; i++)
    {
      float[] ws = new float[nh];
      for (int j=0; j<nh; j++)
      {
        ws[j] = car.weights[ni*nh +i*nh +j];
      }
      neuronOut[i].setWeights(ws);
    }
  }

  void getInput(Car car)
  {
    neuronIn[0].value = 1;
    
    float[] sight = car.laser_normalized();
    
    for (int i=0; i<car.Nlasers; i++)
    {
      neuronIn[i+1].value = sight[i];
    }
    
    neuronIn[ni-1].value = car.speed/car.MaxSpeed;
  }
  
  void propagate()
  {
    for (int i=0; i<nh; i++)
      neuronHid[i].update();
      
    for (int i=0; i<no; i++)
      neuronOut[i].update();
  }
  
  void drive(Car car)
  {
    if (neuronOut[0].value > 0.5)
      car.autopilot('w');
    
    if (neuronOut[1].value > 0.5)
      car.autopilot('s');
      
    if (neuronOut[2].value > 0.5)
      car.autopilot('a');
      
    if (neuronOut[3].value > 0.5)
      car.autopilot('d');
  }
  
  void Draw()
  {
    for (Neuron n : neuronOut)
      n.Draw();
    
    for (Neuron n : neuronHid)
      n.Draw();
    
    for (Neuron n : neuronIn)
      n.Draw();
      
    textSize(35);
    fill(0,0,255);
    if (neuronOut[0].value > 0.5)
      text("GAS",neuronOut[0].pos[0]+100,neuronOut[0].pos[1]);
    
    if (neuronOut[1].value > 0.5)
      text("STOP",neuronOut[1].pos[0]+100,neuronOut[1].pos[1]);
    
    if (neuronOut[2].value > 0.5)
      text("LEFT",neuronOut[2].pos[0]+100,neuronOut[2].pos[1]);
    
    if (neuronOut[3].value > 0.5)
      text("RIGHT",neuronOut[3].pos[0]+100,neuronOut[3].pos[1]);
    
  }
}
