#!/usr/bin/env bash

echo "Updating homebrew to make sure we’re using the latest Homebrew..."
brew update

echo "Upgrading any already-installed formulae..."
brew upgrade

echo "Installing GNU core utilities (those that come with macOS are outdated)..."
brew install coreutils

echo "Installing some other useful utilities like sponge..."
brew install moreutils

echo "Installing GNU find, locate, updatedb, and xargs, g-prefixed..."
brew install findutils

echo "Installing GNU sed..."
brew install gnu-sed

echo "Upgrading bash to version 4..."
brew install bash
brew install bash-completion@2

echo "Switch to using brew-installed bash as default shell (password necessary)..."
if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
  chsh -s /usr/local/bin/bash;
fi;

echo "Installing vim..."
brew install vim

echo "Installing grep..."
brew install grep

echo "Installing openssh..."
brew install openssh

echo "Installing screen..."
brew install screen

echo "Installing lastest php version..."
brew install php

echo "Cleaning up..."
brew cleanup

echo "Finished installing packages!"