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
