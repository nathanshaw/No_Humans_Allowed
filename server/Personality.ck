// SerialBot.ck
// Eric Heep
// CalArts Music Tech // MTIID4LIFE

public class Personality{
    
    HandshakeID talk;
    
    OscIn oin;
    OscMsg msg;
    int myPorts[];
    
    // new port number
    50002 => oin.port;
    oin.listenAll();
    
    // for optional rescaling
    int scale[64];
    int actuators[64];
    int botNum;
    int state;
    string address;

    scale.cap() => int scaleCap;
    for (int i; i < scale.cap(); i++) {
        i => scale[i];
        i => actuators[i];
    }
    
    fun void init(int aBotNum, string addr, int ports[]){
        aBotNum => botNum;
        addr => address;
        while(true) {
            if (state == 0) {
                if (ports.cap() > 0){
                    angryStateOne(ports[Math.random2(0, ports.cap()-1)]);
                }
            }
        }
    }

    fun void angryStateOne(int port) {
        <<<"Trigger StateOne on bot : ", botNum, " ", port>>>;
        talk.talk.note(port, Math.random2(0, 5), 100);
        500::ms => now;
    }

    // reassigns incoming MIDI notes to their proper robot note
    fun void rescale(int newScale[]) {
        newScale.cap() => scaleCap;
        for (int i; i < newScale.cap(); i++) {
            newScale[i] => scale[i];
        }
    }
    
    // reassigns incoming MIDI notes to their proper robot note
    // overloaded in case you need to specify an order (ie 1,2,3,5) 
    fun void rescale(int newScale[], int order[]) {
        order @=> actuators;
        newScale.cap() => scaleCap;
        for (int i; i < newScale.cap(); i++) {
            newScale[i] => scale[i];
        }
    }
    
    // note reassignment, also checks if message is a valid note
    fun int renote(int oldNote) {
        int pass, newNote;
        for (int i; i < scaleCap; i++) {
            if (oldNote == scale[i]) {
                actuators[i] => newNote;
                1 => pass;
            }
        }
        if (pass != 1) {
            -1 => newNote;
        }
        return newNote;
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
                    renote(msg.getInt(0)) => int note;
                    //<<<"requesting sensor data : ", address, " ", 
                    //    note, " ", msg.getInt(1)>>>;
                    int data;
                    if (note >= 0) {
                        // talk.talk.getTheiaState(port, note, 
                        //                        msg.getInt(1), address) => data;
                        <<<"Asking theia for state">>>;
                    }
                    else {
                        <<< msg.getInt(0), "is not an accepted note number for", address, "" >>>;
                    }
                }
            }
        }
        }
}
