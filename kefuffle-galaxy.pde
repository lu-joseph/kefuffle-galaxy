//adjustable
int n = 100;
float cellSize;
float padding = 10;
int blinksPerSecond = 10;
int earthR = 20;
int rRedPlanet = 7;
int rPinkPlanet = 10;
int rBluePlanet = 15;
int rPurplePlanet = 20;

//don't adjust
boolean overpopulationEarth = false;
boolean overpopulationRed = false;
boolean overpopulationPink = false;
boolean overpopulationBlue = false;
boolean overpopulationPurple = false;

color[][] drawnCells;//array for cells to be drawn at the end of each frame
color[][] backGround;//default cell colors if there aren't people occupying that cell
People[][] people;//two arrays for keeping track of where people currently are and where there will be people in the next generation
People[][] pplNext;
String[][] landType; //keeps track of the type of land of each cell

//an array of planet objects
ArrayList<Planet> planetList = new ArrayList<Planet>();

//some preset color names to use
color black=color(0), white=color(255), green=color(0, 255, 0), blue=color(0, 0, 255), red=color(255, 0, 0), yellow=color(255,255,0);

//called once at the start
void setup() {
  size(1000,1000);
  cellSize = (width-2*padding)/n;

  //initialize arrays
  drawnCells = new color[n][n];
  backGround = new color[n][n];
  people = new People[n][n];
  pplNext = new People[n][n];
  landType = new String[n][n];

  frameRate(blinksPerSecond);
  
  //set the background and where the people will start off
  setBackground();
  setInitPpl();
}

//called every frame
void draw() {
  background(255, 0, 0);
  for (int i=0; i<n; i++) {
    for (int j=0; j<n; j++) {
      float x = padding + i*cellSize;
      float y = padding + j*cellSize;

      fill(drawnCells[i][j]);     
      rect(x, y, cellSize, cellSize);
    }
  }
  resetCellValues();//determines next generation
}

//procedure for creating the background
void setBackground() { 
  //random center coordinates for the earth
  int xEC = round(random(earthR, n-earthR));
  int yEC = round(random(earthR, n-earthR));
  
  //set the planet objects; their x-y coordinates, radii, names, and land types are all stored
  Planet redPlanet = new Planet(round(random(rRedPlanet,n-rRedPlanet)),round(random(rRedPlanet,n-rRedPlanet)),rRedPlanet,"redPlanet","red");
  Planet pinkPlanet = new Planet(round(random(rPinkPlanet,n-rPinkPlanet)),round(random(rPinkPlanet,n-rPinkPlanet)),rPinkPlanet,"pinkPlanet","pink");
  Planet bluePlanet = new Planet(round(random(rBluePlanet,n-rBluePlanet)),round(random(rBluePlanet,n-rBluePlanet)),rBluePlanet,"bluePlanet","blue");
  Planet purplePlanet = new Planet(round(random(rPurplePlanet,n-rPurplePlanet)),round(random(rPurplePlanet,n-rPurplePlanet)),rPurplePlanet,"purplePlanet","purple");
  
  //add each object to the list of planets
  planetList.add(redPlanet);
  planetList.add(pinkPlanet);
  planetList.add(bluePlanet);
  planetList.add(purplePlanet);
  
  //make sure none of the other planets overlap with earth
  for(int i=0;i<planetList.size();i++){
    planetList.get(i).separateFromPlanet(xEC,yEC);
  }

  //sets a few initial spots of water on earth
  int waterSpots = 6;
  int[][] waterOnEarth = new int[waterSpots][2]; //this is an array of x,y coordinates (in terms of indices of drawnCells)
  
  //adds these water spots at a random location to the array
  for (int i=0; i<waterSpots; i++) {
    waterOnEarth[i][0] = round(random(xEC-earthR, xEC+earthR));//index [][0] is x coordinate
    waterOnEarth[i][1] = round(random(yEC-earthR, yEC+earthR));//index [][1] is y coordinate
    float d = sqrt(pow(xEC-waterOnEarth[i][0],2)+pow(yEC-waterOnEarth[i][1],2)); //gets the distance between the water spot and the center of the earth
    
    //makes sure the water spots always land on the earth and not in the "corners" that get cut off
    if(d>earthR){
      if(waterOnEarth[i][0]>xEC)
        waterOnEarth[i][0] -= earthR;//if the water spot is in a right corner, the x coordinate gets shifted to the left by the earth's radius
      
      else
        waterOnEarth[i][0] += earthR;//vice versa for the left corner
        
      if(waterOnEarth[i][1]>yEC)//similar method for the y coordinates
        waterOnEarth[i][1] -= earthR;
        
      else
        waterOnEarth[i][1] += earthR;
    }
    
    //draws the blue onto the background and sets the land type of that index to be water
    backGround[waterOnEarth[i][0]][waterOnEarth[i][1]] = blue;
    landType[waterOnEarth[i][0]][waterOnEarth[i][1]] = "water";
  }

  for (int i=0; i<n; i++) {
    for (int j=0; j<n; j++) {
      //for each cell, the distance between it and each other planet is calculated.
      float dEarth = sqrt(pow(xEC-i,2)+pow(yEC-j,2));
      float dred = sqrt(pow(redPlanet.xC-i,2)+pow(redPlanet.yC-j,2));
      float dpink = sqrt(pow(pinkPlanet.xC-i,2)+pow(pinkPlanet.yC-j,2));
      float dblue = sqrt(pow(bluePlanet.xC-i,2)+pow(bluePlanet.yC-j,2));
      float dpurple = sqrt(pow(purplePlanet.xC-i,2)+pow(purplePlanet.yC-j,2));
    
      //if the cell is within the radius of any planet, it will be drawn a part of that planet
      if (dEarth<earthR){
        int numBlueNeighbours = waterNeighbours(i,j,1);//each cell will count to see if any nearby are already drawn blue
        int blueProb = min(100, numBlueNeighbours*30);//a probability that this current cell will be blue is decided
        
        if (backGround[i][j]!=blue){//if this cell is not already drawn blue, then it either becomes blue or green, based on the decided probability
          if(probFunction(blueProb)){
            backGround[i][j] = blue;
            landType[i][j] = "water";//the land types are set accordingly
          
          } else{
            backGround[i][j] = green;
            landType[i][j] = "earth";
          }
        }
      } else if(dred<rRedPlanet){//the red planet's colors are decided and the land type of those indices are set
        if(probFunction(70))
          backGround[i][j] = color(random(170,230),random(70,80),random(0,20));
          
        else
          backGround[i][j] = color(random(120,140),random(50,70),0);
        
        landType[i][j] = "red"; 
        
      } else if(dpink<rPinkPlanet){//the other planets are set similarly
        backGround[i][j] = color(random(230,250),random(180,200),random(180,200));
        landType[i][j] = "pink";
        
      } else if(dblue<rBluePlanet){
        backGround[i][j] = color(random(50,70),random(220,240),random(190,210));
        landType[i][j] = "blue";
        
      } else if(dpurple<rPurplePlanet){
        backGround[i][j] = color(random(140,160),0,random(140,160));
        landType[i][j] = "purple";
        
      } else{//if the current cell is not within any of the radii of the planets, it is colored black and the land type is set to space
        backGround[i][j] = black;
        landType[i][j] = "space";
      }
      drawnCells[i][j] = backGround[i][j];//after setting the background, this is overlapped onto the currCells array to be drawn
    }
  }
}

//function counts the number of neighbours around it that have land type water
int waterNeighbours(int i,int j,int w) {
  int c = 0;
  for (int d1=-1*w; d1<=w; d1++) {
    for (int d2=-1*w; d2<=w; d2++) {
      try {
        if (landType[i+d1][j+d2]=="water" && (!(d1==0&&d2==0)))
          c++;
      } catch(Exception e) {}
    }
  }
  return c;
}

//procedure to set where the people start off
void setInitPpl() {
  for (int i=0; i<n; i++) {
    for (int j=0; j<n; j++) {
      people[i][j] = new People("",black,"");//all cells in the people array start off black. In this array, all non-people cells are black, the rest are white or have some red hue
      pplNext[i][j] = new People("",black,"");

      if (landType[i][j]=="earth") {//only gets run if the current cell has a land type of earth
        if (probFunction(20)){ //for each cell that has land, there is a 20% chance a human will start there
          setPerson(i,j,color(round(random(150, 160)), 0, 0),"earthling","earth");//gives that person its starting values (a red hue, its type, and its home)
        }
      }
    }
  }
  mergeArrays();//merges the people array and the background array into the currCells array
}

//a is % chance the function returns true
boolean probFunction(int a){
  if(random(100)>a){
    return false;
  } else
    return true;
}

//this sets the specific cell in the next frame to be the given values
void setPerson(int i,int j,color personColor,String type,String home){
  pplNext[i][j].personColor = personColor;
  pplNext[i][j].type = type;
  pplNext[i][j].home = home;
}

//this updates the arrays; the pplNext array becomes the people array and the people are put into the drawnCells array
void mergeArrays() {
  for (int i=0; i<n; i++) {
    for (int j=0; j<n; j++) { 
      people[i][j].personColor = pplNext[i][j].personColor;
      people[i][j].type = pplNext[i][j].type;
      people[i][j].home = pplNext[i][j].home;
      
      if (people[i][j].personColor!=black)
        drawnCells[i][j] = people[i][j].personColor;//every cell in the people array that isn't black is put into the currCells array
        
      else
        drawnCells[i][j] = backGround[i][j];//the cells without people there will show the background
    }
  }
}

//this changes all the cells to the next generation
void resetCellValues() {
  overpopulation("earth","earth"); //determine overpopulation for each planet
  for(int x=0;x<planetList.size();x++){
    overpopulation(planetList.get(x).name,planetList.get(x).planetType);
  }

  for (int i=0; i<n; i++) {
    for (int j=0; j<n; j++) {
      int closeEarthNeighbours = pplNeighbours(i,j,1,"earthling");//the cell's close neighbours are counted (those directly touching, including diagonal)
      int farEarthNeighbours = pplNeighbours(i,j,3,"earthling");//cell's farther neighbours are also counted (those within a radius of 3 cells)
      int closeSpaceNeighbours = pplNeighbours(i,j,1,"colonist");//also counted for colonists, but separately
      
      if (people[i][j].personColor!=black) {//these are conditions for cells with people in them
        if(people[i][j].type=="earthling" && closeEarthNeighbours>4 && red(people[i][j].personColor)>250 && probFunction(2)){
          //these conditions intiate an astronaut
          setPerson(i,j,white,"astronaut",people[i][j].home);
        
        }else if(people[i][j].type=="earthling" && pplNext[i][j].type!="astronaut"){
          //other people who don't become astronauts go through a chance of death, a potential alteration of their red hue, and potential random movement
          calculateEarthDeath(i,j,closeEarthNeighbours,farEarthNeighbours);
          redHue(i,j,closeEarthNeighbours);
          randomMovement(i,j,20);

        }else if(people[i][j].type=="astronaut"){
          //if the current person is in space, their movement is decided differently
          spaceFlight(i,j);
          
        }else if(people[i][j].type=="colonist" && closeSpaceNeighbours>4 && probFunction(2)){
          //these conditions let a colonist on a planet other than earth become an astronaut and target another planet other than its own
          setPerson(i,j,white,"nextGenAstronaut",people[i][j].home);
          
        }else if(people[i][j].type=="nextGenAstronaut"){
          //this next gen astronaut's flight is decided differently from a "first-gen" astronaut
          nextGenSpaceFlight(i,j);
        
        }else if(people[i][j].type=="colonist" && pplNext[i][j].type!="astronaut" && pplNext[i][j].type!="nextGenAstronaut"){
          //colonists death rates and movement are decided differently from "earthling"s
          calculateSpaceDeath(i,j,closeSpaceNeighbours,landType[i][j]);
          randomMovement(i,j,60);
        }
        
        //if a cell isn't occupied by a person and it has 3 neighbours, it has a chance of becoming a person
      }else if (people[i][j].personColor==black && pplNext[i][j].personColor==black && landType[i][j]!="space" 
                && landType[i][j]!="water" && (closeEarthNeighbours>2||closeSpaceNeighbours>1) && probFunction(30)) {
        if(landType[i][j]=="earth"){          
          setPerson(i,j,color(round(random(150, 160)), 0, 0),"earthling","earth");//this is for on earth
          
        }else{
          if(probFunction(50))
            setPerson(i,j,white,"colonist",landType[i][j]+"Planet");//this is for on other planets
        }    
      } 
    }
  }
  mergeArrays();//merge the arrays before drawing them
}

//determine overpopulation for each planet
void overpopulation(String personHome,String landTypeInput){
  //intialize two counters
  int c1 = 0;
  int c2 = 0;
  
  for (int a=0; a<n; a++) {
    for (int b=0; b<n; b++) {
      if(people[a][b].home.equals(personHome) && landType[a][b].equals(landTypeInput))//if there is a person in the cell who's home is land type of that cell, they get counted
        c1++;
        
      if(landType[a][b].equals(landTypeInput))//all the cells with that specific land type get counted
        c2++;
    } 
  }
  
  //overpopulation considered per planet, same format for each planet
  if(landTypeInput.equals("earth")){
    if(overpopulationEarth && c1<c2*0.30){//if overpopulation is already happening and the population now only takes up 
      overpopulationEarth = false;
    }
    if(c1>c2*0.73){//when the population of earth takes up more than 75% of the land, it will set off overpopualation
      overpopulationEarth = true;
    }
  }else if(landTypeInput.equals("red")){//the other planets follow a similar format, just with different population-land %s
    if(overpopulationRed && c1<c2*0.30){
      overpopulationRed = false;
    }
    if(c1>c2*0.65){
      overpopulationRed = true;
    }
  }else if(landTypeInput.equals("pink")){
    if(overpopulationPink && c1<c2*0.30){
      overpopulationPink = false;
    }
    if(c1>c2*0.65){
      overpopulationPink = true;
    }
  }else if(landTypeInput.equals("blue")){
    if(overpopulationBlue && c1<c2*0.30){
      overpopulationBlue = false;
    }
    if(c1>c2*0.65){
      overpopulationBlue = true;
    }
  }else if(landTypeInput.equals("purple")){
    if(overpopulationPurple && c1<c2*0.30){
      overpopulationPurple = false;
    }
    if(c1>c2*0.65){
      overpopulationPurple = true;
    }
  }
}

void calculateEarthDeath(int i,int j,int close,int far){
  int chanceOfDying;
  
  //different conditions lead to different chances of the person in the cell dying
  if(overpopulationEarth)
    chanceOfDying = 80;
  
  else{
    if(far==0)
      chanceOfDying = 50;
      
    else if(close>5)
      chanceOfDying = max(close-3,0);
      
    else
      chanceOfDying = max(100-far*50,0);
  }
  
  if(probFunction(chanceOfDying))
    deletePerson(i,j);
    
  else
    setPerson(i,j,people[i][j].personColor,people[i][j].type,people[i][j].home);//if the person isn't deleted, the next frame will include the same person as the current frame
}

void deletePerson(int i,int j){
  setPerson(i,j,black,"","");
}

//this procedure changes the redness of people on earth
void redHue(int i,int j,int neighbours){
  if(pplNext[i][j].personColor!=black && pplNext[i][j].personColor!=white){
    float currRed = red(people[i][j].personColor);
    
    if (currRed<255&&people[i][j].personColor!=black) {//if the person is not yet at the maximum red coloring, the redness will increase by the number of neighbours it has
      currRed += neighbours;
      pplNext[i][j].personColor = color(currRed, 0, 0);
    }
  }
}

void randomMovement(int i,int j,int chance) {
  //arraylist can be appended to
  ArrayList<int[]> choices = new ArrayList<int[]>();
  
  for (int d1=-1; d1<=1; d1++) {
    for (int d2=-1; d2<=1; d2++) {
      try {
        //available cells to move into will have the d1 and d2 values added into the arraylist
        if (landType[i+d1][j+d2]!="water" && landType[i+d1][j+d2]!="space" && people[i+d1][j+d2].personColor==black && (!(d1==0&&d2==0))) {
          int [] position = {d1,d2};
          choices.add(position);
        }
      } 
      catch(Exception e) {
      }
    }
  }

  //chooses a random index out of the available directions
  int randNum = round(random(choices.size()-1));
  
  //reassigns the neighbour cell and turns the current cell to black
  if (choices.size()>0 && probFunction(chance) && pplNext[i][j].personColor != black) {
    int xDiff = choices.get(randNum)[0];
    int yDiff = choices.get(randNum)[1];
    
    if(pplNext[i+xDiff][j+yDiff].personColor!=white){      
      setPerson(i+xDiff,j+yDiff,people[i][j].personColor,people[i][j].type,people[i][j].home);
      deletePerson(i,j);
    }
  }
}

void spaceFlight(int i,int j){
  //an array of xy coordinates for planet targets is initialized
  int[][] targets = new int[planetList.size()][2];
  
  //inital minimum and index are set; a for loop will use these to determine the closest target
  float min = n;
  int minIndex = 0;
  int minR = 0;//this variable will be used to determine when the astronaut has reached the target planet
  
  for(int a=0;a<planetList.size();a++){
    //the distance between the current cell and the target in the array is calculated
    float dist = planetList.get(a).getDistanceFromPoint(i,j);
    
    //the x and y coordinates of each target are added to the array
    targets[a][0] = planetList.get(a).xC;
    targets[a][1] = planetList.get(a).yC;
    
    //if the distance for the current target is lower than the previous lowest, then the minimum values will get replaced with the current targets
    if(dist<min){
      minIndex = a;//this is the index for the closest index. It'll be used to choose the target
      min = dist;
      minR = planetList.get(a).r;//this is where the radius of the target planet is taken
    } 
  }

  //the x and y distances between the target and the current cell are determined
  int xDist = targets[minIndex][0]-i;
  int yDist = targets[minIndex][1]-j;
  
  //movement in the x and y directions is determined
  int xDir;
  int yDir;
  
  if(xDist!=0)
    xDir = xDist/abs(xDist);//ensures the movement is always either 1 or -1, depending on if xDist is positive or negative
    
  else
    xDir = 0;

  if(yDist!=0)
    yDir = yDist/abs(yDist);
  else
    yDir = 0;
    
  float dirDist = sqrt(pow(xDist,2)+pow(yDist,2));
  
  //as long as the astronaut is not yet at the planet, it will move according to the xy directions
  if(dirDist>minR-1){
    try{
        setPerson(i+xDir,j+yDir,white,"astronaut",people[i][j].home);
    }catch(Exception e){}

    deletePerson(i,j);
  }else{
    setPerson(i,j,white,"colonist",landType[i][j]+"Planet");
  }
}

void nextGenSpaceFlight(int i,int j){
  //an array of xy coordinates for planet targets is initialized
  ArrayList<int[]> targets2 = new ArrayList<int[]>();
  
  //inital minimum and index are set; a for loop will use these to determine the closest target
  float min = n;
  int minIndex = 0;
  int minR = 0;//this variable will be used to determine when the astronaut has reached the target planet
  
  int c = 0;//this counter is used because the variable a in the for loop can't be used because one planet is taken out of consideration
  for(int a=0;a<planetList.size();a++){
    if(!(people[i][j].home.equals(planetList.get(a).name))){//this makes sure the next-gen astronaut does not consider its home planet as a target
      float dist = planetList.get(a).getDistanceFromPoint(i,j);//rest of procedure is the same as regular spaceFlight, with the alteration of the counter c 
           
      int[] coordinate = {planetList.get(a).xC,planetList.get(a).yC};
      targets2.add(coordinate);      
      
      if(dist<min){
        minIndex = c;
        min = dist;
        minR = planetList.get(c).r;
      } 
      c++;
    }
  }

  int xDist = targets2.get(minIndex)[0]-i;
  int yDist = targets2.get(minIndex)[1]-j;

  int xDir;
  int yDir;
  
  if(xDist!=0)
    xDir = xDist/abs(xDist);
    
  else
    xDir = 0;

  if(yDist!=0)
    yDir = yDist/abs(yDist);
  else
    yDir = 0;
    
  float dirDist = sqrt(pow(xDist,2)+pow(yDist,2));

  if(dirDist>minR-1){
    try{
        setPerson(i+xDir,j+yDir,white,"nextGenAstronaut",people[i][j].home);
    }catch(Exception e){}

    deletePerson(i,j);
    
  }else{
    setPerson(i,j,white,"colonist",landType[i][j]+"Planet");
  }
}

//chances of dying in space are decided differently than on earth, but the structure is generally the same
void calculateSpaceDeath(int i,int j,int close,String planet){
  int chanceOfDying;
  
  if((planet.equals("red")&&overpopulationRed)||(planet.equals("pink")&&overpopulationPink)||(planet.equals("blue")&&overpopulationBlue)||(planet.equals("purple")&&overpopulationPurple)){
    chanceOfDying = 80;
  }else if(close>7)
    chanceOfDying = min(close*10,100);
  else
    chanceOfDying = 1;
  
  if(probFunction(chanceOfDying)){
    deletePerson(i,j);
  }else{
    setPerson(i,j,people[i][j].personColor,people[i][j].type,people[i][j].home);
  }
}

//simple function to count neighbours of a cell, with the ability to set how large the radius for consideration is and the type of person to check for
int pplNeighbours(int i,int j,int w,String type){
  int c = 0;  
  for (int d1=-1*w; d1<=w; d1++) {
    for (int d2=-1*w; d2<=w; d2++) {
      try { 
        if (people[i+d1][j+d2].personColor!=black && people[i+d1][j+d2].type==type && (!(d1==0&&d2==0)))
          c++;
      }
      catch(Exception e) {
      }
    }
  }
  return c;
}
