{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        apple-silicon = {
            url = "github:nix-community/nixos-apple-silicon";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = {
        nixpkgs,
        apple-silicon,
        ...
    }: {
        nixosConfigurations = {
            botzRus2 = nixpkgs.lib.nixosSystem {
                system = "aarch64-linux";
                modules = [
                    apple-silicon.nixosModules.default
                    ./configuration.nix
                    ./hosts/botzRus2
                ];
            };
            antilles = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [./configuration.nix ./hosts/antilles];
            };
        };
    };
}
