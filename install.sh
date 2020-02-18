#!/bin/bash

################################################################################
## Installs the basic utilities that one just can't live without. Also        ##
## installs user configuration files for those basic utilities by creating    ##
## symlinks between the `thefiles` directory and the user's home directory.   ##
################################################################################





################################################################################
## Helpers
################################################################################

prompt_confirm() {
    while true; do
        read -r -p "${1:-Continue?} [Y/n]: " response
        response=$(echo "$response" | awk '{print tolower($0)}')
        case $response in
            yes | y | "") echo true ; return 0 ;;
            no | n) echo false ; return 1 ;;
            *) printf " \033[31m %s \n\033[0m" "Please answer yes or no.";;
        esac
    done
}

################################################################################
## Install packages
################################################################################

# Check if this is the initial install by checking for the `.installed` file. 
# If it is the initial install, then we'll install the essential packages 
# using apt, then use git to clone the dotfiles repo
if [ $(whoami) != "root" ] && [ ! -e ".installed" ]; then
    echo "As this is the initial installation, please enter password to install packages using apt:"
    sudo -v
    # keep sudo active
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    # update package list and upgrade packages
    echo "Updating package list and upgrading packages. This may take some time ..."
    sudo apt update -y && sudo apt upgrade

    # install packages
    echo "Installing the essentials ..."
    sudo apt install -y git vim zsh tmux python3-pip

    # change the login shell to zsh
    echo "Changing login shell to zsh ..."
    chsh -s $(which zsh)

    # install virtualenv and virtualenvwrapper
    echo "Installing virtualenv and virtualenvwrapper (for python virtual environments) ..."
    sudo pip3 install virtualenv
    sudo pip3 install virtualenvwrapper

    # clone the dotfiles repo

    cd ~

    if [ ! -e ".dotfiles" ]; then
        echo "Cloning the Dotfiles-Pi repo into ~/.dotfiles ..."
        git clone --recursive https://github.com/shanecb/Dotfiles-Pi.git .dotfiles >/dev/null
    fi

    cd .dotfiles

    if [ ! -e ".git" ]; then
        echo "ERROR: The .dotfiles directory is not a git repository -- terminating install"
        exit
    fi

    # finally, create the `.installed` file
    touch .installed
fi

################################################################################
## Symlink the dotfiles
################################################################################

# symlink all dotfiles into the home directory
echo "Creating symlinks ..."

# change globbing to include . files
shopt -s dotglob

datetime=$(date +"%Y-%m-%d-%H.%M.%S")

cd thefiles
for dotfile in *; do
    # if the file already exists in the home directory, then move it to the backup directory
    if [ -e ~/${dotfile} ]; then
        mkdir -p ../backups/${datetime}
        cp -rL ~/${dotfile} ../backups/${datetime}/
        rm -rf ~/${dotfile}
        unlink ~/${dotfile} 2>/dev/null
    fi

    ln -s ~/.dotfiles/thefiles/${dotfile} ~/${dotfile}
    echo "  > Done linking ${dotfile}"
done

if [ -e backups/${datetime} ]; then
    echo "`expr $(\ls -afq thefiles | wc -l) - 2` files backed up to ~/dotfiles/backups/${datetime}"
fi

# add ssh key
while $(prompt_confirm "Would you like to add a key to your ssh authorized_keys file?"); do
    mkdir -p ~/.ssh
    read -r -p "Please enter the public key you'd like to add to the authorized_keys file: " key
    case $key in
        "") echo "No input given, try again." ;;
        *) echo "Appending key to authorized keys ..." ; echo "$key" >> ~/.ssh/authorized_keys ; break ;;
    esac
done

echo "All done!"
