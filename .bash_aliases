#!/bin/bash
has() { type -p "$1" >/dev/null; }

has grep && alias grep="grep --color=auto"
has diff && alias diff="diff --color=auto"

if has ls; then
    alias ls="ls --color=auto"
    alias la="ls -A"
    alias l="ls -CF"
    alias ll="ls -Alh"
fi

has exit && alias q="exit"
has which && alias which="which -a"
has brew && alias brew="brew -v"
has port && alias port="port -v"
has nmap && alias nmap="nmap -T4"

has vim && alias nano="vim"
has lazygit && alias lg="lazygit"
has ddgr && alias search="ddgr"
has aria2c && alias ddl="aria2c --dir=$HOME/Downloads/aria2 --max-concurrent-downloads=20 --check-integrity=true --continue=true --max-connection-per-server=16 --split=20 --optimize-concurrent-downloads=true"
has batcat && alias bat="batcat"

has trash && alias trash="trash -v -F"
has thefuck && eval $(thefuck --alias)


