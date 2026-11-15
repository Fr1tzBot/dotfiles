{...}: {
    networking.networkmanager.wifi.backend = "iwd";
    networking.networkmanager.enable = true;

    networking.firewall = {
        enable = true;
        allowedTCPPorts = [22];
        allowedUDPPorts = [5353];
    };

    services.avahi = {
        enable = true;
        openFirewall = true;
        nssmdns4 = true;
        settings.publish = {
            publish-addresses = true;
            disable-publishing = false;
        };
    };

    services.chrony = {
        enable = true;
        servers = ["time.mtu.edu" "time.cloudflare.com" "0.nixos.pool.ntp.org"];
        serverOption = "iburst";
    };
    services.openssh.enable = true;
    services.zerotierone.enable = true;
}
