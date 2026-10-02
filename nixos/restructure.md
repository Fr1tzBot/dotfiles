# NixOS Restructure

## Tree:
- modules/
    - apple-silicon-support
    - secrets
    - wifi
    - hardware
    - boot
    - networking
    - locale (fonts too)
    - programs
    - noctalia
    - services

- hosts/
    - botzRus2.nix modules:
        - apple-silicon-support
        -
    - antilles.nix

- configuration.nix
    - detects host and sources host file
    - garbage collection lives here
    - users live here
