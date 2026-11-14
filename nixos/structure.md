nixos/
├── flake.nix
├── flake.lock
├── configuration.nix
└── hosts/
    ├── botzRus2/
    │   ├── default.nix        # was aarch64.nix
    │   ├── asahi.nix          # minus the fetchGit import
    │   └── hardware-configuration.nix
    └── antilles/
        ├── default.nix        # was x86_64.nix
        └── hardware-configuration.nix
