# Goals:

1. need-based install
    - only deploy configs for programs which are actually installed
    - never copy configs that may not work fully (looking at you nvim) if we know better
2. centralized `dotfiles` program
    - functionality:
        - deploy (copy files from ~/Documents/dotfiles to their respective locations)
        - sync (pull files from ~ to git repo)
        - check (look for dependencies and explain what will/wont be installed)
3. improved organization
    - create directory structure in code instead of having it in the actual git repo
    - folders for each program
        - can collect programs that depend on others (eg swaylock can be in sway folder, as that's really the only time it can truly be used
    - add any important /etc files
4. ssh configuration??
    - no idea how this might work but it would be super nice

