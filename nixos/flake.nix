{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        apple-silicon.url = "github:nix-community/nixos-apple-silicon";
        nixpkgs-asahi.follows = "apple-silicon/nixpkgs";
    };

    outputs = {
        nixpkgs,
        nixpkgs-asahi,
        apple-silicon,
        ...
    }: {
        nixosConfigurations = {
            antilles = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./configuration.nix
                    ./hosts/antilles
                ];
            };
            botzRus2 = nixpkgs-asahi.lib.nixosSystem {
                system = "aarch64-linux";
                modules = [
                    apple-silicon.nixosModules.default
                    ./configuration.nix
                    ./hosts/botzRus2
                ];
            };
        };
    };
}
