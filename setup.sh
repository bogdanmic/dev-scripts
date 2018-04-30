#!/bin/bash
#
# I use this script to install all the stuff I ned for development on a fresh linux.
# I use Ubuntu mainly. I'm not saying is the best choice nut it's ok.
#

# TODO: Maybe when adding content to the .bashrc file, instead create a file in
# the SETUP_PATH and add the changes inthere, then include that file into .bashrc

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

echo -en "\e[32mEnter the PATH where to do the setup\e[34m[$(pwd)]:\e[39m: "
read -e SETUP_PATH
# If empty use the current directory
name=${SETUP_PATH:=$(pwd)}
if [[ -d $SETUP_PATH ]]; then
    # case "$SETUP_PATH" in
    #   */)
    #     # The path has a trailing slash
    #   ;;
    #   *)
    #     # The path doesn't have a trailing slash
    #     SETUP_PATH=$SETUP_PATH/
    #   ;;
    # esac
    echo "Start working in [$SETUP_PATH] ..."
else
    echo -e "\e[31m[$SETUP_PATH] is not valid directory.\e[39m"
    exit 1
fi

# Define paths that we will use (All these have the slash because we added above)
SETUP_PATH_SECRETS=$(realpath ${SETUP_PATH}/secrets)
SETUP_PATH_WORK=$(realpath ${SETUP_PATH}/work)
SETUP_PATH_CONTAINERS=$(realpath ${SETUP_PATH_CONTAINERS}/containers)
SETUP_PATH_TOOLS=$(realpath ${WORK_PATH}/tools)
SETUP_PATH_PRIVATE=$(realpath ${WORK_PATH}/private)

ask="Install: git, git-flow?"
if continueYesNo "$ask"; then
    sudo apt install -y git git-flow

    ask="Configure  GIT?"
    if continueYesNo "$ask"; then
        echo -n "Enter your user.name and press [ENTER]: "
        read username
        echo "!!! This email will be used when configureing your GitHub SSH key !!!"
        echo -n "Enter your user.email and press [ENTER]: "
        read useremail
        git config --global user.name "$username"
        git config --global user.email "$useremail"
        git config --global color.ui auto
        git config -l
    fi

    ask="Setup GitHub SSG key?"
    if continueYesNo "$ask"; then
        mkdir -p $SETUP_PATH_SECRETS
        mkdir ~/.ssh/

        ssh-keygen -t rsa -b 4096 -C "$(git config --global user.email)" -f $SETUP_PATH_SECRETS/id_rsa_github
        ln -sf $SETUP_PATH_SECRETS/id_rsa_github ~/.ssh/
        eval "$(ssh-agent -s)"
        echo "IdentityFile ~/.ssh/id_rsa_github" >> ~/.ssh/config
        ssh-add ~/.ssh/id_rsa_github
        echo -n "Enter your GitHub username and press [ENTER]: "
        read githubusername
        curl -u "$githubusername" \
          --data "{\"title\":\"`lsb_release -ds`-`date +%Y-%m-%d-%H:%M:%S`\",\"key\":\"`cat $SETUP_PATH_SECRETS/id_rsa_github.pub`\"}" \
          https://api.github.com/user/keys
    fi

    echo '!!! This might take quite a while. All = max 150 !!!'
    ask="Clone all your GitHub repos?"
    if continueYesNo "$ask"; then
        mkdir -p $SETUP_PATH_WORK
        cd $SETUP_PATH_WORK

        echo -n "Enter your GitHub username and press [ENTER]: "
        read githubusername
        curl -u "$githubusername" "https://api.github.com/user/repos?page=1&per_page=150" | grep -e 'ssh_url*' | cut -d \" -f 4 | xargs -L1 git clone
    fi

    ask="Configure your Terminal prompt for GIT?"
    if continueYesNo "$ask"; then
        echo 'export PS1='\''${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;31m\]$(declare -F __git_ps1 &>/dev/null && __git_ps1 " (%s)")\[\033[00m\]\[\033[01;36m\]:\$\[\033[00m\] '\' >> ~/.bashrc
        echo 'export GIT_PS1_SHOWDIRTYSTATE=true' >> ~/.bashrc
        echo 'export GIT_PS1_SHOWUNTRACKEDFILES=true' >> ~/.bashrc
        echo 'alias gg='\''git status -sb'\' >> ~/.bashrc
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
    # sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
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
        echo "alias dconsul='docker run --rm -it --net=host --name dev-consul consul'" >> ~/.bashrc
        # This allows us to execute command inside the dev-consul container
        echo "alias econsul='docker exec dev-consul consul'" >> ~/.bashrc
        mkdir -p $SETUP_PATH_CONTAINERS

        echo -n "Enter your POSTGRES_USER and press [ENTER]: "
        read postgresuser
        echo -n "Enter your POSTGRES_PASSWORD and press [ENTER]: "
        read postgrespassword
        echo "alias dpostgres='docker run --rm -it -p 5432:5432 --name=dev-postgres -e POSTGRES_USER=$postgresuser -e POSTGRES_PASSWORD=$postgrespassword -v $SETUP_PATH_CONTAINERS/postgres_home:/var/lib/postgresql/data postgres -c \"log_statement=all\" -c \"log_duration=on\" -c \"log_min_duration_statement=-1\"'" >> ~/.bashrc
        mkdir -p $SETUP_PATH_CONTAINERS/pgadmin_home
        sudo chmod -R 777 $SETUP_PATH_CONTAINERS/pgadmin_home
        echo "alias dpgadmin='docker run --rm -it --net=host --name=dev-pgadmin -v $SETUP_PATH_CONTAINERS/pgadmin_home:/pgadmin thajeztah/pgadmin4'" >> ~/.bashrc
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
        echo "PATH=\$PATH:$SETUP_PATH_TOOLS/apache-maven-3.5.3/bin" >> ~/.bashrc
        echo 'export MAVEN_OPTS="-Xmx512m"' >> ~/.bashrc

        # Get nodejs (This gets installed by yarn so we don't do this for now)
        # wget https://nodejs.org/dist/v8.11.1/node-v8.11.1-linux-x64.tar.xz -P $tools_abs_path
        # tar xf $tools_abs_path/node-v8.11.1-linux-x64.tar.xz -C $tools_abs_path && rm $tools_abs_path/node-v8.11.1-linux-x64.tar.xz
        # echo "PATH=\$PATH:$tools_abs_path/node-v8.11.1-linux-x64/bin" >> ~/.bashrc

        # Get typesafe activator
        wget  http://downloads.typesafe.com/typesafe-activator/1.3.12/typesafe-activator-1.3.12-minimal.zip -P $SETUP_PATH_TOOLS
        unzip -o $SETUP_PATH_TOOLS/typesafe-activator-1.3.12-minimal.zip -d $SETUP_PATH_TOOLS && rm $SETUP_PATH_TOOLS/typesafe-activator-1.3.12-minimal.zip
        # Add activator to PATH
        echo "PATH=\$PATH:$SETUP_PATH_TOOLS/activator-1.3.12-minimal/bin" >> ~/.bashrc

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

ask="Add any private aliases found in ${SETUP_PATH_PRIVATE}/aliases file?"
if continueYesNo "$ask"; then
    FILE=$SETUP_PATH_PRIVATE/aliases
    if [ -f $FILE ]; then
      // TODO: Instead of appending the file inside .bashrc, include it so when
      // you add more aliases they are taken into consideration
      cat $FILE >> ~/.bashrc
      echo "SUCCESS!"
    else
      echo "File $FILE does not exist."
    fi
fi

ask="Install awscli?"
if continueYesNo "$ask"; then
  sudo apt install -y python-pip
  pip install awscli --upgrade --user
  echo "PATH=\$PATH:~/.local/bin" >> ~/.bashrc
  read -p $'\e[32mConfigure awscli?[Y/n]\e[39m ' -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
      ~/.local/bin/aws configure
  fi
fi

echo "Cheching for updates ..."
sudo apt update
sudo apt -y upgrade

ask="31mReboot?"
if continueYesNo "$ask"; then
    sudo reboot
fi
