# No_Humans_Allowed
Repo for housing the No Humans Allowed Installation
------------

3 stationary bots

1x Main Bot
-----------
4 ultrasonics,
3x banks of 6 solinoids
1x bank of 4x stepper motors

2x Secondary Bots
---------------------------
2 ultrasonics
2x banks of 6 solinoids
1x bank of 16 solinoids

3x Mobile Bots
--------------
1x bank of 6x DC motots

Divine Council Server (controlling bots)
----------------------------------------
10x Brigid
 2x Hermes
 2x Homados

Sensor Server
-------------
3x Theia (ultrasonics)

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
