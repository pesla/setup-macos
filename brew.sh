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

echo "Installing GNU sed, overwriting the built-in sed..."
brew install gnu-sed --with-default-names

echo "Upgrading bash to version 4..."
brew install bash
brew tap homebrew/versions
brew install bash-completion2

echo "Switch to using brew-installed bash as default shell (password necessary)..."
if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
  chsh -s /usr/local/bin/bash;
fi;

echo "Installing vim..."
brew install vim --override-system-vi

echo "Installing grep..."
brew install homebrew/dupes/grep

echo "Installing openssh..."
brew install homebrew/dupes/openssh

echo "Installing screen..."
brew install homebrew/dupes/screen

echo "Installing php71"
brew tap homebrew/dupes
brew tap homebrew/homebrew-php
brew install php71

echo "Cleaning up..."
brew cleanup

echo "Finished installing packages!"