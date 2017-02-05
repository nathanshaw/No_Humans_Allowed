// Brigid.ck
// Nathan Villicana-Shaw
// CalArts Music Tech // MTIID4LIFE

public class Brigid extends SerialBot {
    // Brigid is 1-40
    // Homados is 41-60
    // Theia is 61-80

    // MIDI notes
    [60,61,62,63,64,65] @=> int scl[];

    rescale(scl);

    fun void setID(int id, string idString) {
        id => int ID;
        "/brigid/" + idString => string address;
        <<<"Brigid created with address of : ", address>>>;
        IDCheck(ID, address) => int check;
        if (check >= 0) {
            spork ~ oscrecv(check, address);
        }
    }
}
