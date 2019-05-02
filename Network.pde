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

    for (Neuron n : neuronIn)
    {
      n = new Neuron(0);
    }

    for (Neuron n : neuronHid)
    {
      n = new Neuron(ni);
      n.linkTo(neuronIn);
    } 

    for (Neuron n : neuronOut)
    {
      n = new Neuron(nh);
      n.linkTo(neuronHid);
    }
    
    
  }

  float[] getWeights()
  {
    float[] weights = car.weights;
    return weights;
  }

  float[] getInput()
  {
    
  }
}
