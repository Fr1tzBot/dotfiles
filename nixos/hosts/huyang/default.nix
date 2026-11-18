{pkgs, ...}: {
    imports = [./hardware-configuration.nix];
    environment.systemPackages = [pkgs.spotify];
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.loader.efi.canTouchEfiVariables = true;
    networking.hostName = "huyang";
    system.stateVersion = "26.05"; # Don't mess with this alr bud
    hardware.cpu.intel.updateMicrocode = true;
    swapDevices = [
        {
            device = "/swap";
        }
    ];
    services.octoprint.enable = true;
    networking.firewall.allowedTCPPorts = [5000];
}
