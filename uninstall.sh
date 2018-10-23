#!/bin/bash

## Unlinks the dotfiles (doesn't remove packages installed by apt-get)

echo "Removing symlinks ..."

shopt -s dotglob

datetime=$(date +"%Y-%m-%d-%H.%M.%S")

cd thefiles
for dotfile in *; do
    # if the file already exists in the home directory, then move it to the backup directory
    if [ -e "~/${dotfile}" ]; then
        mkdir -p ../backups/${datetime}
        mv ~/${dotfile} ../backups/${datetime}/
        unlink ~/${dotfile}
        rm ~/${dotfile}
    fi

    echo "  > Done uninstalling ${dotfile}"
done

if [ -e backups/${datetime} ]; then
    echo "`expr $(\ls -afq thefiles | wc -l) - 2` files backed up to ~/dotfiles/backups/${datetime}"
fi



# remove the .installed file
cd ~/.dotfiles
rm .installed
