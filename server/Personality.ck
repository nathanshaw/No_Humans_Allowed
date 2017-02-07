// each of the three bots will be a Personality
public class  Personality
{
    0 => int numTheia;
    0 => int numBrigid;
    0 => int numHomados;
    0 => int numHermes;
    Theia theias;
    Homados homados;
    Hermes hermes;
    Brigid brigids;

    // listener for receiving sensor information
    fun void theiaListener() {
        // runs forever listening to the responces from the theia's
        while(true) {
            // listen to oin port
            oin => now;
            while(oin.recv(msg)) {
                msg.address => string address;
                msg.getInt(0) => int sensorNum;
                msg.getInt(1) => int distance;
                // theia1 is for bot 1 (the first bot)
                //<<<"received OSC message : ", address, " ", sensorNum, " ", distance>>>;
                if (address == "/theia"){
                    // first argument is the bot num
                    // second argument is the sensorNum
                    // third argument is the distance

                    // immedietly send the data over to processing for analysis
                    // process the message
                    newReading(1, sensorNum, distance);
                    getSmoothedDistance(1, sensorNum) => int smoothedDistance => b1smoothedStates[sensorNum]; 
                    //<<<"smoothed distance : ", smoothedDistance>>>;
                    pOut.start("/theia1");
                    pOut.add(sensorNum);
                    pOut.add(smoothedDistance);
                    pOut.send();
                    // cycle through the four ultrasonic slowStates and change the overall state
                    if (smoothedDistance >= highMidThresh && bot1State[sensorNum] != 0) {
                        0 => bot1State[sensorNum];
                        //<<<"bot1 sensor ", sensorNum, " state changed to : ", bot1State[0]>>>;
                    }
                    else if (smoothedDistance >= highCloseThresh && smoothedDistance < lowMidThresh &&
                    bot1State[sensorNum] != 1) {
                        1 => bot1State[sensorNum];
                        //<<<"bot1 sensor ", sensorNum, " state changed to : ", bot1State[sensorNum]>>>;
                    } 
                    else if (bot1State[sensorNum] != 2 && smoothedDistance < lowCloseThresh) {
                        2 => bot1State[sensorNum];
                        //<<<"bot1 sensor ", sensorNum, " state changed to : ", bot1State[sensorNum]>>>;
                    }
                }
            }
        }
    }
    fun void setBoards(int t, int hom, int b, int her) {
        Theia theia[t];
        Homados homados[hom];
        Brigid brigid[b];
        Hermes hermes[her];
    }

    fun void setTheias(int num) {
        Theia theias[num];
    }
    fun void setBrigids(int num) {
        Brigid brigids[num];
    }
    fun void setHomados(int num) {
        Homados homados[num];
    }
    fun void setHermes(int num) {
        Hermes hermes[num];
    }


}
