#!/bin/bash
# Installs most common apps that you might use

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

ask="Install: filezilla, vlc, firefox, vim, net-tools, curl?"
if continueYesNo "$ask"; then
    sudo apt install -y filezilla vlc firefox vim net-tools curl
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

ask="Install: Tilix terminal?"
if continueYesNo "$ask"; then
    sudo add-apt-repository -y ppa:webupd8team/terminix
    sudo apt-get update
    sudo apt-get install -y tilix
    sudo update-alternatives --config x-terminal-emulator
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

printf "\e[32m%s\e[39m\n" "Cheching for updates ..."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

ask="Reboot?"
if continueYesNo "$ask"; then
    sudo reboot
fi