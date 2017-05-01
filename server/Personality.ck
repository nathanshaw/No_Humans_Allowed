public class Personality{
    
    HandshakeID talk;
    
    OscIn oin;
    OscMsg msg;
    int brigidPorts[0];
    int homadosPorts[0];
    int theiaPorts[0];
    
    // ultrasonic rangefinders distances
    int distances[4];
    
    // new port number
    50002 => oin.port;
    oin.listenAll();
    
    // for optional rescaling
    int botNum;
    int state;
    string address;
    
    fun void init(int aBotNum, string addr, 
                  int bPorts[], int hPorts[],
                  int tPorts[]){
        // dynamically set up the bot
        <<<"Initializing personality", botNum>>>;
        
        for (int i; i < bPorts.size(); i++){
            // <<<"port contents : ", bPorts[i]>>>;//, "-", hPorts[i], "-", tPorts[i]>>>;
            if (bPorts[i] >= 0){
                brigidPorts << bPorts[i];
            }
        }
        for (int i; i < hPorts.size(); i++){
            // <<<"hport contents : ", hPorts[i]>>>;
            if (hPorts[i] >= 0){
                homadosPorts << hPorts[i];
            }
        }
        for (int i; i < tPorts.size(); i++){
            // <<<"tPort contents : ", tPorts[i]>>>;
            if (tPorts[i] >= 0){
                theiaPorts << tPorts[i];
                spork ~ theiaListener();
            }
        }
        aBotNum => botNum;
        addr => address;
        while(true) {
            // <<<"bot ", botNum, " state ", state>>>;
            if (state == 1) {
                // resting state
                2::second => now;
            }
            else if (state == 2) {
                //  bports, hports, minWait, maxWait
                if (brigidPorts.size() > 0 || homadosPorts.size() > 0){
                    angryStateOne(brigidPorts, homadosPorts, 50, 2750);
                }
                else{
                    2::second => now;   
                }
            }
            else if (state == 0) {
                if (brigidPorts.size() > 0 || homadosPorts.size() > 0){
                    // 80% of the time its normal
                    Math.random2(1,10) => int chance;
                    200 => int mint;
                    200 => int maxt;
                    12 => int minv;
                    17 => int maxv;
                    if (chance <  9){
                        productiveStateOne(brigidPorts, homadosPorts, Math.random2(mint, maxt),
                        Math.random2(minv, maxv));
                    }
                    else if (chance == 9){
                        productiveStateTwo(brigidPorts, homadosPorts, Math.random2(mint, maxt),
                        Math.random2(minv, maxv));
                    }
                    else if (chance == 10){
                        productiveStateThree(brigidPorts, homadosPorts, Math.random2(mint, maxt),
                        Math.random2(minv, maxv));
                    }
                }
                else{
                    2::second => now;
                }
            }
        }
    }
    fun void productiveStateOne(int bPorts[], int hPorts[], int wait, int vel) {
        <<<wait, " - ", vel, " - Trigger ProductiveStateOne on bot : ", botNum>>>;
        for (int i; i < 48; i++){
            for (int b; b < bPorts.size(); b++){
                talk.talk.note(bPorts[b], i%6, vel + Math.random2(1,5));
            }
            for (int h; h < hPorts.size(); h++){
                talk.talk.note(hPorts[h], i%16, vel*2 + Math.random2(1,5));
            }
            wait::ms => now;
        }
    }
    
    
    fun void productiveStateTwo(int bPorts[], int hPorts[], int wait, int vel) {
        <<<wait, " - ", vel, " - Trigger ProductiveStateTwo on bot : ", botNum>>>;
        for (int i; i < 384; i++){
            for (int b; b < bPorts.size(); b++){
                talk.talk.note(bPorts[b], i%6, vel + Math.random2(1,5));
            }
            for (int h; h < hPorts.size(); h++){
                talk.talk.note(hPorts[h], i%16, vel*2 + Math.random2(1,5));
            }
            // 1/3 of the time it waits twice as long
            if (i%3 == 2){
                wait::ms => now;
            }
            wait::ms => now;
        }
    }
    
    fun void productiveStateThree(int bPorts[], int hPorts[], int wait, int vel) {
        <<<wait, " - ", vel, " - Trigger ProductiveStateThree on bot : ", botNum>>>;
        for (int i; i < 384; i++){
            for (int b; b < bPorts.size(); b++){
                talk.talk.note(bPorts[b], i%6, vel);
            }
            for (int h; h < hPorts.size(); h++){
                talk.talk.note(hPorts[h], i%16, vel*2);
            }
            // little funky
            if (i%5 < 3){
                wait::ms => now;
            }
            else{
                wait::ms => now;
            }
        }
    }
    
    fun void angryStateOne(int bPorts[], int hPorts[], int minWait, int maxWait) {
        <<<"Trigger angryStateOne on bot : ", botNum>>>;
        // turn on all solinoids at a random interval 16 times
        for (int z; z < 16; z++){
            // for brigid
            for (int i; i < 6; i++){
                for (int p; p < bPorts.size(); p++){
                    talk.talk.note(bPorts[p], i%6, 30 + Math.random2(0, 100));
                }  
            }
            // for homados
            for (int i; i < 16; i++){
                for (int p; p < hPorts.size(); p++){
                    talk.talk.note(hPorts[p], i%16, 30 + Math.random2(0, 100));
                }  
            }
            // wait a random amount of time, before repeating
            Math.random2(minWait, maxWait)::ms => now;
        }
    } 

    // theia listener
    fun void theiaListener(){
        5::second => now;
        <<<"Starting theia listener from personality">>>;
        while(true){
            100::ms => now;
            talk.talk.getTheiaDistance(theiaPorts[0]) @=> distances;
            determineState();
        }
    }

    fun void determineState() {
        // if distance 0 is less than 30 enter into mad, 
        // if distance less than 150 enter into silent
        // else stay productive
        if (distances[0] < 40){
            if (state != 2) {
                2 => state;
                <<<"determineState changed state to : ", state>>>;
            }
        } else if (distances[0] < 150){
            if (state != 1) {
                1 => state;
                <<<"determineState changed state to : ", state>>>;
            }
        } else{
            if (state != 0) {
                0 => state;
                <<<"determineState changed state to : ", state>>>;
            }
        }
    }
    
    // tells child class to only send theiaPorts gc messages
    // if it has successfully connected to a matching robot
    fun int IDCheck(int arduinoID, string address) {
        -1 => int check;
        for (int i; i < talk.talk.robotID.cap(); i++) {
            if (arduinoID == talk.talk.robotID[i]) {
                <<< address, "connected!", i >>>;
                i => check;
            }
        }
        if (check == -1) {
            <<< address, "was unable to connect">>>;
        }
        return check;
    }
}
