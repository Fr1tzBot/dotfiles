# Native Touch ID for botzRus2, the J313 (M1 MacBook Air), with Aurora's apple_sep driver. Imported from flake.nix for
# botzRus2 only (enabled in hosts/botzRus2): the kernel, m1n1 and calibration path are specific to this machine.
# Knowledge base: mesa-vault, "Native NixOS Touch ID" and "Linux Touch ID recipe".
#
# Every patched or forked component is pinned in `pins` below, so updating nixpkgs or nixos-apple-silicon never changes
# it. Bump one deliberately by editing its entry (and its hash), then rebuild and check Touch ID.
#
# Pieces:
#  1. Kernel: omacom/linux-aurora integration/aurora-7.3 with one patch, patches/0001-apple-sep-t8103-key-store-v5.patch
#     (`key_store_v5=1`: this Mac's identity keybag is variant 5, the T8103 profile assumes the 13.5 key store). Its
#     DTBs (SEP and Mesa nodes) go into boot.bin. Config: generated, as for linux-asahi (see auroraKernel below).
#  2. m1n1: Aurora's fork, unpatched. It forwards /chosen/apfs-preboot-uuid, the SEP's OS identity; without it the
#     master catacomb save/load fails 0x6 (mesa-vault "Why does the master SAVE_CATACOMB fail in Linux").
#  3. apple_sep is loaded by apple-sep.service, once: after the iBootSystemContainer partition exists and only when the
#     seeded keybag and calibration are in /var/lib. provision_keybag=0 always: a second keybag is never created.
#  4. Aurora's userspace (aurora-sep-userspace): libfprint + apple-sep driver, fprintd, with Aurora's desktop
#     integration from tools/aurora-sep/: Touch ID warmed up at boot before fprintd starts, fprintd resident, fprintd
#     stopped before sleep, short power-button press suspends (the sensor IS the button).
#  5. PAM: fingerprint only where it is asked for (cfg.pamServices); never at greetd/login (the fingerprint can't
#     unlock gnome-keyring) or sshd.
#
# Every enrolment and match writes the device-wide xART store (mesa-vault "xART anti-replay risk"); the user accepted
# that for this Mac on 2026-11-18. Private data (host state, calibration) lives only in /var/lib, never in the store.
{
    config,
    lib,
    pkgs,
    ...
}: let
    cfg = config.mesa.auroraTouchId;

    pins = {
        # integration/aurora-7.3, 2026-11-20
        kernel = {
            owner = "omacom";
            repo = "linux-aurora";
            rev = "ce3c5d3c95d223830edc7f722cccc726ec0f20d9";
            hash = "sha256-M0RMZnYPRnkNzQcNRN99Iw30E220e7yxbzy80KT5ip4=";
            version = "7.3.0";
        };
        # integration/aurora, 2026-11-10
        m1n1 = {
            owner = "omacom";
            repo = "m1n1";
            rev = "ba130ffbeeadaa35215ed88b07ebcee3199d0be7";
            hash = "sha256-MDqdtFFP4Mo+aYYT51K2OcsAd93+6V1CIwciqfhHQXw=";
            cargoHash = "sha256-Rw9xhDAZx1YIiS62fKmSoq8FDZ1JJNhA7p/Wx35R7RQ=";
            version = "2.0.0-aurora-ba130ff";
        };
        # the bindgen release Aurora's tools/aurora-bindgen patches are written against (its sources.json)
        bindgen = {
            version = "0.73.2";
            hash = "sha256-b+0LM4AbngOsOPp0YjLww3EINHJFSbISLbUa2H/HiaA=";
            cargoHash = "sha256-eiIw/FcTb+s1Syf7hLnlLyeU1+TEZa8Mz4c1NC1dEN0=";
        };
        # aurora-silicon/aurora-sep-userspace: libfprint/ and fprintd/ patches, 2026-11-20
        userspace = {
            owner = "aurora-silicon";
            repo = "aurora-sep-userspace";
            rev = "c889b449c2b79b4722b30f34f0fa90d5118b2900";
            hash = "sha256-1BjpVp4lELS5cc9+2o5P9hOeMw6pkvwiHxWoWNbghCI=";
        };
        # the versions the userspace patches are written against
        libfprint = {
            version = "1.94.100";
            hash = "sha256-JwD8U6CjVH+huvVFIxRWRrsWbLOEeqOd1lCMdWgPtrA=";
        };
        fprintd = {
            version = "1.94.5";
            hash = "sha256-aGIz50S0zfE3rV6QJp8iQz3uUVn8WAL68KU70j8GyOU=";
        };
    };

    fromGitHub = p: pkgs.fetchFromGitHub {inherit (p) owner repo rev hash;};
    auroraSrc = fromGitHub pins.kernel;
    userspace = fromGitHub pins.userspace;

    # Apply every numbered patch of a userspace directory in order; a bump picks up new ones without a list here.
    applyNumbered = dir: ''
        for p in ${userspace}/${dir}/0*.patch; do
            echo "applying $p"
            patch -p1 --no-backup-if-mismatch < "$p"
        done
    '';

    libfprintAurora = pkgs.libfprint.overrideAttrs (old: {
        inherit (pins.libfprint) version;
        src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "libfprint";
            repo = "libfprint";
            rev = "v${pins.libfprint.version}";
            inherit (pins.libfprint) hash;
        };
        # the driver itself first, then 0002.. on top of it
        patches = (old.patches or []) ++ ["${userspace}/libfprint/libfprint-${pins.libfprint.version}-apple-sep.patch"];
        # the kernel UAPI header isn't in distribution headers; same as their Fedora spec
        postPatch =
            (old.postPatch or "")
            + applyNumbered "libfprint"
            + ''
                install -Dm0644 ${userspace}/libfprint/apple-sep.h aurora-uapi/linux/apple-sep.h
            '';
        preConfigure =
            (old.preConfigure or "")
            + ''
                export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$PWD/aurora-uapi"
            '';
        doCheck = false;
    });
    fprintdAurora = (pkgs.fprintd.override {libfprint = libfprintAurora;}).overrideAttrs (old: {
        inherit (pins.fprintd) version;
        src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "libfprint";
            repo = "fprintd";
            tag = "v${pins.fprintd.version}";
            inherit (pins.fprintd) hash;
        };
        postPatch = (old.postPatch or "") + applyNumbered "fprintd";
        doCheck = false;
    });

    # Aurora's 7.3 tree needs bindgen 0.73.2 with its two layout fixes (tools/aurora-bindgen, see
    # Documentation/rust/bindgen-layout-checks.rst there): stock bindgen drops the alignment of aligned empty C
    # structs, which shifts Rust field offsets; the kernel's layout assertions then stop the build (E0080). The patches
    # come from the pinned kernel tree, so they move with it. Built like nixpkgs' rust-bindgen-unwrapped (libclang
    # linked, not loaded at run time), from the upstream workspace that the patches apply to.
    bindgenSrc = pkgs.fetchFromGitHub {
        owner = "rust-lang";
        repo = "rust-bindgen";
        tag = "v${pins.bindgen.version}";
        inherit (pins.bindgen) hash;
    };
    auroraBindgen = pkgs.rust-bindgen-unwrapped.overrideAttrs (old: {
        pname = "rust-bindgen-aurora";
        inherit (pins.bindgen) version;
        src = bindgenSrc;
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
            pname = "rust-bindgen-aurora";
            inherit (pins.bindgen) version;
            src = bindgenSrc;
            hash = pins.bindgen.cargoHash;
        };
        cargoBuildFlags = ["-p" "bindgen-cli"];
        postPatch =
            (old.postPatch or "")
            + ''
                for p in ${auroraSrc}/tools/aurora-bindgen/patches/*.patch; do
                    echo "applying $p"
                    patch -p1 --no-backup-if-mismatch < "$p"
                done
            '';
        # upstream's own suite; the kernel's mandatory layout assertions are what check this generator
        doCheck = false;
    });

    # nixos-apple-silicon's linux-asahi recipe (NixOS's common kernel config + their Asahi options) on Aurora's source,
    # with Aurora's own Apple-hardware fragment (arch/arm64/configs/asahi.config) merged over defconfig as the base.
    # The recipe takes no extra arguments, so its buildLinux call is wrapped. No config file is kept here: the config
    # follows nixpkgs and nixos-apple-silicon like linux-asahi's does; the source and the patch stay pinned.
    asahiPkgs = config.hardware.asahi.pkgs;
    auroraKernel =
        (asahiPkgs.linux-asahi.override {
            _kernelPatches =
                config.boot.kernelPatches
                ++ [
                    {
                        name = "apple-sep: T8103 variant-5 key store (key_store_v5)";
                        patch = ./patches/0001-apple-sep-t8103-key-store-v5.patch;
                        structuredExtraConfig = with lib.kernel; {
                            # fail the build, not the boot, if the driver ever drops out of the config
                            APPLE_SEP = module;
                            # under COMPAT (32-bit EL0), which Aurora's fragment turns off: M1 cores have no AArch32
                            ARMV8_DEPRECATED = lib.mkForce unset;
                            COMPAT_ALIGNMENT_FIXUPS = lib.mkForce unset;
                            CP15_BARRIER_EMULATION = lib.mkForce unset;
                        };
                    }
                ];
        })
        .kernel
        .override {
            buildLinux = args:
                asahiPkgs.buildLinux (args
                    // {
                        pname = "linux-aurora";
                        src = auroraSrc;
                        inherit (pins.kernel) version;
                        modDirVersion = pins.kernel.version;
                        defconfig = "defconfig asahi.config";
                        # used for the config generation and the build alike
                        extraMakeFlags = (args.extraMakeFlags or []) ++ ["BINDGEN=${auroraBindgen}/bin/bindgen"];
                    });
        };

    m1n1Aurora = config.hardware.asahi.pkgs.m1n1.overrideAttrs (finalAttrs: old: {
        inherit (pins.m1n1) version;
        src = fromGitHub pins.m1n1;
        cargoDeps = old.passthru.rustPlatform.fetchCargoVendor {
            inherit (finalAttrs) pname version;
            src = "${finalAttrs.src}/rust";
            sourceRoot = "rust";
            hash = pins.m1n1.cargoHash;
        };
        # The fork's Python suite tests Aurora's harness tooling: it needs git and clang, and compiles host C programs
        # that nixpkgs' hardening flags turn into -Werror failures. None of it tests the firmware that boots.
        doCheck = false;
        meta = old.meta // {changelog = "https://github.com/${pins.m1n1.owner}/${pins.m1n1.repo}/commits/${pins.m1n1.rev}";};
    });

    # Aurora's readiness check (tools/aurora-sep/aurora-sep-ready, GPL-2.0-only), unchanged: the first open of
    # /dev/sep-bio restores the enrolled fingerprints; it then waits for the driver's diag attributes to say the
    # sensor attached and the restore ran, and fails with the reason otherwise.
    auroraSepReady = pkgs.runCommand "aurora-sep-ready" {} ''
        install -Dm755 ${auroraSrc}/tools/aurora-sep/aurora-sep-ready $out/bin/aurora-sep-ready
        substituteInPlace $out/bin/aurora-sep-ready --replace-fail '#!/bin/sh' '#!${pkgs.runtimeShell}'
    '';

    # Private state the driver keeps in /var/lib (names from mesa-vault linux19 and Aurora's HOST-STATE.md).
    keybag = "/var/lib/aurora-sep-keybag.bin";
    calibration = "/var/lib/apple-sep-firmware/apple/mesacal-j313.bin"; # DT firmware-name apple/mesacal-j313.bin
    iboot = "/dev/disk/by-partlabel/iBootSystemContainer";
    ibootUnit = "dev-disk-by\\x2dpartlabel-iBootSystemContainer.device";

    # Copy the host state aside before each load: every match re-saves it, and a lost keybag cannot be recreated
    # without risk. Keeps the newest cfg.backups copies, root-only. Restore only the newest one.
    touchid-backup = pkgs.writeShellApplication {
        name = "touchid-backup";
        runtimeInputs = with pkgs; [coreutils findutils];
        text = ''
            umask 077
            dest=/var/lib/touchid-backup
            install -d -m 700 "$dest"
            snap="$dest/$(date -u +%Y%m%dT%H%M%SZ)"
            mkdir "$snap"
            for f in /var/lib/aurora-sep-*.bin /var/lib/apple-sep-*.bin; do
                [ -f "$f" ] && cp -a "$f" "$snap/"
            done
            [ -d /var/lib/fprint ] && cp -a /var/lib/fprint "$snap/fprint"
            # drop all but the newest ${toString cfg.backups}
            find "$dest" -mindepth 1 -maxdepth 1 -type d -name '20*' -print0 | sort -z -r |
                tail -z -n +${toString (cfg.backups + 1)} | xargs -0 -r rm -rf --
            echo "touchid-backup: $snap"
        '';
    };

    touchid-status = pkgs.writeShellApplication {
        name = "touchid-status";
        runtimeInputs = with pkgs; [coreutils systemd gnugrep kmod fprintdAurora];
        text = ''
            echo "== services"
            for u in apple-sep fprintd; do
                printf '  %-16s %s\n' "$u" "$(systemctl is-active "$u.service" || true)"
            done
            echo "== module"
            if grep -q '^apple_sep ' /proc/modules; then echo "  apple_sep loaded"; else echo "  apple_sep NOT loaded"; fi
            if [ -c /dev/sep-bio ]; then echo "  /dev/sep-bio present"; else echo "  /dev/sep-bio absent"; fi
            if [ -s ${keybag} ]; then echo "  keybag present"; else echo "  keybag MISSING (restore from /var/lib/touchid-backup)"; fi
            if [ -s ${calibration} ]; then echo "  calibration present"; else echo "  calibration MISSING (restore from /var/lib/touchid-backup)"; fi
            for d in /sys/bus/platform/devices/*.sep/diag; do
                [ -d "$d" ] || continue
                echo "== diag"
                for a in "$d"/*; do
                    [ -f "$a" ] && [ -r "$a" ] && printf '  %-22s %s\n' "''${a##*/}" "$(head -c 200 "$a" | tr '\n' ' ')"
                done
            done
            echo "== kernel log (this boot)"
            journalctl -k -b --no-pager -o cat 2>/dev/null | grep -E 'apple_sep|apple-sep|Touch ID|xART' | tail -n 25 || true
            echo "== apple-sep.service"
            journalctl -b -u apple-sep.service --no-pager -o cat 2>/dev/null | tail -n 5 || true
            user=''${DOAS_USER:-''${SUDO_USER:-$(id -un)}}
            echo "== fprintd prints for $user"
            fprintd-list "$user" 2>&1 | sed 's/^/  /' || true
        '';
    };
in {
    options.mesa.auroraTouchId = {
        enable = lib.mkEnableOption "Aurora apple_sep Touch ID";

        driverParams = lib.mkOption {
            type = lib.types.str;
            # linux19: stock user 1000, OS UUID from m1n1, variant-5 keybag. Never provision_keybag=1.
            # trusted_keys/filevault_api (new in 7.3, default on) stay off until wanted.
            default = "xart_writes=1 provision_keybag=0 xart_guard=0 key_store_v5=1 trusted_keys=0 filevault_api=0";
            description = "apple_sep module parameters.";
        };

        pamServices = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = ["doas" "polkit-1"];
            example = ["doas" "polkit-1" "noctalia"];
            description = ''
              PAM services that try Touch ID before the password. Add the lock screen's service once known.
              Keep greetd/login off: a fingerprint login cannot unlock gnome-keyring.
            '';
        };

        pamTimeout = lib.mkOption {
            type = lib.types.ints.positive;
            default = 15;
            description = "Seconds pam_fprintd waits for a finger before falling back to the password.";
        };

        powerKeySuspend = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              The sensor is the power button; a firm press while authenticating is a key press. Make a short press
              suspend (logind's default is power off) and a 5 s hold power off.
            '';
        };

        backups = lib.mkOption {
            type = lib.types.ints.positive;
            default = 10;
            description = "Boot-time copies of the host state kept in /var/lib/touchid-backup.";
        };
    };

    config = lib.mkIf cfg.enable {
        boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor auroraKernel);
        boot.m1n1Package = m1n1Aurora;

        # The driver has a DT alias: keep udev from loading it before /var/lib and the iBootSystemContainer partition
        # are there (it attaches to the enclave once per boot). apple-sep.service loads it by name, which a blacklist
        # does not block.
        boot.blacklistedKernelModules = ["apple_sep"];
        boot.extraModprobeConfig = ''
            options apple_sep ${cfg.driverParams}
        '';
        # Per-device calibration (private, never in the store). The driver loads apple/mesacal-j313.bin at boot and again
        # whenever it re-registers the sensor (each verify). A firmware_class.path= kernel parameter does not work:
        # NixOS's udev activation overwrites /sys/module/firmware_class/parameters/path with the store firmware dir.
        # /lib/firmware is always searched, so link the seeded file there; the kernel reads firmware with its own
        # credentials, so the target stays root-only.
        systemd.tmpfiles.rules = [
            "d /lib/firmware/apple 0755 root root -"
            "L+ /lib/firmware/apple/mesacal-j313.bin - - - - ${calibration}"
        ];

        systemd.services.apple-sep = {
            description = "Apple SEP driver (Touch ID)";
            wantedBy = ["multi-user.target"];
            before = ["fprintd.service"];
            requires = [ibootUnit];
            after = [ibootUnit "local-fs.target" "systemd-tmpfiles-setup.service"];
            unitConfig = {
                RequiresMountsFor = "/var/lib";
                # Seeded state only: without the keybag the driver would come up with no identity (or, with other
                # parameters, make one). Restore it from /var/lib/touchid-backup, then start this unit.
                ConditionPathExists = [keybag calibration iboot];
            };
            # aurora-sep-ready opens /dev/sep-bio through `sh -c` (a NixOS unit's PATH has no sh by default)
            path = [pkgs.kmod pkgs.coreutils pkgs.bash];
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStartPre = "${touchid-backup}/bin/touchid-backup";
                # The driver attaches to the enclave once per boot: never reload the module.
                ExecStart = pkgs.writeShellScript "apple-sep-load" ''
                    set -eu
                    grep -q '^apple_sep ' /proc/modules || modprobe apple_sep
                    i=0
                    while [ ! -c /dev/sep-bio ] && [ $i -lt 600 ]; do sleep 0.1; i=$((i + 1)); done
                    [ -c /dev/sep-bio ] || { echo "apple-sep: /dev/sep-bio did not appear in 60 s" >&2; exit 1; }
                    echo "apple-sep: /dev/sep-bio after $((i / 10)) s"
                '';
                # Activate Touch ID and restore its fingerprints before fprintd starts.
                ExecStartPost = "${auroraSepReady}/bin/aurora-sep-ready";
                TimeoutStartSec = 150;
            };
        };

        services.fprintd = {
            enable = true;
            package = fprintdAurora;
            # nixpkgs would otherwise add pam_fprintd to every PAM service (greetd, login, sshd, su, passwd, ...).
            enablePam = false;
        };
        systemd.services.fprintd = {
            wants = ["apple-sep.service"];
            after = ["apple-sep.service"];
            serviceConfig = {
                # /dev/sep-bio for the reader (the misc class, since a path rule resolves before the node exists);
                # input devices read-only for the lid switch (the reader is hidden while the lid is closed).
                DeviceAllow = ["char-misc rw" "char-input r"];
                # Stay resident: each new start re-probes the reader and the lock screen asks right away.
                ExecStart = ["" "${fprintdAurora}/libexec/fprintd --no-timeout"];
            };
        };

        # A lock screen waiting for a finger when the lid closes keeps fprintd's claim across suspend, and every
        # later session fails until fprintd restarts. Stop it before sleep; D-Bus activation brings it back.
        # (Aurora's aurora-touchid.sleep, omacom/linux#7.)
        systemd.services.fprintd-sleep = {
            description = "Stop fprintd before sleep";
            wantedBy = ["sleep.target"];
            before = ["sleep.target"];
            serviceConfig = {
                Type = "oneshot";
                ExecStart = "-${pkgs.coreutils}/bin/timeout 5 ${pkgs.systemd}/bin/systemctl stop fprintd.service";
            };
        };

        services.logind.settings.Login = lib.mkIf cfg.powerKeySuspend {
            HandlePowerKey = "suspend";
            HandlePowerKeyLongPress = "poweroff";
        };

        security.pam.services = lib.genAttrs cfg.pamServices (_: {
            fprintAuth = true;
            rules.auth.fprintd.args = ["max-tries=3" "timeout=${toString cfg.pamTimeout}"];
        });

        environment.systemPackages = [touchid-status touchid-backup];
    };
}
