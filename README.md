# Create SQLite Core Data database file for use and shipping with an iOS app

This project showing the creation of SQLite Core Data with the help of scripts (`zsh`, `Python`, `PL/pgSQL`, `Swift`, `SQLite and PosgreSQL SQL`) is not a ready-to-use solution for similar requirements in your own projects, but many procedures can perhaps be adopted and some architectural features of the script solution should also be usable for others.

`Core Data` is a propietary persistence framework from Apple for iOS, iPhoneOS, macOS apps.

There are several base technologies that can be managed by `Core Data` for storing data on a file system, one is `SQLite` - and that is what we are using here in this project.

There is no official support or documentation from Apple how to create `Core Data` compliant `SQLite` databases and how to fill them with data using standard `SQL`. `Core Data` even does not have a API that allows `SQL` statements for data change.

Actually `SQLite` files are hidden from the developer and should not be directly created or changed, except with the `Core Data` framework SDK and the `Core Data` modelling tool that is part of `Xcode`.

Because of the lack of documentation, at the beginning, there was a bit of research, investigation and experimentation.

So the project shows a well-tested workflow and scripts that work well.

I have often created `Core Data` compliant `SQLite` database files and shipped them directly with my iOS app (up to deployment target `iOS 15.2`) or made them available as in-app purchase assets.

## Getting started

All sources can be found here [src](/src/), the example `Core Data` model that we use is here [datamodel](/datamodel/).

Much of the complexity of the scripts comes from the relatively complex data models of the source and target databases I am using here. 

Those who wish to use these scripts for their own implementations with simpler data migration projects will do well with shorter and simpler scripts.

On the other hand, the techniques used - especially when migrating from `PostgreSQL` to `Core Data` `SQLite` - should be sufficient to solve many common problems.

The `zsh` and `Python` scripts have been tested and run on `Ubuntu 22.04 LTS (Jammy Jellyfish)`.

There is a little command line tool `main.swift` that runs only on `macOS`, it has been tested on a Silicon Mac with `macOS 12.4 (Monterey)` and `Xcode 13.4 (13F17a)` so far.

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

Roughly speaking, `convert.zsh` automates the entire conversion from the target database to the core data `.sqlite` file:

<div align="center">
![script architecture](https://www.mascapp.com/createcoredata/img/Folien700x400/Folien700x400.001.png)
</div>

In more detail the conversion looks like this:

<div align="center">
![script architecture detail first run](https://www.mascapp.com/createcoredata/img/Folien700x700/Folien700x700.001.png)
</div>

If the script is used for conversion with other configuration value after the first run with the import of the original _raw_ data, the intermediate _interim_ data is used instead of importing the original source data again, resulting in higher performance and faster conversion:

<div align="center">
![script architecture detail](https://www.mascapp.com/createcoredata/img/Folien700x700/Folien700x700.002.png)
</div>



Three steps to create the Core Data SQLite database *):


1.) Create `.momd` from Xcode Core Data model files `.xcdatamodeld`:

   `/Applications/Xcode.app/Contents/Developer/usr/bin/momc ../datamodel/Taxa.xcdatamodeld ../datamodel`

2.) Create an empty Core Data SQLite database file with the help of `main.swift`:
   
   `swift main.swift System ../datamodel/Taxa.momd ../datamodel/SYSTEM.sqlite`

3.) Start to convert data and fill the the Core Data SQLite database:

   `convert.zsh -conf <conf> -username <username> -password <password>`


*) Steps 1.) and 2.) are only done once in order to get an empty Core Data SQLite database file