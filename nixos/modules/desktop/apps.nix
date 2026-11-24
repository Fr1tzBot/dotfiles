{pkgs, ...}: {
    programs.firefox.enable = true;
    programs.foot.enable = true;
    programs.kdeconnect.enable = true;

    environment.systemPackages = with pkgs; [
        adwaita-icon-theme
        baobab
        ffmpegthumbnailer
        gimp
        gnome-firmware
        meld
        mpv
        nautilus
        obsidian
        webcord
        wl-clipboard-rs
    ];

    services.gvfs.enable = true;
    services.udisks2 = {
        enable = true;
        mountOnMedia = true;
    };
    services.gnome.sushi.enable = true;
    services.gnome.localsearch.enable = true;
    services.gnome.tinysparql.enable = true;
    programs.nautilus-open-any-terminal = {
        enable = true;
        terminal = "foot";
    };
}
