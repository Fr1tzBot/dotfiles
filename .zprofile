eval $(/opt/homebrew/bin/brew shellenv)

PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/Users/fritz/bin:/usr/bin:/usr/sbin:/sbin:/opt/X11/bin:/Applications/Wireshark.app/Contents/MacOS"

PATH="/opt/homebrew/opt/ed/libexec/gnubin:$PATH"
PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"
PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
PATH="/opt/homebrew/opt/python@3.9/libexec/bin:$PATH"

PATH="/opt/homebrew/opt/zip/bin:$PATH"
PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"

PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
PATH="/opt/homebrew/opt/gnu-which/libexec/gnubin:$PATH"
PATH="/opt/homebrew/opt/gnu-time/libexec/gnubin:$PATH"
PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

export PATH
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
#export PS1="%B%F{green}%n%f%b%B%F{green}@%f%b%B%F{green}%m%f%b:%F{blue}%~%f$ "
eval `gdircolors ~/.dir_colors`
