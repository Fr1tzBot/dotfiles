{ config, lib, pkgs, ... }:

{
    imports = [
        ./hardware-configuration.nix
        ./aarch64.nix
        ./x86_64.nix
    ] ++ lib.optional (builtins.pathExists ./apple-silicon-support) ./asahi.nix
      ++ lib.optional (builtins.pathExists ./wifi.nix) ./wifi.nix;

    hardware.graphics.enable = true;

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    nixpkgs.config.allowUnfree = true;

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 5;

    networking.networkmanager.wifi.backend = "iwd";
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "America/Detroit";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    nix.gc = {
        automatic = true;
        dates = "weekly";
    };

    fonts.packages = with pkgs; [
        nerd-fonts.hack
        dejavu_fonts
        fira-sans
        font-awesome
        nerd-fonts.space-mono
        source-code-pro
    ];

    fonts.fontconfig.defaultFonts = {
        sansSerif = [ "DejaVu Sans" ];
        serif = [ "DejaVu Serif" ];
        monospace = [ "DejaVu Sans Mono" ];
    };


    users.users.fritz = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" ];
    };

    programs.bat.enable = true;
    programs.firefox.enable = true;
    programs.foot.enable = true;
    programs.git.enable = true;
    programs.lazygit.enable = true;
    programs.niri.enable = true;
    systemd.user.services.niri.enableDefaultPath = false;

    environment.systemPackages = with pkgs; [
        aria2
        adwaita-icon-theme
        baobab
        btop
        cava
        fastfetch
        gimp
        htop
        meld
        mpv
        noctalia
            ddcutil
            iw
        neovim
            R
            asm-lsp
            bash-language-server
            clang-tools
            jdt-language-server
            lua-language-server
            matlab-language-server
            nil
            python314Packages.python-lsp-server
            rust-analyzer
            shellcheck
            verible

        nmap
        obsidian
        restic #this should be done with services.restic later
        tealdeer
        tree
        viu
        waybar-lyric #last waybar dep still hanging around
        webcord
        wget
        wl-clipboard-rs
    ] ++ lib.optional pkgs.stdenv.hostPlatform.isx86_64 pkgs.spotify;

    xdg.mime.defaultApplications = {
        # Nvim Files
        "text/plain" = "nvim.desktop";
        "text/markdown" = "nvim.desktop";

        # MPV Files
        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";

        # Firefox files
        "application/pdf" = "firefox.desktop";
        "image/png" = "firefox.desktop";
        "image/jpeg" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "text/html" = "firefox.desktop";
    };

    services.avahi = {
        enable = true;
        openFirewall = true;
        nssmdns4 = true;
        publish = {
            enable = true;
            addresses = true;
        };
    };

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

    services.libinput.enable = true;
    services.pipewire = {
        enable = true;
        pulse.enable = true;
    };
    services.openssh.enable = true;
    services.printing.enable = false;
    services.upower.enable = true;
    services.zerotierone.enable = true;

    security.doas.enable = true;
    security.doas.extraRules = [
        { users = ["fritz"]; keepEnv = true; persist = true; }
    ];
    security.polkit.enable = true;
    security.sudo.enable = false;

    networking.firewall.enable = false;
}

