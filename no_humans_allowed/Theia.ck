public class Theia
{
    4 => int sensors;
    // loads into array to set a default reading when initalized
    150 => int defaultReading;
    // how many past states to keep a hold of
    8 => int memorySize;
    // array to hold sensor values
    int readings[0];
    memorySize => readings.size;
    
    fun int weightedAverage() {
        // return weighted average 
    }
    fun int onePole() {
        // return single pole lowpass
    }
    
}
