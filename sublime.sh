#!/usr/bin/env bash

echo -n "This will copy the included sublime settings. Continue? [y/n] "
read answer

if echo "$answer" | grep -iq "^n" ;then
    echo "Aborting..."
    exit
fi

cp -r init/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text*/Packages/User/Preferences.sublime-settings 2> /dev/null