# Create SQLite Core Data database file for use with an iOS app

This project showing data migration to a `Core Data` compatible `SQLite` database using scripts (`zsh`, `Python`, `PL/pgSQL`, `Swift`, `SQLite and PosgreSQL SQL`) is not a ready-made solution for similar requirements in other projects, but some procedures can perhaps be adopted and some architectural features of the script solution should be usable for others.

`Core Data` is a propietary persistence framework from Apple for iPadOS, iOS, macOS apps.

There are several base technologies that can be managed by `Core Data` for storing data on a file system, one is `SQLite` - and that is what we are using here.

There is no official support or documentation from Apple how to create `Core Data` compatible `SQLite` databases and how to fill them with data using standard `SQL`. `Core Data` even does not have an API that allows `SQL` statements for data manipulation.

Actually `SQLite` files are hidden from the developer and should not be directly created or changed, except with the `Core Data` framework SDK and the `Core Data` modelling tool that is part of `Xcode`.

Due to the lack of documentation, a little research and experimentation was done at the beginning.

So the project now shows a tested workflow and scripts that work well.

I have often created `Core Data` compliant `SQLite` database files and shipped them directly with an iOS app.

## Getting started

All sources can be found here [src](/src/), the example `Core Data` model that we use is here [datamodel](/datamodel/).

Much of the complexity of the scripts comes from the relatively complex data models of the source and target databases. 

Those who wish to use these scripts for their own implementations with simpler data migration projects will do well with shorter and simpler scripts.

On the other hand, the techniques used here - especially when migrating from `PostgreSQL` to `Core Data` `SQLite` - should be sufficient to solve many common problems.

The `zsh` and `Python` scripts have been last tested and run on `Arch Linux 6.17.6-arch1-1`.

There is a little Swift command line tool `sqlite-tool` that can be built and run on `macOS`, it has been last tested and run on a Silicon Mac and Intel Mac with `Xcode 26.0.1`. See 'Build `sqlite-tool`' below.

## Set up

### Versions

#### Arch Linux

```bash

(.venv) user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % uname -r                                                                                                                                          main
6.17.6-arch1-1

(.venv) user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % zsh --version                                                                                                                                     main
zsh 5.9 (x86_64-pc-linux-gnu)

(.venv) user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % python --version                                                                                                                                  main
Python 3.13.7

(.venv) user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % sqlite3 --version                                                                                                                                 main
3.50.4 2025-07-30 19:33:53 4d8adfb30e03f9cf27f800a2c1ba3c48fb4ca1b08b0f5ed59a4d5ecbf45ealt1 (64-bit)

(.venv) user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % psql --version                                                                                                                                    main
psql (PostgreSQL) 18.0

```

#### macOS (Intel)

```bash

user@mac sqlite-core-data-creation % uname -r

24.6.0

user@mac sqlite-core-data-creation % xcodebuild -version

Xcode 26.0.1

Build version 17A400

user@mac sqlite-core-data-creation % swift --version                                                

swift-driver version: 1.127.14.1 Apple Swift version 6.2 (swiftlang-6.2.0.19.9 clang-1700.3.19.1)

Target: x86_64-apple-macosx15.0


```

### Installation on Arch Linux

1.) Install core tools.
This command installs Zsh, PostgreSQL, Python, the Python virtual environment tool (venv), and the SQLite CLI.

```bash
sudo pacman -S zsh postgresql python python-venv sqlite
```

```bash
yay -S pyenv pyenv-virtualenv
```

2.) (Optional) Install graphical DB client (e.g. DBeaver).

```bash
sudo pacman -S dbeaver
```

*Note on Java:* When installing `dbeaver`, `pacman` will ask you to choose a Java Runtime provider. A good and lightweight choice is `jre21-openjdk`.

3.) (Optional) Configure PostgreSQL to use a custom data directory.
This is useful if you want to store your data on a separate drive (e.g., an SSD mounted at /mnt/datassd).

a. Create the new directories and set permissions (replace `/mnt/datassd` with your path):
```bash
sudo mkdir -p /mnt/datassd/postgresql/data
sudo chown -R postgres:postgres /mnt/datassd/postgresql/
sudo chmod 700 /mnt/datassd/postgresql/data
```

b. Initialize the new database cluster *as* the `postgres` user (adjust locale if needed):
```bash
sudo -iu postgres initdb --locale=de_DE.UTF-8 -E UTF8 -D '/mnt/datassd/postgresql/data'
```

c. Tell the `systemd` service where to find the new path.
   Run `sudo systemctl edit postgresql.service`. This opens an override file. Paste the following content (adjust the paths):

```ini
[Service]
Environment=PGROOT=/mnt/datassd/postgresql
Environment=PGDATA=/mnt/datassd/postgresql/data
PIDFile=/mnt/datassd/postgresql/data/postmaster.pid
```

d. Reload `systemd` and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl start postgresql.service
sudo systemctl enable postgresql.service
```

4.) Set a password for the PostgreSQL admin user.

a. Switch to the `postgres` system user:
```bash
sudo -iu postgres
```
b. Open the `psql` console (this is done inside the `postgres` user's shell):
```bash
psql
```
c. Set the password inside the `psql` console:
```sql
ALTER USER postgres WITH PASSWORD 'YourStrongPassword';
```

d. Exit the `psql` console and the `postgres` user's shell:

```bash
\q
exit
```

5.) Set up the Python Environment.
The scripts need a Python environment with the psycopg2 library.

a. Create a virtual environment in your project folder:
   ```bash
   python -m venv .venv
   ```
b. Activate the environment (run this every time you work on the project):
   ```bash
   source .venv/bin/activate
   ```
c. Install the required Python package:
   ```bash
   pip install psycopg2
   ```

### Installation on macOS

1.) Install `Xcode` (The last successfully tested version was 26.0.1)

2.) Build `sqlite-tool`:

    cd src/swift/sqlite-tool-suite
    sqlite-tool-suite % swift build -c release

<div style="max-height: 350px; overflow-y: auto;">

```bash
user@mac sqlite-tool-suite % swift build -c release

Fetching https://github.com/apple/swift-argument-parser
Fetched https://github.com/apple/swift-argument-parser from cache (2.53s)
Computing version for https://github.com/apple/swift-argument-parser
Computed https://github.com/apple/swift-argument-parser at 1.6.2 (3.49s)
Creating working copy for https://github.com/apple/swift-argument-parser
Working copy of https://github.com/apple/swift-argument-parser resolved at 1.6.2
Building for production...
[15/15] Linking sqlite-tool
Build complete! (143.80s)
```
</div>

3.) Check if the built was successful

<div style="max-height: 350px; overflow-y: auto;">

```bash
user@mac sqlite-tool-suite % ./.build/release/sqlite-tool --help
OVERVIEW: A tool for Core Data sqlite creation and performing simple queries.

USAGE: sqlite-tool <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  new (default)           Create a new Core Data SQLite file.
  query                   Simple queries on the Taxa Core Data SQLite data base.

  See 'sqlite-tool help <subcommand>' for detailed help.
```
</div>

## Usage 

The main script is `convert.zsh`.

### Syntax:

    convert.zsh -conf <conf> -username <username> -password <password>

There is a configuration file in `zsh` syntax `configuration.zsh` where array variables with configuration data are defined.

The names of the array variables are the valid values for the `<conf>` parameter from the `convert.zsh` command syntax.

`<username>` `<password>` is a valid access username and password for the PostgreSQL database server.
 
Check if username and password are in the `~/.pgpass` file:

<div style="max-height: 350px; overflow-y: auto;">

```bash
nano ~/.pgpass
localhost:5432:ITIS:<username>:<password>
```

</div>


### Workflow:

Before the script can be started, an empty target database is needed. In order to create such a target database, the `momd` format of the target data model is needed; thus the three steps result: *):

**A.) Create `.momd` from Xcode Core Data model files `.xcdatamodeld`**

<div style="max-height: 350px; overflow-y: auto;">

```bash
user@mac sqlite-core-data-creation % /Applications/Xcode.app/Contents/Developer/usr/bin/momc ./datamodel/Taxa.xcdatamodeld ./datamodel
Taxa56.xcdatamodel: note: Model Taxa56 version checksum: 7slBPn60d+0irFNGApudBcuf7UT65qkpYqiJI4ddXd4=
59.xcdatamodel: note: Model 59 version checksum: aqFBkTg9LWEfHYhWxYk95nWHp/2rzJJGxURSlwiJbcI=
58.xcdatamodel: note: Model 58 version checksum: /BBWUl5jcAc85mTOzUuQ8MCfVJBm6MUAmOsJSSCOz7w=
Taxa54.xcdatamodel: note: Model Taxa54 version checksum: iOZJMDYZl0c1b+jvcxxqDE0J/2vGFRiu4V2sM5AY/9o=
62.xcdatamodel: note: Model 62 version checksum: uqEjVLZoSU43Wy/swYOHN7SmBiiRuJgTvlGtZml31tA=
57.xcdatamodel: note: Model 57 version checksum: FcuBBWAMzjaOxZRaHmcICFxmAlavxsv6KCNjaBH78v0=
61.xcdatamodel: note: Model 61 version checksum: pBArdU2/LXXLZdFQcLFkBBNLx0GNlwFf2xZuMHM7Hio=
Taxa55.xcdatamodel: note: Model Taxa55 version checksum: FcuBBWAMzjaOxZRaHmcICFxmAlavxsv6KCNjaBH78v0=
60.xcdatamodel: note: Model 60 version checksum: pBArdU2/LXXLZdFQcLFkBBNLx0GNlwFf2xZuMHM7Hio=
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/59.xcdatamodel:IMAGE.licence: warning: IMAGE.licence should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/59.xcdatamodel:INFO.licence: warning: INFO.licence should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/59.xcdatamodel:LINK.licence: warning: LINK.licence should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/59.xcdatamodel:LOCATION.licence: warning: LOCATION.licence should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/59.xcdatamodel:OBSERVATION.licence: warning: OBSERVATION.licence should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/59.xcdatamodel:SET.license: warning: SET.license should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/58.xcdatamodel:IMAGE.licence: warning: IMAGE.licence should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/58.xcdatamodel:INFO.licence: warning: INFO.licence should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/58.xcdatamodel:LINK.licence: warning: LINK.licence should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/58.xcdatamodel:LOCATION.licence: warning: LOCATION.licence should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/58.xcdatamodel:OBSERVATION.licence: warning: OBSERVATION.licence should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/58.xcdatamodel:SET.license: warning: SET.license should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/62.xcdatamodel:COLLECTIONVIEW.specdetails: warning: COLLECTIONVIEW.specdetails should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/62.xcdatamodel:LINK.author: warning: LINK.author should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/61.xcdatamodel:COLLECTIONVIEW.specdetails: warning: COLLECTIONVIEW.specdetails should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/61.xcdatamodel:LINK.author: warning: LINK.author should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/60.xcdatamodel:COLLECTIONVIEW.specdetails: warning: COLLECTIONVIEW.specdetails should have an inverse [2]
/Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.xcdatamodeld/60.xcdatamodel:LINK.author: warning: LINK.author should have an inverse [2]

```

</div>

<br/>

**B.) Create an empty Core Data SQLite database file with the `sqlite-tool`**

This creates the empty `SYSTEM.sqlite` with the correct Core Data tables:
   
    ./src/swift/sqlite-tool-suite/.build/release/sqlite-tool new ./datamodel/Taxa.momd ./data/SYSTEM.sqlite System

```bash

user@mac sqlite-core-data-creation % ./src/swift/sqlite-tool-suite/.build/release/sqlite-tool new ./datamodel/Taxa.momd ./data/SYSTEM.sqlite System

Create Core Data SQLite database file:///Users/user/Projekte/github/sqlite-core-data-creation/data/SYSTEM.sqlite
Use Core Data SQLite database model file:///Users/user/Projekte/github/sqlite-core-data-creation/datamodel/Taxa.momd/
Model version: 61
Core Data SQLite database file is compatible
Core Data SQLite database file created file:///Users/user/Projekte/github/sqlite-core-data-creation/data/SYSTEM.sqlite

```

**C.) Copy the `SYSTEM.sqlite` file from your Mac to your Arch Linux machine**

Copy the `data/SYSTEM.sqlite` file into the `data/` directory of your project on the Arch Linux machine.

**D.) Start the conversion on Arch Linux This is the main, long-running step**

   `convert.zsh -conf ITIS_Complete -username <username> -password <password>`

*) Steps A.), B.) anc C.) are only required on the first run to obtain an empty Core Data SQLite database file

`convert.zsh` automates the entire data migration from the source database to the target core data `.sqlite` file:

```bash
user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % source ../.venv/bin/activate

(.venv) user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % time ./convert.zsh -conf ITIS_Complete -username postgres -password postgres
```

Full Run Log:

<div style="max-height: 350px; overflow-y: auto;">

```bash
###################################
Import from proprietary data source
###################################
Importing /mnt/lightroomssd/itisPostgreSql092425/ITIS.sql data into Postgres ...
migrate PostgreSQL dump file to UTF8 
Create database and tables and import data
HINWEIS:  Datenbank »ITIS« existiert nicht, wird übersprungen
DROP DATABASE
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 Zeile)

SET
SET
SET
SET
CREATE DATABASE
Sie sind jetzt verbunden mit der Datenbank »ITIS« als Benutzer »postgres«.
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 Zeile)

SET
SET
SET
SET
CREATE EXTENSION
COMMENT
SET
SET
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
COPY 70382
COPY 197
COPY 468884
COPY 675923
COPY 159543
COPY 7
COPY 981990
COPY 209565
COPY 1049
COPY 28617
COPY 1941350
COPY 212967
COPY 306333
COPY 212967
COPY 182
COPY 981990
COPY 192998
COPY 90107
COPY 159323
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
ALTER TABLE
SET
DROP EXTENSION
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP TABLE
DROP TABLE
DROP TABLE
DROP TABLE
DROP TABLE
DROP SEQUENCE
DROP SEQUENCE
DROP SEQUENCE
DROP SEQUENCE
DROP SEQUENCE
CREATE EXTENSION
CREATE SEQUENCE
CREATE SEQUENCE
CREATE SEQUENCE
CREATE SEQUENCE
CREATE SEQUENCE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
DROP FUNCTION
CREATE FUNCTION
DROP FUNCTION
CREATE FUNCTION
CREATE INDEX
CREATE INDEX
DROP FUNCTION
CREATE FUNCTION
DROP FUNCTION
CREATE FUNCTION

###################################
Insert into Z Tables (postgres)
###################################
SET
DROP EXTENSION
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP TABLE
DROP TABLE
DROP TABLE
DROP TABLE
DROP TABLE
DROP SEQUENCE
DROP SEQUENCE
DROP SEQUENCE
DROP SEQUENCE
DROP SEQUENCE
CREATE EXTENSION
CREATE SEQUENCE
CREATE SEQUENCE
CREATE SEQUENCE
CREATE SEQUENCE
CREATE SEQUENCE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
INSERT 0 212967
INSERT 0 938363
UPDATE 938363
UPDATE 938363
UPDATE 938363
UPDATE 938363
UPDATE 938363
UPDATE 845963
UPDATE 930014
UPDATE 938312
UPDATE 262440
UPDATE 262440
UPDATE 675923
UPDATE 675923
UPDATE 262440
UPDATE 572290
UPDATE 540079
Process select * from aggsupdateV02(50,10050) ...
... finished !
Process select * from aggsupdateV02(10051,20051) ...
... finished !
Process select * from aggsupdateV02(20052,30052) ...
... finished !
Process select * from aggsupdateV02(30053,40053) ...
... finished !
Process select * from aggsupdateV02(40054,50054) ...
... finished !
Process select * from aggsupdateV02(50055,60055) ...
... finished !
Process select * from aggsupdateV02(60056,70056) ...
... finished !
Process select * from aggsupdateV02(70057,80057) ...
... finished !
Process select * from aggsupdateV02(80058,90058) ...
... finished !
Process select * from aggsupdateV02(90059,100059) ...
... finished !
Process select * from aggsupdateV02(100060,110060) ...
... finished !
Process select * from aggsupdateV02(110061,120061) ...
... finished !
Process select * from aggsupdateV02(120062,130062) ...
... finished !
Process select * from aggsupdateV02(130063,140063) ...
... finished !
Process select * from aggsupdateV02(140064,150064) ...
... finished !
Process select * from aggsupdateV02(150065,160065) ...
... finished !
Process select * from aggsupdateV02(160066,170066) ...
... finished !
Process select * from aggsupdateV02(170067,180067) ...
... finished !
Process select * from aggsupdateV02(180068,190068) ...
... finished !
Process select * from aggsupdateV02(190069,200069) ...
... finished !
Process select * from aggsupdateV02(200070,210070) ...
... finished !
Process select * from aggsupdateV02(210071,220071) ...
... finished !
Process select * from aggsupdateV02(220072,230072) ...
... finished !
Process select * from aggsupdateV02(230073,240073) ...
... finished !
Process select * from aggsupdateV02(240074,250074) ...
... finished !
Process select * from aggsupdateV02(250075,260075) ...
... finished !
Process select * from aggsupdateV02(260076,270076) ...
... finished !
Process select * from aggsupdateV02(270077,280077) ...
... finished !
Process select * from aggsupdateV02(280078,290078) ...
... finished !
Process select * from aggsupdateV02(290079,300079) ...
... finished !
Process select * from aggsupdateV02(300080,310080) ...
... finished !
Process select * from aggsupdateV02(310081,320081) ...
... finished !
Process select * from aggsupdateV02(320082,330082) ...
... finished !
Process select * from aggsupdateV02(330083,340083) ...
... finished !
Process select * from aggsupdateV02(340084,350084) ...
... finished !
Process select * from aggsupdateV02(350085,360085) ...
... finished !
Process select * from aggsupdateV02(360086,370086) ...
... finished !
Process select * from aggsupdateV02(370087,380087) ...
... finished !
Process select * from aggsupdateV02(380088,390088) ...
... finished !
Process select * from aggsupdateV02(390089,400089) ...
... finished !
Process select * from aggsupdateV02(400090,410090) ...
... finished !
Process select * from aggsupdateV02(410091,420091) ...
... finished !
Process select * from aggsupdateV02(420092,430092) ...
... finished !
Process select * from aggsupdateV02(430093,440093) ...
... finished !
Process select * from aggsupdateV02(440094,450094) ...
... finished !
Process select * from aggsupdateV02(450095,460095) ...
... finished !
Process select * from aggsupdateV02(460096,470096) ...
... finished !
Process select * from aggsupdateV02(470097,480097) ...
... finished !
Process select * from aggsupdateV02(480098,490098) ...
... finished !
Process select * from aggsupdateV02(490099,500099) ...
... finished !
Process select * from aggsupdateV02(500100,510100) ...
... finished !
Process select * from aggsupdateV02(510101,520101) ...
... finished !
Process select * from aggsupdateV02(520102,530102) ...
... finished !
Process select * from aggsupdateV02(530103,540103) ...
... finished !
Process select * from aggsupdateV02(540104,550104) ...
... finished !
Process select * from aggsupdateV02(550105,560105) ...
... finished !
Process select * from aggsupdateV02(560106,570106) ...
... finished !
Process select * from aggsupdateV02(570107,580107) ...
... finished !
Process select * from aggsupdateV02(580108,590108) ...
... finished !
Process select * from aggsupdateV02(590109,600109) ...
... finished !
Process select * from aggsupdateV02(600110,610110) ...
... finished !
Process select * from aggsupdateV02(610111,620111) ...
... finished !
Process select * from aggsupdateV02(620112,630112) ...
... finished !
Process select * from aggsupdateV02(630113,640113) ...
... finished !
Process select * from aggsupdateV02(640114,650114) ...
... finished !
Process select * from aggsupdateV02(650115,660115) ...
... finished !
Process select * from aggsupdateV02(660116,670116) ...
... finished !
Process select * from aggsupdateV02(670117,680117) ...
... finished !
Process select * from aggsupdateV02(680118,690118) ...
... finished !
Process select * from aggsupdateV02(690119,700119) ...
... finished !
Process select * from aggsupdateV02(700120,710120) ...
... finished !
Process select * from aggsupdateV02(710121,720121) ...
... finished !
Process select * from aggsupdateV02(720122,730122) ...
... finished !
Process select * from aggsupdateV02(730123,740123) ...
... finished !
Process select * from aggsupdateV02(740124,750124) ...
... finished !
Process select * from aggsupdateV02(750125,760125) ...
... finished !
Process select * from aggsupdateV02(760126,770126) ...
... finished !
Process select * from aggsupdateV02(770127,780127) ...
... finished !
Process select * from aggsupdateV02(780128,790128) ...
... finished !
Process select * from aggsupdateV02(790129,800129) ...
... finished !
Process select * from aggsupdateV02(800130,810130) ...
... finished !
Process select * from aggsupdateV02(810131,820131) ...
... finished !
Process select * from aggsupdateV02(820132,830132) ...
... finished !
Process select * from aggsupdateV02(830133,840133) ...
... finished !
Process select * from aggsupdateV02(840134,850134) ...
... finished !
Process select * from aggsupdateV02(850135,860135) ...
... finished !
Process select * from aggsupdateV02(860136,870136) ...
... finished !
Process select * from aggsupdateV02(870137,880137) ...
... finished !
Process select * from aggsupdateV02(880138,890138) ...
... finished !
Process select * from aggsupdateV02(890139,900139) ...
... finished !
Process select * from aggsupdateV02(900140,910140) ...
... finished !
Process select * from aggsupdateV02(910141,920141) ...
... finished !
Process select * from aggsupdateV02(920142,930142) ...
... finished !
Process select * from aggsupdateV02(930143,940143) ...
... finished !
Process select * from aggsupdateV02(940144,950144) ...
... finished !
Process select * from aggsupdateV02(950145,960145) ...
... finished !
Process select * from aggsupdateV02(960146,970146) ...
... finished !
Process select * from aggsupdateV02(970147,980147) ...
... finished !
Process select * from aggsupdateV02(980148,990148) ...
... finished !
Process select * from aggsupdateV02(990149,1000149) ...
... finished !
Process select * from aggsupdateV02(1000150,1010150) ...
... finished !
Process select * from aggsupdateV02(1010151,1020151) ...
... finished !
Process select * from aggsupdateV02(1020152,1030152) ...
... finished !
Process select * from aggsupdateV02(1030153,1040153) ...
... finished !
Process select * from aggsupdateV02(1040154,1050154) ...
... finished !
Process select * from aggsupdateV02(1050155,1060155) ...
... finished !
Process select * from aggsupdateV02(1060156,1070156) ...
... finished !
Process select * from aggsupdateV02(1070157,1080157) ...
... finished !
Process select * from aggsupdateV02(1080158,1090158) ...
... finished !
Process select * from aggsupdateV02(1090159,1100159) ...
... finished !
Process select * from aggsupdateV02(1100160,1110160) ...
... finished !
Process select * from aggsupdateV02(1110161,1120161) ...
... finished !
Process select * from aggsupdateV02(1120162,1130162) ...
... finished !
Process select * from aggsupdateV02(1130163,1140163) ...
... finished !
Process select * from aggsupdateV02(1140164,1150164) ...
... finished !
Process select * from aggsupdateV02(1150165,1160165) ...
... finished !
Process select * from aggsupdateV02(1160166,1170166) ...
... finished !
Process select * from aggsupdateV02(1170167,1180167) ...
... finished !
Process select * from aggsupdateV02(1180168,1190168) ...
... finished !
Process select * from aggsupdateV02(1190169,1200169) ...
... finished !
UPDATE 7
INSERT 0 182
UPDATE 7
UPDATE 7
UPDATE 4
UPDATE 1
UPDATE 4
UPDATE 4
UPDATE 2
UPDATE 6
UPDATE 7
UPDATE 7
UPDATE 6
UPDATE 7
UPDATE 7
UPDATE 7
UPDATE 4
UPDATE 4
UPDATE 4
UPDATE 4
UPDATE 7
UPDATE 7
UPDATE 7
UPDATE 7
UPDATE 7
UPDATE 7
UPDATE 7
UPDATE 7
UPDATE 6
UPDATE 3
UPDATE 5
UPDATE 3
UPDATE 1
UPDATE 1
UPDATE 1
UPDATE 1
UPDATE 1
UPDATE 2
UPDATE 3
UPDATE 3
UPDATE 2
UPDATE 1
UPDATE 1

###################################
Copy ZSPEC to File
###################################
COPY 938363

###################################
Copy ZRANK to File
###################################
COPY 182

###################################
Copy ZPERSON to File
###################################
COPY 212967

###################################
Update for Root Taxa
###################################

###################################
Generate Info data (statistics)
###################################
Import data to interims tables

###################################
Generate Info data (synomyms)
###################################

###################################
Prepare Specindex
###################################

###################################
Insert Specindex
###################################
COPY 46473003

###################################
Insert Namesindex
###################################
DROP TABLE
DROP SEQUENCE
CREATE SEQUENCE
CREATE TABLE
INSERT 0 2975843
CREATE INDEX
CREATE INDEX
CREATE INDEX

###################################
Prepare data to insert into Z Tables (sqlite)
###################################
SET
DELETE 0
DELETE 262440
ALTER TABLE
ALTER TABLE
UPDATE 631324
UPDATE 98055
INSERT 0 1
UPDATE 9
UPDATE 631325
UPDATE 631334
UPDATE 631334
UPDATE 631334
UPDATE 631334
ALTER TABLE
ALTER TABLE
ALTER SEQUENCE
REINDEX
UPDATE 631334
ALTER SEQUENCE
UPDATE 631334
REINDEX
DELETE 57934
ALTER TABLE

###################################
Insert into Z Tables (sqlite)
###################################
Exporting ZSPEC ...
memory
Exporting ZRANK ...
memory
Exporting ZNAMESIDX ...
memory
Exporting ZPERSON ...
memory
./convert.zsh -conf ITIS_Complete -username postgres -password postgres  71,53s user 24,78s system 4% cpu 32:06,85 total
```
</div>

<br/>

**E.) Run subsequent conversions (Fast)**

If you use the script for other configurations (like `ITIS_Birds` from `configuration.zsh`), it will detect the .copy files and skip the slow import and indexing steps. This is much faster.

```bash
user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % source ../.venv/bin/activate
(.venv) user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % time ./convert.zsh -conf ITIS_Birds -username postgres -password postgres
```

Full Run Log:

<div style="max-height: 350px; overflow-y: auto;">

```bash

###################################
Import from ZSPEC and ZRANK and ZPERSON copy
###################################
SET
DROP EXTENSION
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP INDEX
DROP TABLE
DROP TABLE
DROP TABLE
DROP TABLE
DROP TABLE
DROP SEQUENCE
DROP SEQUENCE
DROP SEQUENCE
DROP SEQUENCE
DROP SEQUENCE
CREATE EXTENSION
CREATE SEQUENCE
CREATE SEQUENCE
CREATE SEQUENCE
CREATE SEQUENCE
CREATE SEQUENCE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
COPY 938363
COPY 182
COPY 212967

###################################
Update for Root Taxa
###################################

###################################
Generate Info data (statistics)
###################################
Import data to interims tables

###################################
Generate Info data (synomyms)
###################################

###################################
Prepare Specindex
###################################

###################################
Insert Specindex
###################################
COPY 15339617

###################################
Insert Namesindex
###################################
DROP TABLE
DROP SEQUENCE
CREATE SEQUENCE
CREATE TABLE
INSERT 0 1349325
CREATE INDEX
CREATE INDEX
CREATE INDEX

###################################
Prepare data to insert into Z Tables (sqlite)
###################################
SET
DELETE 0
DELETE 262440
ALTER TABLE
ALTER TABLE
UPDATE 31739
UPDATE 7306
INSERT 0 1
UPDATE 43
UPDATE 31739
UPDATE 31782
UPDATE 31782
UPDATE 31782
UPDATE 31782
ALTER TABLE
ALTER TABLE
ALTER SEQUENCE
REINDEX
UPDATE 31782
ALTER SEQUENCE
UPDATE 31782
REINDEX
DELETE 204914
ALTER TABLE

###################################
Insert into Z Tables (sqlite)
###################################
Exporting ZSPEC ...
memory
Exporting ZRANK ...
memory
Exporting ZNAMESIDX ...
memory
Exporting ZPERSON ...
memory
./convert.zsh -conf ITIS_Birds -username postgres -password postgres  20,32s user 7,71s system 12% cpu 3:39,45 total
```

</div>

<br/>

**F.) Perform queries on the final SQLite database (Optional)**

You can use the `sqlite-tool` on your Mac (or DBeaver on Arch) to verify the final file.

```bash

user@mac sqlite-core-data-creation % ./src/swift/sqlite-tool-suite/.build/release/sqlite-tool query species-info ./data/SYSTEM.sqlite ./datamodel/Taxa.momd  "Bellis perennis"
Taxa <Bellis perennis> found with nr = 36826

user@mac sqlite-core-data-creation % ./src/swift/sqlite-tool-suite/.build/release/sqlite-tool query species-info ./data/SYSTEM.sqlite ./datamodel/Taxa.momd  "Apis"
Taxa <Apis> found with nr = 154395

user@mac sqlite-core-data-creation % ./src/swift/sqlite-tool-suite/.build/release/sqlite-tool query count-species ./data/SYSTEM.sqlite ./datamodel/Taxa.momd
631334

```