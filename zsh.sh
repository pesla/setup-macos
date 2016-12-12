#!/usr/bin/env bash

echo -n "This will install a custom Zsh theme. Continue? [y/n] "
read answer

if echo "$answer" | grep -iq "^n" ;then
    echo "Aborting..."
    exit
fi

if [ ! -d "~/.oh-my-zsh/custom" ]; then
    echo "Unable to find target directory '~/.oh-my-zsh/custom'"
    exit
fi

if [ ! -d "~/.oh-my-zsh/custom/themes" ]; then
    echo "Creating Zsh themes directory..."
    mkdir "~/.oh-my-zsh/custom/themes"
fi

cp -r zsh/pesla.zsh-theme ~/.oh-my-zsh/custom/themes 2> /dev/null