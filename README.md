# Create SQLite Core Data database file for use with an iOS app

Das Repo enthält eine Daten-Pipeline, die zeigt, wie man große, Datensätze (als Beispiel: öffentliche, taxonomische Daten von ITIS oder GermanSL) in eine Apple Core Data kompatible SQLite-Datenbank für eine iOS-App migriert.

Da Apple keinen direkten SQL-Zugriff oder eine Dokumentation für das Pre-Loading von Core Data-Datenbanken bereitstellt, wurde etwas Reverse Engineering gemacht.

Der Prozess ist in zwei Hauptteile gegliedert:

Vorbereitung/Erstellung der Zieldatenbank (macOS):

Ein Xcode xcdatamodeld (Taxa.xcdatamodeld) definiert das Schema.

Ein Swift-Kommandozeilen-Tool (sqlite-tool-suite) wird verwendet, um eine leere SYSTEM.sqlite-Datei zu erstellen, die das korrekte, proprietäre Core Data-Schema und alle Metadaten-Tabellen (Z_METADATA, Z_PRIMARYKEY etc.) enthält.

Daten-ETL (Linux/Arch):

Ein zsh-Orchestrierungs-Skript (convert.zsh) verwaltet den gesamten Prozess.

Es lädt die Rohdaten (z.B. ITIS.sql) in eine PostgreSQL-Zwischendatenbank.

Ein Python-Skript (migrate.py mit psycopg2) wird aufgerufen, um die Daten zu transformieren, Hierarchien (ZAGGS) aufzubauen, Synonyme zu verarbeiten und einen rechenintensiven N-Gramm-Suchindex (ZSPECINDEX) zu erstellen.

Abschließend exportiert das Skript die bereinigten Daten per pg_dump und lädt sie mittels sqlite3 in die von Swift erstellte Zieldatenbank.

----

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

(.venv) user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % uname -r

6.17.6-arch1-1

(.venv) user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % zsh --version                                                                                                                                    

zsh 5.9 (x86_64-pc-linux-gnu)

(.venv) user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % python --version                                                                                                                                  

Python 3.13.7

(.venv) user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % sqlite3 --version                                                                                                                                 

3.50.4 2025-07-30 19:33:53 4d8adfb30e03f9cf27f800a2c1ba3c48fb4ca1b08b0f5ed59a4d5ecbf45ealt1 (64-bit)

(.venv) user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % psql --version                                                                                                                                    

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

3.) Configure PostgreSQL to use a custom data directory.
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

3.) Check if the built was successful

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

## Usage 

The main script is `convert.zsh`.

### Syntax:

    convert.zsh -conf <conf> -username <username> -password <password>

There is a configuration file in `zsh` syntax `configuration.zsh` where array variables with configuration data are defined.

The names of the array variables are the valid values for the `<conf>` parameter from the `convert.zsh` command syntax.

`<username>` `<password>` is a valid access username and password for the PostgreSQL database server.
 
Check if username and password are in the `~/.pgpass` file:

```bash
nano ~/.pgpass
localhost:5432:ITIS:<username>:<password>
```

### Workflow:

Before the script can be started, an empty target database is needed. In order to create such a target database, the `momd` format of the target data model is needed; thus the three steps result: *):

**A.) Create `.momd` from Xcode Core Data model files `.xcdatamodeld`**

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

Run Log:

```bash
###################################
Import from proprietary data source
###################################
Importing /mnt/lightroomssd/itisPostgreSql092425/ITIS.sql data into Postgres ...
migrate PostgreSQL dump file to UTF8 
Create database and tables and import data
HINWEIS:  Datenbank »ITIS« existiert nicht, wird übersprungen
DROP DATABASE
CREATE DATABASE
Sie sind jetzt verbunden mit der Datenbank »ITIS« als Benutzer »postgres«.
... (SET-Befehle) ...
CREATE EXTENSION
...
CREATE TABLE
... (Viele CREATE TABLE, COPY und ALTER TABLE-Befehle) ...
COPY 70382
...
COPY 159323
ALTER TABLE
...
DROP EXTENSION
... (DROP/CREATE von Indizes, Tabellen, Sequenzen und Funktionen) ...
CREATE FUNCTION

###################################
Insert into Z Tables (postgres)
###################################
... (DROP/CREATE von Indizes, Tabellen, Sequenzen) ...
CREATE INDEX
INSERT 0 212967
INSERT 0 938363
UPDATE 938363
... (Weitere UPDATEs) ...
Process select * from aggsupdateV02(50,10050) ...
... finished !
Process select * from aggsupdateV02(10051,20051) ...
... finished !
...
... (aggsupdateV02 wird in vielen Batches ausgeführt)
...
Process select * from aggsupdateV02(1190169,1200169) ...
... finished !
UPDATE 7
... (Weitere UPDATEs) ...

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
...
INSERT 0 2975843
...
CREATE INDEX

###################################
Prepare data to insert into Z Tables (sqlite)
###################################
SET
DELETE 0
DELETE 262440
...
UPDATE 631334
...
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

**E.) Run subsequent conversions (Fast)**

If you use the script for other configurations (like `ITIS_Birds` from `configuration.zsh`), it will detect the .copy files and skip the slow import and indexing steps. This is much faster.

```bash
user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % source ../.venv/bin/activate
(.venv) user@archlinux ~/Projekte/github/sqlite-core-data-creation/src % time ./convert.zsh -conf ITIS_Birds -username postgres -password postgres
```

Run Log:

```bash

###################################
Import from ZSPEC and ZRANK and ZPERSON copy
###################################
SET
...
COPY 938363
COPY 182
COPY 212967
...
###################################
Insert into Z Tables (sqlite)
###################################
Exporting ZSPEC ...
memory
...
./convert.zsh -conf ITIS_Birds -username postgres -password postgres  20,32s user 7,71s system 12% cpu 3:39,45 total
```

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
