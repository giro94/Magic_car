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
    float Value = in.value * weight; 
    return Value;
  }
  

}
