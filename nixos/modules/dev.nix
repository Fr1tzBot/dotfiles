{pkgs, ...}: {
    environment.systemPackages = with pkgs; [
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
    ];
}
