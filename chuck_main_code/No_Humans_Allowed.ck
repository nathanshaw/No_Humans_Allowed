// No Humans Allowed
OscOut out;
OscIn oin;
OscMsg msg;
("localhost", 50000) => out.dest;
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
[200, 200, 200] @=> int midThresh[];
75 => int closeThresh;

int pastStates1[6];
int pastStates2[6];
int pastStates3[6];

int slowStates[3];

[0.4, 0.2, 0.1, 0.1, 0.1, 0.1] @=> float smoothingWeights[];

fun void newReading(int whatBot, int reading) {
    if (whatBot == 1) {
        for (4 => int i; i >= 0; i--) {
            pastStates1[i] => pastStates1[i+1];
        }
        reading => pastStates1[0];
        if (reading > slowStates[0]) {
            slowStates[0] + 1 => slowStates[0];
        }
        else if (reading < slowStates[0]) {
            slowStates[0] - 1 => slowStates[0]; 
        }
    }
    else if (whatBot == 2) {
        for (4 => int i; i >= 0; i--) {
            pastStates2[i] => pastStates2[i+1];
        }
        reading => pastStates2[0];
        if (reading > slowStates[1]) {
            slowStates[1] + 1 => slowStates[1];
        }
        else if (reading < slowStates[0]) {
            slowStates[1] - 1 => slowStates[1]; 
        }
    }
    else if (whatBot == 3) {
        for (4 => int i; i >= 0; i--) {
            pastStates3[i] => pastStates3[i+1];
        }
        reading => pastStates3[0];
        if (reading > slowStates[2]) {
            slowStates[2] + 1 => slowStates[2];
        }
        else if (reading < slowStates[2]) {
            slowStates[2] - 1 => slowStates[2]; 
        }
    }
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
            if (address == "/theia1"){
                newReading(1, distance);
                if (slowStates[0] >= midThresh[0] && botState[0] != 0) {
                    0 => botState[0];
                    <<<"bot1 state changed to : ", botState[0]>>>;
                }
                else if (slowStates[0] >= closeThresh && botState[0] != 1) {
                    1 => botState[0];
                    <<<"bot1 state changed to : ", botState[0]>>>;
                } 
                else if (botState[0] != 2 && slowStates[0] < closeThresh) {
                    2 => botState[0];
                    <<<"bot1 state changed to : ", botState[0]>>>;
                } 
            }
            else if (address == "/theia2"){
                newReading(2, distance);
                if (slowStates[1] >= midThresh[1] && botState[1] != 0) {
                    0 => botState[1];
                    <<<"bot2 state changed to : ", botState[1]>>>;
                }
                else if (slowStates[1] >= closeThresh && botState[1] != 1) {
                    1 => botState[1];
                    <<<"bot2 state changed to : ", botState[1]>>>;
                } 
                else if (botState[1] != 2 && slowStates[1] < closeThresh) {
                    2 => botState[1];
                    <<<"bot2 state changed to : ", botState[1]>>>;
                }             
            }
            else if (address == "/theia3"){
                newReading(3, distance);
                <<<"distance : ", distance, "smoothed distance : ", getSmoothedDistance(3),
                "supersmoothed : ", slowStates[2]>>>;
                if (slowStates[2] >= midThresh[2] && botState[2] != 0) {
                    0 => botState[2];
                    <<<"bot3 state changed to : ", botState[2]>>>;
                }
                else if (slowStates[2] >= closeThresh && botState[2] != 1) {
                    1 => botState[2];
                    <<<"bot3 state changed to : ", botState[2]>>>;
                } 
                else if (botState[2] != 2 && slowStates[2] < closeThresh) {
                    2 => botState[2];
                    <<<"bot3 state changed to : ", botState[2]>>>;
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

fun void gods1(int note, int vel, int delay){
    out.start("/brigid4");
    out.add(note);
    out.add(vel);
    out.send();
    out.start("/brigid1");
    out.add(note);
    out.add(vel);
    out.send();
    delay::ms => now;
    out.start("/brigid4");
    out.add(note);
    out.add(0);
    out.send();
    out.start("/brigid1");
    out.add(note);
    out.add(0);
    out.send();
}

fun void gods2(int note, int vel, int delay){
    out.start("/brigid5");
    out.add(note);
    out.add(vel);
    out.send();
    out.start("/brigid2");
    out.add(note);
    out.add(vel);
    out.send();
    delay::ms => now;
    out.start("/brigid5");
    out.add(note);
    out.add(0);
    out.send();
    out.start("/brigid2");
    out.add(note);
    out.add(0);
    out.send();
}

fun void gods3(int note, int vel, int delay){
    out.start("/brigid6");
    out.add(note);
    out.add(vel);
    out.send();
    out.start("/brigid3");
    out.add(note);
    out.add(vel);
    out.send();
    delay::ms => now;
    out.start("/brigid6");
    out.add(note);
    out.add(0);
    out.send();
    out.start("/brigid3");
    out.add(note);
    out.add(0);
    out.send();
}


fun void gods4(int note, int vel, int delay){
    out.start("/brigid7");
    out.add(note);
    out.add(vel);
    out.send();
    delay::ms => now;
    out.start("/brigid7");
    out.add(note);
    out.add(0);
    out.send();
}


fun void gods5(int note, int vel, int delay){
    out.start("/brigid8");
    out.add(note);
    out.add(vel);
    out.send();
    delay::ms => now;
    out.start("/brigid8");
    out.add(note);
    out.add(0);
    out.send();
}

fun void stairwayToHeavan(int note, int vel){
    out.start("/hermes1");
    out.add(note);
    out.add(vel);
    out.send();
}

fun void pollUltrasonics() {
    while(true) {
        for (1 => int theiaNum; theiaNum <= 3; theiaNum++) {
            2 => int numUltrasonics;
            if (theiaNum == 1) {
                4 => numUltrasonics;
            }  
            for (int sensorNum; sensorNum < numUltrasonics; sensorNum++) {
                spork ~ getTheiaDistance(theiaNum, sensorNum);
            }
        }
        100::ms => now;
    }   
}

spork ~ oscrecv();
spork ~ pollUltrasonics();

while(true) {
    1::second => now;
    
    
}

