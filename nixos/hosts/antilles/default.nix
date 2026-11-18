{pkgs, ...}: {
    imports = [./hardware-configuration.nix];
    environment.systemPackages = [pkgs.spotify];
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.loader.efi.canTouchEfiVariables = true;
    networking.hostName = "antilles";
    system.stateVersion = "26.05"; # Don't mess with this alr bud
    hardware.cpu.intel.updateMicrocode = true;
    # Apple devices in DFU/recovery mode (e.g. the M1 Air test machine), so irecovery/idevicerestore run without root.
    # libirecovery's own rule is a template (group "myusergroup") and does nothing as shipped.
    services.udev.extraRules = ''
        SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="122[27]|128[0-3]", MODE="0660", GROUP="dialout", TAG+="uaccess"
    '';
    swapDevices = [
        {
            device = "/swap";
        }
    ];
    fileSystems."/home/fritz/mnt" = {
        device = "/dev/disk/by-uuid/62E8-18EA";
        fsType = "exfat";
        noCheck = true;
        options = [
            "uid=1000"
            "gid=100" # "users" group
            "umask=0022" # or dmask=0022,fmask=0133
            "nofail"
            "x-systemd.automount"
            "x-systemd.device-timeout=5s"
            "noauto" # optional: don't mount at boot, only on access
        ];
    };
}
