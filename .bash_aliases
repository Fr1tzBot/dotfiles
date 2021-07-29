alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias diff="diff --color=auto"

alias la="ls -A"
alias l="ls -CF"
alias ll="ls -Alh"

alias which="which -a"
alias brew="brew -v"
alias port="port -v"
alias nmap="nmap -T4"

alias nano="vim"
alias lg="lazygit"
alias search="ddgr"
alias ddl="aria2c --dir=$HOME/Downloads/aria2 --max-concurrent-downloads=20 --check-integrity=true --continue=true --max-connection-per-server=16 --split=20 --optimize-concurrent-downloads=true"

alias trash="trash -v -F"
if [ command -v thefuck &> /dev/null ] ; then
    eval $(thefuck --alias)
fi

