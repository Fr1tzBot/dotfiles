{lib, pkgs, ...}:
let
  pkgver = "4.10.2710.0";
  lacrosVersion = "128.0.6613.137";

  lacrosImage = pkgs.fetchurl {
    name = "lacros-arm64-${lacrosVersion}.squashfs";
    url = "https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/chromeos-lacros-arm64-squash-zstd-${lacrosVersion}";
    sha256 = "8aa6714c943c7d344c828e822028890b430c674981016f4c77417c26db25d909";
  };

  # 64-bit fixup script from mogwai/widevine (hash is the one in the PKGBUILD)
  fixupScript = pkgs.fetchurl {
    name = "widevine_fixup.py";
    url = "https://codeberg.org/mogwai/widevine/raw/commit/4aeec1ca8e13b25621d33a58f9737b24a41ce64e/widevine_fixup.py";
    sha256 = "6e886755201f1ba9dab1ead5f11846bae321cbf343da1112f06c08c8a8012182";
  };

  widevineGmp = pkgs.runCommand "widevine-gmp-${pkgver}" {
    nativeBuildInputs = [ pkgs.squashfsTools pkgs.python3 pkgs.patchelf ];
  } ''
    unsquashfs -q -no-xattrs ${lacrosImage} 'WidevineCdm/*'

    # patch widevine lib: add missing functions, support non-4k page sizes
    python3 ${fixupScript} \
      squashfs-root/WidevineCdm/_platform_specific/cros_arm64/libwidevinecdm.so \
      libwidevinecdm.so

    # NixOS-only: Arch finds libnspr4 in /usr/lib, we have to point at it
    patchelf --add-rpath ${lib.getLib pkgs.nspr}/lib libwidevinecdm.so

    d=$out/gmp-widevinecdm/system-installed
    mkdir -p $d
    install -m755 libwidevinecdm.so $d/

    # same manifest the PKGBUILD generates (major=4, minor=10)
    cat > $d/manifest.json <<EOF
    {
       "name": "WidevineCdm",
       "description": "Widevine Content Decryption Module",
       "version": "${pkgver}",
       "x-cdm-codecs": "vp8,vp9.0,avc1,av01",
       "x-cdm-host-versions": "10",
       "x-cdm-interface-versions": "10",
       "x-cdm-module-versions": "4",
       "x-cdm-persistent-license-support": true
    }
    EOF
  '';
in
{
    imports = [ ./apple-silicon-support ];
    hardware.asahi.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;
    environment.sessionVariables.MOZ_GMP_PATH = "${widevineGmp}/gmp-widevinecdm/system-installed";
    programs.firefox = {
        enable = true;
        preferencesStatus = "default";   # closest to Arch's defaults/preferences file; also stops locking the UI
        preferences = {
            "media.gmp-widevinecdm.version" = pkgver;
            "media.gmp-widevinecdm.visible" = true;
            "media.gmp-widevinecdm.enabled" = true;
            "media.gmp-widevinecdm.autoupdate" = false;
            "media.eme.enabled" = true;
            "media.eme.encrypted-media-encryption-scheme.enabled" = true;
        };
    };
}

