{modulesPath, ...}: {
    imports = ["${modulesPath}/virtualisation/proxmox-lxc.nix"];

    networking.hostName = "jesse";
    proxmoxLXC.manageHostName = true;
    networking.domain = "lan";
    system.stateVersion = "26.11";

    users.users.agent = {
        isNormalUser = true;
        extraGroups = ["networkmanager" "wheel"];
    };

    nix.settings = {
        trusted-users = ["fritz"];
        extra-platforms = ["aarch64-linux"];
        sandbox = true;
    };
}
