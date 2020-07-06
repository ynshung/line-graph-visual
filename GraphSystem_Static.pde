class Graph { //<>//

  PVector centre;
  int vWidth, vHeight;

  int xScale;
  int yScale, p_yScale;
  float speedFac;

  int vLine;

  float offset = 0;

  int currX, currX_scale, currX_max, real_currX, p_currX;
  int currY, currY_scale, currY_max; //dep
  float lines_f, lines_curr;

  String[] lineTexts;
  Table data;
  String xUnits[];
  ArrayList<float[]> dataVal = new ArrayList<float[]>();

  float scalePixels_x, scalePixels_y;
  int frameT = 0;
  int def_frameT = 30;
  int frameT_vx = 0;
  float def_frameT_vx;
  boolean isFade = false;
  //float data_min = 0;
  //float data_max = 0;
  
  int recCurrRow = 0;

  Graph (PVector ct, int xS, int vL, int os, int yS,
    float sf, Table csv) {
    centre = ct;
    xScale = xS;
    offset = os;
    vLine = vL;
    yScale = yS;
    p_yScale = yScale;
    speedFac = sf;
    currX = 0;
    real_currX = 0;

    vWidth = width - int(centre.x);
    vHeight = int(centre.y);

    scalePixels_x = vWidth / vLine;
    def_frameT_vx = round(scalePixels_x / speedFac / xScale);
    scalePixels_y = vHeight / yScale / 6;
    
    println("def_frameT_vx:", def_frameT_vx);

    data = csv;
    xUnits = data.getStringColumn("Date");
    lineTexts = data.getColumnTitles();
    for (int i=1; i<data.getColumnCount(); i++) {
      float a[] = float(data.getStringColumn(i));
      dataVal.add(a);
    }
  }

  float getData(int col, int row) {
    return dataVal.get(col)[row];
  }

  //void deprecUpdate() {
  //  float data_min = getData(0, currX_max);
  //  float data_max = 0;

  //  // check if data_min init is nan
  //  if (str(data_min) == "NaN") {
  //    for (int i=1; i<dataVal.size(); i++) {
  //      if (str(getData(i, currX_max)) != "NaN") {
  //        data_min = getData(i, currX_max);
  //        break;
  //      }
  //    }
  //  }

  //  for (int i=0; i<dataVal.size(); i++) {
  //    float cData = getData(i, currX_max);
  //    if (cData < data_min) data_min = cData;
  //    if (cData > data_max) data_max = cData;
  //  }

  //  float data_range = data_max - data_min;
  //  lines_f = round(data_range / yScale);

  //  while (lines_f > 7 || lines_f < 4) {
  //    if (lines_f > 7) yScale = scaleUnitsSteps(yScale, true);
  //    else if (lines_f < 4) yScale = scaleUnitsSteps(yScale, false);
  //    lines_f = round(data_range / yScale);
  //  }

  //  currY = round(data_min - 1);
  //  currY_scale = floor(currY / yScale) * yScale;
  //  currY_max = ceil(currY + lines_curr * yScale);
  //}

  boolean checkFade(int i, int scale, int p_scale, boolean isFade) {
    stroke(255, 64);
    fill(255, 164);
    if (i % scale == 0) {
      // fade in
      if (i % p_scale != 0 && isFade) {
        stroke(255, map(frameT, 0, def_frameT, 0, 64));
        fill(255, map(frameT, 0, def_frameT, 0, 128));
      }
    } else if (i % scale != 0) {
      // fade out
      if (i % p_scale == 0 && isFade) {
        stroke(255, map(frameT, 0, def_frameT, 64, 0));
        fill(255, map(frameT, 0, def_frameT, 128, 0));
      } else {
        return false;
      }
    }
    return true;
  }

  void yUpdate() {
    // count number of lines in screen

    int currLine = ceil(vHeight/scalePixels_y/yScale);

    p_yScale = yScale;
    if (currLine > 6) yScale = scaleUnitsSteps(yScale, true);
    else if (currLine < 3) yScale = scaleUnitsSteps(yScale, false);

    if (p_yScale != yScale) isFade = true;
  }

  ///////////////////////////////////////////////

  int scaleFrtFrame = 0;
  int posFrtFrame = 0;

  // 0: none, 1: fade-in, 2: constant, 3: fade-out, 0 ...
  int scaleModifyState = 0;
  int posModifyState = 0;

  // only 1 and -1
  int scaleZoomIn = 1;
  int posMoveUp = 1; // positive move down

  float getFadeMap(int init_frame, float max, float trans_frame, boolean fade_in) {
    if (fade_in) {
      return max * sin(map(frameCount, init_frame, init_frame + trans_frame, 0, PI/2));
    } else {
      return max * sin(map(frameCount, init_frame, init_frame + trans_frame, PI/2, PI));
    }
  }

  void toggleScale(boolean zoom_in) {
    if (zoom_in) scaleZoomIn = 1;
    else scaleZoomIn = -1;

    if (scaleModifyState == 0) scaleModifyState = 1;
    else if (scaleModifyState == 1) scaleModifyState = 3;
    else if (scaleModifyState == 2) scaleModifyState = 3;
    else if (scaleModifyState == 3) scaleModifyState = 0;
    scaleFrtFrame = frameCount;
    
    if (currMode == 2) {
      TableRow nr = record.addRow();
      nr.setInt("fc",frameCount);
      if (zoom_in) nr.setInt("action",01);
      else nr.setInt("action",00);
    }
  }

  void modifyPos(boolean up) {
    if (up) posMoveUp = 1;
    else posMoveUp = -1;

    if (posModifyState == 0) posModifyState = 1;
    else if (posModifyState == 1) posModifyState = 3;
    else if (posModifyState == 2) posModifyState = 3;
    else if (posModifyState == 3) posModifyState = 0;
    posFrtFrame = frameCount;
    
    if (currMode == 2) {
      TableRow nr = record.addRow();
      nr.setInt("fc",frameCount);
      if (up) nr.setInt("action",11);
      else nr.setInt("action",10);
    }
  }

  ////////////////////////////////////////////////////

  int const_tf = 15;

  void update() {
    // Auto playback
    if (currMode == 0) {

      float data_min = getData(0, currX_max);
      float data_max = 0;

      // check if data_min init is nan
      if (str(data_min) == "NaN") {
        for (int i=1; i<dataVal.size(); i++) {
          if (str(getData(i, currX_max)) != "NaN") {
            data_min = getData(i, currX_max);
            break;
          }
        }
      }

      for (int i=0; i<dataVal.size(); i++) {
        float cData = getData(i, currX_max);
        if (cData < data_min) data_min = cData;
        if (cData > data_max) data_max = cData;
      }
      float data_range = getCoord(0, data_min).y - getCoord(0, data_max).y;

      float data_max_c = getCoord(0, data_max).y;
      float data_min_c = getCoord(0, data_min).y;

      if (data_range < 256) toggleScale(true);
      else if (data_range > 400) toggleScale(false);
      text(data_range, width*.95, height*.5);
      if (data_max_c < 100) modifyPos(true);
      else if (data_max_c > height/2) modifyPos(false);
      //if (data_min_c < height/2) modifyPos(true);
      if (data_min_c > centre.y) modifyPos(false);

      if (data_max_c < 0 && data_min_c < height/2) toggleScale(false);
    }
    
    // Playback table
    
    else if (currMode == 3 && recCurrRow < record.getRowCount()) {
      if (frameCount >= record.getInt(recCurrRow,"fc")) {
        int action = record.getInt(recCurrRow,"action");
        
        if (action == 0) toggleScale(false);
        else if (action == 1) toggleScale(true);
        else if (action == 10) modifyPos(false);
        else if (action == 11) modifyPos(true);
        
        recCurrRow++;
      }
    }

    // Scale & pos modification
    
    if (frameCount > scaleFrtFrame + const_tf) {
      if (scaleModifyState == 1) scaleModifyState = 2;
      if (scaleModifyState == 3) scaleModifyState = 0;
    }
    if (frameCount > posFrtFrame + const_tf) {
      if (posModifyState == 1) posModifyState = 2;
      if (posModifyState == 3) posModifyState = 0;
    }

    if (scaleModifyState == 1) {
      scalePixels_y += scaleZoomIn * getFadeMap(scaleFrtFrame, .5, const_tf, true) / yScale;
    } else if (scaleModifyState == 2) {
      scalePixels_y += scaleZoomIn * .5 / yScale;
    } else if (scaleModifyState == 3) {
      scalePixels_y += scaleZoomIn * getFadeMap(scaleFrtFrame, .5, const_tf, false) / yScale;
    }

    if (posModifyState == 1) {
      offset += posMoveUp * getFadeMap(posFrtFrame, 1, const_tf, true);
    } else if (posModifyState == 2) {
      offset += posMoveUp;
    } else if (posModifyState == 3) {
      offset += posMoveUp * getFadeMap(posFrtFrame, 1, const_tf, false);
    }

    //////////////////////

    if (frameCount % 30 == 0) yUpdate();

    p_currX = currX;
    currX = floor(speedFac*frameCount / scalePixels_x * xScale);
    currX_scale = floor(currX / xScale) * xScale;
    currX_max = currX + vLine * xScale - (xScale/3);
    real_currX = currX_max-2;

    if (frameT_vx < def_frameT_vx) frameT_vx++;
    if (p_currX != currX) {
      frameT_vx = 0;
    }

    pushStyle();
    textAlign(CENTER);
    strokeWeight(4);
    stroke(255, 64);
    fill(255, 164);
    textSize(16);

    /////////////////////////////////////////////

    // Vertical line
    for (int i=0; i<=currX+vLine; i++) {
      int xVal = round(getCoord(i*xScale, 0).x - centre.x);
      if (xVal >= 0 && xVal <= width+64) {
        line(xVal, centre.y, xVal, 0);
        //text(xUnits[i*xScale], xVal, centre.y+20);
      }
    }

    textAlign(CENTER, CENTER);

    // Horizontal line
    for (int i=0; i<=300; i++) {
      if (checkFade(i, yScale, p_yScale, isFade)) {
        float yVal = getCoord(0, i).y;

        line(centre.x, yVal, width, yVal);
        //text(i, centre.x-20, yVal);
      }
    }
    popStyle();

    // Lines
    float d[];

    for (int i=0; i<dataVal.size(); i++) {
      pushStyle();

      stroke(255);
      strokeWeight(3);
      strokeJoin(ROUND);
      strokeCap(ROUND);
      noFill();

      d = dataVal.get(i);

      beginShape();
      for (int j=currX; j<currX_max; j++) {
        PVector xy = getCoord(j, d[j]);
        xy.set(xy.x-centre.x, xy.y);
        if (j != 0 && str(d[j-1]) == "NaN") {
          beginShape();
        }
        if (str(d[j]) == "NaN") {
          endShape();
          continue;
        } else if (j == currX_max-1) {
          curveVertex(xy.x, xy.y);
          endShape();

          // Last vertex
          PVector xy0 = getCoord(j-2, d[j-2]);
          PVector xy1 = getCoord(j-1, d[j-1]);
          PVector xy3 = getCoord(j+1, d[j+1]);

          xy0.set(xy0.x-centre.x, xy0.y);
          xy1.set(xy1.x-centre.x, xy1.y);
          xy3.set(xy3.x-centre.x, xy3.y);

          float t = map(frameT_vx, 0, def_frameT_vx, 0, 1);

          beginShape();
          PVector trans_coord = xy1;
          for (float k=0; k<t; k+=0.1) {
            trans_coord = catmull_rom(xy0, xy1, xy, xy3, k);
            vertex(trans_coord.x, trans_coord.y);
          }
          endShape();
          
          pushStyle();
          fill(255);
          circle(1074, trans_coord.y, 10);
          popStyle();

          /////////////////
          // Text

          pushStyle();

          textAlign(LEFT, CENTER);
          fill(255, 200);
          textSize(16);

          //String txt = lineTexts[i+1];
          String txt = lineTexts[i+1] + ": " + int(d[real_currX]);
          float txtW = textWidth(txt);

          text(txt, 1100, trans_coord.y);
          //println(trans_coord.x);

          noStroke();
          fill(255, 100);
          rect(1090, trans_coord.y-12, txtW+20, 30, 8);

          popStyle();
        } else {
          curveVertex(xy.x, xy.y);
        }
      }
      popStyle();
    }

    if (frameT != def_frameT && isFade) frameT++;
    else {
      frameT = 0;
      isFade = false;
    }

    // Left, bottom border
    pushStyle();
    noStroke();
    fill(0,255);
    rectMode(CORNERS);
    rect(0, 0, centre.x, height);

    fill(255, 164);
    textSize(16);
    textAlign(CENTER, CENTER);

    // Horizontal line text
    for (int i=0; i<=300; i++) {
      if (checkFade(i, yScale, p_yScale, isFade)) {
        float yVal = getCoord(0, i).y;
        text(i, centre.x-20, yVal);
      }
    }
    
    fill(0,255);
    noStroke();
    rect(0, centre.y, width, height);
    textAlign(CENTER);
    fill(255, 164);

    // Vertical line text
    for (int i=0; i<=currX+vLine; i++) {
      int xVal = round(getCoord(i*xScale, 0).x - centre.x);
      if (xVal >= -64 && xVal <= width+64) {
        text(xUnits[i*xScale], xVal, centre.y+20);
      }
    }

    popStyle();
  }

  int scaleUnitsSteps(int c, boolean pve) {
    int zeros = 0;
    float nz = c; // no zeros
    while (nz % 10 == 0) {
      nz /= 10;
      zeros++;
    }
    if (pve) {
      if (nz == 1) nz++;
      else if (nz == 2) nz = 5;
      else nz = 10;
    } else {
      if (nz == 1 || nz == 2) nz /= 2;
      else if (nz == 5) nz = 2;
      else nz = 5;
    }
    return round(nz * pow(10, zeros));
  }

  PVector getCoord(float x, float y) {
    float xv, yv;

    xv = centre.x + ((x - currX_scale)/xScale * scalePixels_x) - (speedFac*frameCount % scalePixels_x);
    yv = centre.y + offset - (y * scalePixels_y);
    return new PVector(xv, yv);
  }

  PVector catmull_rom(PVector p0, PVector p1, 
    PVector p2, PVector p3, float t) {
    float x = 0.5 * ( (2 * p1.x) + (-p0.x + p2.x) * t +
      (2*p0.x - 5*p1.x + 4*p2.x - p3.x) * t * t +
      (-p0.x + 3*p1.x - 3*p2.x + p3.x) * t * t * t);
    float y = 0.5 * ( (2 * p1.y) + (-p0.y + p2.y) * t +
      (2*p0.y - 5*p1.y + 4*p2.y - p3.y) * t * t +
      (-p0.y + 3*p1.y - 3*p2.y + p3.y) * t * t * t);
    return new PVector(x, y);
  }
}
