{
    lib,
    pkgs,
    ...
}: {
    config = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
        boot.kernelPackages = pkgs.linuxPackages_latest;
        boot.loader.efi.canTouchEfiVariables = true;
        networking.hostName = "antilles";
        system.stateVersion = "26.05"; # Don't mess with this alr bud
        hardware.cpu.intel.updateMicrocode = true;
        swapDevices = [
            {
                device = "/swap";
            }
        ];
        fileSystems."/home/fritz/mnt" = {
            device = "/dev/disk/by-uuid/62E8-18EA";
            fsType = "exfat";
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
    };
}
