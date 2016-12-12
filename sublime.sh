#!/usr/bin/env bash

echo -n "This will copy the included sublime settings. Continue? [y/n] "
read answer

if echo "$answer" | grep -iq "^n" ;then
    echo "Aborting..."
    exit
fi

echo "Copying preferences..."
cp -r sublime/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text*/Packages/User/Preferences.sublime-settings 2> /dev/null
echo "Copying Darcula theme..."
cp -r sublime/Darcula.tmTheme ~/Library/Application\ Support/Sublime\ Text*/Packages/User/Darcula.tmTheme 2> /dev/null
echo "Done!"