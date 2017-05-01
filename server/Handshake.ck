// Handshake.ck
// Nathan Villicana-Shaw based off code written by Eric Heep
// communicates with the Arduinos, pairs them up with the ports
// Spring 2017

public class Handshake { 
    // for sending sensor data to clients
    OscOut out;
    OscMsg msg;
    int theiaBots[3];
    ("localhost", 50003) => out.dest;
    
    SerialIO.list() @=> string list[];
    int serial_port[list.cap()];
    
    // calls num_ports() to find how many USB ports are available
    SerialIO serial[num_ports()];
    int robotID[serial.cap()];

    fun int returnNumRobotID() {
        return robotID.cap();
    }
    
    fun int returnRobotID(int index) {
        return robotID[index];
    }

    fun void init() { 
        for (int i; i < robotID.cap(); i++) {
            i => robotID[i];
        }
        open_ports();
        handshake();
    } 
    
    // returns the proper robot ID to the child class
    fun int port(int ID) {
        return serial_port[robotID[ID]];
    }
    
    // returns how many usb serial connections are available
    fun int num_ports() {
        int num;
        <<< "-", "" >>>;
        for (int i; i < serial_port.cap(); i++) {
            if (list[i].find("usb") > 0) {
                i => serial_port[num];
                num++;
            }
        }
        <<< "Found", num, "available USB ports:", "" >>>;
        return num;
    }
    
    // opens only how many serial ports there are usb ports connected
    fun void open_ports() {
        for (int i; i < serial.cap(); i++) {
            if (!serial[i].open(serial_port[i], SerialIO.B57600, SerialIO.BINARY)) {
                <<< "Unable to open serial device:", "\t", list[serial_port[i]] >>>;
            }
            else {
                <<< list[serial_port[i]], 
                    "assigned to port", 
                    serial_port[i], "" >>>;
            }
        }
        <<< "-", "" >>>;
        2.5::second => now;
    }
    
    // pings the Arduinos and returns their 'arduinoID'
    fun void handshake() {
        <<<"Starting Handshake">>>;
        [255, 255, 255] @=> int ping[];
        for (int i ; i < serial.cap(); i++) {
            <<<"Looking at serial port : ", i>>>;
            serial[i].writeBytes(ping);
            serial[i].onByte() => now;
            serial[i].getByte() => int botID;
            // <<<"bot id : ", botID>>>;
            serial[i].onByte() => now;
            serial[i].getByte() => int botType;
            if ( botType == 4){
                <<<"found theia : botID : ", botID-1, " i - ", i>>>;
                i => theiaBots[botID-1];
            }
            // <<<"bot type : ", botType>>>;
            serial[i].onByte() => now;
            serial[i].getByte() => int arduinoID;
            // <<<"arduino ID :", arduinoID>>>;
            (botID*100) + (botType*10) + (arduinoID) => robotID[i];
            <<<"ROBOT ID : ", robotID[i]>>>;
            100::ms => now;
            <<<"- - - - - - - - - - - - - - -">>>;
        }
    }

    fun int[] getTheiaDistance(int bot_id){
        [0xFF, 0x0A, 0x00] @=> int bytes[];
        bot_id => int id;
        serial[id].writeBytes(bytes);
        // <<<"writting bytes to serial : ", id>>>;
        serial[id].onByte() => now;
        int distances[4];
        if (serial[id].getByte() == 0xFF){
            // <<<"received a 0xFF">>>;
            serial[id].onByte() => now;
            serial[id].getByte() => distances[0];
            serial[id].onByte() => now;
            serial[id].getByte() => distances[1];
            serial[id].onByte() => now;
            serial[id].getByte() => distances[2];
            serial[id].onByte() => now;
            serial[id].getByte() => distances[3];
             // <<<id, "- Dist: ", distances[0], 
             //   distances[1], distances[2], distances[3]>>>;
        }
        else{
            <<<"FLUSHED BYTE : ", id>>>;
        }
        return distances;
    }

    // bitwise operations, allows note numbers 0-63 and note velocities 0-1023
    fun void note(int ID, int num, int vel) {
        // <<<"sending note : ", ID, " - ", num, " - ", vel>>>;
        int bytes[3];
        0xff => bytes[0];
        (num << 2) | (vel >> 8) => bytes[1]; 
        vel & 255 => bytes[2];
        serial[ID].writeBytes(bytes);
    }
}
