#!/bin/bash
#
# I use this script to install all the stuff I ned for development on a fresh linux.
# I use Ubuntu mainly. I'm not saying is the best choice nut it's ok.
#

continueYesNo() {
  echo -en "\e[32m${1} \e[34m[Y/n]\e[39m "
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
  echo -en "\e[32m${1}:\e[39m " > /dev/stderr  # goes to the screen
  if [[ ! -z "$2" ]]; then
    # If default si present
    echo -en "\e[34m[$2]\e[39m " > /dev/stderr  # goes to the screen
  fi

  read -e input
  # If empty, use the default
  inputOrDefault=${input:=$2}
  echo $inputOrDefault # This is how we return something
}

customizeBash(){
  # The $SETUP_PATH_SECRETS is initialized when the script starts
  mkdir -p $SETUP_PATH_SECRETS
  echo $1 >> $BASH_CUSTOMIZATION_FILE
}

appendFileToBashProfile(){
  if [ -f $1 ]; then
    echo -e "if [ -f $1 ]; then \n\t. $1 \nfi" >> ~/.bashrc

    echo "File [$1] was added!"
  else
    echo -e "\e[31mFile [$1] does not exist!\e[39m"
  fi
}

SETUP_PATH=$(askInput "Enter the SETUP_PATH where to do the setup" $(pwd))
if [[ -d $SETUP_PATH ]]; then
    echo "Start working in [$SETUP_PATH] ..."
else
    echo -e "\e[31m[$SETUP_PATH] is not valid directory.\e[39m"
    exit 1
fi

# Define paths that we will use (All these have the slash because we added above)
SETUP_PATH_SECRETS=$(realpath ${SETUP_PATH}/secrets)
SETUP_PATH_WORK=$(realpath ${SETUP_PATH}/work)
SETUP_PATH_CONTAINERS=$(realpath ${SETUP_PATH}/containers)
SETUP_PATH_TOOLS=$(realpath ${SETUP_PATH}/tools)
SETUP_PATH_PRIVATE=$(realpath ${SETUP_PATH}/private)

BASH_CUSTOMIZATION_FILE=$SETUP_PATH_SECRETS/bash_customization
BASH_PRIVATE_FILE=$SETUP_PATH_PRIVATE/aliases

ask="Install: git, git-flow?"
if continueYesNo "$ask"; then
    sudo apt install -y git git-flow

    ask="Configure  GIT?"
    if continueYesNo "$ask"; then
        github_username=$(askInput "Enter your GIT user.name" $github_username)
        github_useremail=$(askInput "Enter your GIT user.email" $github_useremail)

        git config --global user.name "$github_username"
        git config --global user.email "$github_useremail"
        git config --global color.ui auto
        git config -l
    fi

    ask="Setup GitHub SSH key?"
    if continueYesNo "$ask"; then
        mkdir -p $SETUP_PATH_SECRETS
        mkdir -p ~/.ssh/

        ssh-keygen -t rsa -b 4096 -C "$(git config --global user.email)" -f $SETUP_PATH_SECRETS/id_rsa_github
        ln -sf $SETUP_PATH_SECRETS/id_rsa_github ~/.ssh/
        eval "$(ssh-agent -s)"
        echo "IdentityFile ~/.ssh/id_rsa_github" >> ~/.ssh/config
        ssh-add ~/.ssh/id_rsa_github

        github_username=$(askInput "Enter your GitHub user.name" $github_username)

        curl -u "$github_username" \
          --data "{\"title\":\"`lsb_release -ds`-`date +%Y-%m-%d-%H:%M:%S`\",\"key\":\"`cat $SETUP_PATH_SECRETS/id_rsa_github.pub`\"}" \
          https://api.github.com/user/keys
    fi

    echo '!!! This might take quite a while. All = max 150 !!!'
    ask="Clone all your GitHub repos?"
    if continueYesNo "$ask"; then
        mkdir -p $SETUP_PATH_WORK
        cd $SETUP_PATH_WORK

        github_username=$(askInput "Enter your GitHub user.name" $github_username)

        curl -u "$github_username" "https://api.github.com/user/repos?page=1&per_page=150" | grep -e 'ssh_url*' | cut -d \" -f 4 | xargs -L1 git clone
    fi

    ask="Configure your Terminal prompt for GIT?"
    if continueYesNo "$ask"; then
        customizeBash 'export PS1='\''${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;31m\]$(declare -F __git_ps1 &>/dev/null && __git_ps1 " (%s)")\[\033[00m\]\[\033[01;36m\]:\$\[\033[00m\] '\'
        customizeBash 'export GIT_PS1_SHOWDIRTYSTATE=true'
        customizeBash 'export GIT_PS1_SHOWUNTRACKEDFILES=true'
        customizeBash 'alias gg='\''git status -sb'\'
        customizeBash "alias myip='ifconfig | sed -En '\''s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'\'"
    fi
    echo "SUCCESS!"
fi

ask="Install: filezilla, vlc, virtualbox, firefox, vim, net-tools?"
if continueYesNo "$ask"; then
    sudo apt install -y filezilla vlc virtualbox firefox vim net-tools
    echo "SUCCESS!"
fi

ask="Install: chrome?"
if continueYesNo "$ask"; then
    sudo add-apt-repository -y "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"
    sudo curl -L https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo apt update
    sudo apt install google-chrome-stable
    echo "SUCCESS!"
fi

ask="Install: skype?"
if continueYesNo "$ask"; then
    wget https://repo.skype.com/latest/skypeforlinux-64.deb
    sudo dpkg -i skypeforlinux-64.deb
    sudo apt install -y -f
    rm skypeforlinux-64.deb
    echo "SUCCESS!"
fi

ask="Install: dbeaver (sql client)?"
if continueYesNo "$ask"; then
    wget https://dbeaver.jkiss.org/files/dbeaver-ce_latest_amd64.deb
    sudo dpkg -i dbeaver-ce_latest_amd64.deb
    sudo apt install -y -f
    rm dbeaver-ce_latest_amd64.deb
    echo "SUCCESS!"
fi

ask="Install: numix-icon-theme-circle?"
if continueYesNo "$ask"; then
    sudo add-apt-repository -y ppa:numix/ppa
    sudo apt update
    sudo apt install -y numix-icon-theme-circle
    echo "SUCCESS!"
fi

ask="Install: atom ide?"
if continueYesNo "$ask"; then
    sudo curl -L https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
    sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
    sudo apt update
    sudo apt install -y atom
    echo "SUCCESS!"
fi

ask="Install: docker, docker-compose?"
if continueYesNo "$ask"; then
    # Install docker
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    # In some cases if the Linux used is to fresh(new), then the docker package
    # might not be available yet so we can use the previous version one
    sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu artful stable"
    # sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install -y docker-ce
    sudo usermod -aG docker $USER

    # Install docker-compose
    sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo curl -L https://raw.githubusercontent.com/docker/compose/1.21.0/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

    echo "d[name] starts a container of the [name] service type"
    echo "e[name] executes a command in the container of the [name] service type"
    ask="Add aliases for docker consul(dconsul,econsul), docker postgresql(dpostgres), docker pgadmin4(dpgadmin)?"
    if continueYesNo "$ask"; then
        mkdir -p $SETUP_PATH_CONTAINERS

        customizeBash "alias dconsul='docker run --rm -it --net=host --name dev-consul consul'"
        # This allows us to execute command inside the dev-consul container
        customizeBash "alias econsul='docker exec -i dev-consul consul'"

        postgresuser=$(askInput "Enter your POSTGRES_USER" $postgresuser)
        postgrespassword=$(askInput "Enter your POSTGRES_PASSWORD" $postgrespassword)
        customizeBash "alias dpostgres='docker run --rm -it -p 5432:5432 --name=dev-postgres -e POSTGRES_USER=$postgresuser -e POSTGRES_PASSWORD=$postgrespassword -v $SETUP_PATH_CONTAINERS/postgres_home:/var/lib/postgresql/data postgres -c \"log_statement=all\" -c \"log_duration=on\" -c \"log_min_duration_statement=-1\"'"
        customizeBash "alias epsql='PGPASSWORD=$postgrespassword docker exec -i dev-postgres psql -h localhost -U $postgresuser '"
        
        mkdir -p $SETUP_PATH_CONTAINERS/pgadmin_home
        sudo chmod -R 777 $SETUP_PATH_CONTAINERS/pgadmin_home
        customizeBash "alias dpgadmin='docker run --rm -it --net=host --name=dev-pgadmin -v $SETUP_PATH_CONTAINERS/pgadmin_home:/pgadmin thajeztah/pgadmin4'"
    fi
    echo "SUCCESS!"
fi

ask="Install: java8?"
if continueYesNo "$ask"; then
    sudo add-apt-repository -y ppa:webupd8team/java
    sudo apt update
    sudo apt install -y oracle-java8-installer

    ask="Install: maven, activator, JetBrains ToolBox?"
    if continueYesNo "$ask"; then
        sudo apt install -y zip gzip tar
        mkdir -p $SETUP_PATH_TOOLS

        # Get maven
        wget -qO- http://mirrors.m247.ro/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz | tar xvz -C $SETUP_PATH_TOOLS
        # Add maven to PATH
        customizeBash "PATH=\$PATH:$SETUP_PATH_TOOLS/apache-maven-3.5.3/bin"
        customizeBash 'export MAVEN_OPTS="-Xmx512m"'

        # Get nodejs (This gets installed by yarn so we don't do this for now)
        # wget https://nodejs.org/dist/v8.11.1/node-v8.11.1-linux-x64.tar.xz -P $tools_abs_path
        # tar xf $tools_abs_path/node-v8.11.1-linux-x64.tar.xz -C $tools_abs_path && rm $tools_abs_path/node-v8.11.1-linux-x64.tar.xz
        # customizeBash "PATH=\$PATH:$tools_abs_path/node-v8.11.1-linux-x64/bin"

        # Get typesafe activator
        wget  http://downloads.typesafe.com/typesafe-activator/1.3.12/typesafe-activator-1.3.12-minimal.zip -P $SETUP_PATH_TOOLS
        unzip -o $SETUP_PATH_TOOLS/typesafe-activator-1.3.12-minimal.zip -d $SETUP_PATH_TOOLS && rm $SETUP_PATH_TOOLS/typesafe-activator-1.3.12-minimal.zip
        # Add activator to PATH
        customizeBash "PATH=\$PATH:$SETUP_PATH_TOOLS/activator-1.3.12-minimal/bin"

        # Get JetBrains ToolBox app that makes it easier to update InteliJ ad get it.
        wget -qO- https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.8.3678.tar.gz | tar xvz -C $SETUP_PATH_TOOLS
        echo "SUCCESS!"
    fi
    echo "SUCCESS!"
fi

ask="Install: yarn and node?"
if continueYesNo "$ask"; then
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update && sudo apt install -y yarn
    echo "SUCCESS!"
fi

ask="Add any private aliases found in ${BASH_PRIVATE_FILE} file?"
if continueYesNo "$ask"; then
    if [ -f $BASH_PRIVATE_FILE ]; then
      appendFileToBashProfile $BASH_PRIVATE_FILE
      echo "SUCCESS!"
    else
      echo "File $BASH_PRIVATE_FILE does not exist."
    fi
fi

ask="Install: awscli?"
if continueYesNo "$ask"; then
  sudo apt install -y python-pip
  pip install awscli --upgrade --user
  customizeBash "PATH=\$PATH:~/.local/bin"

  ask="Configure awscli?"
  if continueYesNo "$ask"; then
      ~/.local/bin/aws configure
  fi
fi

# Add all the bash customization that we did to the ~/.bashrc file.
appendFileToBashProfile $BASH_CUSTOMIZATION_FILE

echo "Cheching for updates ..."
sudo apt update
sudo apt -y upgrade

ask="Reboot?"
if continueYesNo "$ask"; then
    sudo reboot
fi
