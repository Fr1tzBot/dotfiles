{...}: {
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
}
