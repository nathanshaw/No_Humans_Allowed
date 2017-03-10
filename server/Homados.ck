// Homados.ck
// Nathan Villicana-Shaw
// CalArts Music Tech // MTIID4LIFE

public class Homados extends SerialBot {
    // MIDI notes
    //[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14] @=> int scl[];
    [60,61,62,63,64,65,66,67,68,69,70,71,72,73,74] @=> int scl[];

    rescale(scl);

    int ID;
    fun void setID(int id, string stringID) {
        id => ID;
        "/Homados/" + stringID => string address;
        IDCheck(ID, address) => int check;
        if (check >= 0) {
            spork ~ oscrecv(check, address);
        }
    }
}
