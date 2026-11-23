{...}: {
    imports = [
        ./asahi.nix
        ./hardware-configuration.nix
    ];
    networking.hostName = "botzRus2";
    system.stateVersion = "26.05"; # Don't mess with this alr bud
}
