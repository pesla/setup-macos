#!/usr/bin/env bash

echo -n "Did you modify the script to your needs? If not, abort! [y/n] "
read answer

if echo "$answer" | grep -iq "^n" ;then
    echo "Aborting..."
    exit
fi

echo "Closing any open System Preferences panes, to prevent them from overriding settings we’re about to change..."
osascript -e 'tell application "System Preferences" to quit'

echo "Asking for the administrator password upfront as some commands require admin access..."
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

echo "### General UI and UX settings ###"

# Set computer name (as done via System Preferences → Sharing)
COMPUTER_NAME="0x7065746572"

echo -n "Setting computer name to $COMPUTER_NAME. Are you sure? [y/n] "
read answer

if echo "$answer" | grep -iq "^n" ;then
    echo "Aborting..."
    exit
fi

sudo scutil --set ComputerName ${COMPUTER_NAME}
sudo scutil --set HostName ${COMPUTER_NAME}
sudo scutil --set LocalHostName ${COMPUTER_NAME}
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string ${COMPUTER_NAME}

echo "Setting stand by delay to 24 hours (default is 1 hour)..."
sudo pmset -a standbydelay 86400

echo "Disabling the sound effects on boot..."
sudo nvram SystemAudioVolume=" "

echo "Disabling transparency in the menu bar and elsewhere..."
defaults write com.apple.universalaccess reduceTransparency -bool true

echo "Hiding volume and user icon in menu bar..."
for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
	defaults write "${domain}" dontAutoLoad -array \
		"/System/Library/CoreServices/Menu Extras/Volume.menu" \
		"/System/Library/CoreServices/Menu Extras/User.menu"
done

echo "Enabling bluetooth and battery menu"
defaults write com.apple.systemuiserver menuExtras -array \
	"/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
	"/System/Library/CoreServices/Menu Extras/Battery.menu" \

echo "Setting highlight color to green..."
defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

echo "Setting sidebar icon size to medium..."
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

echo "Forcing scrollbars to be always visible..."
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

echo "Increasing window resize speed for cocoa apps..."
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

echo "Forcing save panels to expand by default..."
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

echo "Forcing print panels to expand by default..."
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "Forcing new documents to save to disk by default (not to iCloud)..."
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo "Disabling the 'Are you sure you want to open this application?'-dialog..."
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "Display ASCII control characters using caret notation in standard text views..."
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

echo "Disabling Resume system-wide..."
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

echo "Disabling automatic termination of inactive apps..."
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

echo "Restart automatically if the computer freezes..."
sudo systemsetup -setrestartfreeze on

echo "Disabling computer sleep mode..."
sudo systemsetup -setcomputersleep Off > /dev/null

echo "Disabling smart quotes as they’re annoying when typing code..."
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

echo "Disabling smart dashes as they’re annoying when typing code..."
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

###############################################################################
# SSD-specific tweaks                                                         #
###############################################################################

echo "### SSD specific tweaks ###"

echo  "Disabling hibernation (speeds up entering sleep mode)..."
sudo pmset -a hibernatemode 0

echo "Removing the sleep image file to save disk space..."
sudo rm /private/var/vm/sleepimage
sudo touch /private/var/vm/sleepimage
sudo chflags uchg /private/var/vm/sleepimage

echo "Disabling the sudden motion sensor as it’s not useful for SSDs..."
sudo pmset -a sms 0

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

echo "### Trackpad, mouse, and keyboard tweaks ###"

echo "Trackpad: enabling tap to click for this user and for the login screen..."
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo "Trackpad: mapping bottom right corner to right-click..."
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

echo "Increasing sound quality for Bluetooth headphones/headsets..."
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

echo "Enabling full keyboard access for all controls..."
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo "Setting up scroll gesture to use the Ctrl (^) modifier key to zoom..."
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

echo "Disabling press-and-hold for keys in favor of key repeat..."
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo "Enabling a blazingly fast keyboard repeat rate..."
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

echo -n "Setting up timezone, languages, formats..."
defaults write NSGlobalDomain AppleLanguages -array "en" "nl"
defaults write NSGlobalDomain AppleLocale -string "en_GB@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true
sudo systemsetup -settimezone "Europe/Amsterdam" > /dev/null

echo "Disabling auto-correct..."
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "Stopping iTunes to respond to media keys..."
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

###############################################################################
# Screen                                                                      #
###############################################################################

echo "### Screen (saver) related tweaks ###"

echo "Require password immediately after sleep or screen saver begins..."
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "Changing default screenshot location to the desktop..."
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

echo "Changing default screenshot format to PNG..."
defaults write com.apple.screencapture type -string "png"

echo "Disabling shadow in screenshots..."
defaults write com.apple.screencapture disable-shadow -bool true

echo "Enabling subpixel font rendering on non-Apple LCDs..."
defaults write NSGlobalDomain AppleFontSmoothing -int 2

echo "Enable HiDPI display modes (requires restart)..."
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

echo "### Finder tweaks ###"

echo "Enabling ⌘ + Q to allow quitting Finder..."
defaults write com.apple.finder QuitMenuItem -bool true

echo "Disabling window animations and Get Info animations..."
defaults write com.apple.finder DisableAllAnimations -bool true

echo "Setting Desktop as the default location for new Finder windows..."
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

echo "Show icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

echo "Telling Finder to show all filename extensions..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "Setting up various Finder related UI settings..."
# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true
# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

echo "Setting up Finder to search the current folder by default..."
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "Enabling spring loading for directories..."
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay -float 0

echo "Disabling creation of .DS_Store files on network or USB volumes..."
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

echo "Disabling disk image verification..."
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

echo "Setting up Finder to automatically open a new Finder window when a volume is mounted..."
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

echo "Enabling item info near icons on the desktop and in other icon views..."
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

echo "Enabling snap-to-grid for icons on the desktop and in other icon views..."
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

echo "Increasing grid spacing for icons on the desktop and in other icon views..."
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

echo "Increasing the size of icons on the desktop and in other icon views..."
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

echo "Forcing list view in all Finder windows by default..."
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

echo "Disavbling the warning before emptying the Trash..."
defaults write com.apple.finder WarnOnEmptyTrash -bool false

echo "Enabling AirDrop over Ethernet and on unsupported Macs running Lion..."
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Enable the MacBook Air SuperDrive on any Mac
# Commented out as it seems to be unsupported on OS X Sierra
# sudo nvram boot-args="mbasd=1"

echo "Forcing Finder to show the (normally hidden) ~/Library folder..."
chflags nohidden ~/Library

echo "Forcing Finder to show the (normally hidden) /Volumes folder..."
sudo chflags nohidden /Volumes

echo "Setting up Finder to expand open with panes by default..."
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

echo "### Dock, dashboard and hot corners ###"

echo "Enabling highlight hover effect for the grid view of a stack (Dock)..."
defaults write com.apple.dock mouse-over-hilite-stack -bool true

echo "Setting the icon size of Dock items to 36 pixels..."
defaults write com.apple.dock tilesize -int 36

echo "Changing minimize/maximize window effect..."
defaults write com.apple.dock mineffect -string "scale"

echo "Forcing windows  to minimize into their application’s icon..."
defaults write com.apple.dock minimize-to-application -bool true

echo "Enabling spring loading for all Dock items..."
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

echo "Enabling indicator lights for open applications in the Dock..."
defaults write com.apple.dock show-process-indicators -bool true

echo -n "Do you want to wipe all default dock icons? [y/n] "
read answer

if echo "$answer" | grep -iq "^y" ;then
    echo "Wiping default dock items..."
    defaults write com.apple.dock persistent-apps -array
fi

# Show only open applications in the Dock
defaults write com.apple.dock static-only -bool true

echo "Disabling opening animation of applications from the Dock..."
defaults write com.apple.dock launchanim -bool false

echo "Speeding up Mission Control animations..."
defaults write com.apple.dock expose-animation-duration -float 0.1

echo "Disabling Dashbpard..."
defaults write com.apple.dashboard mcx-disabled -bool true

echo "Disabling Dashboard to show as a space..."
defaults write com.apple.dock dashboard-in-overlay -bool true

echo "Disabling automatic ordering of spaces based on use..."
defaults write com.apple.dock mru-spaces -bool false

echo "Removing the auto-hiding Dock delay..."
defaults write com.apple.dock autohide-delay -float 0

echo "Removing the animation when hiding/showing the Dock..."
defaults write com.apple.dock autohide-time-modifier -float 0

echo "Enabling automatically show/hide of the Dock..."
defaults write com.apple.dock autohide -bool true

echo "Making Dock icons of hidden applications translucent..."
defaults write com.apple.dock showhidden -bool true

echo "Adding iOS & Watch Simulator to Launchpad..."
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"

echo "Setting up hot corners..."
# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# Top left screen corner → Mission Control
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0
# Top right screen corner → Desktop
defaults write com.apple.dock wvous-tr-corner -int 4
defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom left screen corner → Start screen saver
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

echo "### Safari & WebKit settings ###"

echo "Disabling the 'feature' that sends search queries to Apple..."
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

echo "Setting up various usability related properties..."
# Press Tab to highlight each item on a web page
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true
# Show the full URL in the address bar (note: this still hides the scheme)
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
# Set Safari’s home page to `about:blank` for faster loading
defaults write com.apple.Safari HomePage -string "about:blank"
# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
# Allow hitting the Backspace key to go to the previous page in history
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true
# Hide Safari’s bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar -bool false
# Hide Safari’s sidebar in Top Sites
defaults write com.apple.Safari ShowSidebarInTopSites -bool false
# Disable Safari’s thumbnail cache for History and Top Sites
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2
# Make Safari’s search banners default to Contains instead of Starts With
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false
# Remove useless icons from Safari’s bookmarks bar
defaults write com.apple.Safari ProxiesInBookmarksBar "()"
# Enable continuous spellchecking
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
# Disable auto-correct
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false
# Disable AutoFill
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false
# Warn about fraudulent websites
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true
# Block pop-up windows
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false
# Enable “Do Not Track”
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
# Update extensions automatically
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

echo "Enabling Safari’s developer tools..."
# Debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

echo "Disabling plug-ins, Java..."
# Disable plug-ins
defaults write com.apple.Safari WebKitPluginsEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false
# Disable Java
defaults write com.apple.Safari WebKitJavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false

###############################################################################
# Spotlight                                                                   #
###############################################################################

echo "### Spotlight related settings ###"

# Hide Spotlight tray-icon (and subsequent helper)
# Commented out as it doesn't seem to work on OS X Sierra
# sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search

echo "Disabling Spotlight indexing for any volume that gets mounted and has not yet..."
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"

echo "Changing indexing order and disable some search results..."
# Yosemite-specific search results (remove them if you are using macOS 10.9 or older):
# 	MENU_DEFINITION
# 	MENU_CONVERSION
# 	MENU_EXPRESSION
# 	MENU_SPOTLIGHT_SUGGESTIONS (send search queries to Apple)
# 	MENU_WEBSEARCH             (send search queries to Apple)
# 	MENU_OTHER
defaults write com.apple.spotlight orderedItems -array \
	'{"enabled" = 1;"name" = "APPLICATIONS";}' \
	'{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
	'{"enabled" = 1;"name" = "DIRECTORIES";}' \
	'{"enabled" = 1;"name" = "PDF";}' \
	'{"enabled" = 1;"name" = "FONTS";}' \
	'{"enabled" = 0;"name" = "DOCUMENTS";}' \
	'{"enabled" = 0;"name" = "MESSAGES";}' \
	'{"enabled" = 0;"name" = "CONTACT";}' \
	'{"enabled" = 0;"name" = "EVENT_TODO";}' \
	'{"enabled" = 0;"name" = "IMAGES";}' \
	'{"enabled" = 0;"name" = "BOOKMARKS";}' \
	'{"enabled" = 0;"name" = "MUSIC";}' \
	'{"enabled" = 0;"name" = "MOVIES";}' \
	'{"enabled" = 0;"name" = "PRESENTATIONS";}' \
	'{"enabled" = 0;"name" = "SPREADSHEETS";}' \
	'{"enabled" = 0;"name" = "SOURCE";}' \
	'{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
	'{"enabled" = 0;"name" = "MENU_OTHER";}' \
	'{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
	'{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
	'{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
	'{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

echo "Rebooting spotlight..."
# Load new settings before rebuilding the index
killall mds > /dev/null 2>&1
# Make sure indexing is enabled for the main volume
sudo mdutil -i on / > /dev/null
# Rebuild the index from scratch
sudo mdutil -E / > /dev/null

###############################################################################
# Terminal & iTerm 2                                                          #
###############################################################################

echo "### Terminal and iTerm related settings ###"

echo "Forcing UTF-8 in the terminal..."
defaults write com.apple.terminal StringEncodings -array 4

echo "Enabling Secure Keyboard Entry in Terminal.app..."
defaults write com.apple.terminal SecureKeyboardEntry -bool true

echo "Disabling the annoying line marks..."
defaults write com.apple.Terminal ShowLineMarks -int 0

echo "Disabling the annoying prompt when quitting iTerm"
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

###############################################################################
# Time Machine                                                                #
###############################################################################

echo "### Time Machine related settings ###"

echo "Disabling Time Machine promt to use new hard drives as backup volume..."
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo "Disabling local Time Machine backups..."
hash tmutil &> /dev/null && sudo tmutil disablelocal

###############################################################################
# Activity Monitor                                                            #
###############################################################################

echo "### Activity Monitor related settings ###"

echo "Forcing AM to show the main window after launching..."
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

echo "Visualize CPU usage in the Activity Monitor Dock icon..."
defaults write com.apple.ActivityMonitor IconType -int 5

echo "Showing all processes in Activity Monitor..."
defaults write com.apple.ActivityMonitor ShowCategory -int 0

echo "Setting AM up to sort results by CPU usage..."
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# Address Book, Dashboard, iCal, TextEdit, and Disk Utility                   #
###############################################################################

echo "### Default Mac apps settings ###"

echo "Enabling the debug menu in Address Book..."
defaults write com.apple.addressbook ABShowDebugMenu -bool true

echo "Enabling Dashboard dev mode (allows keeping widgets on the desktop)..."
defaults write com.apple.dashboard devmode -bool true

echo "Forcing the use of plain text mode for new TextEdit documents..."
defaults write com.apple.TextEdit RichText -int 0

echo "Forcing TextEdit to open and save files as UTF-8..."
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

echo "Enabling the debug menu in Disk Utility..."
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

echo "Preventing Photos from opening automatically when devices are plugged in..."
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

echo "Disabling automatic emoji substitution (i.e. use plain text smileys) in Messages.app..."
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

echo "Disabling smart quotes as it’s annoying for messages that contain code in Messages.app..."
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

echo "Disabling continuous spell checking in Messages.app..."
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

###############################################################################
# Mac App Store                                                               #
###############################################################################

echo "### Mac App Store settings ###"

echo "Enabling the WebKit Developer Tools in the Mac App Store..."
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

echo "Enabling Debug Menu in the Mac App Store..."
defaults write com.apple.appstore ShowDebugMenu -bool true

echo "Enabling the automatic update check..."
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

echo "Forcing to check for software updates daily, not just once per week..."
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo "Enabling background downloading for new updates..."
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

echo "Enabling installation of system data files & security updates..."
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

echo "Enabling app auto updates..."
defaults write com.apple.commerce AutoUpdate -bool true

###############################################################################
# Google Chrome & Google Chrome Canary                                        #
###############################################################################

echo "### Google Chrome and Google Chrome Canary ###"

echo "Disabling the all too sensitive backswipe..."
# ... on a trackpad
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false
# ... on a magic mouse
defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

echo "Forcing the use the system-native print preview dialog..."
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true

echo "Forcing Chrome to expand the print dialog by default..."
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
	"Dock" "Finder" "Google Chrome" "Google Chrome Canary" \
	"Photos" "Safari" "SystemUIServer" "Terminal"; do
	killall "${app}" &> /dev/null
done

echo "Done. Note that some of these changes require a logout/restart to take effect."