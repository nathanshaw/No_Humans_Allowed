public class Personality{
    
    HandshakeID talk;
    
    OscIn oin;
    OscMsg msg;
    int myPorts[];
    
    // new port number
    50002 => oin.port;
    oin.listenAll();
    
    // for optional rescaling
    int botNum;
    int state;
    string address;

    fun void init(int aBotNum, string addr, int ports[]){
        aBotNum => botNum;
        addr => address;
        while(true) {
            if (state == 1) {
                if (ports.cap() > 0){
                    angryStateOne(ports);
                    // 0 => state;
                }
            }
            if (state == 0) {
                if (ports.cap() > 0){
                    Math.random2(0,3) => int chance;
                    50 => int mint;
                    200 => int maxt;
                    609 => int minv;
                    900 => int maxv;
                    if (chance <  2){
                        productiveStateOne(ports, Math.random2(mint, maxt),
                        Math.random2(minv, maxv));
                    }
                    else if (chance == 2){
                        productiveStateTwo(ports, Math.random2(mint, maxt),
                        Math.random2(minv, maxv));
                    }
                    else if (chance == 3){
                        productiveStateThree(ports, Math.random2(mint, maxt),
                        Math.random2(minv, maxv));
                    }
                }
            }
        }
    }

    fun void productiveStateOne(int ports[], int wait, int vel) {
         <<<wait, " - ", vel, " - Trigger ProductiveStateOne on bot : ", botNum, " ", ports[0], ports[1], ports[2],
        ports[3], ports[4], ports[5], ports[6]>>>;
        for (int i; i < 48; i++){
            // front led strip
            // should be front small solenoids
            talk.talk.note(ports[0], i%6, vel);
            talk.talk.note(ports[1], i%6, vel);
            talk.talk.note(ports[2], i%6, (vel*0.8) $ int);
            talk.talk.note(ports[3], i%6, vel);
            talk.talk.note(ports[4], i%16, (vel*0.8) $ int);
            talk.talk.note(ports[5], i%16, vel);
            wait::ms => now;
        }
    }
    

    fun void productiveStateTwo(int ports[], int wait, int vel) {
         <<<wait, " - ", vel, " - Trigger ProductiveStateTwo on bot : ", botNum, " ", ports[0], ports[1], ports[2],
        ports[3], ports[4], ports[5], ports[6]>>>;
        for (int i; i < 48; i++){
            // front led strip
            // should be front small solenoids
            talk.talk.note(ports[0], i%6, vel);
            talk.talk.note(ports[1], i%6, vel);
            talk.talk.note(ports[2], i%6, (vel*0.8) $ int);
            talk.talk.note(ports[3], i%6, vel);
            talk.talk.note(ports[4], i%16, (vel*0.8) $ int);
            talk.talk.note(ports[5], i%16, vel);
            if (i%2 == 1){
                wait::ms => now;
            }
            wait::ms => now;
        }
    }

    fun void productiveStateThree(int ports[], int wait, int vel) {
         <<<wait, " - ", vel, " - Trigger ProductiveStateThree on bot : ", botNum, " ", ports[0], ports[1], ports[2],
        ports[3], ports[4], ports[5], ports[6]>>>;
        for (int i; i < 48; i++){
            // front led strip
            // should be front small solenoids
            talk.talk.note(ports[0], i%6, vel);
            talk.talk.note(ports[1], i%6, vel);
            talk.talk.note(ports[2], i%6, (vel*0.8) $ int);
            talk.talk.note(ports[3], i%6, vel);
            talk.talk.note(ports[4], i%16, (vel*0.8) $ int);
            talk.talk.note(ports[5], i%16, vel);
            if (i%5 < 3){
                (wait/2)::ms => now;
            }
            else{
                (wait*2)::ms => now;
            }
        }
    }
    fun void angryStateOne(int ports[]) {
         <<<"Trigger StateOne on bot : ", botNum, " ", ports[0], ports[1], ports[2],
        ports[3], ports[4], ports[5], ports[6]>>>;
        for (int i; i < 48; i++){
            // front led strip
            // should be front small solenoids
            talk.talk.note(ports[0], i%6, 100);
            //
            // should be front leds
            // talk.talk.note(ports[1], i%6, 100);
            // front led strip?
            // talk.talk.note(ports[2], i%6, 100);
            // front led strip? and fron solenoids
            // talk.talk.note(ports[3], i%6, 100);
            // front led strip?
            // talk.talk.note(ports[4], i%6, 100);
            // large back solenoids
            // talk.talk.note(ports[5], i%6, 100);
            // large back solenoids
            //talk.talk.note(ports[6], i%6, 100);
            100::ms => now;
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
