#!/bin/zsh
# Installs git and other git helpers and aliases

SCRIPT_PATH="$(
    cd "$(dirname "$0")"
    pwd -P
)"
BIN_PATH="$SCRIPT_PATH/bin"
ALIAS_HELPERS_FILE="$SCRIPT_PATH/bin/.git_bash"

askInput() {
    printf "%s\e[34m%s\e[39m" "$1" "[$2] " >/dev/stderr
    read -e input
    # If empty, use the default
    inputOrDefault=${input:=$2}
    echo $inputOrDefault # This is how we return something
}

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

SETUP_PATH_PRIVATE=""
if [ -z "$1" ]; then
    printf "%s\n" "Optional valid path can be passed as first argument."
    printf "%s \e[34m%s\e[39m\n" "Usage:" "./install_git.sh VALID_PATH"
    printf "\t\e[34m%s\e[39m %s \033[1m%s\033[0m\n" "VALID_PATH:" "Path where the GitHub SSH key will be stored. e.g." "/vol/private"
else
    SETUP_PATH_PRIVATE=$1
fi

if [[ -d $SETUP_PATH_PRIVATE ]]; then
    printf "%s \e[32m[%s]\e[39m\n" "Start working in:" $SETUP_PATH_PRIVATE
fi

ask="Install: git, git-flow ?"
if continueYesNo "$ask"; then
    sudo apt install -y git git-flow

    ask="Configure:  GIT?"
    if continueYesNo "$ask"; then
        github_username="your_username"
        github_username=$(askInput "Enter your GIT user.name:" $github_username)
        github_useremail=$(askInput "Enter your GIT user.email:" $github_useremail)

        git config --global user.name "$github_username"
        git config --global user.email "$github_useremail"
        git config --global color.ui auto
        git config -l
    fi

    ask="Setup: GitHub SSH key? (You will need to add it manually in your GitHub account)"
    if [ -d $SETUP_PATH_PRIVATE ] && [ ! -z "$SETUP_PATH_PRIVATE" ]; then
        if continueYesNo "$ask"; then
            mkdir -p $SETUP_PATH_PRIVATE
            mkdir -p ~/.ssh/

            ssh-keygen -t rsa -b 4096 -C "$(git config --global user.email)" -f $SETUP_PATH_PRIVATE/id_rsa_github
            ln -sf $SETUP_PATH_PRIVATE/id_rsa_github ~/.ssh/
            $(ssh-agent -s)
            echo "IdentityFile ~/.ssh/id_rsa_github" >> ~/.ssh/config
            ssh-add ~/.ssh/id_rsa_github
        fi
    else
        printf "%s \e[31m[%s]\e[39m. Skipping \e[34m[%s]\e[39m step\n" "Not a valid directory:" "$SETUP_PATH_PRIVATE" "$ask"
    fi

    # Until we have an official version use this: https://github.com/shiftkey/desktop/releases
    ask="Install: GitHub Desktop (un-official: https://github.com/shiftkey/desktop/releases)?"
    if continueYesNo "$ask"; then
        wget -O GitHubDesktop.deb https://github.com/shiftkey/desktop/releases/download/release-3.3.3-linux2/GitHubDesktop-linux-amd64-3.3.3-linux2.deb
        sudo dpkg -i GitHubDesktop.deb
        sudo apt install -y -f
        rm GitHubDesktop.deb
    fi

    ask="Install: git-flow alias helpers and git terminal prompt integration?"
    if continueYesNo "$ask"; then
        # Add the file of aliases if it exists
        if [ -f $ALIAS_HELPERS_FILE ]; then
            echo -e "if [ -f $ALIAS_HELPERS_FILE ]; then \n\t. $ALIAS_HELPERS_FILE \nfi" >> ~/.zshrc
        fi
    fi

    printf "\e[32m%s\e[39m\n" "SUCCESS!"
fi