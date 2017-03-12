public class Personality{
    
    HandshakeID talk;
    
    OscIn oin;
    OscMsg msg;
    int brigidPorts[];
    int homadosPorts[];
    int theiaPorts[];
    
    // new port number
    50002 => oin.port;
    oin.listenAll();
    
    // for optional rescaling
    int botNum;
    int state;
    string address;
    
    fun void init(int aBotNum, string addr, 
    int bPorts[]. int hPorts[],
    int tPorts[]){
        bPorts => brigidPorts;
        tPorts => theiaPorts;
        hPorts => homadosPorts;
        aBotNum => botNum;
        addr => address;
        while(true) {
            if (state == 2) {
                // resting state
                2::second => now;
            }
            else if (state == 1) {
                angryStateOne(brigidPorts, homadosPorts);
            }
            else if (state == 0) {
                if (ports.cap() > 0){
                    // 80% of the time its normal
                    Math.random2(1,10) => int chance;
                    5 => int mint;
                    20 => int maxt;
                    60 => int minv;
                    300 => int maxv;
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
            }
        }
    }
    
    fun void productiveStateOne(int bPorts[], int hPorts, int wait, int vel) {
        <<<wait, " - ", vel, " - Trigger ProductiveStateOne on bot : ", botNum>>>;
        for (int i; i < 48; i++){
            for (int b; b < bPorts.size(); b++){
                talk.talk.note(ports[b], i%6, vel + Math.random2(1,5));
            }
            for (int h; h < hPorts.size(); h++){
                talk.talk.note(ports[h], i%16, vel + Math.random2(1,5));
            }
            wait::ms => now;
        }
    }
    
    
    fun void productiveStateTwo(int bPorts[], int hPorts, int wait, int vel) {
        <<<wait, " - ", vel, " - Trigger ProductiveStateTwo on bot : ", botNum>>>;
        for (int i; i < 48; i++){
            for (int b; b < bPorts.size(); b++){
                talk.talk.note(ports[b], i%6, vel + Math.random2(1,5));
            }
            for (int h; h < hPorts.size(); h++){
                talk.talk.note(ports[h], i%16, vel + Math.random2(1,5));
            }
            // 1/3 of the time it waits twice as long
            if (i%3 == 2){
                wait::ms => now;
            }
            wait::ms => now;
        }
    }
    
    fun void productiveStateThree(int bPorts[], int hPorts, int wait, int vel) {
        <<<wait, " - ", vel, " - Trigger ProductiveStateThree on bot : ", botNum>>>;
        for (int i; i < 48; i++){
            for (int b; b < bPorts.size(); b++){
                talk.talk.note(ports[b], i%6, vel);
            }
            for (int h; h < hPorts.size(); h++){
                talk.talk.note(ports[h], i%16, vel);
            }
            // little funky
            if (i%5 < 3){
                wait*0.5::ms => now;
            }
            else{
                wait::ms => now;
            }
        }
    }
    
    fun void angryStateOne(int bPorts[], int hPorts, int minWait, int maxWait) {
        <<<"Trigger angryStateOne on bot : ", botNum>>>;
        // turn on all solinoids at a random interval 16 times
        for (int z; z < 16; z++){
            for (int i; i < 6; i++){
                for (int p; p < bPorts.size(); p++){
                    talk.talk.note(bPorts[p], i%6, 200 + Math.random2(0, 100));
                }  
            }
            for (int i; i < 6; i++){
                for (int p; p < bPorts.size(); p++){
                    talk.talk.note(hPorts[p], i%16, 200 + Math.random2(0, 100));
                }  
            }
            // wait a random amount of time, before repeating
            Math.random2(minWait, maxWait)::ms => now;
        }
    } 
    
    // tells child class to only send serial messages
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
    
    // receives OSC and sends out serial
    fun void oscrecv(int port, string address) {
        <<<"-- Creating osc receiver at port : ", port, " and address : ", address>>>;
        while(true) {
            oin => now;
            while (oin.recv(msg)) {
                if (msg.address == address) {
                    <<<"Incomming message : ", msg.address, msg.getInt(0), msg.getInt(1)>>>;
                    // renote(msg.getInt(0)) => int note;
                    //<<<"requesting sensor data : ", address, " ", 
                    //    note, " ", msg.getInt(1)>>>;
                    // int data;
                    // if (note >= 0) {
                    // talk.talk.getTheiaState(port, note, 
                    //                        msg.getInt(1), address) => data;
                    // <<<"Asking theia for state">>>;
                    // }
                    //else {
                    //    <<< msg.getInt(0), "is not an accepted note number for", address, "" >>>;
                    //}
                }
            }
        }
    }
}
