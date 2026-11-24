{
    modulesPath,
    pkgs,
    ...
}: {
    imports = ["${modulesPath}/virtualisation/proxmox-lxc.nix"];

    networking.hostName = "kickback";
    proxmoxLXC.manageHostName = true;
    system.stateVersion = "26.05";

    environment.systemPackages = with pkgs; [
        docker-compose
    ];

    virtualisation.docker.enable = true;
}
