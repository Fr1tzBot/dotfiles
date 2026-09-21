# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
    imports =
        [ # Include the results of the hardware scan.
        ./hardware-configuration.nix
        ./aarch64.nix
        ./x86_64.nix
        ] ++ lib.optional (builtins.pathExists ./apple-silicon-support) ./asahi.nix;


    hardware.graphics.enable = true;
    # changed for asahi, need to autodetect swap
    # swapDevices = [{
    #     device="/swap";
    # }];

    nixpkgs.config.allowUnfree = true;

# Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 5;

    networking.networkmanager.wifi.backend = "iwd";

# Configure network connections interactively with nmcli or nmtui.
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
        serif = [ "DejaVu Sans Serif" ];
        monospace = [ "DejaVu Sans Mono" ];
    };

# Enable sound.
    services.pipewire = {
        enable = true;
        pulse.enable = true;
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
        baobab
        btop
        cava
        fastfetch
        fuzzel
        gimp
        gnome-firmware
        htop
        meld
        mpv
        noctalia
        neovim
            asm-lsp
            bash-language-server
            jdt-language-server
            clang-tools
            lua-language-server
            matlab-language-server
            nil
            python314Packages.python-lsp-server
            rust-analyzer
            verible

        nmap
        obsidian
        pavucontrol
        R
        restic #this should be done with services.restic later
        tealdeer
        tree
        viu
        waybar
        waybar-lyric #last waybar dep still hanging around
        webcord
        wget
        wl-clipboard-rs
    ] ++ lib.optional pkgs.stdenv.hostPlatform.isx86_64 pkgs.spotify;

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# List services that you want to enable:
    services.avahi = {
        enable = true;
        openFirewall = true;
        nssmdns4 = true;
        publish = {
            enable = true;
            addresses = true;
        };
    };
    services.blueman.enable = true;
    services.greetd = {
        enable = true;
        settings.default_session = {
            command = "${config.programs.niri.package}/bin/niri-session";
            user = "fritz";
        };
    };
    services.libinput.enable = true;
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

# disable the firewall altogether.
    networking.firewall.enable = false;
}

