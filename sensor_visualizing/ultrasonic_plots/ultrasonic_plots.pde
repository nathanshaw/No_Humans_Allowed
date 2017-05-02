import netP5.*;
import oscP5.*;

// Sketch for visualizing Theia inputs

OscP5 osc;

// make a bar for each sensor on each bot
int numSensors = 4;
int numBots = 3;
int windowWidth;
int windowHeight;
int sensorMaxValue = 255;
int memorySize = 64;
int memoryLengthInSeconds = 2;
int windowHHop;
int totalHHop;
int totalVHop;
int windowVHop;
String botNames[] = {"/theia1", "/theia2", "/theia3"};
//int mostRescentReading = [];
int mostRescentReading[] = new int[numBots*numSensors];

// store past states to create a graph
//int pastStates[] = {0};

Slider[] sliders;

// osc messages
//OscMessage pollTheia1 = new OscMessage("/theia1/0/0");
NetAddress destAddress;

void setup() {
  size(1200, 300);
  osc = new OscP5(this, 50002);
  destAddress = new NetAddress("127.0.0.1", 50000);
  windowHHop = int((width / 15) - numSensors);
  windowVHop = int((height / 15) - numBots);

  totalHHop = (windowHHop * numSensors) + windowHHop;
  totalVHop = (windowVHop * numBots) + windowVHop;

  windowWidth = int((width - totalHHop)/numSensors);
  windowHeight = int((height - totalVHop)/numBots);

  frameRate(memorySize/memoryLengthInSeconds);
  // expand pastStates to proper size
  sliders = new Slider[numSensors*numBots];
  for (int b = 0; b < numBots; b++) {
    for (int i = 0; i < numSensors; i++) {
      int tempX = int((windowHHop*i) + i * windowWidth) + windowHHop;
      int tempY = int(windowVHop*(b+1) + (windowHeight * b));
      int _index = (b * numSensors) + i;
      sliders[_index] = new Slider(tempX, tempY, 
        windowHeight, sensorMaxValue, 
        i, windowHHop, 
        b);
    }
  }
}

// object for a slider
class Slider {
  int x, y;
  int w, h;
  int value;
  int maxValue;
  int sliderHeight;
  int sensorNum;
  int boarder;
  int botNum;
  int myIndex;
  int[] pastStates = new int[memorySize];

  Slider(int initX, int initY, int tempSliderHeight, int initMaxValue, int initSensorNum, int initBoarder, int initBotNum) {
    sensorNum = initSensorNum;
    x = initX;
    y = initY;
    botNum = initBotNum;
    sensorNum = initSensorNum;
    value = 0;
    maxValue = initMaxValue;
    sliderHeight = tempSliderHeight;
    boarder = initBoarder;
    myIndex = (botNum * numSensors) + sensorNum;
  }

  void update() {
    //value = int((mostRescentReading[myIndex]/maxValue) * sliderHeight);
    for (int i = (memorySize-1); i > 0; i--) {
      pastStates[i] = pastStates[i-1];
    }
    // simple low pass filter
    pastStates[0] = int(float(mostRescentReading[myIndex] + pastStates[1]) / 2.0);
    // no filtering
    pastStates[0] = mostRescentReading[myIndex];
  }



  void display() {
    // draw the boarder
    strokeWeight(1);
    rectMode(CORNER);
    fill(255);
    rect(x, y, windowWidth, windowHeight);
    // draw a rect for each datapoint
    strokeWeight(0);
    for (int r = 0; r < memorySize; r++) {

      int tempHHop = int(windowWidth/(memorySize));
      int tempHop = int(tempHHop * r);
      float tempValue = float(pastStates[r]) / float(sensorMaxValue);
      int tempHeight = int(tempValue * windowHeight * -1);
      if (tempValue < 0.25) {
        fill(255, 0, 0);
      } else if (tempValue < 0.60) {
        fill(255, 255, 0);
      } else {
        fill(0, 255, 0);
      }
      if (r == memorySize - 1) {
        rect(x + tempHop, y + windowHeight, windowWidth - tempHop, tempHeight);
      } else {
        rect(x + tempHop, y + windowHeight, tempHHop, tempHeight);
      }
    }
    // display Text to name the bot
    if ((sensorNum % numSensors) == 0) {
      pushMatrix();
      translate(x - boarder - boarder, y);
      rotate(HALF_PI);
      textSize(36 - (3 * numBots));
      //fill(0, 0, 0);
      text("BOT " + str((sensorNum/numSensors) + 1), 0, 0);
      popMatrix();
    }
    // text for bot num and sensor num
    textSize(16);
    String s = "B" + str((sensorNum / numSensors) + 1) + "S" + str(sensorNum % numSensors);
    //fill(0, 0, 0);
    text(s, x, y - 10);
    // set up vertical text for the bot
  }
}

void draw() {
  // make background grey
  for (int b = 0; b < numBots; b++) {
    for (int i = 0; i < numSensors; i++) {
      int index = (b*4) + i;
      sliders[index].update();
      sliders[index].display();
    }
  }
}

void oscEvent(OscMessage theOscMessage) {
  String address = theOscMessage.addrPattern();
  int ultraNum = theOscMessage.get(0).intValue();
  int reading = theOscMessage.get(1).intValue();
  int offset = 0;
  if (address.equals("/theia1")) {
    // TODO, need to add in support for nultiple bots...
    offset = 0;
  } else if (address.equals("/theia2")) {
    offset = numSensors - 1;
  } else if (address.equals("/theia3")) {
    offset = numSensors * 2 - 1;
  }
  mostRescentReading[offset + ultraNum] = reading;
}
