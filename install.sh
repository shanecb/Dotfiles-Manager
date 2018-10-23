#!/bin/bash

## Installs the basic utilities needed for hackery. Also installs user configuration files for those
## basic utilities by creating symlinks between the `thefiles` directory and the user's home directory.


# Check if this is the initial install by checking for the `.installed` file. If it is the initial install,
# then we'll install the essential packages using apt-get, then use git to clone the dotfiles repo
if [ $(whoami) != "root" ] && [ ! -e ".installed" ]; then
    echo "As this is the initial installation, please enter password to install packages using apt-get:"
    sudo -v
    # keep sudo active
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    # install packages
    echo "Installing the essentials ..."
    sudo apt-get install git vim zsh tmux

    # change the login shell to zsh
    chsh -s $(which zsh)

    # install and configure libsecret for managing git credentials
    sudo apt-get install libsecret-1-0 libsecret-1-dev
    cd /usr/share/doc/git/contrib/credential/libsecret
    sudo make
    git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret

    # clone the dotfiles repo
    echo "Cloning the Dotfiles-Pi repo into ~/.dotfiles ..."
    cd ~
    git clone --recursive https://github.com/shanecb/Dotfiles-Pi.git .dotfiles >/dev/null
    cd .dotfiles

    # finally, create the `.installed` file
    touch .installed
fi




# symlink all dotfiles into the home directory
echo "Creating symlinks ..."

# change globbing to include . files
shopt -s dotglob

datetime=$(date +"%Y-%m-%d-%H.%M.%S")

cd thefiles
for dotfile in *; do
    # if the file already exists in the home directory, then move it to the backup directory
    if [ -e "~/${dotfile}" ]; then
        mkdir -p ../backups/${datetime}
        mv ~/${dotfile} ../backups/${datetime}/
        unlink ~/${dotfile}
    fi

    ln -s ~/.dotfiles/thefiles/${dotfile} ~/${dotfile}
    echo "  > Done linking ${dotfile}"
done

if [ -e backups/${datetime} ]; then
    echo "`expr $(\ls -afq thefiles | wc -l) - 2` files backed up to ~/dotfiles/backups/${datetime}"
fi



echo "All done!"
