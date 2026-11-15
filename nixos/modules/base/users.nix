{...}: {
    users.users.fritz = {
        isNormalUser = true;
        extraGroups = ["networkmanager" "wheel" "dialout" "video"];
    };
}
