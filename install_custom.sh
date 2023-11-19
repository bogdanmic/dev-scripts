#!/bin/zsh
# Installs custom eye candy packages 

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

if [ -z "$1" ]; then
    printf "%s\n" "Optiona valid path can be passed as first argument."
    printf "%s \e[34m%s\e[39m\n" "Usage:" "./install_custom.sh VALID_PATH_TO_ZSH_CUSTOMIZATION"
    printf "\t\e[34m%s\e[39m %s \033[1m%s\033[0m\n" "VALID_PATH_TO_ZSH_CUSTOMIZATION:" "Path to file that contains custom ZSH settings. e.g." "/vol/private/aliases"
else
    ZSH_CUSTOMIZATION_FILE=$1
fi

ask="Install: numix-icon-theme-circle?"
if continueYesNo "$ask"; then
    sudo add-apt-repository -y ppa:numix/ppa
    sudo apt update
    sudo apt install -y numix-icon-theme-circle
fi

ask="Install: papirus-icon-theme?"
if continueYesNo "$ask"; then
    sudo add-apt-repository -y ppa:papirus/papirus
    sudo apt update
    sudo apt install -y papirus-icon-theme
fi

ask="Install: Any private aliases/customizations found in ${ZSH_CUSTOMIZATION_FILE} file?"
if [ -f $ZSH_CUSTOMIZATION_FILE ] && [ ! -z "$ZSH_CUSTOMIZATION_FILE" ]; then
    if continueYesNo "$ask"; then
        echo -e "if [ -f $ZSH_CUSTOMIZATION_FILE ]; then \n\t. $ZSH_CUSTOMIZATION_FILE \nfi" >> ~/.zshrc
        printf "File \e[32m[%s]\e[39m was added!\n" "$ZSH_CUSTOMIZATION_FILE"
    fi
else
    printf "%s \e[31m[%s]\e[39m. Skipping \e[34m[%s]\e[39m step\n" "Not a valid file:" "$ZSH_CUSTOMIZATION_FILE" "$ask"
fi

# TODO: Can we create the custom shorcuts from the terminal?
# win+t
# win+d
# win+e
# win+L
printf "\e[32m%s\e[39m\n" "SUCCESS!"