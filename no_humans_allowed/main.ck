// main.ck
// CalArts Music Tech // MTIID4LIFE

// give it some time to breathe
HandshakeID talk;
0.5::second => now;

// initial handshake between ChucK and Arduinos
talk.talk.init();
1::second => now;

<<< "Handshakes done" >>>;
// bring on the bots
Personality bots[3];

// MainBot - Craig
bots[0].setTheias(1);
bots[0].setBrigids(6);

// Secondary Bot
bots[1].setTheias(1);
bots[1].setBrigids(4);
bots[1].setHomados(2);

// Trinary Bot
bots[2].setTheias(1);
bots[2].setBrigids(4);
bots[2].setHomados(2);

// for keeping track of the states of all the bots
// if someone is really close the state is 2: agressive
// if someone is sort of close the state is 1: quiet and timid
// if someone if not detected, the state is 0: productive
[0, 0, 0] @=> int botMood[];

fun void moodRipple() {
    // conducts logic for mood
    // if one is agressive, make the productive ones quiet
}

while (true) {
    1::second => now;
    moodRipple();
}

/*
no-humans-allowed.ck

This file provides the compositional logic for no-humans-allowed.ck

*/
OscOut out;
OscOut pOut;
OscIn oin;
OscMsg msg;
("localhost", 50000) => out.dest;
("localhost", 50010) => pOut.dest;
50003 => oin.port;
oin.listenAll();


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
            if (address == "/theia"){
                // first argument is the bot num
                // second argument is the sensorNum
                // third argument is the distance

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

fun void pollUltrasonics() {
    while(true) {
        for (int b; b < 3; b++) {
            for (int i; i < 4; i++){
                spork ~ getTheiaDistance(b, i);
                100::ms => now;
                //<<<"getting theia1 distance : ", i>>>;
            }
        }
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

while(1) {
    now => current_time;
    for (int i; i < 4; i++) { 
        if (bot1State[i] == 0 && current_time > next_trigger[i]){
            spork ~ productive1(i, speed $ int); 
            now + delay_time => next_trigger[i];
            speed::ms => delay_time;
        }
        else if (bot1State[i] == 2 && current_time > next_trigger[i]) {
            spork ~ triggerAll(i, speed $ int);
            now + delay_time => next_trigger[i];
            speed::ms => delay_time;
        }
        else if (bot1State[i] == 1 && current_time > next_trigger[i]){
            now + delay_time => next_trigger[i]; 
            speed::ms => delay_time;
        }
        else {
            5::ms => now;
        }
    }
}
