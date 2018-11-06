config-scripts
==============

This is collection of scripts that I use on my linux machine to configure my
workspace. For now I use a **Ubuntu** distribution.

Ubuntu 18.04
------------
The [**setup.sh**](setup.sh) script when running creates the following directory structure in a specified **SETUP_PATH**:
 - **tools** - if it requires to download certain dev tools, this is the folder used to store them. *e.g. maven, jetbrains-toolbox, etc.*
 - **private** - here we will store secrets like the GitHub ssh keys, bash customization file and if an **aliases** file is present with your personal aliases, it will be added to your ***bashrc*** profile
 - **work** - here you will find clones of all your GitHub repositories
 - **containers** - this will be the home directory where any **docker** services used will hold their data *(e.g. dpostgres will store the databases there)*

### Get started
 ```bash
 $ bash <(curl -s https://raw.githubusercontent.com/bogdanmic/config-scripts/master/setup.sh)
 ```
 **NOTICE:** Since you are executing an untrusted script from the interwebs, I
 would recommend you to take a look at it before proceeding. So probably you
 should do this.
 ```bash
 $ git clone https://github.com/bogdanmic/config-scripts.git
 $ cd config-scripts
 $ ./setup.sh
 ```
If you want to go through the steps without any changes to your computer you can run it like this
 ```bash
 $ ./setup.sh --dry-run
 ```

### What does it do?
This script runs in multiple steps that are optional and some depend on others. These steps are in order with their substeps:
- Install **git, git-flow**
  - Configure  GIT
  - Setup GitHub SSH key
  - Clone all your GitHub repositories (max 200)
  - Configure your Terminal prompt for GIT
- Install **filezilla, vlc, virtualbox, firefox, vim, net-tools**
- Install **chrome** browser
- Install **skype**
- Install **dbeaver** (sql client)
- Install **numix-icon-theme-circle** this is just a icon theme I like :)
- Install **atom ide** a quite decent and lightweight IDE
- Install **docker, docker-compose**
  - Add aliases for docker consul(**dconsul,econsul**), docker postgresql(**dpostgres**), docker pgadmin4(**dpgadmin**)
  - Add aliases for docker mongo(**dmongo,emongo**)
    - Install **MongoDB Compass** (UI for MongoDB)
  - Add aliases for docker rabbitmq(**drabbit**)
  - Add aliases for docker mysql 5.7(**dmysql**)
    - Install: **MySql Workbench** (UI for Mysql)
- Install **java8**
  - Install **maven, activator, JetBrains ToolBox** (makes it easier to install and
  update JetBrains products)
- Install **nodejs**
- Install **yarn**
- Add any private aliases found in the **aliases** file
- Install **awscli**
  - Configure awscli
- Add all the bash customization that we did to the **~/.bashrc** file.
- Update and Reboot

### The aliases generated and how to use them
   - **dconsul** - starts consul
   - **econsul** - executes consul commands in the started consul container
   - **dpostgres** - starts a postgres database
   - **epsql** - executes psql commands in the started postgres container
     e.g. To do a restore:
     ```bash
     $ cat db_backup_file | epsql db_name
     ```
   - **dpgadmin** - starts pgadmin4
   - **dmongo** - starts mongodb
   - **emongo** - starts the mongo client
   - **emongodump** - executes a mongodb dump
     e.g. To dump a database:
     ```bash
     $ emongodump db_name > file_name.gz
     ```
   - **emongorestore** - executes a restore into mongodb
     e.g. To restore a database:
     ```bash
     # This restores in the same database
     $ cat file_name.gz | emongorestore
     # To restore in a different database
     $ cat file_name.gz | emongorestore --nsFrom "<OLD_DB_NAME>.*" --nsTo "<NEW_DB_NAME>.*"
     ```
   - **drabbit** - starts rabbitmq. it starts with the management console enabled http://localhost:15672 with default user/pass **guest/guest**
   - **dmysql** - starts mysql
   - **emysqldump** - executes a mysql db dump
     ```bash
     $ emysqldump DB_NAME > DUMP_FILE.sql
     ```
   - **emysqlrestore** - executes a restore from a mysql dump
     ```bash
     $ cat DUMP_FILE.sql | emysqlrestore DB_NAME
     ```


***Feel free to contribute in any way.***
