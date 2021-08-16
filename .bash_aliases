#!/bin/bash
has() { type -p "$1" >/dev/null; }

#Color auto aliases
has grep && alias grep="grep --color=auto"
has fgrep && alias fgrep='fgrep --color=auto'
has egrep && alias egrep='egrep --color=auto'
has diff && alias diff="diff --color=auto"
has dir && alias dir='dir --color=auto'
has vdir && alias vdir='vdir --color=auto'

if has ls; then
    alias ls="ls --color=auto"
    alias la="ls -A"
    alias l="ls -CF"
    alias ll="ls -Alh"
fi

#Util aliases
has clear && alias cls="clear"
has exit && alias q="exit"
has which && alias which="which -a"

#Other software aliases
has brew && alias brew="brew -v"
has port && alias port="port -v"
has nmap && alias nmap="nmap -T4"
has lazygit && alias lg="lazygit"
has ddgr && alias search="ddgr"
has vim && alias vi="vim"
has vim && alias nano="vim"
has batcat && alias bat="batcat"
has trash && alias trash="trash -v -F"
has aria2c && alias ddl="aria2c --dir=$HOME/Downloads/aria2 --max-concurrent-downloads=20 --check-integrity=true --continue=true --max-connection-per-server=16 --split=20 --optimize-concurrent-downloads=true"
has thefuck && eval "$(thefuck --alias)"
has ytfzf && alias yt="ytfzf"
has ytfzf && alias ytdl="ytfzf -d"
