int dimX = 1280;
int dimY = 720;

void settings() {
  size(dimX, dimY, JAVA2D);
  //size(dimX, dimY, P2D);
  smooth(8);
}

//String inputData = "covid-19-malaysia.csv";
String inputData = "APIMS-final-avg-states-ss.csv";
Graph g;
PVector centre = new PVector(dimX*.05, dimY*.95);
PVector scale = new PVector(10,10);

// 0: auto playback, 1: normal playback, 2: record, 3: playback table;
int currMode = 1;
Table record;

void setup() {
  println("Loading table...");
  frameRate(60);
  Table csv = loadTable(inputData, "header");
  println("Table loaded");
  
  //           xScale, vLine, offset, yScale, speedFac
  g = new Graph(centre,7,5,128,10,2,csv);
  
  // Rec mode
  if (currMode == 2) {
    record = new Table();
    record.addColumn("fc");
    record.addColumn("action");
  }
  if (currMode == 3) {
    record = loadTable("record.csv", "header");
    println("Recording data loaded");
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) g.modifyPos(true);
    else if (keyCode == DOWN) g.modifyPos(false);
  }
  if (key == 'w') g.toggleScale(true);
  else if (key == 's') g.toggleScale(false);
}

void draw() {
  String c = "000000";
  background(unhex(c));
  
  g.update();
  
  pushStyle();
  textSize(16);
  text(frameCount, dimX*.95, dimY*.1);
  text(frameRate, dimX*.95, dimY*.8);
  popStyle();
  
  //saveFrame("frames/frame-####.png");
  if (currMode == 2 && frameCount % frameRate == 0) {
    saveTable(record, "record.csv");
  }
}
