# Create SQLite Core Data database file for use and shipping with an iOS app

This project showing data migration to a `Core Data` compatible `SQLite` database using scripts (`zsh`, `Python`, `PL/pgSQL`, `Swift`, `SQLite and PosgreSQL SQL`) is not a ready-made solution for similar requirements in other projects, but some procedures can perhaps be adopted and some architectural features of the script solution should be usable for others.

`Core Data` is a propietary persistence framework from Apple for iPadOS, iOS, macOS apps.

There are several base technologies that can be managed by `Core Data` for storing data on a file system, one is `SQLite` - and that is what we are using here.

There is no official support or documentation from Apple how to create `Core Data` compatible `SQLite` databases and how to fill them with data using standard `SQL`. `Core Data` even does not have an API that allows `SQL` statements for data manipulation.

Actually `SQLite` files are hidden from the developer and should not be directly created or changed, except with the `Core Data` framework SDK and the `Core Data` modelling tool that is part of `Xcode`.

Due to the lack of documentation, a little research and experimentation was done at the beginning.

So the project now shows a well-tested workflow and scripts that work well.

I have often created `Core Data` compliant `SQLite` database files and shipped them directly with my iOS app [TaxaDB](https://apps.apple.com/de/app/taxadb/id1571018041), which is currently offered in the App Store, and I regularly create new `Core Data` compliant `SQLite` database files to make them available as assets of In-app purchases.

## Getting started

All sources can be found here [src](/src/), the example `Core Data` model that we use is here [datamodel](/datamodel/).

Much of the complexity of the scripts comes from the relatively complex data models of the source and target databases. 

Those who wish to use these scripts for their own implementations with simpler data migration projects will do well with shorter and simpler scripts.

On the other hand, the techniques used here - especially when migrating from `PostgreSQL` to `Core Data` `SQLite` - should be sufficient to solve many common problems.

The `zsh` and `Python` scripts have been tested and run on `Ubuntu 22.04 LTS (Jammy Jellyfish)`.

There is a little Swift command line tool `sqlite-tool` that can be built and run on `macOS`, it has been tested on a Silicon Mac with `macOS 12.4 (Monterey)` and `Xcode 13.4 (13F17a)` so far. See 'Build `sqlite-tool`' below.

## Set up

### Installation on Ubuntu

1.) Install `zsh`

    zsh --version
    zsh 5.8.1 (x86_64-ubuntu-linux-gnu)

2.) Install `python3`

    python3 --version
    Python 3.10.4

3.) Install `apache2`

    systemctl status apache2
    ● apache2.service - The Apache HTTP Server
        Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
        Active: active (running) since Sat 2022-07-02 09:48:21 CEST; 12min ago
        ...

4.) Install `postgresql`

    sudo systemctl status postgresql
    ● postgresql.service - PostgreSQL RDBMS
        Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: enabled)
        Active: active (exited) since Sat 2022-07-02 09:48:24 CEST; 14min ago
        ...

5.) Install `postgresql-client`

    psql --version
    psql (PostgreSQL) 14.3 (Ubuntu 14.3-0ubuntu0.22.04.1)

6.) Install `php`

    php -version
    PHP 8.1.2 (cli) (built: Jun 13 2022 13:52:54) (NTS)
    ...

7.) Install `phppgadmin`

<div align="center">
![http://10.0.0.4/phppgadmin/](https://www.mascapp.com/createcoredata/img/Screen01.png)
</div>

8.) Install `sqlite3`

    sqlite3 --version
    3.37.2 ...

9.) Install `pip3`

    pip3 --version
    pip 22.0.2 from /usr/lib/python3/dist-packages/pip (python 3.10)

10.) Install Python package `psycopg2` using `pip3 install`

    pip3 show psycopg2
    Name: psycopg2
    Version: 2.9.3
    ...

### Installation on macOS

1.) Install `Xcode` Version 13.4

2.) Build `sqlite-tool`:

    cd src/swift/sqlite-tool-suite

    user@Mac sqlite-tool-suite % tree -Dt  

    user@Mac sqlite-tool-suite % swift build -c release

    Fetching https://github.com/apple/swift-argument-parser from cache
    Fetched https://github.com/apple/swift-argument-parser (0.62s)
    Computing version for https://github.com/apple/swift-argument-parser
    Computed https://github.com/apple/swift-argument-parser at 1.1.3 (0.43s)
    Creating working copy for https://github.com/apple/swift-argument-parser
    Working copy of https://github.com/apple/swift-argument-parser resolved at 1.1.3
    Building for production...
    [6/6] Linking sqlite-tool
    Build complete! (10.81s)

3.) Check if the built was successful

    user@Mac sqlite-tool-suite % ./.build/release/sqlite-tool --help

    OVERVIEW: A tool for Core Data sqlite creation and performing simple queries.

    USAGE: sqlite-tool <subcommand>

    OPTIONS:
      --version               Show the version.
      -h, --help              Show help information.

    SUBCOMMANDS:
      new (default)           Create a new Core Data SQLite file.
      query                   Simple queries on the Taxa Core Data SQLite data base.

      See 'sqlite-tool help <subcommand>' for detailed help.

## Usage 

The main script is `convert.zsh`.

### Syntax:

    convert.zsh -conf <conf> -username <username> -password <password>

There is a configuration file in `zsh` syntax `configuration.zsh` where array variables with configuration data are defined.

The names of the array variables are the valid values for the `<conf>` parameter from the `convert.zsh` command syntax.

`<username>` `<password>` is a valid access username and password for the PostgreSQL database server.
 
Check if username and password are in the `~/.pgpass` file:

    nano ~/.pgpass
    localhost:5432:nutzer:<username>:<password>
    localhost:5432:ITIS:<username>:<password>
    ...

`convert.zsh` automates the entire data migration from the source database to the target core data `.sqlite` file:

<div align="center">
![script architecture](https://www.mascapp.com/createcoredata/img/Folien700x400/Folien700x400.001.png)
</div>

In more detail:

<div align="center">
![script architecture detail first run](https://www.mascapp.com/createcoredata/img/Folien700x700/Folien700x700.001.png)
</div>

If the script is used for conversion with other configuration value after the first run with the import of the original _raw_ data, the intermediate _interim_ data is used instead of importing the original source data again, resulting in higher performance and faster conversion:

<div align="center">
![script architecture detail](https://www.mascapp.com/createcoredata/img/Folien700x700/Folien700x700.002.png)
</div>

Before the script can be started, an empty target database is needed. In order to create such a target database, the `momd` format of the target data model is needed; thus the three steps result: *):


A.) Create `.momd` from Xcode Core Data model files `.xcdatamodeld`:

   `/Applications/Xcode.app/Contents/Developer/usr/bin/momc ../datamodel/Taxa.xcdatamodeld ../datamodel`

B.) Create an empty Core Data SQLite database file with the help of `sqlite-tool`:
   
   `./swift/sqlite-tool-suite/.build/release/sqlite-tool new ../datamodel/Taxa.momd ../data/SYSTEM.sqlite System`

C.) Start to convert data and fill the the Core Data SQLite database:

   `convert.zsh -conf <conf> -username <username> -password <password>`

*) Steps A.) and B.) are only required on the first run to obtain an empty Core Data SQLite database file

## Example

In the terminal, change dir `sqlite-core-data-creation`:

    user@Mac sqlite-core-data-creation % cd <projects>/sqlite-core-data-creation

#### Content of dir `sqlite-core-data-creation`:

    user@Mac sqlite-core-data-creation % tree -Dt

    [Jul  8 06:41]  .
    ├── [Jul  8 06:41]  data
    ├── [Jul  8 06:41]  datamodel
    │   └── [Jul 26  2021]  Taxa.xcdatamodeld
            ...
    └── [Jul  8 06:41]  src
        ├── [Jul  2 18:46]  migrate.py
        └── [Jul 17 14:29]  swift
            └── [Jul 17 14:45]  sqlite-tool-suite
            ...
        ├── [Jul  7 20:11]  convert.zsh
        └── [Jul  8 06:03]  configuration.zsh

1.) Download source database `https://www.itis.gov/downloads/itisPostgreSql.zip` and unzip it under data:

#### Content of dir `sqlite-core-data-creation`:

    user@Mac sqlite-core-data-creation % tree -Dt

    [Jul  8 06:41]  .
    ├── [Jul  8 06:41]  data
    │   └── [Jun 28 17:33]  itisPostgreSql062822
    │       ├── [Jun 28 17:33]  ITIS.sql
    │       └── [Jun 28 17:33]  ReadmePostgreSql.txt
    ├── [Jul  8 06:41]  datamodel
    │   └── [Jul 26  2021]  Taxa.xcdatamodeld
            ...
    └── [Jul  8 06:41]  src
        ├── [Jul  2 18:46]  migrate.py
        └── [Jul 17 14:29]  swift
            └── [Jul 17 14:45]  sqlite-tool-suite
            ...
        ├── [Jul  7 20:11]  convert.zsh
        └── [Jul  8 06:03]  configuration.zsh

2.) Create `.momd` from Xcode Core Data model files `.xcdatamodeld`:

    user@Mac sqlite-core-data-creation % /Applications/Xcode.app/Contents/Developer/usr/bin/momc ./datamodel/Taxa.xcdatamodeld ./datamodel 
    
    ...

#### Content of dir `sqlite-core-data-creation`:

    user@Mac sqlite-core-data-creation % tree -Dt  

    [Jul  8 06:41]  .
    ├── [Jul  8 06:41]  data
    │   └── [Jun 28 17:33]  itisPostgreSql062822
    │       ├── [Jun 28 17:33]  ITIS.sql
    │       └── [Jun 28 17:33]  ReadmePostgreSql.txt
    ├── [Jul  8 06:41]  src
    │   ├── [Jul  2 18:46]  migrate.py
        └── [Jul 17 14:29]  swift
            └── [Jul 17 14:45]  sqlite-tool-suite
            ...
    │   ├── [Jul  7 20:11]  convert.zsh
    │   └── [Jul  8 06:03]  configuration.zsh
    └── [Jul  8 06:55]  datamodel
        ├── [Jul 26  2021]  Taxa.xcdatamodeld
            ...
        └── [Jul  8 06:55]  Taxa.momd
            ...

3.) Create an empty Core Data SQLite database file:


    user@Mac sqlite-core-data-creation % ./src/swift/sqlite-tool-suite/.build/release/sqlite-tool new ./datamodel/Taxa.momd ./data/SYSTEM.sqlite System
    Create Core Data SQLite database file:///Users/fama/Projekte/sqlite-core-data-creation/data/SYSTEM.sqlite
    Use Core Data SQLite database model file:///Users/fama/Projekte/sqlite-core-data-creation/datamodel/Taxa.momd/
    Model version: 61
    Core Data SQLite database file is compatible
    Core Data SQLite database file created file:///Users/fama/Projekte/sqlite-core-data-creation/data/SYSTEM.sqlite

#### Content of dir `sqlite-core-data-creation`:

    user@Mac sqlite-core-data-creation % tree -Dt

    [Jul  8 06:41]  .
    ├── [Jul  8 06:41]  src
    │   ├── [Jul  2 18:46]  migrate.py
        └── [Jul 17 14:29]  swift
            └── [Jul 17 14:45]  sqlite-tool-suite
            ...
    │   ├── [Jul  7 20:11]  convert.zsh
    │   └── [Jul  8 06:03]  configuration.zsh
    ├── [Jul  8 06:55]  datamodel
    │   ├── [Jul 26  2021]  Taxa.xcdatamodeld
             ...
    │   └── [Jul  8 06:55]  Taxa.momd
             ...
    └── [Jul  8 06:57]  data
        ├── [Jun 28 17:33]  itisPostgreSql062822
        │   ├── [Jun 28 17:33]  ITIS.sql
        │   └── [Jun 28 17:33]  ReadmePostgreSql.txt
        └── [Jul  8 06:57]  SYSTEM.sqlite
    
4.) Run data migration (!!! The whole run of this example takes about one to two hours, depending on the PostgresSQL server performance !!!)

    user@Mac ./convert.zsh -conf ITIS_1501 -username <username> -password <password>
    ...

#### Content of dir `sqlite-core-data-creation`:

    user@Mac sqlite-core-data-creation % tree -Dt

    [Jul  8 06:41]  .
    ├── [Jul  8 06:55]  datamodel
    │   ├── [Jul 26  2021]  Taxa.xcdatamodeld
             ...
    │   └── [Jul  8 06:55]  Taxa.momd
             ...
    ├── [Jul  8 06:57]  data
    │   ├── [Jun 28 17:33]  itisPostgreSql062822
    │   │   ├── [Jun 28 17:33]  ITIS.sql
    │   │   └── [Jun 28 17:33]  ReadmePostgreSql.txt
    │   └── [Jul  8 08:17]  SYSTEM.sqlite
    └── [Jul  8 08:16]  src
        ├── [Jul  2 18:46]  migrate.py
        └── [Jul 17 14:29]  swift
            └── [Jul 17 14:45]  sqlite-tool-suite
            ...
        ├── [Jul  7 20:11]  convert.zsh
        ├── [Jul  8 06:03]  configuration.zsh
        ├── [Jul  8 07:08]  __pycache__
        │   └── [Jul  8 07:08]  migrate.cpython-310.pyc
        ├── [Jul  8 07:14]  ITIS_220628001_ZPERSON.copy
        ├── [Jul  8 07:14]  ITIS_220628001_ZRANK.copy
        ├── [Jul  8 07:14]  ITIS_220628001_ZSPEC.copy
        ├── [Jul  8 07:52]  tmp1.sql
        ├── [Jul  8 08:13]  exportZSPEC.sql
        ├── [Jul  8 08:14]  exportZRANK.sql
        ├── [Jul  8 08:15]  exportZNAMESIDX.sql
        └── [Jul  8 08:16]  exportZPERSON.sql

5.) Perform some queries in the SQLite Core Data target database

    user@Mac sqlite-core-data-creation % ./src/swift/sqlite-tool-suite/.build/release/sqlite-tool query species-info ./data/SYSTEM.sqlite ./datamodel/Taxa.momd  "Bellis perennis"
    Taxa <Bellis perennis> found with nr = 36826

    user@Mac sqlite-core-data-creation % ./src/swift/sqlite-tool-suite/.build/release/sqlite-tool query species-info ./data/SYSTEM.sqlite ./datamodel/Taxa.momd  "Apis"
    Taxa <Apis> found with nr = 154395

    user@Mac sqlite-core-data-creation % ./src/swift/sqlite-tool-suite/.build/release/sqlite-tool query count-species ./data/SYSTEM.sqlite ./datamodel/Taxa.momd
    631087