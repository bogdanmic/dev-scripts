#!/bin/zsh
# Installs most common apps that you might use

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

ask="Install: filezilla, vlc, firefox, vim, net-tools, curl?"
if continueYesNo "$ask"; then
    sudo apt install -y filezilla vlc firefox vim net-tools curl
fi

ask="Install: chrome?"
if continueYesNo "$ask"; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo apt install -y -f
    rm google-chrome-stable_current_amd64.deb
fi

ask="Install: Tilix terminal?"
if continueYesNo "$ask"; then
    sudo add-apt-repository -y ppa:webupd8team/terminix
    sudo apt-get update
    sudo apt-get install -y tilix
    sudo update-alternatives --config x-terminal-emulator
fi

ask="Install: slack-desktop?"
if continueYesNo "$ask"; then
    wget -O slack-desktop.deb https://downloads.slack-edge.com/releases/linux/4.35.126/prod/x64/slack-desktop-4.35.126-amd64.deb
    sudo dpkg -i slack-desktop.deb
    sudo apt install -y -f
    rm slack-desktop.deb
fi

ask="Install: etcher (Flash OS images to SD cards & USB drives)?"
if continueYesNo "$ask"; then
    echo "deb https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list
    sudo apt-key adv --keyserver hkps://keyserver.ubuntu.com:443 --recv-keys 379CE192D401AB61
    sudo apt-get update
    sudo apt-get install -y balena-etcher-electron
fi

printf "\e[32m%s\e[39m\n" "Cheching for updates ..."
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

ask="Reboot?"
if continueYesNo "$ask"; then
    sudo reboot
fi