//b main.ck
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
// shield specific bot ID's
int brigidBotIDs[3][7];
int homadosBotIDs[3][7];
int brigidLightIDs[3][7];
int homadosLightIDs[3][7];
int theiaBotIDs[3][7];

// set defaults to -1
for (int i; i < 3; i++){
    for (int ii; ii < 7; ii++){
        -1 => brigidBotIDs[i][ii];
        -1 => homadosBotIDs[i][ii];
        -1 => theiaBotIDs[i][ii];
    }
}
// for keeping track of how many shields of each
// type are found in each of the personalities
int brigidBotNum[3];
int homadosBotNum[3];
int theiaBotNum[3];
int brigidLightNum[3];
int homadosLightNum[3];

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
<<<"- - - - - - - - - - - - - - - - - ">>>;
for (0 => int i; i < arduinoIDs.cap(); i++) {
    <<<"----------------------------">>>;
    <<<"looking at arduino ID : ", arduinoIDs[i]>>>;
    // figure out the bots
    for (bots.cap() => int botNum; botNum >= 0; botNum--) {
        if ((arduinoIDs[i] / 100) -1 == botNum) {
            for (9 => int board_type; board_type > 0; board_type--) {
                if ((arduinoIDs[i] % 100) / 10 == board_type) {
                    for (9 => int board_num; board_num > -1; board_num--) {
                        if ((arduinoIDs[i] % 10) == board_num) {
                            //  <<<"BOARD is num               : ", 
                            //  board_num, " - ", arduinoIDs[i]>>>;
                            // brigid
                            if (board_type == 1){
                                if (arduinoIDs[i] % 2 == 0){
                                    i => brigidLightIDs[botNum][brigidLightNum[botNum]];
                                    brigidLightNum[botNum]++;
                                    <<<"Brigid assigned light shield : ", i, " to bot : ", botNum>>>;
                                }
                                else{
                                    i => brigidBotIDs[botNum][brigidBotNum[botNum]];
                                    brigidBotNum[botNum]++;
                                    <<<"Brigid assigned solenoid shield : ", i, " to bot : ", botNum>>>;
                                }
                            }
                            // homados
                            else if (board_type == 2){
                                if (arduinoIDs[i] % 2 == 1){
                                    <<<"Homados assigned solenoid : ", i, " to bot : ", botNum>>>;
                                    i => homadosBotIDs[botNum][homadosBotNum[botNum]];
                                    homadosBotNum[botNum]++;
                                }
                                else {
                                    <<<"Homados assigned light: ", i, " to bot : ", botNum>>>;
                                    i => homadosLightIDs[botNum][homadosLightNum[botNum]];
                                    homadosLightNum[botNum]++;
                                }
                            }
                            // theia
                            else if (board_type == 4){
                                <<<"Theia assigned : ", i, " to bot : ", botNum>>>;
                                i => theiaBotIDs[botNum][theiaBotNum[botNum]];
                                theiaBotNum[botNum]++;
                            }
                        }
                    }
                }
            }
        }
    }
}

<<<"- - - - - - - - - - - - - - - - - ">>>;
<<<"Initalizing Bots">>>;
spork ~ bots[0].init(1, "/bot1", brigidBotIDs[0], homadosBotIDs[0], theiaBotIDs[0],
brigidLightIDs[0], homadosLightIDs[0]);
1.2::second => now;
spork ~ bots[1].init(2, "/bot2", brigidBotIDs[1], homadosBotIDs[1], theiaBotIDs[1], brigidLightIDs[1], homadosLightIDs[1]);
1.2::second => now;
spork ~ bots[2].init(3, "/bot3", brigidBotIDs[2], homadosBotIDs[2], theiaBotIDs[2], brigidLightIDs[2], homadosLightIDs[2]);


int botPastMoods[3];
// create a shred that keeps track of the bots states
<<<"- - - - - - - - - - - - - - - - - ">>>;
<<<"Done with initializations">>>;
fun void botListener() {
    // poll bots for their states, applies logic to change the behavior
    // <<<"Bot listener started">>>;
    int botMoods[bots.cap()];
    while(true) {
        for (int i; i < bots.cap(); i++) {
            bots[i].determineState();
            if (bots[i].state != botMoods[i]) {
                botMoods[i] => botPastMoods[i];
                bots[i].state => botMoods[i];
                <<<"Bot Moods : ", botMoods[0], botMoods[1], botMoods[2]>>>;
            }
        }
        for (int i; i < botMoods.cap(); i++) {
            // if one of the bots is angry
            if (botMoods[i] == 2) {
                bots[i].setState(2);
                // set the other bots to quiet
                if (botPastMoods[i] != 2) {
                    for (int t; t < botMoods.cap(); t++) {
                        if ( t != i && botMoods[t] == 0) {
                            if (Math.random2f(0, 1.0) < 0.2){
                                1 => botMoods[t];
                                bots[t].setState(1);
                                bots[t].wait(1000);
                                <<<"bot ", i, " is angry, changing bot ", t, " to quiet">>>;
                                <<<"Bot Moods : ", botMoods[0], botMoods[1], botMoods[2]>>>;
                            }
                        }
                    }
                }
            }
        }
        // poll the theia boards for 5 seconds or so
        for (int t; t < 1; t++){
            for (int i; i < 3; i++){
                bots[i].pollTheia();
                60::ms => now;
            }
        }
    }
}

spork ~ botListener();
while (true) {
    1::second => now;
}
