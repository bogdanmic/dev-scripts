dev-scripts
==============

A collection of shell scripts to prepare a fresh install of a **Ubuntu** based 
distribution.

### Prerequisites
- A linux distribution based on **Ubuntu Focal Fossa** or later. I personally 
use [Linux Mint](https://linuxmint.com/) so it's very likely that the scripts 
will work for you if you do the same, otherwise there might be small issues.
- *(Optional)* **git** although recommended.
- *(Optional)* **curl**
- *(Optional)* **unzip** or some tool that will allow you un-archive a zip file.
- Switch to **ZSH** if you haven't already
  ```bash
  $ sudo apt install zsh -y
  $ sudo chsh -s /usr/bin/zsh $USER
  # Close and open your terminal again
  $ sudo wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
  $ sudo git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
  # nano ~./zshrc and change your theme to ZSH_THEME="powerlevel10k/powerlevel10k"
  # Install font from https://github.com/romkatv/powerlevel10k/blob/master/font.md#manual-font-installation
  # Select it as custom font for your terminal and update your Terminal font family for VS Code to "MesloLGS NF"
  $ sudo git clone https://github.com/zsh-users/zsh-autosuggestions  ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions 
  $ sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  # Update your .zshrc plugins to plugins=(git nvm zsh-autosuggestions zsh-syntax-highlighting)
  $ source ~/.zshrc
  ``` 

## The scripts
The scripts available are as follows:
- [install_apps.sh](install_apps.sh) - Install common applications.
- [install_custom.sh](install_custom.sh) - Install customization packages like 
icon packs and others.
- [install_dev.sh](install_dev.sh) - Installs applications used for development.
- [install_git.sh](install_git.sh) - Installs **git-flow**, helps to configure 
git and adds a few git related aliases. Recommended installation method is with 
**git** to be able to use the **git-flow aliases** provided.

Looking for **docker** related helpers, then check out [bogdanmic/dev-services](https://github.com/bogdanmic/dev-services).

## How to use
The recommended way is to clone the repository using git and then run the scripts
that you need.
```bash
# The preferred way of using the scripts.
$ git clone git@github.com:bogdanmic/dev-scripts.git
$ cd dev-scripts
# Make sure that the scripts are executable
$ sudo chmod 755 install_*
# Execute the desired scripts and follow the prompts
$ ./install_apps.sh
```
Or if you don't want to clone the repository then you can download it as a **zip**.

Another way is to execute the scripts you want, directly from the web like so:
```bash
$ sudo apt install -y curl
# Execute the install_apps.sh from github. You can choose any of the available scripts
$ bash <(curl -s https://raw.githubusercontent.com/bogdanmic/dev-scripts/master/install_apps.sh)
```

## The scripts detailed
The scripts provided will install packages and make minor changes to your system.
Here is a list of those changes and other helpful usage information for each
of them.

### [install_apps.sh](install_apps.sh)
Installs most common apps needed for a Linux machine. At least my most common apps.
#### Usage
```bash
$ ./install_apps.sh
```
#### Execution effect
This script runs in multiple steps, steps that are optional:
- Install: **filezilla, vlc, firefox, vim, net-tools, curl**
- Install: **chrome** browser
- Install: **Tilix terminal** tiling terminal emulator
- Install: **Slack Desktop**
- Install: **etcher** that helps you to "Flash OS images to SD cards & USB drives"
- Update and Reboot

### [install_custom.sh](install_custom.sh)
Installs popular icon-packs and other ZSH customization file that you might have.
#### Usage
```bash
# The /path/to/zsh/custom_file is optional and if not present some steps will be skipped
$ ./install_apps.sh /path/to/zsh/custom_file
```
#### Execution effect
This script runs in multiple steps, steps that are optional:
- Install: **numix-icon-theme-circle** this is just a icon theme I like, suited 
for a dock setup because it has circle icons
- Install: **papirus-icon-theme** this is just a icon theme I like, suited for 
a classic setup
- Install: any zsh customization/aliases file to the **~/.zshrc** file if 
a ```/optional/path/to/zsh/custom_file``` was provided.

### [install_dev.sh](install_dev.sh)
Installs packages and applications needed for a development work flow. Well the
ones I use at the moment at least.
#### Usage
```bash
# The /path/to/tools/download/folder is optional and if not present some steps will be skipped
$ ./install_dev.sh /path/to/tools/download/folder
```
#### Execution effect
This script runs in multiple steps, steps that are optional and some steps 
have sub-steps. Some of the steps require a distribution based on **Focal Fossa**
or later:
- Install: **vscode ide**
- Install: **SDKMan (Software Development Kit Manager)**. We will use this to 
manage multiple versions of java on the same machine. And it can do much more.
  - Install: **Java 17 & 21 using SDKMan**. To change from one version of Java to 
  another:
  ```bash
  # Make default java 21
  $ sdk default java 21.0.1-tem
  # Use java 17 in the current terminal session
  $ sdk use java 17.0.9-tem
  # For more usage example for sdkman check: https://sdkman.io/
  ```
  - Install: **maven using SDKMan**.
- Install: **nodejs** using **nvm**.
- Install: **docker, docker-compose**. *Focal Fossa or later required.
- Install: **dbeaver (sql client)**
- Install: **PGAdmin4 (UI for Postgres)**. *Focal Fossa or later required.
- Install: **MongoDB Compass (UI for MongoDB)**
- Install: **MySql Workbench (UI for Mysql)**
- Install: **awscli**. This one needs a bit more testing...
  - Configure awscli
- Install: **terraform**
- Install: **JetBrains ToolBox** if a ```/path/to/tools/download/folder```
 was provided. **JetBrains ToolBox** makes it easier to install and update 
 JetBrains products.
- Install: **Postman** if a ```/path/to/tools/download/folder``` was provided.
A rest client app. Can be invoked with Postman from a terminal or it should 
appear in the start menu.

### [install_git.sh](install_git.sh)
Installs **git-flow**, [GitHub Desktop un-official](https://github.com/shiftkey/desktop/releases)
and tries to help your development workflow especially if you are using 
[git-flow](https://nvie.com/posts/a-successful-git-branching-model/)
#### Usage
```bash
# The /path/to/private/folder is optional and if not present some steps will be skipped
$ ./install_git.sh /path/to/private/folder
```
#### Execution effect
This script runs in multiple steps, steps that are optional and have sub-steps:
- Install: **git, git-flow**
  - Configure  GIT
  - Prepares a GitHub SSH key if a ```/path/to/private/folder``` was provided.
  Due to MFA you will need to add the SSH key to your GitHub account.
  - Install: [GitHub Desktop un-official](https://github.com/shiftkey/desktop/releases)
  - Install: **git-flow alias helpers and git terminal prompt integration**

#### Available aliases
If you chose to install the **git-flow alias helpers** you have a bunch of them
available to you.
##### Available aliases
- ```gg``` - Displays the current git status and the latest 3 tags
- ```gitcpb``` - Checks out your previous branch
- And here are a few **git-flow** aliases:
  - ```gitfs``` - Update the ```develop``` branch and start a new *feature* branch.
  - ```gitfp``` - Publish your *feature* branch.
  - ```gitff``` - Update the ```develop``` branch, finish your *feature* branch
  **with squash** and push your changes. 
  - ```giths``` - Update the ```main``` branch and start a new *hotfix* branch.
  - ```githp``` - Publish your *hotfix* branch.
  - ```githf``` - Update the ```main``` and ```develop``` branches, finish your
   *hotfix* branch **with squash** and push your changes. 
  - ```gitrs``` - Update the ```develop``` branch and start a new *release* branch.
  - ```gitrp``` - Publish your *release* branch.
  - ```gitrf``` - Update the ```main``` and ```develop``` branches, finish your
   feature branch **without squash** and push your changes. 
The **git-flow** aliases they work on the current checked out feature/hotfix/release
branch. And that is how they are intended to be used.
##### Aliases usage examples
Here are some usage examples for the git-flow aliases described above. We will 
only cover the ones that expect some sort of argument or need some conditions
to be met.
```bash
# Starts a feature with the given name
$ gitfs feature_name
# The current branch needs to be the feature branch that we want to publish/finish
$ gitfp
$ gitff

# Starts a hotfix with the given name
$ giths hotfix_name
# The current branch needs to be the hotfix branch that we want to publish/finish
$ githp
$ githf

# Starts a release with the given name
$ gitrs release_name
# The current branch needs to be the release branch that we want to publish/finish
$ gitrp
$ gitrf
```
##### ***Feel free to contribute in any way.***
