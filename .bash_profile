#!/bin/bash

#if not running interactively, dont do anything
[ -z "$PS1" ] && return

#function to check if program is in path
has() { type -p "$1" >/dev/null; }

#add a directory to path
appendPath() { if [ -d "$1" ] ; then PATH="$PATH:$1"; fi }
prependPath() { if [ -d "$1" ] ; then PATH="$1:$PATH"; fi }

#add a brew directory to path
brewPath() { prependPath "$prefix$1"; }

#Notify if PATH is already set
if [ -n "$PATH" ] ; then
    #if set, replace it
    printf '\033[31mWARNING: reset path from %s \033[39m\n' "$PATH"
    export PATH=""
fi

#Set Base PATH
appendPath "/usr/local/bin"
appendPath "/usr/bin"
appendPath "/usr/sbin"
appendPath "/sbin"
appendPath "/data/data/com.termux/files/usr/bin"

#set PATH so it includes homebrew bins if they exists, otherwise add /bin
if [ -f "/opt/homebrew/bin/brew" ] ; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ] ; then
    eval "$(/usr/local/bin/brew shellenv)"
else
    appendPath "/bin"
fi

# set PATH so it includes user's private bin(s) if they exist
appendPath "$HOME/bin"
appendPath "$HOME/.local/bin"

#set PATH so it includes scoop if it exists
appendPath "$HOME/scoop/shims"

#set PATH to include windows dirs
appendPath "/c/WINDOWS/System32/WindowsPowershell/v1.0"
appendPath "/c/WINDOWS"
appendPath "/c/WINDOWS/System32"

#Set PATH so it includes X11 bin if it exists
appendPath "opt/X11/bin"

#Set PATH so it includes firefox if it exists
appendPath "/Applications/Firefox.app/Contents/MacOS"

#Set PATH so it includes discord if it exists
appendPath "/Applications/Discord.app/Contents/MacOS"

#Set PATH So it includes Wireshark bin if it exists
appendPath "/Applications/Wireshark.app/Contents/MacOS"

#Set PATH So it includes individual brew app bins
if has brew ; then
    prefix="$(brew --prefix)"
    #Add editors to the end
    brewPath "/opt/ed/libexec/gnubin"
    brewPath "/opt/gnu-sed/libexec/gnubin"
    #Add Basic Utils
    brewPath "/opt/bison/bin"
    brewPath "/opt/man-db/libexec/bin"
    #Add languages next
    brewPath "/opt/gawk/libexec/gnubin"
    brewPath "/opt/ruby/bin"
    brewPath "/opt/python@3.10/bin"
    brewPath "/opt/python@3.10/libexec/bin"
    #Add archive tools
    brewPath "/opt/zip/bin"
    brewPath "/opt/unzip/bin"
    brewPath "/opt/gnu-tar/libexec/gnubin"
    #Add basic utilities finally
    brewPath "/opt/curl/bin"
    brewPath "/opt/findutils/libexec/gnubin"
    brewPath "/opt/binutils/bin"
    brewPath "/opt/gnu-which/libexec/gnubin"
    brewPath "/opt/gnu-time/libexec/gnubin"
    brewPath "/opt/make/libexec/gnubin"
    brewPath "/opt/grep/libexec/gnubin"
    brewPath "/opt/util-linux/bin"
    brewPath "/opt/coreutils/libexec/gnubin"

    #load brew bash completion script
    [[ -r "$prefix/etc/profile.d/bash_completion.sh" ]] && . "$prefix/etc/profile.d/bash_completion.sh"
fi

#Export env variables
export PATH="$PATH"
if [ "$COLUMNS" -gt 70 ] ; then
    export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
    # (for zsh) export PS1="%B%F{green}%n%f%b%B%F{green}@%f%b%B%F{green}%m%f%b:%F{blue}%~%f$ "
else
    export PS1="\[\e[0;32m\]\w\[\e[0m\] \[\e[0;97m\]\$\[\e[0m\] "
fi
export MANPATH

if has vim ; then
    EDITOR=$(command -v "vim")
elif has nano ; then
    EDITOR=$(command -v "nano")
fi

if [ "$(has arch && arch)" = "i386" ] ; then
    export BASH_SILENCE_DEPRECATION_WARNING=1
fi
export EDITOR
has java && export CPPFLAGS="-I$prefix/opt/openjdk@11/include"
#Source remaining files
if has dircolors ; then
    eval "$(dircolors "$HOME/.dir_colors")"
fi

if [ -f "$HOME/.bash_aliases" ] ; then
    source "$HOME/.bash_aliases"
fi

if [ -f "$HOME/.launchscripts" ] ; then
    source "$HOME/.launchscripts"
fi
