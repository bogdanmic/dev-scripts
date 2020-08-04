#!/bin/bash
# Installs custom eye candy packages 

continueYesNo() {
    printf "%s \e[34m%s\e[39m" "$1" "[Y/n]" >/dev/stderr
    read -n 1 -r
    echo # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # 0 = true
        return 0
    else
        # 1 = false
        return 1
    fi
}

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

# TODO: Can we create the custom shorcuts from the terminal?

printf "\e[32m%s\e[39m\n" "SUCCESS!"