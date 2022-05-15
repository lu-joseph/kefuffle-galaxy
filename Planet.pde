class Planet{
  int xC;
  int yC;
  int r;
  String name;
  String planetType;
   
  Planet(int xInput,int yInput,int rInput,String nameInput,String ltInput){
    xC = xInput;
    yC = yInput;
    r = rInput;
    name = nameInput;
    planetType = ltInput;
  }
  
  void separateFromPlanet(int xTC,int yTC){
    float dist = sqrt(pow(xTC-xC,2)+pow(yTC-yC,2));
    if(dist-1<earthR+r){
      int offset = 0;
      if(probFunction(50)){        
        if(xTC>xC){
          offset = abs((xC+r)-(xTC-earthR));
          xC -= offset+5;
        }else if(xTC<xC){
          offset = abs((xC-r)-(xTC+earthR));
          xC += offset+5;
        }else{
          offset = r+earthR;
          xC -= offset;
        }
      }else{
        if(yTC>yC){
          offset = abs((yC+r)-(yTC-earthR));
          yC -= offset+5;
        }else if(yTC<yC){
          offset = abs((yC-r)-(yTC+earthR));
          yC += offset+5;
        }else{
          offset = r+earthR;
          yC -= offset;
        }
      }
    }
  }
  
  float getDistanceFromPoint(int x,int y){
    return sqrt(pow(xC-x,2)+pow(yC-y,2));
  }
  
  int getTotalLand(){
    int c1 = 0;
    for(int i=0;i<n;i++){
      for(int j=0;j<n;j++){
        if(landType[i][j]==planetType){
          c1++;
        }
      }
    }
    return c1;
  }
}
