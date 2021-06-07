#Set Base PATH
PATH="/usr/local/bin:/usr/bin:/usr/sbin:/sbin"

#set PATH so it includes homebrew bin if it exists, otherwise add /bin
if [ -d "/opt/homebrew" ] ; then
    PATH="/opt/homebrew/sbin:$PATH"
    PATH="/opt/homebrew/bin:$PATH"
else
    PATH="/bin:$PATH"

fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
 
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
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
if [ -d "/opt/homebrew" ] ; then
    #Add editors last
    PATH="/opt/homebrew/opt/ed/libexec/gnubin:$PATH"
    PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
    #Add languages
    PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
    PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
    PATH="/opt/homebrew/opt/python@3.9/libexec/bin:$PATH"
    #Add archive tools
    PATH="/opt/homebrew/opt/zip/bin:$PATH"
    PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"
    #Add basic utilities first
    PATH="/opt/homebrew/opt/curl/bin:$PATH"
    PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
    PATH="/opt/homebrew/opt/gnu-which/libexec/gnubin:$PATH"
    PATH="/opt/homebrew/opt/gnu-time/libexec/gnubin:$PATH"
    PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"
    PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
    PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
fi

#Export env variables
export PATH
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
# (for zsh) export PS1="%B%F{green}%n%f%b%B%F{green}@%f%b%B%F{green}%m%f%b:%F{blue}%~%f$ "
eval $(/opt/homebrew/bin/brew shellenv)
eval $(/opt/homebrew/opt/coreutils/libexec/gnubin/dircolors $HOME/.dir_colors)
if [ -f $HOME/.bash_aliases ]; then
    source $HOME/.bash_aliases
fi
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"
