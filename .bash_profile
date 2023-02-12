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
basePaths=(
    "/usr/local/bin"
    "/usr/bin"
    "/usr/sbin"
    "/sbin"
    "/data/data/com.termux/files/usr/bin"
    "/bin"
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/scoop/shims"
    "/c/WINDOWS/System32/WindowsPowershell/v1.0"
    "/c/WINDOWS"
    "/c/WINDOWS/System32"
    "opt/X11/bin"
    "/Applications/Firefox.app/Contents/MacOS"
    "/Applications/Discord.app/Contents/MacOS"
    "/Applications/Wireshark.app/Contents/MacOS"
)

for i in "${basePaths[@]}" ; do
    case "$i" in
        "/bin")
            #set PATH so it includes homebrew bins if they exists, otherwise add /bin
            if [ -f "/opt/homebrew/bin/brew" ] ; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [ -f "/usr/local/bin/brew" ] ; then
                eval "$(/usr/local/bin/brew shellenv)"
            else
                appendPath "/bin"
            fi ;;
        *)
            appendPath "$i" ;;
    esac
done

#Set PATH So it includes individual brew app bins
if has brew ; then
    prefix="$(brew --prefix)"
    brewPaths=(
        #Add editors to the end
        "/opt/ed/libexec/gnubin"
        "/opt/gnu-sed/libexec/gnubin"
        #Add Basic Utils
        "/opt/bison/bin"
        "/opt/man-db/libexec/bin"
        #Add languages next
        "/opt/gawk/libexec/gnubin"
        "/opt/ruby/bin"
        "/opt/python@3.10/bin"
        "/opt/python@3.10/libexec/bin"
        "/opt/openjdk@17/bin"
        #Add archive tools
        "/opt/zip/bin"
        "/opt/unzip/bin"
        "/opt/gnu-tar/libexec/gnubin"
        #Add basic utilities finally
        "/opt/curl/bin"
        "/opt/findutils/libexec/gnubin"
        "/opt/binutils/bin"
        "/opt/gnu-which/libexec/gnubin"
        "/opt/gnu-time/libexec/gnubin"
        "/opt/make/libexec/gnubin"
        "/opt/grep/libexec/gnubin"
        "/opt/util-linux/bin"
        "/opt/coreutils/libexec/gnubin"
    )

    for i in "${brewPaths[@]}" ; do
        brewPath "$i"
    done

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
has java && export CPPFLAGS="-I$prefix/opt/openjdk@17/include"
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
