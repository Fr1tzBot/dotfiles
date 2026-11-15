{pkgs, ...}: {
    programs.firefox.enable = true;
    programs.foot.enable = true;

    environment.systemPackages = with pkgs; [
        adwaita-icon-theme
        baobab
        gimp
        gnome-firmware
        meld
        mpv
        obsidian
        webcord
        wl-clipboard-rs
    ];
}
