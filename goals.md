## Features:
1. [WIP] need-based install
    - only deploy configs for programs which are actually installed
    - never copy configs that may not work fully (looking at you nvim) if we know better
    - definitely don't try to install lsps that don't have the right deps
2. [ ] dotfile manager:
    - functionality:
        - [x] deploy (copy files from ~/Documents/dotfiles to their respective locations)
        - [ ] sync (pull files from ~ to git repo)
        - [ ] check (look for dependencies and explain what will/wont be installed)
        - [ ] bash completion?
3. [ ] iprove environment variable handling
    - work with fuzzel and ideally anything launched in user session
4. [ ] nvim: switch to 0.12 package management:
    - waiting for release
5. [ ] niri: power, wifi, and bluetooth menus:
    - probably with fuzzel using borrowed scripts

## Bugs:
- [ ] waybar doesn't refresh automatically sometimes
    - this seems to be a sway bug...
- [ ] nvim: clangd fails to install
- [ ] nvim: asm_lsp doesn't detect architectures
- [ ] nvim: verible doesn't autofill
- [ ] nvim: jdtls throws error whenever a .java file is opened
- [ ] nvim: matlab_language_server doesn't autofill
- [x] foot: erorr ([colors]: use [colors-dark] instead)

