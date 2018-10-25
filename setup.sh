#!/bin/bash
#
# I use this script to install all the stuff I ned for development on a fresh linux.
# I use Ubuntu mainly. I'm not saying is the best choice nut it's ok.
#

continueYesNo() {
  echo -en "\e[32m >>> ${1} \e[34m[Y/n]\e[39m "
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
  echo -en "\e[32m >>> ${1}:\e[39m " > /dev/stderr  # goes to the screen
  if [[ ! -z "$2" ]]; then
    # If default si present
    echo -en "\e[34m[$2]\e[39m " > /dev/stderr  # goes to the screen
  fi

  read -e input
  # If empty, use the default
  inputOrDefault=${input:=$2}
  echo $inputOrDefault # This is how we return something
}

runCommand() {
  if $DRY_RUN; then
    echo -e " >>> [DRY-RUN] \e[32m${1}\e[39m " > /dev/stderr  # goes to the screen
  else
    eval $1
  fi
}

customizeBash(){
  # The $SETUP_PATH_PRIVATE is initialized when the script starts
  runCommand "mkdir -p $SETUP_PATH_PRIVATE"
  runCommand "echo $1 >> $BASH_CUSTOMIZATION_FILE"
}

appendFileToBashProfile(){
  if [ -f $1 ]; then
    runCommand "echo -e \"if [ -f $1 ]; then \n\t. $1 \nfi\" >> ~/.bashrc"

    echo " >>> File [$1] was added!"
  else
    echo -e " >>> \e[31mFile [$1] does not exist!\e[39m"
  fi
}


# We can use this to simulate the run of the script.
DRY_RUN=false

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -dr|--dry-run)
    DRY_RUN=true
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

SETUP_PATH=$(askInput "Where do you want to do the setup? SETUP_PATH=" $(pwd))
if [[ -d $SETUP_PATH ]]; then
    echo " >>> Start working in [$SETUP_PATH] ..."
else
    echo -e "\e[31m >>> [$SETUP_PATH] is not valid directory.\e[39m"
    exit 1
fi

# Define paths that we will use (All these have the slash because we added above)
SETUP_PATH_WORK=$(realpath ${SETUP_PATH}/work)
SETUP_PATH_CONTAINERS=$(realpath ${SETUP_PATH}/containers)
SETUP_PATH_TOOLS=$(realpath ${SETUP_PATH}/tools)
SETUP_PATH_PRIVATE=$(realpath ${SETUP_PATH}/private)

echo " >>> This script will use the following paths where applicable:"
echo -e " >>> \e[34m[$SETUP_PATH_PRIVATE]:\e[39m - stores keys and customization files"
echo -e " >>> \e[34m[$SETUP_PATH_WORK]:\e[39m - stores your GitHub repositories"
echo -e " >>> \e[34m[$SETUP_PATH_CONTAINERS]:\e[39m - stores Docker containers data"
echo -e " >>> \e[34m[$SETUP_PATH_TOOLS]:\e[39m - stores tools that we will use for development"

ask="Continue?"
if ! continueYesNo "$ask"; then
    exit 1
fi

BASH_CUSTOMIZATION_FILE=$SETUP_PATH_PRIVATE/bash_customization
BASH_PRIVATE_FILE=$SETUP_PATH_PRIVATE/aliases

ask="Install: git, git-flow?"
if continueYesNo "$ask"; then
    runCommand "sudo apt install -y git git-flow"

    ask="Configure  GIT?"
    if continueYesNo "$ask"; then
        github_username=$(askInput "Enter your GIT user.name" $github_username)
        github_useremail=$(askInput "Enter your GIT user.email" $github_useremail)

        runCommand "git config --global user.name \"$github_username\""
        runCommand "git config --global user.email \"$github_useremail\""
        runCommand "git config --global color.ui auto"
        runCommand "git config -l"
    fi

    ask="Setup GitHub SSH key?"
    if continueYesNo "$ask"; then
        runCommand "mkdir -p $SETUP_PATH_PRIVATE"
        runCommand "mkdir -p ~/.ssh/"

        runCommand "ssh-keygen -t rsa -b 4096 -C \"$(git config --global user.email)\" -f $SETUP_PATH_PRIVATE/id_rsa_github"
        runCommand "ln -sf $SETUP_PATH_PRIVATE/id_rsa_github ~/.ssh/"
        runCommand "\$(ssh-agent -s)"
        runCommand "echo \"IdentityFile ~/.ssh/id_rsa_github\" >> ~/.ssh/config"
        runCommand "ssh-add ~/.ssh/id_rsa_github"

        github_username=$(askInput "Enter your GitHub user.name" $github_username)

        if ! $DRY_RUN; then
          curl -u "$github_username" \
            --data "{\"title\":\"`lsb_release -ds`-`date +%Y-%m-%d-%H:%M:%S`\",\"key\":\"`cat $SETUP_PATH_PRIVATE/id_rsa_github.pub`\"}" \
            https://api.github.com/user/keys
        else
          runCommand "Some complicated command that adds the generated SSH KEY to your github  account."
        fi
    fi

    echo ' >>> !!! This might take quite a while. All = max 150 !!!'
    ask="Clone all your GitHub repos?"
    if continueYesNo "$ask"; then
        runCommand "mkdir -p $SETUP_PATH_WORK"
        runCommand "cd $SETUP_PATH_WORK"

        github_username=$(askInput "Enter your GitHub user.name" $github_username)

        if ! $DRY_RUN; then
          curl -u "$github_username" "https://api.github.com/user/repos?page=1&per_page=150" | grep -e 'ssh_url*' | cut -d \" -f 4 | xargs -L1 git clone
        else
          runCommand "Some complicated command that clones your github  repositories."
        fi
    fi

    ask="Configure your Terminal prompt for GIT?"
    if continueYesNo "$ask"; then
        customizeBash 'export PS1='\''${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;31m\]$(declare -F __git_ps1 &>/dev/null && __git_ps1 " (%s)")\[\033[00m\]\[\033[01;36m\]:\$\[\033[00m\] '\'
        customizeBash 'export GIT_PS1_SHOWDIRTYSTATE=true'
        customizeBash 'export GIT_PS1_SHOWUNTRACKEDFILES=true'
        customizeBash 'alias gg='\''echo "Latest 3 tags:" && git tag --sort=-version:refname | head -n 3 && git status -sb'\'
        customizeBash "alias myip='ifconfig | sed -En '\''s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'\'"
    fi
    echo " >>> SUCCESS!"
fi

ask="Install: filezilla, vlc, virtualbox, firefox, vim, net-tools?"
if continueYesNo "$ask"; then
    runCommand "sudo apt install -y filezilla vlc virtualbox firefox vim net-tools"
    echo " >>> SUCCESS!"
fi

ask="Install: chrome?"
if continueYesNo "$ask"; then
    # TODO: Check if google-chrome-stable is allready available before adding the apt-repository
    runCommand "sudo add-apt-repository -y \"deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main\""
    runCommand "sudo curl -L https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -"
    runCommand "sudo apt update"
    runCommand "sudo apt install -y google-chrome-stable"
    echo " >>> SUCCESS!"
fi

ask="Install: skype?"
if continueYesNo "$ask"; then
    runCommand "wget https://repo.skype.com/latest/skypeforlinux-64.deb"
    runCommand "sudo dpkg -i skypeforlinux-64.deb"
    runCommand "sudo apt install -y -f"
    runCommand "rm skypeforlinux-64.deb"
    echo " >>> SUCCESS!"
fi

ask="Install: dbeaver (sql client)?"
if continueYesNo "$ask"; then
    runCommand "wget https://dbeaver.jkiss.org/files/dbeaver-ce_latest_amd64.deb"
    runCommand "sudo dpkg -i dbeaver-ce_latest_amd64.deb"
    runCommand "sudo apt install -y -f"
    runCommand "rm dbeaver-ce_latest_amd64.deb"
    echo " >>> SUCCESS!"
fi

ask="Install: numix-icon-theme-circle?"
if continueYesNo "$ask"; then
    runCommand "sudo add-apt-repository -y ppa:numix/ppa"
    runCommand "sudo apt update"
    runCommand "sudo apt install -y numix-icon-theme-circle"
    echo " >>> SUCCESS!"
fi

ask="Install: atom ide?"
if continueYesNo "$ask"; then
    runCommand "sudo curl -L https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -"
    runCommand "sudo sh -c 'echo \"deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main\" > /etc/apt/sources.list.d/atom.list'"
    runCommand "sudo apt update"
    runCommand "sudo apt install -y atom"
    echo " >>> SUCCESS!"
fi

ask="Install: docker, docker-compose?"
if continueYesNo "$ask"; then
    # Install docker
    runCommand "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common"
    runCommand "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
    # In some cases if the Linux used is to fresh(new), then the docker package
    # might not be available yet so we can use the previous version one
    runCommand "sudo add-apt-repository -y \"deb [arch=amd64] https://download.docker.com/linux/ubuntu artful stable\""
    # sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    runCommand "sudo apt update"
    runCommand "sudo apt install -y docker-ce"
    runCommand "sudo usermod -aG docker $USER"

    # Install docker-compose
    runCommand "sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose"
    runCommand "sudo chmod +x /usr/local/bin/docker-compose"
    runCommand "sudo curl -L https://raw.githubusercontent.com/docker/compose/1.21.0/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose"

    echo " >>> d[name] starts a container of the [name] service type"
    echo " >>> e[name] executes a command in the container of the [name] service type"
    ask="Add aliases for docker consul(dconsul,econsul), docker postgresql(dpostgres), docker pgadmin4(dpgadmin)?"
    if continueYesNo "$ask"; then
        runCommand "mkdir -p $SETUP_PATH_CONTAINERS"

        customizeBash "alias dconsul='docker run --rm -it --net=host --name dev-consul consul'"
        # This allows us to execute command inside the dev-consul container
        customizeBash "alias econsul='docker exec -i dev-consul consul'"

        postgresuser=$(askInput "Enter your POSTGRES_USER" $postgresuser)
        postgrespassword=$(askInput "Enter your POSTGRES_PASSWORD" $postgrespassword)
        customizeBash "alias dpostgres='docker run --rm -it -p 5432:5432 --name=dev-postgres -e POSTGRES_USER=$postgresuser -e POSTGRES_PASSWORD=$postgrespassword -v $SETUP_PATH_CONTAINERS/postgres_home:/var/lib/postgresql/data postgres -c \"log_statement=all\" -c \"log_duration=on\" -c \"log_min_duration_statement=-1\"'"
        customizeBash "alias epsql='PGPASSWORD=$postgrespassword docker exec -i dev-postgres psql -h localhost -U $postgresuser '"

        runCommand "mkdir -p $SETUP_PATH_CONTAINERS/pgadmin_home"
        runCommand "sudo chmod -R 777 $SETUP_PATH_CONTAINERS/pgadmin_home"
        customizeBash "alias dpgadmin='docker run --rm -it --net=host --name=dev-pgadmin -v $SETUP_PATH_CONTAINERS/pgadmin_home:/pgadmin thajeztah/pgadmin4'"
    fi

    ask="Add aliases for docker mongo(dmongo,emongo)?"
    if continueYesNo "$ask"; then
        runCommand "mkdir -p $SETUP_PATH_CONTAINERS"

        customizeBash "alias dmongo='docker run --rm -it -p 27017:27017 --name=dev-mongo -v $SETUP_PATH_CONTAINERS/mongodb_home:/data/db mongo'"
        # This allows us to execute command inside the dev-consul container
        customizeBash "alias emongo='docker exec -it dev-mongo bash -c mongo'"
        customizeBash "alias emongorestore='docker exec -i dev-mongo mongorestore --gzip --archive'"
        customizeBash "alias emongodump='docker exec -i dev-mongo mongodump --archive --gzip --db'"

        ask="Install: MongoDB Compass (UI for MongoDB)?"
        if continueYesNo "$ask"; then
            runCommand "wget https://downloads.mongodb.com/compass/mongodb-compass_1.15.4_amd64.deb"
            runCommand "sudo dpkg -i mongodb-compass_1.15.4_amd64.deb"
            runCommand "sudo apt install -y -f"
            runCommand "rm mongodb-compass_1.15.4_amd64.deb"
        fi
    fi
    echo " >>> SUCCESS!"
fi

ask="Install: java8?"
if continueYesNo "$ask"; then
    runCommand "sudo add-apt-repository -y ppa:webupd8team/java"
    runCommand "sudo apt update"
    runCommand "sudo apt install -y oracle-java8-installer"

    ask="Install: maven, activator, JetBrains ToolBox?"
    if continueYesNo "$ask"; then
        runCommand "sudo apt install -y zip gzip tar"
        runCommand "mkdir -p $SETUP_PATH_TOOLS"

        # Get maven
        runCommand "wget -qO- http://mirrors.m247.ro/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz | tar xvz -C $SETUP_PATH_TOOLS"
        # Add maven to PATH
        customizeBash "PATH=\$PATH:$SETUP_PATH_TOOLS/apache-maven-3.5.3/bin"
        customizeBash 'export MAVEN_OPTS="-Xmx512m"'

        # Get typesafe activator
        runCommand "wget  http://downloads.typesafe.com/typesafe-activator/1.3.12/typesafe-activator-1.3.12-minimal.zip -P $SETUP_PATH_TOOLS"
        runCommand "unzip -o $SETUP_PATH_TOOLS/typesafe-activator-1.3.12-minimal.zip -d $SETUP_PATH_TOOLS && rm $SETUP_PATH_TOOLS/typesafe-activator-1.3.12-minimal.zip"
        # Add activator to PATH
        customizeBash "PATH=\$PATH:$SETUP_PATH_TOOLS/activator-1.3.12-minimal/bin"

        # Get JetBrains ToolBox app that makes it easier to update InteliJ ad get it.
        runCommand "wget -qO- https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.8.3678.tar.gz | tar xvz -C $SETUP_PATH_TOOLS"
    fi
    echo " >>> SUCCESS!"
fi
#
ask="Install: nodejs?"
if continueYesNo "$ask"; then
    runCommand "wget -qO- https://deb.nodesource.com/setup_8.x | sudo -E bash -"
    runCommand "sudo apt-get install -y nodejs"
    echo " >>> SUCCESS!"
fi

ask="Install: yarn?"
if continueYesNo "$ask"; then
    runCommand "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -"
    runCommand "echo \"deb https://dl.yarnpkg.com/debian/ stable main\" | sudo tee /etc/apt/sources.list.d/yarn.list"
    runCommand "sudo apt update && sudo apt install -y yarn"
    echo " >>> SUCCESS!"
fi

ask="Add any private aliases found in ${BASH_PRIVATE_FILE} file?"
if continueYesNo "$ask"; then
    if [ -f $BASH_PRIVATE_FILE ]; then
      appendFileToBashProfile $BASH_PRIVATE_FILE
      echo " >>> SUCCESS!"
    else
      echo " >>> File $BASH_PRIVATE_FILE does not exist."
    fi
fi

ask="Install: awscli?"
if continueYesNo "$ask"; then
  runCommand "sudo apt install -y python-pip"
  runCommand "pip install awscli --upgrade --user"
  customizeBash "PATH=\$PATH:~/.local/bin"

  ask="Configure awscli?"
  if continueYesNo "$ask"; then
      runCommand "~/.local/bin/aws configure"
  fi
fi

# Add all the bash customization that we did to the ~/.bashrc file.
appendFileToBashProfile $BASH_CUSTOMIZATION_FILE

echo " >>> Cheching for updates ..."
runCommand "sudo apt update"
runCommand "sudo apt -y upgrade"
runCommand "sudo apt -y autoremove"

ask="Reboot?"
if continueYesNo "$ask"; then
    runCommand "sudo reboot"
fi
