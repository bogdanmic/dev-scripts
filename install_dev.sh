#!/bin/zsh
# Installs development related tools

continueYesNo() {
    printf "%s \e[34m%s\e[39m" "$1" "[Y/n]" >/dev/stderr
    read -k 1 -r
    echo # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # 0 = true
        return 0
    else
        # 1 = false
        return 1
    fi
}

SETUP_PATH_TOOLS=""
if [ -z "$1" ]; then
    printf "%s\n" "Optional valid path can be passed as first argument."
    printf "%s \e[34m%s\e[39m\n" "Usage:" "./install_dev.sh VALID_PATH"
    printf "\t\e[34m%s\e[39m %s \033[1m%s\033[0m\n" "VALID_PATH:" "Path where apps can be downloaded. e.g." "/vol/tools"
else
    SETUP_PATH_TOOLS=$1
fi

if [[ -d $SETUP_PATH_TOOLS ]]; then
    printf "%s \e[32m[%s]\e[39m\n" "Start working in:" $SETUP_PATH_TOOLS
fi

ask="Install: vscode ide?"
if continueYesNo "$ask"; then
    wget -O vscode.deb https://update.code.visualstudio.com/latest/linux-deb-x64/stable
    sudo dpkg -i vscode.deb
    sudo apt install -y -f
    rm vscode.deb
fi

ask="Install: SDKMan (Software Development Kit Manager)?"
if continueYesNo "$ask"; then
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    ask="Install: Java 17 & 21 using SDKMan?"
    if continueYesNo "$ask"; then
        sdk install java 17.0.9-tem
        sdk install java 21.0.1-tem
    fi
    ask="Install: Maven using SDKMan?"
    if continueYesNo "$ask"; then
        sdk install maven
    fi
fi

ask="Install: nodejs?"
if continueYesNo "$ask"; then
    sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
    nvm install 20
    node -v
fi

# TODO: Test if it works now.
ask="Install: docker, docker-compose?"
if continueYesNo "$ask"; then
    sudo apt remove docker docker-engine docker.io containerd runc
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    # echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker-ce.list
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu lunar stable" | sudo tee /etc/apt/sources.list.d/docker-ce.list
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-compose
    sudo usermod -aG docker $USER
fi

ask="Install: dbeaver (sql client)?"
if continueYesNo "$ask"; then
    wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
    sudo dpkg -i dbeaver-ce_latest_amd64.deb
    sudo apt install -y -f
    rm dbeaver-ce_latest_amd64.deb
fi

ask="Install: PGAdmin4 (UI for Postgres)?"
if continueYesNo "$ask"; then
    curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
    sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/lunar pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
    sudo apt update
    sudo apt install -y pgadmin4
fi

ask="Install: MongoDB Compass (UI for MongoDB)?"
if continueYesNo "$ask"; then
    wget -O mongodb-compass_amd64.deb https://downloads.mongodb.com/compass/mongodb-mongosh_2.0.2_amd64.deb
    sudo dpkg -i mongodb-compass_amd64.deb
    sudo apt install -y -f
    rm mongodb-compass_amd64.deb
fi

ask="Install: MySql Workbench (UI for Mysql)?"
if continueYesNo "$ask"; then
    wget -O mysql-workbench-community_amd64.deb https://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community_8.0.34-1ubuntu23.04_amd64.deb
    sudo dpkg -i mysql-workbench-community_amd64.deb
    sudo apt install -y -f
    rm mysql-workbench-community_amd64.deb
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
fi

ask="Install: terraform?"
if continueYesNo "$ask"; then
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com lunar main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list

    sudo apt-get update && sudo apt-get -y install terraform
fi


ask="Install: JetBrains ToolBox?"
if [ -d $SETUP_PATH_TOOLS ] && [ ! -z "$SETUP_PATH_TOOLS" ]; then
    if continueYesNo "$ask"; then
        sudo apt install -y zip gzip tar
        mkdir -p $SETUP_PATH_TOOLS

        # Get JetBrains ToolBox app that makes it easier to update InteliJ and get it.
        wget -qO- https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.1.0.18144.tar.gz | tar xvz -C $SETUP_PATH_TOOLS
    fi
else
    printf "%s \e[31m[%s]\e[39m. Skipping \e[34m[%s]\e[39m step\n" "Not a valid directory:" "$SETUP_PATH_TOOLS" "$ask"
fi

ask="Install: Postman?"
if [ -d $SETUP_PATH_TOOLS ] && [ ! -z "$SETUP_PATH_TOOLS" ]; then
    if continueYesNo "$ask"; then
        wget -qO- https://dl.pstmn.io/download/latest/linux64 | tar xvz -C $SETUP_PATH_TOOLS
        # Add postman to PATH
        echo "PATH=\$PATH:$SETUP_PATH_TOOLS/Postman" >> ~/.zshrc
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
    fi
else
    printf "%s \e[31m[%s]\e[39m. Skipping \e[34m[%s]\e[39m step\n" "Not a valid directory:" "$SETUP_PATH_TOOLS" "$ask"
fi

printf "\e[32m%s\e[39m\n" "SUCCESS!"