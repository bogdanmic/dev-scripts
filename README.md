config-scripts
==============

This is collection of scripts that I use on my linux machine to configure my
workspace. For now I use a **Ubuntu** distribution.

Ubuntu 18.04
------------
The [**setup.sh**](setup.sh) script when running creates directories in a specified WORK_PATH.

To  get started:
 ```bash
 $ bash <(curl -s https://raw.githubusercontent.com/bogdanmic/config-scripts/master/setup.sh)
 ```
 **NOTICE** Since you are executing an untrusted script from the interwebs, I
 would recommend you to take a look at ti before proceeding. So probably you
 should do this.
 ```bash
 $ git clone https://github.com/bogdanmic/config-scripts.git
 $ cd config-scripts
 $ ./setup.sh
 ```

The folder it creates:
 - **tools** - here downloads tools like maven, node, etc.
 - **secrets** - generates the GitHub ssh keys
 - **work** - clones all your git repositories
 - **containers** - the home directory where any containers started by then
 setup will hold their data (e.g. dpostgres will store the databses there)

What does it do?
 - installs: git, git-flow, vim, filezilla, vlc, virtualbox, firefox, chrome,
 skype, numix-icon-theme-circle, **atom ide**, docker, docker-compose, java8, yarn,
 node, maven, typesafe activator, JetBrains ToolBox (makes easier to install and
 update JetBrains products), dbeaver, awscli, net-tools
 - makes your terminal prompt nice
 - configures git
 - create a github ssh-key file for your github account
 - clones all your github repositories
 - creates some aliases to start services inside containers:
   - dconsul - starts consul
   - econsul - executes consul commands in the started consul container
   - dpostgres - starts a postgres database
   - dpgadmin - starts pgadmin4
 - if you have a folder named **private** in the same folder where you cloned
 this repo, then this is also possible:
   - any aliases in the file **aliases** will be added to your bashrc

***Feel free to contribute in any way.***
