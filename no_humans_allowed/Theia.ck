// Theia.ck
// Nathan Villicana-Shaw

public class Theia extends SensorBot{
    8 => int sensorMemory;
    int pastSensorReadings[4][sensorMemory];
    int smoothedReadings[4];

    int ID;

    fun void setID(int id, string stringID) {
        id => ID;
        "/theia/" + stringID => string address;
        IDCheck(ID, address) => int check;
        // if a message comes in to the bot, return the distances
        int distance;
        if (check >= 0) {
            spork ~ oscrecv(check, address);
        }
    }

    fun void smoothReadings() {
        for (int i; i < smoothReadings.size(); i++) {
            smoothReadings[i] = pastSensorReadings[i][0];
        }
    }

    fun void newReading(int sensorNum, int reading) {
        for (int i; i < pastSensorReadings[sensorNum].size(); i++){
            <<<"DUMMY CODE?">>>;
        }
    }
}
