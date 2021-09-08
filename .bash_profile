#!/bin/bash
has() { type -p "$1" >/dev/null; }
#Notify if PATH is already set
if [ -n "$PATH" ] ; then
    #if set, replace it
    printf '\033[31mWARNING: reset path from %s \033[39m\n' "$PATH"
    PATH=""
fi

#Set Base PATH
if [ -d "/usr/local/bin" ] ; then
    PATH="$PATH:/usr/local/bin"
fi
if [ -d "/usr" ] ; then
    PATH="$PATH:/usr/bin:/usr/sbin"
fi
if [ -d "/sbin" ] ; then
    PATH="$PATH:/sbin"
fi

if [ -d "/data/data/com.termux/files/usr" ] ; then
    PATH="$PATH:/data/data/com.termux/files/usr/bin"
fi

#set PATH so it includes homebrew bins if they exists, otherwise add /bin
if [ -d "/opt/homebrew" ] ; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ] ; then
    eval "$(/usr/local/bin/brew shellenv)"
else
    if [ -d "/bin" ] ; then
        PATH="/bin:$PATH"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

#set PATH so it includes scoop if it exists
if [ -d "$HOME/scoop/shims" ] ; then
    PATH="$HOME/scoop/shims:$PATH"
fi

#Set PATH so it includes X11 bin if it exists
if [ -d "/opt/X11" ] ; then
    PATH="$PATH:/opt/X11/bin"
fi

#Set PATH So it includes Wireshark bin if it exists
if [ -d "/Applications/Wireshark.app" ] ; then
    PATH="$PATH:/Applications/Wireshark.app/Contents/MacOS"
fi

#Set PATH So it includes individual brew app bins
if has brew ; then
    prefix="$(brew --prefix)"
    #Add editors to the end
    PATH="$prefix/opt/ed/libexec/gnubin:$PATH"
    PATH="$prefix/opt/gnu-sed/libexec/gnubin:$PATH"
    #Add Basic Utils
    PATH="$prefix/opt/bison/bin:$PATH"
    PATH="$prefix/opt/man-db/libexec/bin:$PATH"
    #Add languages next
    PATH="$prefix/opt/gawk/libexec/gnubin:$PATH"
    PATH="$prefix/opt/ruby/bin:$PATH"
    PATH="$prefix/opt/openjdk@11/bin:$PATH"
    PATH="$prefix/opt/python@3.9/libexec/bin:$PATH"
    #Add archive tools
    PATH="$prefix/opt/zip/bin:$PATH"
    PATH="$prefix/opt/unzip/bin:$PATH"
    PATH="$prefix/opt/gnu-tar/libexec/gnubin:$PATH"
    #Add basic utilities finally
    PATH="$prefix/opt/curl/bin:$PATH"
    PATH="$prefix/opt/findutils/libexec/gnubin:$PATH"
    PATH="$prefix/opt/gnu-which/libexec/gnubin:$PATH"
    PATH="$prefix/opt/gnu-time/libexec/gnubin:$PATH"
    PATH="$prefix/opt/make/libexec/gnubin:$PATH"
    PATH="$prefix/opt/grep/libexec/gnubin:$PATH"
    PATH="$prefix/opt/coreutils/libexec/gnubin:$PATH"

    #load brew bash completion script
    [[ -r "$prefix/etc/profile.d/bash_completion.sh" ]] && . "$prefix/etc/profile.d/bash_completion.sh"
fi

#Export env variables
export PATH
if [ "$COLUMNS" -gt "70" ] ; then
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

