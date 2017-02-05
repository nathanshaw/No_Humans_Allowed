# No_Humans_Allowed
Repo for housing the No Humans Allowed Installation
------------

Arduino ID's
------------
The Arduino ID's consist of three bytes
The first byte corresponds with the Bot it is associated with
    1   : MainBot
    2-3 : Secondary Bots
    4-6 : Motor Mobile
    7-9 : Eye Bots
The second byte corresponds with the Type of Shield it is
    1   : Brigid
    2   : Homados
    3   : Hermes
    4   : Theia
The last byte corresponds with the board number (if it is the third brigid this will be 3)

For example the Brigid boards on the second secondary bot will have the following ID's :
311, 312, 313, 314


Bots
----
3x stationary bots
3x mobile bots

1x Main Bot
-----------
4x ultrasonics,
3x banks of 6 solinoids
3x banks of 6 LED strips

2x Secondary Bots
---------------------------
4x ultrasonics
2x banks of 6 solinoids
2x banks of 6 LED Strips
1x bank of 16 solinoids
1x bank of 16 LED Strips

3x Mobile Bots
--------------
1x bank of 6x DC motots

Interaction Rail
----------------
1 - All of the bots are in sync when no one is in the room, playing
  quietly

2 - If someone is detected by a bot, the bot will slow 
  down for the  first few feet, then it
  will stop until the person is within 4 feet, at which point the 
  bot will start to arhythmically trigger all of its solinoids at
  once to try and scare the person away.

3 - Once noone is detected again the bot will return 
  to normal operation

How to Operate
---------------
1. All of the USB hubs have to be turned on for each bot
2. Run serial-robot-server/master.ck
3. Run midi-robot-server/master.ck
4. Run no-humans-allowed/master
