// main.ck
// CalArts Music Tech // MTIID4LIFE

// give it some time to breathe
HandshakeID talk;
0.5::second => now;

// initial handshake between ChucK and Arduinos
talk.talk.init();
1::second => now;

<<< "Handshakes done" >>>;
// bring on the bots
Personality bots[3];

// MainBot - Craig
bots[0].setTheias(1);
bots[0].setBrigids(6);

// Secondary Bot
bots[1].setTheias(1);
bots[1].setBrigids(4);
bots[1].setHomados(2);

// Trinary Bot
bots[2].setTheias(1);
bots[2].setBrigids(4);
bots[2].setHomados(2);

while (true) {
    1::second => now;
}
