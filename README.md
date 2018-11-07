config-scripts
==============

This is collection of scripts that I use on my linux machine to configure my
workspace. For now I use a **Ubuntu** distribution.

The [**setup.sh**](setup.sh) script when running creates the following directory structure in a specified **SETUP_PATH**:
 - **tools** - if it requires to download certain dev tools, this is the folder used to store them. *e.g. maven, jetbrains-toolbox, etc.*
 - **private** - here we will store secrets like the GitHub ssh keys, bash customization file and if an **aliases** file is present with your personal aliases, it will be added to your ***bashrc*** profile
 - **work** - here you will find clones of all your GitHub repositories
 - **containers** - this will be the home directory where any **docker** services used will hold their data *(e.g. dpostgres will store the databases there)*

Get started
------------
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

What does it do?
------------
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

The aliases generated and how to use them
------------
#### Miscellaneous
- **gg** - Shows the latest 3 git tags and shows the git status
- **myip** - Shows your IPs

#### Consul
- **dconsul** - Starts consul docker container
- **econsul** - Executes consul command into the consul docker container
```bash
$  econsul members
```

#### Postgres
- **dpostgres** - Starts potgres docker container
- **epsql** - Executes command inside the docker postgres container
```bash
# To restore a database dump
$ cat DB_BACKUP_FILE | epsql DB_NAME
```
- **dpgadmin** - Starts PgAdmin in a docker container. It can be accessed at: http://0.0.0.0:5050/browser/

#### MongoDb
- **dmongo** - Starts mongodb docker container
- **emongo** - Gain access to the mongo shell client from the docker container
- **emongodump** - You can use this to create a mongo database backup file
```bash
# Create a dump file for a given database
$ emongodump DB_NAME | DB_BACKUP_FILE.gz
```
- **emongorestore** - You can use this to restore a mongo database from a backup file
```bash
# To restore in the same database
$ cat  DB_BACKUP_FILE.gz | emongorestore
# To restore in a different database
$ cat  DB_BACKUP_FILE.gz | emongorestore "OLD_DB_NAME.*" --nsTo "NEW_DB_NAME.*"
```

#### RabbitMq
- **drabbit** - Starts the rabbitmq docker container. It's started with the management console enabled. You can access it at http://localhost:15672 with default user/pass **guest/guest**

#### MySql 5.7 (for now)
- **dmysql** - Starts the mysql docker container
- **emysqldump** - You can use this to create mysql database backups
```bash
# To create a database backup file
$ emysqldump DB_NAME > DB_BACKUP_FILE.sql
```
- **emysqlrestore** - You can use this to restore a mysql database backup
```bash
# To restore a database backup file
$ cat DB_BACKUP_FILE.sql | emysqlrestore DB_NAME
```

##### ***Feel free to contribute in any way.***
