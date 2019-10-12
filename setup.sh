#!/bin/bash
#
# I use this script to install all the stuff I ned for development on a fresh linux.
# I use Ubuntu mainly or other ubuntu based distributions like Linux Mint. 
# I'm not saying is the best choice nut it's ok.
#

output(){
  printf " >>> \e[32m%s\e[39m" "$1" > /dev/stderr
  if [[ ! -z "$2" ]]; then
    printf " \e[34m%s\e[39m " "[$2]" > /dev/stderr
  fi

  if [[ ! $3 ]]; then
    printf "\n" > /dev/stderr
  fi
}

continueYesNo() {
  output "$1" "Y/n" false
  read -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    # 0 = true
    return 0
  else
    # 1 = false
    return 1
  fi
}

askInput() {
  output "$1" "$2" false

  read -e input
  # If empty, use the default
  inputOrDefault=${input:=$2}
  echo $inputOrDefault # This is how we return something
}

customizeBash(){
  # The $SETUP_PATH_PRIVATE is initialized when the script starts
  mkdir -p $SETUP_PATH_PRIVATE
  echo $1 >> $BASH_CUSTOMIZATION_FILE
}

appendFileToBashProfile(){
  if [ -f $1 ]; then
    echo -e "if [ -f $1 ]; then \n\t. $1 \nfi" >> ~/.bashrc

    output "File [$1] was added!"
  else
    output "File [$1] does not exist!"
  fi
}


SETUP_PATH=$(askInput "Where do you want to do the setup? SETUP_PATH:" $(pwd))
if [[ -d $SETUP_PATH ]]; then
    output "Start working in..." $SETUP_PATH
else
    output "[$SETUP_PATH] is not valid directory."
    exit 1
fi

# Define paths that we will use (All these have the slash because we added above)
SETUP_PATH_WORK=$(realpath ${SETUP_PATH}/work)
SETUP_PATH_TOOLS=$(realpath ${SETUP_PATH}/tools)
SETUP_PATH_PRIVATE=$(realpath ${SETUP_PATH}/private)

output "This script will use the following paths where applicable:"
output "   to store keys and customization files" $SETUP_PATH_PRIVATE
output "   to store your GitHub repositories" $SETUP_PATH_WORK
output "   to store tools that we will use for development" $SETUP_PATH_TOOLS

ask="Continue?"
if ! continueYesNo "$ask"; then
    exit 1
fi

sudo apt install -y curl

#TODO: generate the files from the start and then just append to them if they don' exist
BASH_CUSTOMIZATION_FILE=$SETUP_PATH_PRIVATE/bash_customization
BASH_PRIVATE_FILE=$SETUP_PATH_PRIVATE/aliases

ask="Install: git, git-flow?"
if continueYesNo "$ask"; then
    sudo apt install -y git git-flow

    ask="Configure  GIT?"
    if continueYesNo "$ask"; then
        github_username=$(askInput "Enter your GIT user.name: " $github_username)
        github_useremail=$(askInput "Enter your GIT user.email: " $github_useremail)

        git config --global user.name "$github_username"
        git config --global user.email "$github_useremail"
        git config --global color.ui auto
        git config -l
    fi

    ask="Setup GitHub SSH key?"
    if continueYesNo "$ask"; then
        mkdir -p $SETUP_PATH_PRIVATE
        mkdir -p ~/.ssh/

        ssh-keygen -t rsa -b 4096 -C "$(git config --global user.email)" -f $SETUP_PATH_PRIVATE/id_rsa_github
        ln -sf $SETUP_PATH_PRIVATE/id_rsa_github ~/.ssh/
        $(ssh-agent -s)
        echo "IdentityFile ~/.ssh/id_rsa_github" >> ~/.ssh/config
        ssh-add ~/.ssh/id_rsa_github

        github_username=$(askInput "Enter your GitHub user.name" $github_username)

        curl -u "$github_username" \
          --data "{\"title\":\"`lsb_release -ds`-`date +%Y-%m-%d-%H:%M:%S`\",\"key\":\"`cat $SETUP_PATH_PRIVATE/id_rsa_github.pub`\"}" \
          https://api.github.com/user/keys
    fi

    output '!!! This might take quite a while. All = max 300 (3 requests, each time input the password)!!!'
    ask="Clone all your GitHub repos?"
    if continueYesNo "$ask"; then
        mkdir -p $SETUP_PATH_WORK
        cd $SETUP_PATH_WORK

        github_username=$(askInput "Enter your GitHub user.name" $github_username)

        curl -u "$github_username" "https://api.github.com/user/repos?page=1&per_page=100" | grep -e 'ssh_url*' | cut -d \" -f 4 | xargs -L1 git clone
        curl -u "$github_username" "https://api.github.com/user/repos?page=2&per_page=100" | grep -e 'ssh_url*' | cut -d \" -f 4 | xargs -L1 git clone
        curl -u "$github_username" "https://api.github.com/user/repos?page=3&per_page=100" | grep -e 'ssh_url*' | cut -d \" -f 4 | xargs -L1 git clone
    fi

    ask="Configure your Terminal prompt for GIT?"
    if continueYesNo "$ask"; then
        customizeBash 'export PS1='\''${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;31m\]$(declare -F __git_ps1 &>/dev/null && __git_ps1 " (%s)")\[\033[00m\]\[\033[01;36m\]:\$\[\033[00m\] '\'
        customizeBash 'export GIT_PS1_SHOWDIRTYSTATE=true'
        customizeBash 'export GIT_PS1_SHOWUNTRACKEDFILES=true'
        customizeBash 'alias gg='\''echo "Latest 3 tags:" && git tag --sort=-version:refname | head -n 3 && git status -sb'\'
        customizeBash "alias myip='ifconfig | sed -En '\''s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'\'"
    fi
    output "SUCCESS!"
fi

ask="Install: filezilla, vlc, firefox, vim, net-tools?"
if continueYesNo "$ask"; then
    sudo apt install -y filezilla vlc firefox vim net-tools
    output "SUCCESS!"
fi

ask="Install: chrome?"
if continueYesNo "$ask"; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo apt install -y -f
    rm google-chrome-stable_current_amd64.deb
    output "SUCCESS!"
fi

ask="Install: skype?"
if continueYesNo "$ask"; then
    wget https://repo.skype.com/latest/skypeforlinux-64.deb
    sudo dpkg -i skypeforlinux-64.deb
    sudo apt install -y -f
    rm skypeforlinux-64.deb
    output "SUCCESS!"
fi

ask="Install: dbeaver (sql client)?"
if continueYesNo "$ask"; then
    wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
    sudo dpkg -i dbeaver-ce_latest_amd64.deb
    sudo apt install -y -f
    rm dbeaver-ce_latest_amd64.deb
    output "SUCCESS!"
fi

ask="Install: numix-icon-theme-circle?"
if continueYesNo "$ask"; then
    sudo add-apt-repository -y ppa:numix/ppa
    sudo apt update
    sudo apt install -y numix-icon-theme-circle
    output "SUCCESS!"
fi

ask="Install: papirus-icon-theme?"
if continueYesNo "$ask"; then
    sudo add-apt-repository -y ppa:papirus/papirus
    sudo apt update
    sudo apt install -y papirus-icon-theme
    output "SUCCESS!"
fi

ask="Install: docker, docker-compose?"
if continueYesNo "$ask"; then
    sudo apt remove docker docker-engine docker.io containerd runc
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    # echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker-ce.list
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" | sudo tee /etc/apt/sources.list.d/docker-ce.list
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-compose
    sudo usermod -aG docker $USER

    output "SUCCESS!"
fi

ask="Install: PGAdmin4 (UI for Postgres)?"
if continueYesNo "$ask"; then
    sudo apt-get install curl ca-certificates gnupg
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    sudo apt update
    sudo apt install -y pgadmin4
fi

ask="Install: MongoDB Compass (UI for MongoDB)?"
if continueYesNo "$ask"; then
    wget -O mongodb-compass_amd64.deb https://downloads.mongodb.com/compass/mongodb-compass_1.19.12_amd64.deb
    sudo dpkg -i mongodb-compass_amd64.deb
    sudo apt install -y -f
    rm mongodb-compass_amd64.deb
    output "SUCCESS!"
fi

# TODO: This does not work because of some missing dependencies.At least not on kubuntu 19.04
ask="Install: MySql Workbench (UI for Mysql)?"
if continueYesNo "$ask"; then
    wget -O mysql-workbench-community_amd64.deb https://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community_8.0.16-1ubuntu18.04_amd64.deb
    sudo dpkg -i mysql-workbench-community_amd64.deb
    sudo apt install -y -f
    rm mysql-workbench-community_amd64.deb
    output "SUCCESS!"
fi

# TODO: Install SDKMan (Software Development Kit Manager - Java and others)?
ask="Install: SDKMan (Software Development Kit Manager)?"
if continueYesNo "$ask"; then
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    ask="Install: Java 8 & 11 using SDKMan?"
    if continueYesNo "$ask"; then
        sdk install java 11.0.2-open
        sdk install java 8.0.222.hs-adpt
    fi
    output "SUCCESS!"
fi

ask="Install: maven, activator, JetBrains ToolBox?"
if continueYesNo "$ask"; then
    sudo apt install -y zip gzip tar
    mkdir -p $SETUP_PATH_TOOLS

    # Get maven
    wget http://mirrors.hostingromania.ro/apache.org/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.zip -P $SETUP_PATH_TOOLS
    unzip -o $SETUP_PATH_TOOLS/apache-maven-3.6.2-bin.zip -d $SETUP_PATH_TOOLS && rm $SETUP_PATH_TOOLS/apache-maven-3.6.2-bin.zip
    # Add maven to PATH
    customizeBash "PATH=\$PATH:$SETUP_PATH_TOOLS/apache-maven-3.6.2/bin"
    customizeBash 'export MAVEN_OPTS="-Xmx512m"'

    # Get typesafe activator
    wget http://downloads.typesafe.com/typesafe-activator/1.3.12/typesafe-activator-1.3.12-minimal.zip -P $SETUP_PATH_TOOLS
    unzip -o $SETUP_PATH_TOOLS/typesafe-activator-1.3.12-minimal.zip -d $SETUP_PATH_TOOLS && rm $SETUP_PATH_TOOLS/typesafe-activator-1.3.12-minimal.zip
    # Add activator to PATH
    customizeBash "PATH=\$PATH:$SETUP_PATH_TOOLS/activator-1.3.12-minimal/bin"

    # Get JetBrains ToolBox app that makes it easier to update InteliJ ad get it.
    wget -qO- https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.15.5796.tar.gz | tar xvz -C $SETUP_PATH_TOOLS
    output "SUCCESS!"
fi

ask="Install: nodejs?"
if continueYesNo "$ask"; then
    # TODO: Linux Mint Tina(19.2) is not supporte atm so we commented this out.
    # wget -qO- https://deb.nodesource.com/setup_10.x | sudo -E bash -

    curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
    VERSION=node_10.x
    # DISTRO="$(lsb_release -s -c)" # This works on Ubuntu distributions
    DISTRO="bionic" # Beause Linux Mint Tina(19.2) is not spported
    echo "deb https://deb.nodesource.com/$VERSION $DISTRO main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    echo "deb-src https://deb.nodesource.com/$VERSION $DISTRO main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list
    sudo apt update && sudo apt install -y nodejs
    output "SUCCESS!"

    ask="Install: yarn?"
    if continueYesNo "$ask"; then
        curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
        sudo apt update && sudo apt install -y yarn
        output "SUCCESS!"
    fi
fi

ask="Install: Tilix terminal?"
if continueYesNo "$ask"; then
    sudo add-apt-repository -y ppa:webupd8team/terminix
    sudo apt-get update
    sudo apt-get install -y tilix
    sudo update-alternatives --config x-terminal-emulator
    output "SUCCESS!"
fi

ask="Add any private aliases found in ${BASH_PRIVATE_FILE} file?"
if continueYesNo "$ask"; then
    if [ -f $BASH_PRIVATE_FILE ]; then
      appendFileToBashProfile $BASH_PRIVATE_FILE
      output "SUCCESS!"
    else
      output "File $BASH_PRIVATE_FILE does not exist."
    fi
fi

ask="Install: vscode ide?"
if continueYesNo "$ask"; then
    wget -O vscode.deb https://update.code.visualstudio.com/latest/linux-deb-x64/stable
    sudo dpkg -i vscode.deb
    sudo apt install -y -f
    rm vscode.deb
    ask="Install: vscode ide - settings sync extension?"
    if continueYesNo "$ask"; then
      code --install-extension Shan.code-settings-sync
    fi
    output "SUCCESS!"
fi

ask="Install: Postman?"
if continueYesNo "$ask"; then
    # TODO: At some point consider snap packages
    wget -qO- https://dl.pstmn.io/download/latest/linux64 | tar xvz -C $SETUP_PATH_TOOLS
    # Add postman to PATH
    customizeBash "PATH=\$PATH:$SETUP_PATH_TOOLS/Postman"
    echo -e "[Desktop Entry]\n
      Version=1.0\n
      Type=Application\n
      Terminal=false\n
      Exec=$SETUP_PATH_TOOLS/Postman/Postman\n
      Name=Postman\n
      Comment=Postman\n
      Icon=$SETUP_PATH_TOOLS/Postman/app/resources/app/assets/icon.png" > $SETUP_PATH_TOOLS/Postman.desktop
    mkdir -p ~/.local/share/applications/
    sudo ln -s $SETUP_PATH_TOOLS/Postman.desktop ~/.local/share/applications/
    output "SUCCESS!"
fi

ask="Install: slack-desktop?"
if continueYesNo "$ask"; then
    # TODO: At some point consider snap packages
    wget -O slack-desktop.deb https://downloads.slack-edge.com/linux_releases/slack-desktop-4.1.1-amd64.deb
    sudo dpkg -i slack-desktop.deb
    sudo apt install -y -f
    rm slack-desktop.deb
    output "SUCCESS!"
fi

ask="Install: awscli?"
if continueYesNo "$ask"; then
    curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip
    unzip awscli-bundle.zip
    sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    rm -R awscli-bundle*

  ask="Configure awscli?"
  if continueYesNo "$ask"; then
      aws configure
  fi
  output "SUCCESS!"
fi

output "Add all the bash customization that we did to the ~/.bashrc file ..."
appendFileToBashProfile $BASH_CUSTOMIZATION_FILE

output "Cheching for updates ..."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

ask="Reboot?"
if continueYesNo "$ask"; then
    sudo reboot
fi