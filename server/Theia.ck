// Theia.ck
// Nathan Villicana-Shaw

public class Theia extends SensorBot{
    8 => int sensorMemory;
    4 => int activeSensors;

    int pastSensorReadings[activeSensors][sensorMemory];
    int smoothedReadings[activeSensors];

    int ID;

    <<<"Theia initialized with ID of :", ID>>>;
    fun void setID(int id, string stringID) {
        <<<"Set ID called for Theia : ", ID>>>;
        id => ID;
        "/theia/" + stringID => string address;
        IDCheck(ID, address) => int check;
        // if a message comes in to the bot, return the distances
        int distance;
        if (check >= 0) {
            // spork ~ oscrecv(check, address);
            spork ~ ultrasonicListener();
        }
        else{
            <<<"Theia check failed...">>>;
        }
    }

    fun void smoothReadings() {
        for (0 => int i; i < activeSensors; i++){
            pastSensorReadings[i][0] => smoothedReadings[i];
        }
    }

    fun void newReading(int sensorNum, int reading) {
        for (int i; i < pastSensorReadings[sensorNum].size(); i++){
            <<<"DUMMY CODE?">>>;
        }
    }

    fun void ultrasonicListener(){
        <<<"Starting Ultrasonic listener">>>;
        while(true){
            1000::ms => now;
            <<<"Listening baaaby!">>>;
        }
    }
}
