#!/bin/bash
if [  -z "$1" ]; then
    printf "\nOptions:\n    update  | List Updates\n    upgrade | Install Recommended Updates\n"
    read -p "> " option
else
    option="$1"
fi
if [ $option == "update" ]; then
    printf "checking for availible updates...\n"
    softwareupdate -l --verbose
elif [ $option == "upgrade" ]; then
    printf "installing availible updates...\n"
    if [ $2 == "reboot" ]; then
        sudo softwareupdate -irR --agree-to-license --verbose
    else
        softwareupdate -ir --agree-to-license --verbose
    fi
else
    printf "Please Enter an option"
fi
