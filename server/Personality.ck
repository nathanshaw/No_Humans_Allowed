// each of the three bots will be a Personality
public class  Personality
{
    OscOut out;

    ("localhost", 50000) => out.dest;

    0 => int numTheia;
    0 => int numBrigid;
    0 => int numHomados;
    0 => int numHermes;
    int ID;
    1500 => int rate;
    // 0 is angry
    // 1 is quiet
    // 2 is productive
    2 => int state;
    Theia theias;
    Homados homados;
    Hermes hermes;
    Brigid brigids;

    fun void frontSolenoids(int note, int vel, int light){
        out.start("/brigid");
        out.add(1);// board num
        out.add(note);// note num
        out.add(vel);// velocity
        out.send();

        if (light) {
            out.start("/brigid");
            out.add(2);
            out.add(note);
            out.add(vel);
            out.send();
        }
    }

    fun void backSolenoids(int note, int vel, int light){

        out.start("/brigid");
        out.add(3);// board num
        out.add(note);// note num
        out.add(vel);// velocity
        out.send();

        if (light) {
            out.start("/brigid");
            out.add(4);
            out.add(note);
            out.add(vel);
            out.send();
        }
    }

    fun void rotarySolenoids(int note, int vel, int light){

        out.start("/brigid");
        out.add(5);// board num
        out.add(note);// note num
        out.add(vel);// velocity
        out.send();

        if (light) {
            out.start("/brigid");
            out.add(6);
            out.add(note);
            out.add(vel);
            out.send();
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
        for (int i; i < theias.cap(); i++) {
            (ID * 100) + 40 + i => int tempID;
            <<<Std.itoa(tempID)>>>;
            Std.itoa(tempID) => string tempIDString;
            theias[i].setID(tempID, tempIDString);
        }
    }

    fun void setBrigids(int num) {
        Brigid brigids[num];
        for (int i; i < brigids.cap(); i++) {
            (ID*100) + 10 + i => int tempID;
            <<<"Brigid temp ID : ", tempID>>>;
            <<<Std.itoa(tempID)>>>;
            Std.itoa(tempID) => string tempIDString;
            brigids[i].setID(tempID, tempIDString);
        }
    }

    fun void setHomados(int num) {
        Homados homados[num];
    }

    fun void setHermes(int num) {
        Hermes hermes[num];
    }

    fun void setState(int num) {
        num => state;
    }

    fun void angry(int rate) {
        for (int i; i < 16; i++) {
            frontSolenoids(Math.random2(0,6), 200, 1);
            backSolenoids(Math.random2(0,6), 200, 1);
            rotarySolenoids(Math.random2(0,6), 200, 1);
            Math.random2f(5, (rate/16))::ms => now;
            // <<<ID, " is angry">>>;
        }
    }

    fun void quiet (int rate) {
        rate::ms => now;
        // <<<ID, " is quiet">>>;
    }

    fun void productive (int rate) {
        // <<<ID, " is productive">>>;
        for (int i; i < 16; i++) {
            frontSolenoids(i%6, 200, 1);
            backSolenoids(i%6, 200, 1);
            rotarySolenoids(i%6, 200, 1);
            (rate/16)::ms => now;
        }
    }

    fun void init(int id) {
        id => ID;
        <<<"Personality initalized with ID of : ", ID>>>;
        while (true) {
            if (state == 0) {
                angry(rate);
            }
            else if (state == 1) {
                quiet(rate);
            }
            else if (state == 2) {
                productive(rate);
            }
        }
    }
}
