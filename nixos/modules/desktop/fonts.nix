{pkgs, ...}: {
    fonts.packages = with pkgs; [
        dejavu_fonts
        fira-sans
        font-awesome
        nerd-fonts.hack
        nerd-fonts.space-mono
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        source-code-pro
    ];

    fonts.fontconfig.defaultFonts = {
        sansSerif = ["DejaVu Sans"];
        serif = ["DejaVu Serif"];
        monospace = ["DejaVu Sans Mono"];
    };
}
