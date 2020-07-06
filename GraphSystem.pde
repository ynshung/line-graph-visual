class Graph {
  PVector origin;
  PVector maxLineC;
  boolean finished = false;

  float gWidth, gHeight;

  int currX = 0;
  int currY = 0; // values for x,y

  int currhLine = 1;
  int currvLine = 1;

  int p_scaleX = 1;
  int p_scaleY = 1;
  int scaleX = 1;
  int scaleY = 1;
  boolean isFadeX = false;
  boolean isFadeY = false;

  PVector scalePixels;
  PVector p_scalePixels; //previous
  PVector t_scalePixels = new PVector(0, 0); //transition

  int frameT = 0;
  int def_frameT = 30;
  int frameT_e = 0;

  int txtOffset = 24;
  String lineTexts[];

  color lineCol = #ffffff;
  //color lineCol = #17202A;
  color linesCol[] = {
    #EC7063, #3498DB, #2ECC71, #F4D03F
  };
  color currCol = #ffffff;

  Table data;
  String xUnits[];
  ArrayList<float[]> dataVal = new ArrayList<float[]>();

  Graph (PVector xy, PVector max, int fT, Table t) {
    origin = xy;
    maxLineC = max;
    gHeight = origin.y - maxLineC.y;
    gWidth = maxLineC.x - origin.x;
    scalePixels = new PVector(gWidth, gHeight);
    p_scalePixels = scalePixels;
    def_frameT = fT;
    isFadeX = true;
    isFadeY = true;

    data = t;
    xUnits = data.getStringColumn("Date");
    for (int i=1; i<data.getColumnCount(); i++) {
      float a[] = float(data.getStringColumn(i));
      dataVal.add(a);
    }
    lineTexts = data.getColumnTitles();
  }

  float getData(int fIndex, int sIndex) {
    return dataVal.get(fIndex)[sIndex];
  }

  boolean checkFade(int i, int scale, int p_scale, boolean isFade) {
    stroke(lineCol, 64);
    fill(lineCol, 128);
    if (i % scale == 0) {
      // fade in
      if (i % p_scale != 0 && isFade) {
        stroke(lineCol, map(frameT, 0, def_frameT, 0, 64));
        fill(lineCol, map(frameT, 0, def_frameT, 0, 128));
      }
    } else if (i % scale != 0) {
      // fade out
      if (i % p_scale == 0 && isFade) {
        stroke(lineCol, map(frameT, 0, def_frameT, 64, 0));
        fill(lineCol, map(frameT, 0, def_frameT, 128, 0));
      } else {
        return false;
      }
    }
    return true;
  }

  PVector lastVertexAnim(int currX, float d[]) {
    PVector xy = getCoord(map(frameT, 0, def_frameT, currX-1, currX), 
      map(frameT, 0, def_frameT, d[currX-1], d[currX]));

    if (xy.x > maxLineC.x) xy.set(maxLineC.x, xy.y);
    if (xy.y < maxLineC.y) xy.set(xy.x, maxLineC.y);
    return xy;
  }

  void update() {
    pushStyle();
    strokeWeight(4);

    textSize(20);
    textAlign(LEFT, CENTER);

    /////////////////////////////////////////////
    // Horizontal line
    for (int i=0; i<=currY*1.2; i++) {
      if (checkFade(i, scaleY, p_scaleY, isFadeY)) {
        float yVal = getCoord(0, i).y;

        String txt = unitsStr(i);
        line(origin.x-18, yVal, maxLineC.x, yVal);
        text(unitsStr(i), origin.x-textWidth(txt)-24, yVal-2);
      }
    }

    textAlign(CENTER, CENTER);

    // Vertical line
    for (int i=0; i<=currX; i++) {
      if (checkFade(i, scaleX, p_scaleX, isFadeX)) {
        float xVal = getCoord(i, 0).x;

        if (xVal <= maxLineC.x) {
          line(xVal, origin.y, xVal, 0);
          textSize(16);
          text(xUnits[i], xVal, origin.y + 20);
        }
      }
    }

    /////////////////////////////////////////////
    // Lines

    float d[] = dataVal.get(0);

    for (int i=0; i<dataVal.size(); i++) {
      pushStyle();
      noFill();
      strokeWeight(4);

      if (i >= linesCol.length) {
        currCol = #ffffff;
      } else {
        currCol = linesCol[i];
      }

      d = dataVal.get(i);
      strokeJoin(ROUND);
      strokeCap(ROUND);
      stroke(currCol, 222);

      beginShape();
      for (int j=0; j<=currX; j++) {
        PVector xy = getCoord(j, d[j]);
        if (currX == 0) {
          vertex(centre.x, centre.y);
        } else if (j == currX) {
          // Last vertex
          //PVector p_xy = getCoord(j-1, d[j-1]);
          xy = lastVertexAnim(currX, d);
          vertex(xy.x, xy.y);
        } else {
          vertex(xy.x, xy.y);
        }
      }
      endShape();
      popStyle();
    }

    if (currX > 0) {
      for (int i=0; i<dataVal.size(); i++) {

        d = dataVal.get(i);
        if (i >= linesCol.length) {
          currCol = #ffffff;
        } else {
          currCol = linesCol[i];
        }

        PVector xy = lastVertexAnim(currX, d);

        /////////////////
        // Text

        pushStyle();

        textAlign(LEFT, CENTER);
        fill(currCol, 200);
        textSize(16);

        String txt = lineTexts[i+1] + ": " + int(d[currX]);
        float txtW = textWidth(txt);

        text(txt, maxLineC.x+txtOffset, xy.y-3);

        noStroke();
        fill(currCol, 100);
        rect(maxLineC.x+txtOffset*.7, xy.y-15, 
          txtW+15, 30, 8, 8, 8, 8);

        popStyle();
        
        /////////////////
        // Circle effect

        pushStyle();
        stroke(currCol, 255);
        strokeWeight(12);

        point(xy.x, xy.y);

        strokeWeight(2);
        noFill();

        int e_trans = 100;
        int e_trans_fadeout = e_trans + 50;
        if (frameT == def_frameT-1) {
          frameT_e = 0;
        }
        if (frameT_e >= 0) {
          frameT_e++;
          if (frameT_e >= e_trans) {
            stroke(currCol, map(frameT_e, e_trans, 
              e_trans_fadeout, 255, 0));
          }
          circle(xy.x, xy.y, map(frameT_e, 0, e_trans, 10, 20));
        }
        popStyle();
      }
    }
      
    // Text

    pushStyle();
    
    fill(lineCol, 255);
    textSize(24);
    textAlign(LEFT,CENTER);
    
    text("COVID-19 cases in (country)", centre.x+20, 64);
    textSize(35);
    text(xUnits[currX], centre.x+20, 100);

    popStyle();

    if (frameT != def_frameT) frameT++;
    else {
      isFadeX = false;
      isFadeY = false;
    }
  }


  TableRow tr;
  void nextStep() {
    frameT = 0;

    if (currX == data.getRowCount()-1) {
      finished = true;
      frameT = def_frameT;
    }

    int yMax = 0;
    if (!finished) {
      for (int j=currX; j<=currX+1; j++) {
        tr = data.getRow(j);
        // Get column max values
        for (int i=1; i<tr.getColumnCount(); i++) {
          int val = tr.getInt(i);
          if (yMax < val) yMax = val;
        }
        if (yMax > currY) currY = yMax;
      }
      currX++;
    }

    p_scalePixels = scalePixels;
    scalePixels = new PVector(gWidth / currX, gHeight / currY);
    t_scalePixels = new PVector((p_scalePixels.x - scalePixels.x)/def_frameT, 
      (p_scalePixels.y - scalePixels.y)/def_frameT);

    // How many lines will be visible?  Will not affect display
    currvLine = floor(currX/scaleX) + 1;
    currhLine = floor(currY/scaleY) + 1;

    while (currvLine > 6) {
      p_scaleX = scaleX;
      scaleX = scaleUnitsSteps(scaleX);
      currvLine = floor(currX/scaleX) + 1;
      isFadeX = true;
    }
    while (currhLine > 6) {
      p_scaleY = scaleY;
      scaleY = scaleUnitsSteps(scaleY);
      currhLine = floor(currY/scaleY) + 1;
      isFadeY = true;
    }
  }

  int scaleUnitsSteps(int c) {
    int zeros = 0;
    int nz = c; // no zeros
    while (nz % 10 == 0) {
      nz /= 10;
      zeros++;
    }
    if (nz == 1) nz++;
    else if (nz == 2) nz = 5;
    else nz = 10;

    return round(nz * pow(10, zeros));
  }

  String unitsStr(int num) {
    if (num < 1000) return str(num);
    else if (num < 1000000) {
      if (float(num) % 1000 == 0) {
        return str(num / 1000) + "K";
      } else {
        return str(float(num) / 1000) + "K";
      }
    } else {
      if (float(num) % 1000000 == 0) {
        return str(num / 1000000) + "M";
      } else {
        return str(float(num) / 1000000) + "M";
      }
    }
  }

  PVector getCoordFixed(float x, float y) {
    float xc, yc;
    if (x == 0) xc = origin.x;
    else xc = map(x, 0, currX, origin.x, maxLineC.x);
    if (y == 0) yc = origin.y;
    else yc = map(y, 0, currY, origin.y, maxLineC.y);
    return new PVector(xc, yc);
  }

  PVector getCoord(float x, float y) {
    float xc, yc;
    if (x == 0) xc = origin.x;
    else {
      xc = origin.x + x * (p_scalePixels.x - t_scalePixels.x*frameT);
    }
    if (y == 0) yc = origin.y;
    else {
      yc = origin.y - y * (p_scalePixels.y - t_scalePixels.y*frameT);
    }
    return new PVector(xc, yc);
  }

  int numLength(int x) {
    return ceil( log(x) / log(10) );
  }

  boolean isFinished() {
    return finished;
  }
}
