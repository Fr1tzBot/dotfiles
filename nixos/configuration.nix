# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
    imports =
        [ # Include the results of the hardware scan.
        ./hardware-configuration.nix

	# changed for asahi
	./apple-silicon-support
        ];

    hardware.asahi.enable = true;

    hardware.graphics.enable = true;
    # changed for asahi
    # swapDevices = [{
    #     device="/swap";
    # }];

    nixpkgs.config.allowUnfree = true;

# Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 5;
    boot.loader.efi.canTouchEfiVariables = false; # changed for asahi

# Use latest kernel.
    #boot.kernelPackages = pkgs.linuxPackages_latest; #changed for asahi

    networking.hostName = "antilles"; # Define your hostname.
    networking.networkmanager.wifi.backend = "iwd"; #changed for asahi

# Configure network connections interactively with nmcli or nmtui.
    networking.networkmanager.enable = true;

# Set your time zone.
    time.timeZone = "America/Detroit";

# Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    fonts.packages = with pkgs; [
        nerd-fonts.space-mono
    ];

# Enable sound.
    services.pipewire = {
        enable = true;
        pulse.enable = true;
    };

    users.users.fritz = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" ];
    };

    programs.bat.enable = true;
    programs.firefox.enable = true;
    programs.foot.enable = true;
    programs.git.enable = true;
    programs.lazygit.enable = true;
    programs.niri.enable = true;
    systemd.user.services.niri.enableDefaultPath = false;

    environment.systemPackages = with pkgs; [
        pkgs.aria2
        pkgs.baobab
        pkgs.btop
        pkgs.cava
        pkgs.fastfetch
        pkgs.fuzzel
        pkgs.gimp
        pkgs.gnome-firmware
        pkgs.meld
        pkgs.mpv
        pkgs.neovim
        pkgs.nmap
        pkgs.obsidian
        pkgs.pavucontrol
        pkgs.R
        pkgs.restic #this should be done with services.restic later
        #pkgs.spotify # changed for asahi
        pkgs.swaybg
        pkgs.swaylock-effects
        pkgs.swayosd
        pkgs.tealdeer
        pkgs.tree
        pkgs.viu
        pkgs.waybar
        pkgs.waybar-lyric
        pkgs.webcord
        pkgs.wget
    ];

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# List services that you want to enable:
    services.avahi.enable = true;
    services.avahi.openFirewall = true;
    services.blueman.enable = true;
    services.dunst.enable = true;
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
    services.zerotierone.enable = true;

    security.doas.enable = true;
    security.doas.extraRules = [
    { users = ["fritz"]; keepEnv = true; persist = true; }
    ];
    security.polkit.enable = true;
    security.sudo.enable = false;

# disable the firewall altogether.
    networking.firewall.enable = false;

# Copy the NixOS configuration file and link it from the resulting system
# (/run/current-system/configuration.nix). This is useful in case you
# accidentally delete configuration.nix.
# system.copySystemConfiguration = true;

# This option defines the first version of NixOS you have installed on this particular machine,
# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
#
# Most users should NEVER change this value after the initial install, for any reason,
# even if you've upgraded your system to a new NixOS release.
#
# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
# to actually do that.
#
# This value being lower than the current NixOS release does NOT mean your system is
# out of date, out of support, or vulnerable.
#
# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
# and migrated your data accordingly.
#
# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "26.05"; # Did you read the comment?

}

