#!/bin/bash
has() { type -p "$1" &> /dev/null; }

#Color auto aliases
has grep && alias grep="grep --color=auto"
has fgrep && alias fgrep='fgrep --color=auto'
has egrep && alias egrep='egrep --color=auto'
has diff && alias diff="diff --color=auto"
has dir && alias dir='dir --color=auto'
has vdir && alias vdir='vdir --color=auto'
has ls && alias ls="ls --color=auto"

#Util aliases
if has ls ; then
    alias la="ls -A"
    alias l="ls -CF"
    alias ll="ls -Alh"
fi
has trash && alias trash="trash -v -F"
has clear && alias cls="clear"
has exit && alias q="exit"
has which && alias which="which -a"
has cd && alias ..="cd .."
has thefuck && eval "$(thefuck --alias)"

#Text Editor eliases
has vim && alias vi="vim"
has vim && alias nano="vim"
has batcat && alias bat="batcat"

#Youtube Aliases
has ytfzf && alias yt="ytfzf"
has youtube-dl && alias ytdl="youtube-dl --external-downloader=aria2c --external-downloader-args='--max-concurrent-downloads=20 --continue=true --max-connection-per-server=16 --split=20 --optimize-concurrent-downloads=true'"
has youtube-dl && alias ytmp3="youtube-dl -x --audio-format=flac --audio-quality=0 --external-downloader=aria2c --external-downloader-args='--max-concurrent-downloads=20 --continue=true --max-connection-per-server=16 --split=20 --optimize-concurrent-downloads=true'"
has ytfzf && alias ytsearch="ytfzf -L"

#Archive Aliases
has 7z && alias un7zip="7z x"
has tar && alias untar="tar -xvf"
has tar && alias ungz="tar -xvzf"

#Networking Aliases
has Wireshark && alias wireshark="Wireshark"
has nmap && alias nmap="nmap -T4"
if has nslookup ; then
    alias reversedns="nslookup"
elif has dig ; then
    alias reversedns="dig -x"
fi

if has dig ; then
    alias dns="dig +short"
elif has host ; then
    alias dns="host"
fi

#Package Manager Aliases
has brew && alias brew="brew -v"
has port && alias port="port -v"

#Other software aliases
has lazygit && alias lg="lazygit"
has ddgr && alias search="ddgr"
has aria2c && alias ddl="aria2c --dir=$HOME/Downloads/aria2 --max-concurrent-downloads=20 --check-integrity=true --continue=true --max-connection-per-server=16 --split=20 --optimize-concurrent-downloads=true"
has Discord && alias discord="Discord"

#Spelling aliases
has ls && alias al="la"
has ls && alias sl="ls"
has lazygit && alias gl="lg"
