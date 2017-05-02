public class Personality{
    
    HandshakeID talk;
    
    OscIn oin;
    OscMsg msg;
    int brigidPorts[0];
    int homadosPorts[0];
    int theiaPorts[0];
    int bLightPorts[0];
    int hLightPorts[0];
    [12, 12, 12, 12, 12, 12, 12] @=> int homadosSizes[];
    [12, 12, 12, 12, 12, 12, 12] @=> int homadosLightSizes[];

    //FIFO stuff
    int FIFO_index;
    10 => int FIFO_length;
    
    // ultrasonic rangefinders distances
    int distances[4];
    [255.0, 255.0, 255.0, 255.0] @=> float smoothed_distances[];
    int past_distances[4][FIFO_length];
    for (int i; i < 4; i++){
        for (int t; t < FIFO_length; t++){
            255 => past_distances[i][t];
        }
    }
    
    // new port number
    50002 => oin.port;
    oin.listenAll();
    
    // for optional rescaling
    int botNum;
    0 => int state;
    string address;
    

    fun void init(int aBotNum, string addr, 
                  int bPorts[], int hPorts[],
                  int tPorts[], int bLPorts[], int hLPorts[]){
        aBotNum => botNum;
        if (botNum == 1){
            12 => homadosSizes[0];
            12 => homadosLightSizes[0];
        }
        else {
            16 => homadosSizes[0];
            16 => homadosSizes[1];
            16 => homadosLightSizes[0];
            16 => homadosLightSizes[1];
        }
        // dynamically set up the bot
        <<<"Initializing personality", botNum>>>;
        
        for (int i; i < bLPorts.size(); i++){
            // <<<"port contents : ", bPorts[i]>>>;//, "-", hPorts[i], "-", tPorts[i]>>>;
            if (bLPorts[i] >= 0){
                bLightPorts << bLPorts[i];
            }
        }
        for (int i; i < hLPorts.size(); i++){
            // <<<"port contents : ", bPorts[i]>>>;//, "-", hPorts[i], "-", tPorts[i]>>>;
            if (hLPorts[i] >= 0){
                hLightPorts << hLPorts[i];
            }
        }
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
                // spork ~ theiaListener();
            }
        }
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
                    if (Math.random2(0, 100) < 70){
                        angryStateOne(50, 2750);
                    }else {
                        angryStateTwo(50, 2750);
                    }
                }
                else{
                    2::second => now;   
                }
            }
            else if (state == 0) {
                if (brigidPorts.size() > 0 || homadosPorts.size() > 0){
                    // 80% of the time its normal
                    Math.random2(1,10) => int chance;
                    100 => int mint;
                    100 => int maxt;
                    12 => int minv;
                    17 => int maxv;
                    Math.random2(1,2) => int scaler;
                    Math.random2(1,2) * scaler => scaler;
                    if (chance <  9){
                        productiveStateOne(Math.random2(mint*scaler, maxt*scaler),
                        Math.random2(minv, maxv));
                    }
                    else if (chance == 9){
                        productiveStateTwo(Math.random2(mint*scaler, maxt*scaler),
                        Math.random2(minv, maxv));
                    }
                    else if (chance == 10){
                        productiveStateThree(Math.random2(mint*scaler, maxt*scaler),
                        Math.random2(minv, maxv));
                    }
                }
                else{
                    2::second => now;
                }
            }
        }
    }
    fun void productiveStateOne(int wait, int vel) {
        <<<wait, " - ", vel, " - Trigger ProductiveStateOne on bot : ", botNum, " w:",
        wait,
        " v: ", vel>>>;
        for (int i; i < 48; i++){
            // check state to break out of loop when needed
            if (state == 0){
                for (int b; b < brigidPorts.size(); b++){
                    talk.talk.note(brigidPorts[b], i%6, vel + Math.random2(1,5));
                }
                for (int h; h < homadosPorts.size(); h++){
                    talk.talk.note(homadosPorts[h], i%homadosSizes[h], vel*2 + Math.random2(1,5));
                }
                wait::ms => now;
            }
        }
    }
    
    
    fun void productiveStateTwo(int wait, int vel) {
        <<<wait, " - ", vel, " - Trigger ProductiveStateTwo on bot : ", botNum, " w:",
        wait,
        " v: ", vel>>>;
        for (int i; i < 384; i++){
            if (state == 0){
                for (int b; b < brigidPorts.size(); b++){
                    talk.talk.note(brigidPorts[b], i%6, vel + Math.random2(1,5));
                }
                for (int h; h < homadosPorts.size(); h++){
                    talk.talk.note(homadosPorts[h], i%homadosSizes[h], vel*2 + Math.random2(1,5));
                }
                // 1/3 of the time it waits twice as long
                if (i%3 == 2){
                    wait::ms => now;
                }
                wait::ms => now;
            }
        }
    }
    
    fun void productiveStateThree(int wait, int vel) {
        <<<wait, " - ", vel, " - Trigger ProductiveStateThree on bot : ", botNum, " w:",
        wait,
        " v: ", vel>>>;
        for (int i; i < 384; i++){
            if (state == 0){
                for (int b; b < brigidPorts.size(); b++){
                    talk.talk.note(brigidPorts[b], i%6, vel);
                }
                for (int h; h < homadosPorts.size(); h++){
                    talk.talk.note(homadosPorts[h], i%homadosSizes[h], vel*2);
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
    }
    
    fun void angryStateOne(int minWait, int maxWait) {
        <<<"Trigger angryStateOne on bot : ", botNum>>>;
        // turn on all solinoids at a random interval 16 times
        for (int z; z < 16; z++){
            if (state == 2){
                // for brigid
                // <<<"length of brigidPorts : ", brigidPorts.size()>>>;
                for (int i; i < 6; i++){
                    for (int p; p < brigidPorts.size(); p++){
                        talk.talk.note(brigidPorts[p], i%6, 30 + Math.random2(0, 100));
                        Math.random2(0, 5)::ms => now;
                    }  
                    for (int p; p < bLightPorts.size(); p++){
                        talk.talk.note(bLightPorts[p], i%6, 30 + Math.random2(0, 100));
                        Math.random2(0, 5)::ms => now;
                    }
                }
                // for homados
                for (int i; i < 48; i++){
                    for (int p; p < homadosPorts.size(); p++){
                        talk.talk.note(homadosPorts[p], i%homadosSizes[p], 30 + Math.random2(0, 100));
                        Math.random2(0, 5)::ms => now;
                    }  
                    for (int p; p < hLightPorts.size(); p++){
                        talk.talk.note(hLightPorts[p], i%homadosLightSizes[p], 30 + Math.random2(0, 100));
                        Math.random2(0, 5)::ms => now;
                    }  
                }
                // wait a random amount of time, before repeating
                Math.random2(minWait, maxWait)::ms => now;
            }
        }
        <<<"exiting angry state one">>>;
    } 
    fun void angryStateTwo(int minWait, int maxWait) {
        <<<"Trigger angryStateTwo on bot : ", botNum>>>;
        // turn on all solinoids at a random interval 16 times
        for (int z; z < 16; z++){
            if (state == 2){
                // for brigid
                for (int i; i < 6; i++){
                    for (int p; p < brigidPorts.size(); p++){
                        talk.talk.note(brigidPorts[p], i%6, 30 + Math.random2(0, 100));
                        Math.random2f(0, 1)::ms => now;
                    }  
                    for (int p; p < bLightPorts.size(); p++){
                        talk.talk.note(bLightPorts[p], i%6, 30 + Math.random2(0, 100));
                        Math.random2f(0, 1)::ms => now;
                    }
                }
                // for homados
                for (int i; i < 48; i++){
                    for (int p; p < homadosPorts.size(); p++){
                        talk.talk.note(homadosPorts[p], i%homadosSizes[p], 30 + Math.random2(0, 100));
                        Math.random2f(0, 1)::ms => now;
                    }  
                    for (int p; p < hLightPorts.size(); p++){
                        talk.talk.note(hLightPorts[p], i%homadosLightSizes[p], 30 + Math.random2(0, 100));
                        Math.random2f(0, 1)::ms => now;
                    }  
                }
                // wait a random amount of time, before repeating
                (Math.random2f(minWait, maxWait)*0.3)::ms => now;
            }
        }
        <<<"exiting angry state two">>>;
    } 

    // theia listener
    fun void theiaListener(){
        5::second => now;
        <<<"Starting theia listener from personality">>>;
        while(true){
            100::ms => now;
            talk.talk.getTheiaDistance(theiaPorts[0]) @=> distances;
            pastDistancesFIFO();
            smoothDistances();
        }
    }

    fun void pollTheia(){
        talk.talk.getTheiaDistance(theiaPorts[0]) @=> distances;
        pastDistancesFIFO();
        smoothDistances();
    }

    fun int[] pastDistancesFIFO(){
        FIFO_index++;
        if (FIFO_index > (FIFO_length - 1)) {
            0 => FIFO_index;
        }
        for (int i; i < 4; i++){
            distances[i] => past_distances[i][FIFO_index];
        }
    }

    fun void smoothDistances() {
        for (int i; i < 4; i++){
            float total;
            for (int t; t < FIFO_length; t++){
                past_distances[i][t] + total => total;
            }
            total/10 => smoothed_distances[i];
        }
    }

    fun void setState(int _state) {
        _state => state;
    }

    fun void determineState() {
        // if distance 0 is less than 30 enter into mad, 
        // if distance less than 150 enter into silent
        // else stay productive
        if (botNum < 4) {
            <<<botNum, " smoothed distances : ", smoothed_distances[0], "-",
                smoothed_distances[1], "-",
                smoothed_distances[2], "-", smoothed_distances[3]>>>;
        }
        if (smoothed_distances[0] < 45){
            if (state != 2) {
                2 => state;
                <<<1, " determineState changed state to : ", state>>>;
            }
        } else if (smoothed_distances[0] < 390){
            if (state != 1) {
                1 => state;
                <<<1, " determineState changed state to : ", state>>>;
            }
        } else{
            if (state != 0) {
                0 => state;
                <<< 1, " determineState changed state to : ", state>>>;
            }
        }
        if (smoothed_distances[1] < 10){
            if (state != 2) {
                2 => state;
                <<<1, " determineState changed state to : ", state>>>;
            }
        }
        else if (smoothed_distances[2] < 10){
            if (state != 2) {
                2 => state;
                <<<2, " determineState changed state to : ", state>>>;
            }
        }
        else if (smoothed_distances[3] < 10){
            if (state != 2) {
                2 => state;
                <<<3, " determineState changed state to : ", state>>>;
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
