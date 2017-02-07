// Theia.ck
// Nathan Villicana-Shaw

public class Theia extends SensorBot{
    8 => int sensorMemory;
    4 => int activeSensors;

    int pastSensorReadings[activeSensors][sensorMemory];
    int smoothedReadings[activeSensors];

    100 => int pollingRate;

    int ID;

    fun void setID(int id, string stringID) {
        id => ID;
        "/theia/" + stringID => string address;
        IDCheck(ID, address) => int check;
        // if a message comes in to the bot, return the distances
        int distance;
        if (check >= 0) {
            // spork ~ oscrecv(check, address);
            spork ~ pollUltrasonics();
        }
    }

    fun void pollUltrasonics() {
        while(true) {
            for (int i; i < activeSensors; i++){
                //spork ~ getTheiaDistance(ID, i);
                pollingRate::ms => now;
            }
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
}
