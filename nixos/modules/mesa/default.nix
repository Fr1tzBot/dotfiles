# Native Touch ID for botzRus2, the J313 (M1 MacBook Air), with Aurora's apple_sep driver. Imported from
# flake.nix for botzRus2 only (enabled in hosts/botzRus2): the kernel, m1n1 and calibration path are specific to this machine.
# First boot: modules/mesa/README.md.
# Knowledge base: mesa-vault, "Native NixOS Touch ID" and "Linux Touch ID recipe"; parameters from linux19.
#
# Pieces:
#  1. Kernel: aurora-silicon/linux 6a08a08 (7.2.11) + m1harness's cumulative aurora-test patch (it carries the
#     key_store_v5 switch this Mac's variant-5 keybag needs). Its DTBs (SEP and Mesa nodes) go into boot.bin.
#  2. m1n1 with m1harness 0001: forwards /chosen/apfs-preboot-uuid, the SEP's OS identity. Without it the master
#     catacomb save/load fails 0x6 (mesa-vault "Why does the master SAVE_CATACOMB fail in Linux").
#  3. apple_sep is loaded by a service, once: after the iBootSystemContainer partition exists and only when the
#     seeded keybag and calibration are in /var/lib. provision_keybag=0 always: a second keybag is never created.
#  4. Aurora's userspace (aurora-sep-userspace c889b44): libfprint 1.94.100 + aurora driver, fprintd 1.94.5, with
#     its desktop integration ported from tools/aurora-sep/: Touch ID warmed up at boot before fprintd starts,
#     fprintd resident, fprintd stopped before sleep, short power-button press suspends (the sensor IS the button).
#  5. PAM: fingerprint only where it is asked for (cfg.pamServices); never at greetd/login (the fingerprint can't
#     unlock gnome-keyring) or sshd.
#
# Not available on this kernel (sep-bio interface v4): Aurora's touchid-rearm (lockout re-arm by password, needs v5
# SEP_BIO_REARM) and orphan deletion. A lockout ends with the next boot.
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

    # aurora-silicon/linux 6a08a08, the tree the HV runs used (hash checked against that git archive, 2026-11-21)
    auroraSrc = pkgs.fetchFromGitHub {
        owner = "aurora-silicon";
        repo = "linux";
        rev = "6a08a08e57558083f552733a5276d71b1a4d8ff6";
        hash = "sha256-iQVnb5+iFWaRdEc7pLtg5pl8zKWX/50wy71+TMZQNjc=";
    };
    # m1harness: hv-tools/aurora-test/linux15-skip-user-nocatacomb.patch (kernel), m1n1-patches/0001 (m1n1)
    mesaPatches = ./patches;
    # aurora-silicon/aurora-sep-userspace c889b44: only libfprint/ and fprintd/ patches + LICENSES
    userspace = ./userspace;

    libfprintAurora = pkgs.libfprint.overrideAttrs (old: {
        patches =
            (old.patches or [])
            ++ [(userspace + "/libfprint/libfprint-1.94.100-apple-sep.patch")]
            ++ map (n: userspace + "/libfprint/${n}") [
                "0002-aurora-report-unusable-captures-as-retries.patch"
                "0003-hide-lid-covered-readers-while-the-lid-is-closed.patch"
                "0004-aurora-refuse-unbound-enrollment.patch"
                "0005-aurora-support-v4-and-v5.patch"
                "0006-aurora-report-finger-lift-and-lockout.patch"
                "0007-aurora-name-retry-causes-and-keep-waiting.patch"
                "0008-aurora-report-the-touch-id-lockout-as-locked-out.patch"
                "0009-aurora-say-why-touch-id-needs-the-password.patch"
                "0010-let-a-front-end-ask-whether-the-reader-needs-the-password.patch"
                "0011-aurora-name-a-touch-of-another-enrolled-finger.patch"
            ];
        # the kernel UAPI header isn't in distribution headers; same as their Fedora spec
        postPatch =
            (old.postPatch or "")
            + ''
                install -Dm0644 ${userspace + "/libfprint/apple-sep.h"} aurora-uapi/linux/apple-sep.h
            '';
        preConfigure =
            (old.preConfigure or "")
            + ''
                export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$PWD/aurora-uapi"
            '';
        doCheck = false;
    });
    fprintdAurora = (pkgs.fprintd.override {libfprint = libfprintAurora;}).overrideAttrs (old: {
        patches =
            (old.patches or [])
            ++ map (n: userspace + "/fprintd/${n}") [
                "0001-preserve-print-on-device-delete-failure.patch"
                "0002-report-lockout-and-fall-back-to-the-password.patch"
                "0003-say-why-the-reader-needs-the-password.patch"
                "0004-dont-ask-for-a-finger-the-reader-will-not-take.patch"
            ];
        doCheck = false;
    });

    auroraKernel = pkgs.linuxManualConfig {
        version = "7.2.11-aurora";
        modDirVersion = "7.2.11"; # LOCALVERSION cleared in the config; check vermagic after the first build
        src = auroraSrc;
        # aurora-kernel-native.config = ./aurora-kernel.config (Aurora's release19 config through olddefconfig on
        # 6a08a08, 1734 modules, booted in the HV) with only debug info/BTF turned off; every driver option identical.
        # The trimmed ./aurora-kernel-fast.config (localmodconfig, 389 modules) booted natively on 2026-11-22 but
        # lacked CRYPTO_CMAC (iwd: no Wi-Fi), BT_RFCOMM/BT_HIDP (Bluetooth audio profiles, BT keyboards) and ALSA
        # sequencer modules; kept only for reference.
        configfile = ./aurora-kernel-native.config;
        kernelPatches = [
            {
                name = "m1harness aurora-test (linux10..linux15 test parameters, incl. key_store_v5)";
                patch = mesaPatches + "/linux15-skip-user-nocatacomb.patch";
            }
        ];
        allowImportFromDerivation = true;
        # systemd-boot asserts on this flag, not on the config (CONFIG_EFI_STUB=y is set)
        features.efiBootStub = true;
    };

    m1n1UuidFwd = config.hardware.asahi.pkgs.m1n1.overrideAttrs (old: {
        patches = (old.patches or []) ++ [(mesaPatches + "/0001-kboot-forward-apfs-preboot-uuid.patch")];
    });

    # Aurora's readiness check (tools/aurora-sep/aurora-sep-ready, GPL-2.0-only), unchanged: the first open of
    # /dev/sep-bio restores the enrolled fingerprints; it then waits for the driver's diag attributes to say the
    # sensor attached and the restore ran, and fails the unit with the reason otherwise.
    auroraSepReady = pkgs.runCommand "aurora-sep-ready" {} ''
        install -Dm755 ${auroraSrc}/tools/aurora-sep/aurora-sep-ready $out/bin/aurora-sep-ready
        substituteInPlace $out/bin/aurora-sep-ready --replace-fail '#!/bin/sh' '#!${pkgs.runtimeShell}'
    '';

    # Private state the driver keeps in /var/lib (names from mesa-vault linux19 and Aurora's HOST-STATE.md).
    keybag = "/var/lib/aurora-sep-keybag.bin";
    calibration = "/var/lib/apple-sep-firmware/apple/mesacal-j313.bin"; # DT firmware-name apple/mesacal-j313.bin
    iboot = "/dev/disk/by-partlabel/iBootSystemContainer";
    ibootUnit = "dev-disk-by\\x2dpartlabel-iBootSystemContainer.device";

    touchid-seed = pkgs.writeShellApplication {
        name = "touchid-seed";
        runtimeInputs = with pkgs; [coreutils gnutar gzip gnugrep diffutils];
        text = builtins.readFile ./touchid-seed.sh;
    };

    # fprintd record for an identity the SEP already holds (the linux19 HV enrolment); see the script's docstring.
    touchid-adopt = let
        py = pkgs.python3.withPackages (ps: [ps.pygobject3]);
        typelibs = lib.makeSearchPath "lib/girepository-1.0" (map (p: p.out) [libfprintAurora pkgs.gusb pkgs.json-glib pkgs.libgudev pkgs.glib pkgs.gobject-introspection]);
    in
        pkgs.runCommand "touchid-adopt" {nativeBuildInputs = [pkgs.makeWrapper];} ''
            install -Dm644 ${./touchid-adopt.py} $out/share/touchid-adopt.py
            makeWrapper ${py}/bin/python3 $out/bin/touchid-adopt \
                --add-flags "-I $out/share/touchid-adopt.py" \
                --prefix GI_TYPELIB_PATH : ${typelibs} \
                --prefix PATH : ${lib.makeBinPath [pkgs.systemd]}
        '';

    # Copy the host state aside before each load: every match re-saves the catacombs, and a lost keybag cannot be
    # recreated without risk. Keeps the newest cfg.backups copies, root-only.
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
            for u in apple-sep apple-sep-ready fprintd; do
                printf '  %-16s %s\n' "$u" "$(systemctl is-active "$u.service" || true)"
            done
            echo "== module"
            if grep -q '^apple_sep ' /proc/modules; then echo "  apple_sep loaded"; else echo "  apple_sep NOT loaded"; fi
            if [ -c /dev/sep-bio ]; then echo "  /dev/sep-bio present"; else echo "  /dev/sep-bio absent"; fi
            if [ -s ${keybag} ]; then echo "  keybag seeded"; else echo "  keybag MISSING (run touchid-seed)"; fi
            if [ -s ${calibration} ]; then echo "  calibration present"; else echo "  calibration MISSING (run touchid-seed)"; fi
            for d in /sys/bus/platform/devices/*.sep/diag; do
                [ -d "$d" ] || continue
                echo "== diag"
                for a in "$d"/*; do
                    [ -f "$a" ] && [ -r "$a" ] && printf '  %-22s %s\n' "''${a##*/}" "$(head -c 200 "$a" | tr '\n' ' ')"
                done
            done
            echo "== kernel log (this boot)"
            journalctl -k -b --no-pager -o cat 2>/dev/null | grep -E 'apple_sep|apple-sep|Touch ID|xART' | tail -n 25 || true
            echo "== aurora-sep-ready"
            journalctl -b -u apple-sep-ready.service --no-pager -o cat 2>/dev/null | tail -n 5 || true
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
            # linux19: stock user 1000, OS UUID from the patched m1n1, variant-5 keybag. Never provision_keybag=1.
            default = "xart_writes=1 provision_keybag=0 xart_guard=0 key_store_v5=1";
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
        boot.m1n1Package = m1n1UuidFwd;
        # The fast config has everything nixos-apple-silicon's initrd wants for the J313 (nvme_apple, ext4, vfat
        # built in; dwc3/xhci/atcphy/tps6598x/usb-storage/usbhid as modules; checked 2026-11-21). What it lacks is
        # PC-only (ahci, sata_*, [eou]hci, vendor HID drivers, xhci_pci_prom21), absent on this Mac (tpm-tis/crb,
        # mmc_block, hid-sensor-hub, dockchannel-hid = M2 keyboards) or covered otherwise (ext2 by ext4, autofs
        # built in as autofs4). Let the initrd skip those instead of failing.
        boot.initrd.allowMissingModules = true;

        # apple_sep has no module alias, so nothing autoloads it; apple-sep.service below loads it exactly once.
        boot.extraModprobeConfig = ''
            options apple_sep ${cfg.driverParams}
        '';
        # Per-device calibration (private, never in the store). The driver loads apple/mesacal-j313.bin at boot and again
        # whenever it re-registers the sensor (each verify). A firmware_class.path= kernel parameter does not work:
        # NixOS's udev activation overwrites /sys/module/firmware_class/parameters/path with the store firmware dir
        # (first native match failed ENOENT, 2026-11-22). /lib/firmware is always searched, so link the seeded file
        # there; the kernel reads firmware with its own credentials, so the target stays root-only.
        systemd.tmpfiles.rules = [
            "d /lib/firmware/apple 0755 root root -"
            "L+ /lib/firmware/apple/mesacal-j313.bin - - - - ${calibration}"
        ];

        systemd.services.apple-sep = {
            description = "Apple SEP driver (Touch ID)";
            wantedBy = ["multi-user.target"];
            wants = ["apple-sep-ready.service"];
            requires = [ibootUnit];
            after = [ibootUnit "local-fs.target" "systemd-tmpfiles-setup.service"];
            unitConfig = {
                RequiresMountsFor = "/var/lib";
                # Seeded state only: without the keybag the driver would come up with no identity (or, with other
                # parameters, make one). touchid-seed installs both, then `systemctl start apple-sep-ready`.
                ConditionPathExists = [keybag calibration iboot];
            };
            path = [pkgs.kmod pkgs.coreutils];
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStartPre = "${touchid-backup}/bin/touchid-backup";
                # The driver attaches to the enclave once per boot: never restart this or reload the module.
                ExecStart = pkgs.writeShellScript "apple-sep-load" ''
                    set -eu
                    grep -q '^apple_sep ' /proc/modules || modprobe apple_sep
                    i=0
                    while [ ! -c /dev/sep-bio ] && [ $i -lt 600 ]; do sleep 0.1; i=$((i + 1)); done
                    [ -c /dev/sep-bio ] || { echo "apple-sep: /dev/sep-bio did not appear in 60 s" >&2; exit 1; }
                    echo "apple-sep: /dev/sep-bio after $((i / 10)) s"
                '';
                TimeoutStartSec = 150;
            };
        };

        systemd.services.apple-sep-ready = {
            description = "Activate Touch ID and restore its fingerprints";
            requires = ["apple-sep.service"];
            after = ["apple-sep.service"];
            before = ["fprintd.service"];
            unitConfig = {
                ConditionPathExists = "/dev/sep-bio";
                # Stop holding fprintd back if the enclave is broken.
                JobTimeoutSec = 90;
            };
            # the script opens /dev/sep-bio through `sh -c` (a NixOS unit's PATH has no sh by default)
            path = [pkgs.coreutils pkgs.bash];
            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = "${auroraSepReady}/bin/aurora-sep-ready";
                TimeoutStartSec = 60;
            };
        };

        services.fprintd = {
            enable = true;
            package = fprintdAurora;
            # nixpkgs would otherwise add pam_fprintd to every PAM service (greetd, login, sshd, su, passwd, ...).
            enablePam = false;
        };
        systemd.services.fprintd = {
            wants = ["apple-sep-ready.service"];
            after = ["apple-sep-ready.service"];
            serviceConfig = {
                # /dev/sep-bio for the reader (the misc class, since a path rule resolves before the node exists);
                # input devices read-only for the lid switch (libfprint patch 0003 hides the reader when it's closed).
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

        environment.systemPackages = [touchid-seed touchid-status touchid-backup touchid-adopt];
    };
}
