{...}:
{
    imports = [ ./apple-silicon-support ];
    hardware.asahi.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;
}
