config-scripts
==============

This is collection of scripts that I use on my linux machine to configure my
workspace. For now I use a **Ubuntu** distribution. It should work fairly decent with all **Ubuntu** based distros.

The [**setup.sh**](setup.sh) script when running creates the following directory 
structure in a specified **SETUP_PATH**:
 - **tools** - if it requires to download certain dev tools, this is the folder 
 used to store them. *e.g. maven, jetbrains-toolbox, etc.*
 - **private** - here we will store secrets like the GitHub ssh keys, bash 
 customization file and if an **aliases** file is present with your personal 
 aliases, it will be added to your ***bashrc*** profile
 - **work** - here you will find clones of all your GitHub repositories
 - **containers** - this will be the home directory where any **docker** services 
 used will hold their data *(e.g. dpostgres will store the databases there)*

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
If you want to go through the steps without any changes to your computer you can 
run it like this
 ```bash
 $ ./setup.sh --dry-run
 ```

What does it do?
------------
This script runs in multiple steps that are optional and some depend on others. 
These steps are in order with their substeps:
- Install **git, git-flow**
  - Configure  GIT
  - Setup GitHub SSH key
  - Clone all your GitHub repositories (3 api requests of 100 each)
  - Configure your Terminal prompt for GIT
- Install **filezilla, vlc, firefox, vim, net-tools**
- Install **chrome** browser
- Install **skype**
- Install **dbeaver** (sql client)
- Install **numix-icon-theme-circle** this is just a icon theme I like, suited for a dock setup
- Install **papirus-icon-theme** this is just a icon theme I like, suited for a classic setup
- Install **docker, docker-compose**
  - Add aliases for docker consul(**dconsul,econsul**), 
  docker postgresql(**dpostgres**), docker pgadmin4(**dpgadmin**)
  - Add aliases for docker mongo(**dmongo,emongo**)
    - Install **MongoDB Compass** (UI for MongoDB)
  - Add aliases for docker rabbitmq(**drabbit**)
  - Add aliases for docker mysql 5.7(**dmysql**)
    - Install: **MySql Workbench** (UI for Mysql)
  - Add aliases for docker elasticsearch(**delastic**),  docker kibana(**dkibana**)
- Install **java11 (openjdk-11)**. We installed java8 before Orachle changed his licence policies.
  - Install **maven, activator, JetBrains ToolBox** (makes it easier to install and
  update JetBrains products)
- Install **nodejs**
  - Install **yarn**
- Install **Tilix** tiling terminal emulator
- Add any private aliases found in the **aliases** file
- Install **vscode ide** a quite decent and lightweight IDE and an alternative 
to **atom ide**. Add a extension for **Settings sync** to github.
- Install **Postman** a rest client app. Can be invoked with Postman from a 
terminal or it should appear in the start menu.
- Install **Slack App**
- Install **awscli**. This one needs a bit more testing...
  - Configure awscli
- Add all the bash customization that we did to the **~/.bashrc** file.
- Update and Reboot

The aliases generated and how to use them
------------
#### Miscellaneous
- **gg** - Shows the latest 3 git tags and shows the git status
- **myip** - Shows your IPs

#### [Consul](https://www.consul.io/)
- **dconsul** - Starts consul docker container
- **econsul** - Executes consul command into the consul docker container
```bash
$  econsul members
```

#### [Postgres](https://www.postgresql.org/)
- **dpostgres** - Starts potgres docker container
- **epsql** - Executes command inside the docker postgres container
```bash
# To restore a database dump
$ cat DB_BACKUP_FILE | epsql DB_NAME
```
- **dpgadmin** - Starts PgAdmin in a docker container. It can be accessed at: 
[http://0.0.0.0:5050/browser/](http://0.0.0.0:5050/browser/)

#### [MongoDb](https://www.mongodb.com/)
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

#### [RabbitMQ](https://www.rabbitmq.com/)
- **drabbit** - Starts the rabbitmq docker container. It's started with the 
management console enabled. You can access it at [http://localhost:15672](http://localhost:15672) 
with default user/pass **guest/guest**

#### [MySQL](https://www.mysql.com/) 5.7 (for now)
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

#### [ElasticSearch](https://www.elastic.co/products/elasticsearch/)
- **delastic** - Starts ElasticSearch docker container
- **dkibana** - Starts Kibana docker container. It can be accessed at: 
[http://localhost:5601](http://localhost:5601)

This is a strange case. We create two mounted volumes for this:
- ***elasticsearch_home*** - here we will store the elasticsearch database
- ***elasticsearch_backups*** - here we will store snapshots(backups) of our indices

To view all available indices in your elastic search access 
[http://localhost:9200/_cat/indices?pretty](http://localhost:9200/_cat/indices?pretty)

Now we can create snapshots for our indices:
```bash
# Register a folder  where we will create some snapshots. I usually do a folder for each  index
# BACKUP_FOLDER_NAME = the index name
$ curl -X PUT \
      "http://localhost:9200/_snapshot/BACKUP_FOLDER_NAME" \
      -H 'content-type: application/json' \
      -d "{
            \"type\": \"fs\",
            \"settings\": {
                \"location\": \"BACKUP_FOLDER_NAME\",
                \"compress\": true
            }
        }"

# Now to trigger a snapshot of the desired index
# We use the previous define BACKUP_FOLDER_NAME.
# The backups are incremental so SNAPSHOT_NAME needs to be unique.
# For each snapshot we can specify what indices to include but we do only one INDEX_NAME
$ curl -X PUT \
      "http://localhost:9200/_snapshot/BACKUP_FOLDER_NAME/SNAPSHOT_NAME?wait_for_completion=true" \
      -H 'content-type: application/json' \
      -d "{
          \"indices\": \"INDEX_NAME\",
          \"ignore_unavailable\": true,
          \"include_global_state\": false
        }"
```
Bellow we will handle the restoring of a snapshot that we got from another elastic search server.
Usually this is done by copying the BACKUP_FOLDER_NAME from that server onto the new one and following the next steps.
```bash
# Now if you followed the recommendations above, you should be in possession of a tar/zip file
# that contains the BACKUP_FOLDER_NAME created above Take that and extract it into
# your elasticsearch_backups folder so we can start the restore process.
# If elastic search was running while you added the contents to the folder, you need to restart it.
$ curl -X PUT \
      "http://localhost:9200/_snapshot/BACKUP_FOLDER_NAME" \
      -H 'content-type: application/json' \
      -d "{
            \"type\": \"fs\",
            \"settings\": {
                \"location\": \"BACKUP_FOLDER_NAME\",
                \"compress\": true
            }
        }"
```
Now that you registered the backup repository, if you go to http://localhost:9200/_snapshot/BACKUP_FOLDER_NAME/_all you should see all available snapshots that were created. Pick the one you want to restore and:
```bash
# SNAPSHOT_NAME is a name picked from the available snapshots
$ curl -X POST \
      http://localhost:9200/_snapshot/BACKUP_FOLDER_NAME/SNAPSHOT_NAME/_restore \
      -H 'content-type: application/json'
```
To monitor the restore progress you can access http://localhost:9200/_snapshot/BACKUP_FOLDER_NAME/SNAPSHOT_NAME

For more details you can read the [official documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html).

After the restore is done you can access the index you restored http://localhost:9200/INDEX_NAME/_search

##### ***Feel free to contribute in any way.***
