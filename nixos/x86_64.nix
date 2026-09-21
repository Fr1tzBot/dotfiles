{ lib, pkgs, ... }:

{
    config = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64{
        boot.kernelPackages = pkgs.linuxPackages_latest;
        boot.loader.efi.canTouchEfiVariables = true;
        networking.hostName = "antilles";
        system.stateVersion = "26.05"; # Don't mess with this alr bud
        swapDevices = [{
            device="/swap";
        }];
    };
}
