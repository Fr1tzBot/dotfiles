{...}: {
    imports = [
        ./asahi.nix
        ./hardware-configuration.nix
    ];
    # Touch ID via Aurora's apple_sep driver (modules/mesa/README.md before the first boot)
    mesa.auroraTouchId.enable = true;
    networking.hostName = "botzRus2"; # Define your hostname.
    system.stateVersion = "26.05"; # Don't mess with this alr bud
}
