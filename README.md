config-scripts
==============

***Atenttion:*** This script used to create some docker container services, now
those have moved at a new repo [bogdanmic/dev-container-services](https://github.com/bogdanmic/dev-container-services).


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
- Install **PgAdmin4** (UI for Postgres)
- Install **MongoDB Compass** (UI for MongoDB)
- Install: **MySql Workbench** (UI for Mysql)
- Install **java11 and java8 (openjdk-11-jdk openjdk-8-jdk)**. We installed java8 before Oracle changed his licence policies. To change from one version of Java to another ```$ sudo update-alternatives --config java```
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

##### ***Feel free to contribute in any way.***
