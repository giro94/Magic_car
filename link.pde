class Link
{
  Neuron in; 
  float weight;
  

  Link(Neuron input)
  {
    
    weight = 0;
    in = input;
    
  }

  float getValue(){
    return in.value * weight; 
  }
  

}
