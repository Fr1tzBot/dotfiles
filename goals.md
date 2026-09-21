## Features:
1. [x] need-based install
    - only deploy configs for programs which are actually installed
    - has-checking seems to work
2. [ ] dotfile manager:
    - functionality:
        - [x] deploy (copy files from ~/Documents/dotfiles to their respective locations)
        - [ ] sync (pull files from ~ to git repo)
        - [ ] clean (clean up all dfm-deployed files
        - [ ] check (look for dependencies and explain what will/wont be installed)
        - [x] bash completion?
3. [x] iprove environment variable handling
    - work with fuzzel and ideally anything launched in user session
    - solved with nixos
4. [x] nvim: switch to 0.12 package management:
5. [x] niri: power, wifi, and bluetooth menus:
    - solved with noctalia

## Bugs:
- [x] waybar doesn't refresh automatically sometimes
    - solved with noctalia
    - this seems to be a sway bug...
- [x] nvim: clangd fails to install
    - solved with nvim 0.12 + system clangd
- [ ] nvim: asm_lsp doesn't detect architectures
- [ ] nvim: verible doesn't autofill
- [ ] nvim: jdtls throws error whenever a .java file is opened
- [ ] nvim: matlab_language_server doesn't autofill
- [x] foot: erorr ([colors]: use [colors-dark] instead)

