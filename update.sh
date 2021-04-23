#!/bin/bash
printf "\nRunning Brew Update...\n\n"
sleep 0.5
brew -v update
printf "\nRunning Brew Upgrade...\n\n"
sleep 0.5
brew -v upgrade
printf "\nRunning Brew Autoremove...\n\n"
sleep 0.5
brew -v autoremove
printf "\nRunning MacOS Update...\n\n"
sleep 0.5
bash ~/macUpdater.sh update
printf "\nDo the mac upgrade mamually bub\n"
