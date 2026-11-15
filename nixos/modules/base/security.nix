{...}: {
    security.doas.enable = true;
    security.doas.extraRules = [
        {
            users = ["fritz"];
            keepEnv = true;
            persist = true;
        }
    ];
    security.polkit.enable = true;

    security.sudo.enable = false;
}
