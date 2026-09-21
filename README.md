# dotfiles

## Currently Maintained Configs:
- CLI:
    - bash
    - cava
    - fastfetch
    - foot
    - git
    - neovim
    - ssh
- GUI:
    - mpv
    - niri
    - nixos
    - noctalia

## Archive Configs:
- dunst
- fuzzel
- kitty
- neofetch
- sway-wm
- swaylock
- vim
- waybar

Archived configs are still deployed if their respective program is detected.

## Installation
Everything can be installed by running the deploy script with `./bin/dfm-deploy`

## Updating
Once Dotfiles have been installed, you can update them with:

`dfm update` to pull the latest version from git

followed by `dfm deploy` to copy over the new files

on nixos, the config can be updated with `dfm nixdeploy`

## Dependencies
The scripts in `bin/` are written in **Bash**

