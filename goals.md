## Features:
1. [WIP] need-based install
    - only deploy configs for programs which are actually installed
    - never copy configs that may not work fully (looking at you nvim) if we know better
    - definitely don't try to install lsps that don't have the right deps
2. [WIP] centralized `dfm` program
    - functionality:
        - [x] deploy (copy files from ~/Documents/dotfiles to their respective locations)
        - [ ] sync (pull files from ~ to git repo)
        - [ ] check (look for dependencies and explain what will/wont be installed)
        - [ ] bash completion?
3. [DONE] improved organization
    - create directory structure in code instead of having it in the actual git repo
    - folders for each program
    - add any important /etc files
4. [x] ssh configuration??
5. [ ] minimize essential dependencies
    - eliminate python dep?

## Bugs:
- [ ] waybar doesn't refresh automatically sometimes
    - this seems to be a sway bug...
- [ ] nvim: clangd fails to install
- [ ] nvim: asm_lsp doesn't detect architectures
- [ ] nvim: verible doesn't autofill
- [ ] nvim: jdtls throws error whenever a .java file is opened
- [ ] nvim: matlab_language_server doesn't autofill
- [x] foot: erorr ([colors]: use [colors-dark] instead)

