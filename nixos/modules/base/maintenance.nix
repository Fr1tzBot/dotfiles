{...}: {
    services.earlyoom = {
        enable = true;
        enableNotifications = true;
    };
    services.fstrim.enable = true;
    services.fwupd.enable = true;
    services.printing.enable = false;
    services.smartd = {
        enable = true;
        autodetect = true;
        defaults.monitored = "-a -o on -S on -n standby,q -W 4,45,55 -s (S/../.././02|L/../01/./03) ";
        notifications.systembus-notify.enable = true;
    };
    programs.git = {
        enable = true;
        config.safe.directory = "/home/fritz/Documents/dotfiles";
    };
    zramSwap.enable = true;
}
