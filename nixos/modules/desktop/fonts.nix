{pkgs, ...}: {
    fonts.packages = with pkgs; [
        nerd-fonts.hack
        dejavu_fonts
        fira-sans
        font-awesome
        nerd-fonts.space-mono
        source-code-pro
    ];

    fonts.fontconfig.defaultFonts = {
        sansSerif = ["DejaVu Sans"];
        serif = ["DejaVu Serif"];
        monospace = ["DejaVu Sans Mono"];
    };
}
