// main.ck
// CalArts Music Tech // MTIID4LIFE
/*

1. Handshake, figure out the ID's for each of the arduinos
2. Assign shilds to personalities which orchestrate the actuators
    2.1 Each personality polls the Theia for distances
    2.2 Each personality triggers the solenoids according to its state

3. Launch a listener that listens to responces from theia bots
    3.0 Listener script takes care of smoothing, keeping track of distances and the states
    of bots
    3.1 when a bot should enter into a state it is the listener that tells them
    to enter into that state.
*/

// give it some time to breathe
HandshakeID talk;
0.5::second => now;

// initial handshake between ChucK and Arduinos
talk.talk.init();
1::second => now;
<<<"found a total of ", talk.talk.returnNumRobotID(), " bots">>>;
<<< "Handshakes done" >>>;
<<<"----------------">>>;

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
int arduinoIDs[talk.talk.returnNumRobotID()];
for (0 => int i; i < talk.talk.returnNumRobotID(); i++) {
    talk.talk.returnRobotID(i) => arduinoIDs[i];
}
for (0 => int i; i < arduinoIDs.cap(); i++) {
    // figure out the bots
    for (bots.cap() => int botNum; botNum > 0; botNum--) {
        if ((arduinoIDs[i] / 100) > botNum) {
            <<<"BOARD BELONGS TO BOTNUM (index 0) : ", 
                botNum, " - ", arduinoIDs[i]>>>;
        }
    }
}

/*
no-humans-allowed.ck

This file provides the compositional logic for no-humans-allowed.ck

OscOut out;
OscOut pOut;
OscIn oin;
OscMsg msg;
("localhost", 50000) => out.dest;
("localhost", 50010) => pOut.dest;
50003 => oin.port;
oin.listenAll();



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
*/
