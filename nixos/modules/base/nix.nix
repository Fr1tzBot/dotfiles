{...}: {
    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 10d";
    };

    nix.settings = {
        auto-optimise-store = true;
        experimental-features = ["nix-command" "flakes"];
    };

    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;
    environment.defaultPackages = [];
    documentation.nixos.enable = false;
}
