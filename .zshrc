#!/bin/zsh
has() { type -p "$1" >/dev/null; }

#set PATH so it includes homebrew bins if they exist
if [ -d "/opt/homebrew" ] ; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ] ; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

#Export env variables
export PATH
if [ "$COLUMNS" -gt 70 ] ; then
    # (for bash) export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
    export PS1="%B%F{green}%n%f%b%B%F{green}@%f%b%B%F{green}%m(Rosetta)%f%b:%F{blue}%~%f$ "
else
    export PS1="\[\e[0;32m\]\w\[\e[0m\] \[\e[0;97m\]\$\[\e[0m\] "
fi

if [ "$(has arch && arch)" = "i386" ] ; then
    export BASH_SILENCE_DEPRECATION_WARNING=1
fi
has java && export CPPFLAGS="-I$prefix/opt/openjdk@11/include"
#Source remaining files
if has dircolors ; then
    eval "$(dircolors "$HOME/.dir_colors")"
fi

if [ -f "$HOME/.zsh_aliases" ] ; then
    source "$HOME/.zsh_aliases"
fi

if [ -f "$HOME/.launchscripts" ] ; then
    source "$HOME/.launchscripts"
fi
