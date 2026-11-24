{pkgs, ...}: {
  programs.bat.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.lazygit.enable = true;
  programs.nano.enable = false;

  environment.systemPackages = with pkgs; [
    aria2
    btop
    cava
    fastfetch
    htop
    iw #??? may be able to get rid of
    neovim
    nmap
    restic #this should be done with services.restic later
    tealdeer
    tree
    unzip
    (viu.override {withSixel = truel;})
    wget
  ];
}
