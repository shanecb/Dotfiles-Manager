#!/bin/bash

################################################################################
## Installs the basic utilities that one just can't live without. Also        ##
## installs user configuration files for those basic utilities by creating    ##
## symlinks between the `thefiles` directory and the user's home directory.   ##
################################################################################





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

    # install and configure libsecret for managing git credentials
    echo "Installing and configuring libsecret (for managing git credentials) ..."
    sudo apt install libsecret-1-0 libsecret-1-dev
    cd /usr/share/doc/git/contrib/credential/libsecret
    sudo make clean
    sudo make

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

echo "All done!"
