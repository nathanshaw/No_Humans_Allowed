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
[0, 0, 0] @=> int botState[];

// if distance is less than midThresh, bot will enter
// into state 1. This might have to be adjusted according to
// the space
135 => int lowMidThresh;
150 => int highMidThresh;

80 => int lowCloseThresh;
95 => int highCloseThresh;

// keeps track of how many times the
// bot enters into state 2,
// if it enters into state 2
0 => int times_fed;
6 => int how_hungry;
now => time last_fed;
7000::ms => dur feeding_dur;

[150, 150, 150, 150, 150, 150, 150, 150] @=> int pastStates1[];
[150, 150, 150, 150, 150, 150, 150, 150] @=> int pastStates2[];
[150, 150, 150, 150, 150, 150] @=> int pastStates3[];

[150, 150, 150] @=> int slowStates[];

[0.4, 0.2, 0.1, 0.1, 0.1, 0.1] @=> float smoothingWeights[];

fun void newReading(int whatBot, int reading) {
    // often get random 5's
    if (reading > 10 && reading < 240) {
    if (whatBot == 1) {
        for (4 => int i; i >= 0; i--) {
            pastStates1[i] => pastStates1[i+1];
        }
        reading => pastStates1[0];
        if (reading > slowStates[0]) {
            slowStates[0] + 2 => slowStates[0];
        }
        else if (reading < slowStates[0]) {
            slowStates[0] - 2 => slowStates[0]; 
        }
    }
    else if (whatBot == 2) {
        for (4 => int i; i >= 0; i--) {
            pastStates2[i] => pastStates2[i+1];
        }
        reading => pastStates2[0];
        if (reading > slowStates[1]) {
            slowStates[1] + 2 => slowStates[1];
        }
        else if (reading < slowStates[0]) {
            slowStates[1] - 2 => slowStates[1]; 
        }
    }
    else if (whatBot == 3) {
        for (4 => int i; i >= 0; i--) {
            pastStates3[i] => pastStates3[i+1];
        }
        reading => pastStates3[0];
        if (reading > slowStates[2]) {
            slowStates[2] + 2 => slowStates[2];
        }
        else if (reading < slowStates[2]) {
            slowStates[2] - 2 => slowStates[2]; 
        }
    }
    }
}

fun void outro(){
    for (650 => float i; i > 5; i * 0.988 => i){
        i $ int => int ii;
        spork ~ productive2(ii*2);
        spork ~ productive2(ii);
        (i)::ms => now;
    }
    <<<"VERY END">>>;
    // very end
    for (1000 => float i; i < 15000; i * 1.15 => i){
        triggerAllRhythmic(i$int);
    }
    <<<"DONE!!!!">>>;
}


fun int getSmoothedDistance(int whatBot) {
    float distance;
    int returnValue;
    if (whatBot == 1) {
        for (int i; i < 6; i++){
            pastStates1[i] * smoothingWeights[i] +=> distance;
        }
    }
    else if (whatBot == 2) {
        for (int i; i < 6; i++){
            pastStates2[i] * smoothingWeights[i] +=> distance;
        }
    }
    else if (whatBot == 3) {
        for (int i; i < 6; i++){
            pastStates3[i] * smoothingWeights[i] +=> distance;
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
            
            //<<<"received OSC message : ", msg>>>;
            if (address == "/theia1"){
                pOut.start(address);
                pOut.add(sensorNum);
                pOut.add(distance);
                pOut.send();
                newReading(1, distance);
                getSmoothedDistance(1);
                
                pOut.start("/theia2");
                pOut.add(sensorNum);
                (pastStates1[0] + pastStates1[1])/2 $ int => pastStates1[0];
                pOut.add(pastStates1[0]);
                pOut.send();
                
                pOut.start("/theia3");
                pOut.add(sensorNum);
                pOut.add(slowStates[0]);
                pOut.send();
                //<<<sensorNum, " distance : ", distance, "smoothed : ", 
                //slowStates[0], " - state - ", botState[0], "num times fed - ", times_fed>>>;
                if (slowStates[0] >= highMidThresh && botState[0] != 0) {
                    0 => botState[0];
                    <<<"bot1 state changed to : ", botState[0]>>>;
                }
                else if (slowStates[0] >= highCloseThresh && slowStates[0] < lowMidThresh &&
                botState[0] != 1) {
                    1 => botState[0];
                    <<<"bot1 state changed to : ", botState[0]>>>;
                } 
                else if (botState[0] != 2 && slowStates[0] < lowCloseThresh) {
                    2 => botState[0];
                    <<<"bot1 state changed to : ", botState[0]>>>;
                    if (now > last_fed + feeding_dur){
                        now => last_fed;
                        times_fed++;
                        <<<"TIMES FED : ", times_fed>>>;
                        if (times_fed % 10 == 0){
                            outro();
                        }
                    }
                    else {
                        <<<"were just fed, ignoring message">>>;   
                    }
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
            50::ms => now;
            //<<<"getting theia1 distance : ", i>>>;
        }
    }   
}

fun void triggerAll(int maxDelay) {
    (maxDelay / 6) $ int => int delay;
    for (int t; t < 6; t++){
        for (int i; i < 6; i++){
            spork ~ smallSolinoids(i+60, 50, 30);
            spork ~ rotarySolinoids(i+60, 10, 30);
            spork ~ largeSolinoids(i+60, 10, 30);
        }   
    }
    Math.random2(10, delay)::ms => now; 
}

fun void triggerAllRhythmic(int maxDelay) {
    (maxDelay / 6) $ int => int delay;
    for (int i; i < 6; i++){
        spork ~ smallSolinoids(i+60, 20, 30);
        spork ~ rotarySolinoids(i+60, 10, 30);
        spork ~ largeSolinoids(i+60, 5, 30);      
    }   
    delay::ms => now; 
}

fun void productive1(int delayTime){
    delayTime/6 => float inbetween_time;
    for (int i; i < 6; i++){
        // only trigger gods 1 for 'intro'
        if (times_fed < 2){
            spork ~ largeSolinoids(i+60, 10, 30);
        }
        // trigger two durring the 'main' section
        else if (times_fed < 5) {
            spork ~ smallSolinoids(i+60,  4, 30);
            spork ~ rotarySolinoids(i+60, 30, 20);
        }
        // trigger them all at the 'outro'
        else {
            spork ~ smallSolinoids(i+60,  4, 30);
            spork ~ rotarySolinoids(i+60, 50, 20);
            spork ~ largeSolinoids(i+60, 20, 40);            
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
1100 => int speed;
now => time next_trigger;
dur delay_time;
now => time current_time;
// composition starts out with a speed of around 1000, goes down to 50 at end

/*
while(times_fed < how_hungry) {
    now => current_time;
    if (current_time > past_time + segment){
        now => past_time; 
        if (speed >= 50){ 
            speed--;
            if (speed % 50 == 0){
                <<<speed>>>;
            }
        }
    }
    // only look at bot 1 for now
    0 => int i;
    if (botState[i] == 1 && current_time > next_trigger){
        //<<<i, " bot entering into productive state : ", i, " - ", botState[i]>>>;
        //speed::ms => delay_time;
        spork ~ productive1(speed); 
        now + delay_time => next_trigger;
        speed::ms => delay_time;
    }
    else if (botState[i] == 2 && current_time > next_trigger) {
        //<<<i, "bot entering into angry state : ", i, " - ", botState[i]>>>;
        spork ~ triggerAll(speed);    
        now + delay_time => next_trigger;
        speed::ms => delay_time;
    }
    else if (botState[i] == 0 && current_time > next_trigger){
        //<<<i, "bot entering into dormant state">>>;
        now + delay_time => next_trigger; 
        speed::ms => delay_time;       
    }
    else {
        //spork ~ stairwayToHeavan(Math.random2(0,4), Math.random2(100,1000));
        5::ms => now;
    }
}

// test solinoids and leds
while(1){
for (60 => int i; i < 66; i++){
    rotarySolinoids(i, 60, 30);
    Math.random2(10,100)::ms => now;
}
for (60 => int i; i < 66; i++){
        smallSolinoids(i, 60, 30);
    Math.random2(10,100)::ms => now;
}
for (60 => int i; i < 66; i++){
    largeSolinoids(i, 60, 30);
    Math.random2(10,100)::ms => now;
}
for (60 => int i; i < 66; i++){
    rotarySolinoids(i, 60, 30);
    smallSolinoids(i, 60, 30);
    largeSolinoids(i, 60, 30);
    Math.random2(10,100)::ms => now;
}
}
*/
1::day => now;
// now either the composition can end or
// there can be a pre-composed outro for it
