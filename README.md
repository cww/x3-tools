# Tools for X3: Albion Prelude

Well, there's only one tool right now, but it's a good one!

## trade_routes.rb

Based on your current sector, determines the nearest trade routes and the
potential viabilities thereof.

* Enter your trading ship's volume to compute the best possible route for
  your specific ship
* If you're not into trading posts, ignore them altogether
* Adjust the number of routes that are generated

The biggest limitation to this script is that it can't look inside your save
game file to check the price for each good at each station.  Therefore, the
script assumes ideal conditions, i.e. that you'll always buy at the lowest
possible price and sell at the highest possible price.  This is almost
never the case in the game, though.  Use this software only as a rough guide
and always trade wisely.

Sector names, when abbreviated, follow the abbreviations from the 2014-12-17
version of [this interactive map](http://x3ap.e0b.eu/).

### The database

Before you run this script, you must download the SQLite database that
contains all the trading data.  The database needs to reside at
`~/.x3.sqlite3`.

Database download: http://www.colinwetherbee.com/data/x3.sqlite3

SHA256 hash: http://www.colinwetherbee.com/data/x3.sqlite3.sha256

For more information about the database, see the .x3.sqlite section below.

### Synopsis

Output usage information:

```
$ ./trade_routes.rb -h
```

Generate the best trade routes originating from Argon Prime:

```
$ ./trade_routes.rb -s 'Argon Prime'
Starting from: Argon Prime
     8.2 (         Phased Repeater Gun)                Light Weapons Complex alpha ->       Argon Prime/                      Argon Equipment Dock (dist  0 pp [ 133130- 166038] vol 4)
     4.7 (         Phased Repeater Gun)                Light Weapons Complex alpha ->         Red Light/                      Argon Equipment Dock (dist  2 pp [ 133130- 166038] vol 4)
     4.7 (         Phased Repeater Gun)                       Argon Equipment Dock ->         Red Light/                      Argon Equipment Dock (dist  2 pp [ 133130- 166038] vol 4)
     4.1 (         Phased Repeater Gun)                Light Weapons Complex alpha -> Antigone Memorial/                      Argon Equipment Dock (dist  3 pp [ 133130- 166038] vol 4)
     4.1 (         Phased Repeater Gun)                       Argon Equipment Dock ->      Cloudbase SO/                      Argon Equipment Dock (dist  3 pp [ 133130- 166038] vol 4)
     4.1 (         Phased Repeater Gun)                Light Weapons Complex alpha ->      Cloudbase SO/                      Argon Equipment Dock (dist  3 pp [ 133130- 166038] vol 4)
     4.1 (         Phased Repeater Gun)                       Argon Equipment Dock -> Antigone Memorial/                      Argon Equipment Dock (dist  3 pp [ 133130- 166038] vol 4)
     2.9 ( Particle Accelerator Cannon)                Light Weapons Complex alpha ->       Argon Prime/                      Argon Equipment Dock (dist  0 pp [ 34671- 43241] vol 3)
     1.6 ( Particle Accelerator Cannon)                Light Weapons Complex alpha ->         Red Light/                      Argon Equipment Dock (dist  2 pp [ 34671- 43241] vol 3)
     1.6 ( Particle Accelerator Cannon)                       Argon Equipment Dock ->         Red Light/                      Argon Equipment Dock (dist  2 pp [ 34671- 43241] vol 3)
     1.4 ( Particle Accelerator Cannon)                       Argon Equipment Dock ->      Cloudbase SO/                      Argon Equipment Dock (dist  3 pp [ 34671- 43241] vol 3)
     1.4 ( Particle Accelerator Cannon)                Light Weapons Complex alpha ->      Three Worlds/                      Argon Equipment Dock (dist  3 pp [ 34671- 43241] vol 3)
     1.4 ( Particle Accelerator Cannon)                Light Weapons Complex alpha ->      Cloudbase SO/                      Argon Equipment Dock (dist  3 pp [ 34671- 43241] vol 3)
     1.4 ( Particle Accelerator Cannon)                       Argon Equipment Dock ->      Three Worlds/                      Argon Equipment Dock (dist  3 pp [ 34671- 43241] vol 3)
     0.9 (         Impulse Ray Emitter)                       Argon Equipment Dock ->         Red Light/                      Argon Equipment Dock (dist  2 pp [  3928-  5424] vol 1)
     0.8 (            Silkworm Missile) Production Complex Image Recognition alpha ->       Argon Prime/                      Argon Equipment Dock (dist  0 pp [  4295-  5809] vol 2)
     0.7 (         Impulse Ray Emitter)                       Argon Equipment Dock ->      Cloudbase SO/                      Argon Equipment Dock (dist  3 pp [  3928-  5424] vol 1)
     0.7 (         Impulse Ray Emitter)                       Argon Equipment Dock -> Antigone Memorial/                      Argon Equipment Dock (dist  3 pp [  3928-  5424] vol 1)
     0.7 (         Impulse Ray Emitter)                       Argon Equipment Dock ->      Three Worlds/                      Argon Equipment Dock (dist  3 pp [  3928-  5424] vol 1)
     0.6 (         Photon Pulse Cannon)                       Argon Equipment Dock ->         Red Light/                      Argon Equipment Dock (dist  2 pp [ 878810- 990998] vol 100)
```

Generate the best 8 trade routes originating from Cloudbase NW for a ship with a capacity of 75, and don't include trading posts:

```
$ ./trade_routes.rb -s "Cloudbase NW" -v 75 -n 8 -P
Starting from: Cloudbase NW
     0.6 (              Delexian Wheat)                         Wheat Farm M alpha ->   Herron's Nebula/             Space Fuel Distillery M alpha (dist  1 pp [    10-    54] vol 2)
     0.6 (              Delexian Wheat)                          Wheat Farm M beta ->   Herron's Nebula/                        Rimes Fact M alpha (dist  1 pp [    10-    54] vol 2)
     0.6 (              Delexian Wheat)                         Wheat Farm M alpha ->   Herron's Nebula/                        Rimes Fact M alpha (dist  1 pp [    10-    54] vol 2)
     0.6 (              Delexian Wheat)                         Wheat Farm M alpha ->      Three Worlds/                    Cahoona Bakery M Alpha (dist  1 pp [    10-    54] vol 2)
     0.6 (              Delexian Wheat)                          Wheat Farm M beta ->      Three Worlds/                    Cahoona Bakery M Alpha (dist  1 pp [    10-    54] vol 2)
     0.6 (              Delexian Wheat)                          Wheat Farm M beta ->   Herron's Nebula/                         Rimes Fact L beta (dist  1 pp [    10-    54] vol 2)
     0.6 (              Delexian Wheat)                         Wheat Farm M alpha ->   Herron's Nebula/                         Rimes Fact L beta (dist  1 pp [    10-    54] vol 2)
     0.6 (              Delexian Wheat)                          Wheat Farm M beta ->   Herron's Nebula/                    Cahoona Bakery M Alpha (dist  1 pp [    10-    54] vol 2)
```

### Output format

Let's use this example:

```
     0.6 (              Delexian Wheat)                         Wheat Farm M alpha ->      Three Worlds/                    Cahoona Bakery M Alpha (dist  1 pp [    10-    54] vol 2)
```

In order of appearance:

* 0.6 is the score the algorithm gave to this trade route; higher is better
* Delexian Wheat is the good (ware) that's traded on this route
* Wheat Farm M alpha is the station in the system you specified where you
    pick up the wheat
* Three Worlds is the system where the trade route ends
* Cahoona Bakery M Alpha is the station in Three Worlds where the trade
    route ends
* 1 is the number of jumps between the starting sector and Three Worlds
* 10-54 is the full range of prices at which stations will buy and sell
  Delexian Wheat
* 2 is the volume of each Delexian Wheat

### Future plans

* Generate trade routes with multiple legs
* Allow the user to specify the amount of credits they're willing to spend on
  trade
* Allow the user to specify the amount of time a trade route should take
  (assuming multiple legs are implemented first)
* Allow the user to limit the total trade route distance

## .x3.sqlite

A database, used by trade_routes.rb, that contains trading-related data.  It
is not a complete dump of the X3 internal database.

### Database omissions and notes

Currently, only a small number of sectors are included, and they are all in
Argon space.  I am adding information to the database as I progress through
the X universe.

Some station types are omitted entirely:
*   Federal Argon Shipyard (only sells stations)
*   Argon Stock Exchange (requires owning a station in Argon space)
*   TerraCorp Headquarters (only sells ship equipment and services)
*   Some stations I haven't run into in the game yet and therefore haven't
    figured out if they're trading posts or not:
    *   Military Outpost
    *   Pirate Base

Equipment docks and trading stations are considered to be trading posts.  Only
the following categories of good are included from these stations, if applicable.
*   Goods
*   Weapons

Marines are also omitted.

### Schema

If there's ever enough interest, I'll describe the database schema here.

## Contributing

I love contributions!

If you would like to contribute to the code repository, please open a pull
request on GitHub with clean code and a concise but comprehensive description.

For database contributions, please open an issue on GitHub and enclose
a series of INSERT and/or UPDATE statements that can be run on the
currently-published version of the database.

If you are adding stations to the database, please add *all* of the stations
for the entire sector and double-check your updates of the `sector` table.

## License

All code in this repository is copyright Colin Wetherbee and released under
The MIT License, a copy of which may be found in each source file.
