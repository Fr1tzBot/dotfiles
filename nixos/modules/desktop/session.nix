{pkgs, ...}: {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    hardware.graphics.enable = true;

    programs.niri.enable = true;
    systemd.user.services.niri.enableDefaultPath = false;

    environment.systemPackages = with pkgs; [
        ddcutil
        noctalia
    ];

    services.displayManager.noctalia-greeter = {
        enable = true;
        settings = {
            cursor.size = 20;
            keyboard.layout = "us";
        };
        cursorTheme = {
            package = pkgs.adwaita-icon-theme;
            name = "Adwaita";
        };
    };
    security.pam.services.greetd.enableGnomeKeyring = true;
    services.libinput.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
}
