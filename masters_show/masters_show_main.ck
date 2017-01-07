/*
bot_control.ck

This file holds classes for interfacing with the 
Divine Council Bots

TODO for composition
*/
OscOut out;
OscOut pOut;
OscIn oin;
OscMsg msg;
("localhost", 50000) => out.dest;
("localhost", 50010) => pOut.dest;
50003 => oin.port;
oin.listenAll();

// for keeping track of the states of all the bots
// if someone is really close the state is 2: agressive
// if someone is sort of close the state is 1: quiet and timid
// if someone if not detected, the state is 0: productive

// this is the state of each sensor on the first bot
[0, 0, 0, 0] @=> int bot1State[];
[0, 0, 0, 0] @=> int bot2State[];
[0, 0, 0, 0] @=> int bot3State[];

// if distance is less than midThresh, bot will enter
// into state 1. This might have to be adjusted according to
// the space
115 => int lowMidThresh;
150 => int highMidThresh;
50 => int lowCloseThresh;
75 => int highCloseThresh;
// the smoothing weights are universal
[0.5, 0.3, 0.1, 0.1, 0, 0, 0, 0] @=> float smoothingWeights[];

// each sensor gets its own array
[150, 150, 150, 150, 150, 150, 150, 150] @=> int b1pastStates1[];
[150, 150, 150, 150, 150, 150, 150, 150] @=> int b1pastStates2[];
[150, 150, 150, 150, 150, 150, 150, 150] @=> int b1pastStates3[];
[150, 150, 150, 150, 150, 150, 150, 150] @=> int b1pastStates4[];
[150, 150, 150, 150, 150, 150, 150, 150] @=> int b2pastStates1[];
[150, 150, 150, 150, 150, 150, 150, 150] @=> int b2pastStates2[];
[150, 150, 150, 150, 150, 150, 150, 150] @=> int b2pastStates3[];
[150, 150, 150, 150, 150, 150, 150, 150] @=> int b2pastStates4[];
[150, 150, 150, 150, 150, 150, 150, 150] @=> int b3pastStates1[];
[150, 150, 150, 150, 150, 150, 150, 150] @=> int b3pastStates2[];
[150, 150, 150, 150, 150, 150, 150, 150] @=> int b3pastStates3[];
[150, 150, 150, 150, 150, 150, 150, 150] @=> int b3pastStates4[];

[150, 150, 150, 150] @=> int b1smoothedStates[];

fun void newReading(int whatBot, int whatSensor, int reading) {
    // often get random 5's
    // if (reading > 10 && reading < 240) {
    // if reading is 200 difference, only take current reading + 25
    if (whatBot == 1) {
        if (whatSensor == 0) {
            for (6 => int i; i >= 0; i--) {
                b1pastStates1[i] => b1pastStates1[i+1];
            }
            if (reading - b1pastStates1[1] < -200){
                b1pastStates1[0] - 25 => reading;
            }
            else if(reading - b1pastStates1[1] > 200){
                b1pastStates1[0] + 25 => reading; 
            }
            reading => b1pastStates1[0];
            
        }
        else if (whatSensor == 1) {
            for (6 => int i; i >= 0; i--) {
                b1pastStates2[i] => b1pastStates2[i+1];
            }
            if (reading - b1pastStates2[1] < -200){
                b1pastStates2[0] - 25 => reading;
            }
            else if(reading - b1pastStates2[1] > 200){
                b1pastStates2[0] + 25 => reading; 
            }
            reading => b1pastStates2[0];
            
        }
        else if (whatSensor == 2) {
            for (6 => int i; i >= 0; i--) {
                b1pastStates3[i] => b1pastStates3[i+1];
            }
            if (reading - b1pastStates3[1] < -200){
                b1pastStates3[0] - 25 => reading;
            }
            else if(reading - b1pastStates3[1] > 200){
                b1pastStates3[0] + 25 => reading; 
            }
            reading => b1pastStates3[0];
            
        }
        else if (whatSensor == 3) {
            for (6 => int i; i >= 0; i--) {
                b1pastStates4[i] => b1pastStates4[i+1];
            }
            if (reading - b1pastStates4[1] < -200){
                b1pastStates4[0] - 25 => reading;
            }
            else if(reading - b1pastStates4[1] > 200){
                b1pastStates4[0] + 25 => reading; 
            }
            reading => b1pastStates4[0];
            
        }
        getSmoothedDistance(whatBot, whatSensor) => b1smoothedStates[whatSensor];
        // }
    }
}

fun int getSmoothedDistance(int whatBot, int whatSensor) {
    float distance;
    int returnValue;
    if (whatBot == 1) {
        if (whatSensor == 0) {
            for (int i; i < 8; i++){
                b1pastStates1[i] * smoothingWeights[i] +=> distance;
            }
        }
        else if (whatSensor == 1) {
            for (int i; i < 8; i++){
                b1pastStates2[i] * smoothingWeights[i] +=> distance;
            }
        }
        else if (whatSensor == 2) {
            for (int i; i < 8; i++){
                b1pastStates3[i] * smoothingWeights[i] +=> distance;
            }
        }
        else if (whatSensor == 3) {
            for (int i; i < 8; i++){
                b1pastStates4[i] * smoothingWeights[i] +=> distance;
            }
        }
        
    }
    distance $ int => returnValue;
    return returnValue;
}

// listener for receiving sensor information
fun void oscrecv() {
    // theia 1 - main bot
    // theia 2 - second bot
    // theia 3 - third bot
    while(true) {
        oin => now;
        while(oin.recv(msg)) {
            msg.address => string address;
            msg.getInt(0) => int sensorNum;
            msg.getInt(1) => int distance;
            // theia1 is for bot 1 (the first bot)
            //<<<"received OSC message : ", address, " ", sensorNum, " ", distance>>>;
            if (address == "/theia1"){
                // immedietly send the data over to processing for analysis
                // process the message
                newReading(1, sensorNum, distance);
                getSmoothedDistance(1, sensorNum) => int smoothedDistance => b1smoothedStates[sensorNum]; 
                //<<<"smoothed distance : ", smoothedDistance>>>;               
                pOut.start("/theia1");
                pOut.add(sensorNum);
                pOut.add(smoothedDistance);
                pOut.send();
                // cycle through the four ultrasonic slowStates and change the overall state                
                if (smoothedDistance >= highMidThresh && bot1State[sensorNum] != 0) {
                    0 => bot1State[sensorNum];
                    //<<<"bot1 sensor ", sensorNum, " state changed to : ", bot1State[0]>>>;
                }
                else if (smoothedDistance >= highCloseThresh && smoothedDistance < lowMidThresh &&
                bot1State[sensorNum] != 1) {
                    1 => bot1State[sensorNum];
                    //<<<"bot1 sensor ", sensorNum, " state changed to : ", bot1State[sensorNum]>>>;
                } 
                else if (bot1State[sensorNum] != 2 && smoothedDistance < lowCloseThresh) {
                    2 => bot1State[sensorNum];
                    //<<<"bot1 sensor ", sensorNum, " state changed to : ", bot1State[sensorNum]>>>;
                }
            }
            
        }
    }
}

fun void getTheiaDistance(int botNum, int sensorNum){
    if (botNum == 3) {
        out.start("/theia3");
        out.add(sensorNum);
        out.add(0);
        out.send();
    }
    else if (botNum == 2) {
        out.start("/theia2");
        out.add(sensorNum);
        out.add(0);
        out.send();
    }
    else if (botNum == 1) {
        out.start("/theia1");        
        out.add(sensorNum);
        out.add(0);
        out.send();
    }
}

fun void smallSolinoids(int note, int vel, int delay){
    out.start("/brigid4");
    out.add(note);
    out.add(vel);
    out.send();
    out.start("/brigid1");
    out.add(note);
    out.add(vel);
    out.send();
    delay::ms => now;
}
fun void rotarySolinoids(int note, int vel, int delay){
    out.start("/brigid5");
    out.add(note);
    out.add(vel);
    out.send();
    out.start("/brigid3");
    out.add(note);
    out.add(vel);
    out.send();
    delay::ms => now;
}
fun void largeSolinoids(int note, int vel, int delay){
    out.start("/brigid6");
    out.add(note);
    out.add(vel);
    out.send();
    out.start("/brigid2");
    out.add(note);
    out.add(vel);
    out.send();
    delay::ms => now;
}

fun void pollUltrasonics() {
    while(true) {
        for (int i; i < 4; i++){
            spork ~ getTheiaDistance(1, i);
            10::ms => now;
            //<<<"getting theia1 distance : ", i>>>;
        }
    }   
}

fun void triggerAll(int sensorNum, int maxDelay) {
    (maxDelay / 6) $ int => int delay;
    if (sensorNum == 2) {
        for (int t; t < 6; t++){
            for (int i; i < 6; i++){
                spork ~ rotarySolinoids(i+60, 50, 600);
            }
            Math.random2f(0.5*delay, delay*1.5)::ms => now;   
        }
    }
    else if (sensorNum == 1) {
        for (int t; t < 6; t++){
            for (int i; i < 6; i++){
                spork ~ smallSolinoids(i+60, 50, 600);
            }
            Math.random2f(0.5*delay, delay*1.5)::ms => now;   
        }
    }
    if (sensorNum == 0) {
        for (int t; t < 6; t++){
            for (int i; i < 6; i++){
                spork ~ largeSolinoids(i+60, 50, 600);
            }
            Math.random2f(0.5*delay, delay*1.5)::ms => now;     
        }
    }
    if (sensorNum == 3) {
        for (int t; t < 6; t++){
            for (int i; i < 6; i++){
                spork ~ rotarySolinoids(i+60, 50, 600);
            }
            Math.random2f(0.5*delay, delay*1.5)::ms => now;    
        }
    }
}

fun void productive1(int bank, int delayTime){
    delayTime/6 => float inbetween_time;
    for (int i; i < 6; i++){
        // only trigger gods 1 for 'intro'
        if (bank == 2){
            spork ~ smallSolinoids(i+60,  20, 35);            
        }
        // trigger two durring the 'main' section
        else if (bank == 0) {
            spork ~ largeSolinoids(i+60, 40, 40);
            
        }
        // trigger them all at the 'outro'
        else if (bank == 1 | bank == 3) {
            spork ~ rotarySolinoids(i+60, 30, 30);
        }
        inbetween_time::ms => now;
    }   
}


fun void productive2(int delayTime){
    delayTime/6 => float inbetween_time;
    for (int i; i < 6; i++){
        // only trigger gods 1 for 'intro'
        if (Math.random2(0, 10) < 4){
            spork ~ largeSolinoids(Math.random2(0,6)+60, 15, 30);
        }
        if (Math.random2(0,10) < 5) {
            spork ~ rotarySolinoids(Math.random2(0,6)+60, 15, 30);   
        }
        if (Math.random2(0,10) < 5) {
            spork ~ smallSolinoids(Math.random2(0,6)+60, 15, 30);   
        }
        (inbetween_time * Math.random2(1,4))::ms => now;
    }   
}
spork ~ oscrecv();
spork ~ pollUltrasonics();

// TODO make time variable that controls 
// the "velocity" of productive1()
0.5::second => dur segment;
now => time past_time;
1200 => float speed;
[now, now, now, now] @=> time next_trigger[];
dur delay_time;
now => time current_time;
// composition starts out with a speed of around 1000, goes down to 50 at end

while(1) {
    now => current_time;
    // only look at bot 1 for now
    for (int i; i < 4; i++) { 
        if (bot1State[i] == 0 && current_time > next_trigger[i]){
            //<<<" bot entering into productive state : ", i, " - ", bot1State[i]>>>;
            //<<<bot1State[0], "-",bot1State[1], "-",bot1State[2], "-",bot1State[3]>>>;
            //<<<b1smoothedStates[0], "-",b1smoothedStates[1], "-",b1smoothedStates[2], "-",b1smoothedStates[3]>>>;
            //<<<"--------------------">>>;
            spork ~ productive1(i, speed $ int); 
            now + delay_time => next_trigger[i];
            speed::ms => delay_time;
            
        }
        else if (bot1State[i] == 2 && current_time > next_trigger[i]) {
            //<<<"bot entering into angry state : ", i, " - ", bot1State[i]>>>;
            spork ~ triggerAll(i, speed $ int);    
            //<<<bot1State[0], "-",bot1State[1], "-",bot1State[2], "-",bot1State[3]>>>;
            //<<<b1smoothedStates[0], "-",b1smoothedStates[1], "-",b1smoothedStates[2], "-",b1smoothedStates[3]>>>;
            now + delay_time => next_trigger[i];
            speed::ms => delay_time;
            //speed * Math.random2f(0.97, 1.03) => speed;
            //<<<"new speed : ", speed>>>;
        }
        else if (bot1State[i] == 1 && current_time > next_trigger[i]){
            //<<<i, "bot entering into dormant state">>>;
            //<<<bot1State[0], "-",bot1State[1], "-",bot1State[2], "-",bot1State[3]>>>;
            //<<<b1smoothedStates[0], "-",b1smoothedStates[1], "-",b1smoothedStates[2], "-",b1smoothedStates[3]>>>;
            now + delay_time => next_trigger[i]; 
            speed::ms => delay_time;       
        }
        else {
            //<<<b1smoothedStates[0], "-",b1smoothedStates[1], "-",b1smoothedStates[2], "-",b1smoothedStates[3]>>>;
            //spork ~ stairwayToHeavan(Math.random2(0,4), Math.random2(100,1000));
            5::ms => now;
        }
    }
}