{...}: {
    xdg.mime.defaultApplications = {
        #Folders
        "inode/directory" = "org.gnome.Nautilus.desktop";

        # Nvim Files
        "text/plain" = "nvim.desktop";
        "text/markdown" = "nvim.desktop";

        # MPV Files
        "audio/mpeg" = "mpv.desktop";
        "image/gif" = "mpv.desktop";
        "image/jpeg" = "mpv.desktop";
        "image/png" = "mpv.desktop";
        "image/webp" = "mpv.desktop";
        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";

        # Firefox files
        "application/pdf" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "text/html" = "firefox.desktop";
    };

    xdg.terminal-exec = {
        enable = true;
        settings.default = ["foot.desktop"];
    };
}
