#!/bin/bash
has() { type -p "$1" &> /dev/null; }

#Color aliases
has grep && alias grep="grep --color=auto"
has fgrep && alias fgrep='fgrep --color=auto'
has egrep && alias egrep='egrep --color=auto'
has diff && alias diff="diff --color=auto"
has dir && alias dir='dir --color=auto'
has vdir && alias vdir='vdir --color=auto'
has tree && alias tree="tree -a -C"
has ip && alias ip="ip -c"

#Util aliases
if has ls ; then
    alias ls="ls -A --color=auto"
    alias la="ls -A --color=auto"
    alias l="ls -CF --color=auto"
    alias ll="ls -Alh --color=auto"
fi
has pwd && alias pwd="pwd -P"
has doas && alias sudo="doas"
has clear && alias cls="clear"
has exit && alias q="exit"
has which && alias which="which -a"
has cd && alias ..="cd .."
has thefuck && eval "$(thefuck --alias)"
has fuck && alias fk="fuck"
has dd && alias dd="dd status=progress"
has du && alias dush="du -sh"
has gcc && alias gcc="gcc -Wall"
has md5sum && alias md5="md5sum"
has xdg-open && alias open="xdg-open"

#Text Editor Aliases
setEditor() {
    [ "$1" != "vim" ] && alias vim="$1";
    [ "$1" != "vi" ] && alias vi="$1";
    [ "$1" != "nvim" ] && alias nvim="$1";
    [ "$1" != "nano" ] && alias nano="$1";
}

if has nvim ; then
    setEditor nvim
elif has vim ; then
    setEditor vim
elif has vi ; then
    setEditor vi
elif has nano ; then
    setEditor nano
fi

unset setEditor

# Text Viewer Aliases
setViewer() {
    alias bat="$1";
    alias batcat="$1";
    alias cat="$1";
}

if has bat ; then
    setViewer "bat -pp"
elif has batcat ; then
    setViewer "batcat -pp"
elif has cat ; then
    setViewer "cat"
fi

unset setViewer

# Zspotify Aliases
has zspotify && alias zspotify="zspotify -s"

#Youtube Aliases
has ytfzf && alias yt="ytfzf"
has youtube-dl && alias ytdl="youtube-dl --external-downloader=aria2c --external-downloader-args='--max-concurrent-downloads=20 --continue=true --max-connection-per-server=16 --split=20 --optimize-concurrent-downloads=true'"
has youtube-dl && alias ytmp3="youtube-dl -x --audio-format=flac --audio-quality=0 --external-downloader=aria2c --external-downloader-args='--max-concurrent-downloads=20 --continue=true --max-connection-per-server=16 --split=20 --optimize-concurrent-downloads=true'"
has ytfzf && alias ytsearch="ytfzf -L"

#Archive Aliases
has 7z && alias un7zip="7z x"
has tar && alias untar="tar -xvf"
has tar && alias ungz="tar -xvzf"
has unrar && alias unrar="unrar x"

#Networking Aliases
has Wireshark && alias wireshark="Wireshark"
has nmap && alias nmap="nmap -v -T4"
has nmap && alias randmap="nmap -v -iR 100"
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

has iwgetid && alias ssid="iwgetid -r"

#Package Manager Aliases
has port && alias port="port -v"

#Image Aliases
if has viu ; then
    alias icat="viu"
elif has kitty ; then
    alias icat="kitty +kitten icat"
fi

#Other software aliases
has lazygit && alias lg="lazygit"
has ddgr && alias search="ddgr"
has lynx && alias www="lynx"
has aria2c && alias ddl="aria2c --max-concurrent-downloads=20 --check-integrity=true --continue=true --max-connection-per-server=16 --split=20 --optimize-concurrent-downloads=true"
has Discord && alias discord="Discord"
has mpv && alias mpv="mpv --no-input-default-bindings"
has obsidian && alias obs="obsidian"
has matlab && alias matlab="matlab -nodisplay -nosplash -nojvm -r"

#Spelling aliases
has ls && alias al="la"
has ls && alias sl="ls"
has lazygit && alias gl="lg"
has fastfetch $$ alias neofetch="fastfetch"

