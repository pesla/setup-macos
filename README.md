# Setting up OS X

When setting up a new Mac (or when reinstalling your OS), the setup scripts in this repository may come in handy.

## Don't blindly copy and use my settings

A dedicated chapter for a simple warning. Fork this repository, inspect the files and change them to fit your needs.

## Download and install Mac apps

First of all, download the Mac apps you like to use. The scripts in this repository assume that the following apps are installed:

- [Google Chrome](https://www.google.com/chrome/browser/desktop/)
- [iTerm 2](https://www.iterm2.com/downloads.html)
- [Sublime Text 3](https://www.sublimetext.com/3)

You don't have to use any of these apps (obviously), just make sure to edit the scripts to your needs.

## Homebrew formulae

Homebrew is a package manager for OS X. In short: it lets you install stuff you need that Apple didn't. Install Homebrew by
 pasting the following at a Terminal prompt:

```bash
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Next, you may want to install some common Homebrew formulae. `brew.sh` will do that for you.
Run it by executing `./brew.sh`. My brew install script will install some useful CLI tools (like coreutils and findutils)
 upgrade bash, and install some tools I prefer to use (Vim, screen, php71).

## OS X defaults and settings

There are many settings and little tweaks that make an operating system feel like home. `osx.sh` sets it up in a couple of seconds.
Apart from general UI/UX settings, `osx.sh` contains settings for:

- Trackpad, mouse and other input methods
- Screen and screen saver
- Finder
- Dock, dashboard and hot corners
- Safari and WebKit
- Terminal and iTerm2
- Time Machine
- Activity Monitor
- Default Mac apps, like Address Book, Calendar
- Mac App Store
- Google Chrome and Google Chrome Canary

You can execute the script by running `./osx.sh`.

## Color schemes

I love having consistent color schemes across apps. A color scheme that I really appreciate, is the one that comes with [PHPStorm](https://www.jetbrains.com/phpstorm/):
 `Darcula`. It's a dark theme, nice on the eyes, and overall just good looking:

![PHPStorm using the Darcula theme](/screenshots/phpstorm-darcula.png?raw=true)

I've created Darcula themes for Terminal, iTerm and Sublime Text 3. You can install the themes by running the corresponding
 install script (`shell.sh` and `sublime.sh`).

### Terminal.app and iTerm

![Terminal.app using the Darcula theme](/screenshots/terminal-darcula.png?raw=true)

My Terminal.app runs on Bash and is configured by (some of) my [dotfiles](https://github.com/pesla/dotfiles). Check out
 [`.bash_prompt`](https://github.com/pesla/dotfiles/blob/master/.bash_prompt) for my prompt configuration.

![iTerm.app using the Darcula theme](/screenshots/iterm-darcula.png?raw=true)

My iTerm 2 runs on Zsh and [OhMyZsh](https://github.com/robbyrussell/oh-my-zsh) instead of Bash. The prompt is configured
by a custom Zsh theme and depends on powerline fonts to work well.

To install:

1. Clone into `powerline/fonts` and run `install.sh` to install all fonts
2. Make sure you've [installed OhMyZsh](https://github.com/robbyrussell/oh-my-zsh) (Zsh itself comes preloaded on OS X)
3. Run `./zsh.sh` to install the theme
4. Finally, tell Zsh to use the newly installed theme by setting `ZSH_THEME="Darcula"` in `.zshrc`

If you changed the default Zsh installation directory, you should manually install the theme.

### Sublime Text 3

![Sublime Text using the Darcula theme](/screenshots/sublime-darcula.png?raw=true)

Executing `sublime.sh` will copy some default (and sane) preferences and install the Darcula theme.
