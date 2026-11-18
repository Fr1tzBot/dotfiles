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
            huyang = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./hosts/huyang
                    ./modules/base
                    ./modules/cli.nix
                    ./modules/dev.nix
                    ./modules/desktop
                ];
            };
            antilles = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./hosts/antilles
                    ./modules/base
                    ./modules/cli.nix
                    ./modules/dev.nix
                    ./modules/desktop
                ];
            };
            botzRus2 = nixpkgs-asahi.lib.nixosSystem {
                system = "aarch64-linux";
                modules = [
                    apple-silicon.nixosModules.default
                    ./hosts/botzRus2
                    ./modules/base
                    ./modules/cli.nix
                    ./modules/dev.nix
                    ./modules/desktop
                ];
            };
        };
    };
}
