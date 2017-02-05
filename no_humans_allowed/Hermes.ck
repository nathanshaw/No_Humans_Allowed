// Hermes1.ck
// Nathan Villicana-Shaw
// CalArts Music Tech // MTIID4LIFE

public class Hermes extends SerialBot {
    // MIDI notes
    [60,61,62,63,64,65] @=> int scl[];

    rescale(scl);

    int ID;
    fun void setID(int id, string idString){
    id => ID;
    "/hermes/" + idString => string address;
    IDCheck(ID, address) => int check;
    if (check >= 0) {
        spork ~ oscrecv(check, address);
    }
    }
}
