class Neuron{
  
  Link [] link;
  float value;
  
  Neuron(){
    value = 0;
  }
  
  float sigmoid(float x){
  
    float f_sigmoid = 1/(1-exp(-x));
    return f_sigmoid;
    
  };
  
  float sum_all(Link [] links){
    
    float result = 0;
    
    for ( Link v : links){
      result += v.getValue();
    }
    
    return result;
  };
  
  float get_value(){
  
    return sigmoid(sum_all(link)); 
  };
  
  void update(){
    value = get_value();
  }
  
  
}
