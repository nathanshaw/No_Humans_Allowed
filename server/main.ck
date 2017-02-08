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
<<<"Created personality variables">>>;
<<<"- - - - - - - - - - - - - - - - - ">>>;
int arduinoIDs[talk.talk.returnNumRobotID()];
for (0 => int i; i < talk.talk.returnNumRobotID(); i++) {
    talk.talk.returnRobotID(i) => arduinoIDs[i];
}
<<<"found ", arduinoIDs.cap(), " arduinos">>>;
for (0 => int i; i < arduinoIDs.cap(); i++) {
    <<<"looking at arduino ID : ", arduinoIDs[i]>>>;
    // figure out the bots
    for (bots.cap() => int botNum; botNum > 0; botNum--) {
        if ((arduinoIDs[i] / 100) == botNum) {
            <<<"BOARD BELONGS TO BOTNUM    : ", 
                botNum, " - ", arduinoIDs[i]>>>;
            for (9 => int board_type; board_type > 0; board_type--) {
                if ((arduinoIDs[i] % 100) / 10 == board_type) {
                    <<<"BOARD BELONGS TO BOARDTYPE : ", 
                        board_type, " - ", arduinoIDs[i]>>>;
                    for (9 => int board_num; board_num > -1; board_num--) {
                        if ((arduinoIDs[i] % 10) == board_num) {
                            <<<"BOARD is num               : ", 
                                board_num, " - ", arduinoIDs[i]>>>;
                        }
                    }
                }
            }
        }
    }
}
<<<"- - - - - - - - - - - - - - - - - ">>>;
<<<"Initalizing Bots">>>;
for (int i; i < bots.cap(); i++) {
    spork ~ bots[i].init(i * 100);
}

// create a shred that keeps track of the bots states
<<<"- - - - - - - - - - - - - - - - - ">>>;
<<<"Done with initializations">>>;

fun void botListener() {
    // poll bots for their states, applies logic to change the behavior
    int botMoods[bots.cap()];
    while(true) {
        for (int i; i < bots.cap(); i++) {
            if (bots[i].state != botMoods[i]) {
                bots[i].state => botMoods[i];
                <<<botMoods[0], botMoods[1], botMoods[2]>>>;
            }
        }
        for (int i; i < botMoods.cap(); i++) {
            // if one of the bots is angry
            if (botMoods[i] == 0) {
                // set the other bots to quiet
                for (int i; i < botMoods.cap(); i++) {
                    1 => botMoods[i];
                }
                0 => botMoods[i];
            }
        }
        1::second => now;
    }
}

spork ~ botListener();
while (true) {
    1::second => now;
}
