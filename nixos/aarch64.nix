{ lib, pkgs, ... }:
{
    config = lib.mkIf pkgs.stdenv.hostPlatform.isAarch64 {
        networking.hostName = "botzRus2"; # Define your hostname.
        system.stateVersion = "26.05"; # Don't mess with this alr bud
    };
}
