eval $(/opt/homebrew/bin/brew shellenv)

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:/opt/X11/bin:/Applications/Wireshark.app/Contents/MacOS"
export PS1="%B%F{green}%n%f%b%B%F{green}@%f%b%B%F{green}%m%f%b:%F{blue}%~%f$ "
export CLICOLOR=1
#eval `gdircolors ~/.dir_colors`
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi
