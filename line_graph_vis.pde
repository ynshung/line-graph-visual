
int dimX = 1280;
int dimY = 720;

void settings() {
  size(dimX, dimY);
}

String inputData = "covid-19-malaysia.csv";
//String inputData = "apims-final.csv";
Graph g;
int steps = 60;
int transition = 30;
PVector centre = new PVector(dimX*.05, dimY*.92);
PVector maxG = new PVector(dimX*.85, dimY*.1);

void setup() {
  frameRate(60);
  println("Loading table...");
  Table csv = loadTable(inputData, "header");
  println("Table loaded");
  
  g = new Graph(centre,maxG,transition,csv);
}

void draw() {
  String c = "000000";
  background(unhex(c));
  
  if (frameCount % steps == 0 && !g.finished) {
    g.nextStep();
  }
  if (!g.finished) g.update();
  
  pushStyle();
  textSize(16);
  text(frameCount, dimX*.95, dimY*.1);
  text(frameRate, dimX*.95, dimY*.8);
  popStyle();
  
  //saveFrame("frames/frame-####.png");
  
  if (g.finished) {
    println(frameCount);
    exit();
  } else if (frameCount % 60 == 0) {
    println(frameCount/60 + "/88 seconds procesed");
  }
}
