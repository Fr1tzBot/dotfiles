# Build products for test/precheck.sh. Not imported by the module.
#   nix build --impure -f test/precheck.nix --argstr flake path:/abs/dotfiles/nixos -A toplevel
{
    flake,
    host ? "botzRus2",
}: let
    sys = (builtins.getFlake flake).nixosConfigurations.${host};
    inherit (sys) pkgs config;
    lib = pkgs.lib;
    kernel = config.boot.kernelPackages.kernel;

    # The same system as a KVM guest. Only test plumbing is added; the kernel and every package stay identical.
    vmSys = sys.extendModules {
        modules = [
            {
                virtualisation.vmVariant = {
                    virtualisation = {
                        graphics = false;
                        memorySize = 3072;
                        cores = 4;
                        diskSize = 4096;
                        # this Mac's KVM has a 36-bit IPA: keep QEMU's devices below 64 GiB
                        qemu.options = ["-machine" "virt,highmem=off"];
                    };
                    # No SEP in a guest: the iBootSystemContainer device never appears. The unit file itself is
                    # checked statically; here it would only wait for the device timeout.
                    systemd.services.apple-sep.wantedBy = lib.mkForce [];
                    # a getty on the serial line would vhangup() it and SIGHUP the precheck script
                    systemd.services."serial-getty@ttyAMA0".enable = false;
                    systemd.services.precheck = {
                        description = "precheck: report guest state and power off";
                        wantedBy = ["multi-user.target"];
                        after = ["multi-user.target"];
                        path = with pkgs; [coreutils systemd kmod gnugrep gnused util-linux getconf];
                        environment = {
                            SYSTEMD_PAGER = "cat";
                            SYSTEMD_COLORS = "0";
                        };
                        # Power off however the script ends, including a hang (TimeoutStartSec counts as failure).
                        unitConfig = {
                            SuccessAction = "poweroff-force";
                            FailureAction = "poweroff-force";
                        };
                        serviceConfig = {
                            Type = "oneshot";
                            TimeoutStartSec = 420;
                            StandardOutput = "tty";
                            StandardError = "tty";
                            TTYPath = "/dev/ttyAMA0";
                        };
                        # This unit is part of the boot job, so `is-system-running --wait` would deadlock: wait for
                        # the job queue to drain to just this unit instead.
                        script = ''
                            say() { echo "PRECHECK $*"; }
                            say "uname $(uname -r)"
                            say "page_size $(getconf PAGESIZE)"
                            for _ in $(seq 60); do
                                [ "$(systemctl list-jobs --no-legend --plain | grep -cv 'precheck.service')" = 0 ] && break
                                sleep 2
                            done
                            say "system_state $(systemctl is-system-running 2>/dev/null || true)"
                            systemctl --failed --no-legend --plain --no-pager | sed 's/^/PRECHECK failed_unit /'
                            if timeout 60 modprobe apple_sep; then
                                say "apple_sep loaded"
                                # Rust module params have no sysfs files: show what modprobe passed, and whether the
                                # kernel rejected any of it.
                                modprobe --show-depends apple_sep | grep apple-sep | tr ' ' '\n' | grep '=' \
                                    | sed 's/^/PRECHECK param /' || true
                                dmesg | grep -i 'apple_sep.*unknown parameter' | sed 's/^/PRECHECK param_rejected /' || true
                            else
                                say "apple_sep MODPROBE_FAILED"
                            fi
                            # ignore-requirements: its Wants=apple-sep would wait for the iBoot device a guest lacks
                            if timeout 90 systemctl start --job-mode=ignore-requirements fprintd.service; then say "fprintd started"; else say "fprintd START_FAILED"; fi
                            dmesg --level=emerg,alert,crit,err,warn | grep -E 'BUG|Oops|panic|WARNING|Call trace' \
                                | sed 's/^/PRECHECK kernel_bad /' || true
                            journalctl -b -k --no-pager -o cat | grep -iE 'apple_sep|apple-sep' | sed 's/^/PRECHECK sep_log /' || true
                            say "done"
                        '';
                    };
                };
            }
        ];
    };
in {
    toplevel = config.system.build.toplevel;
    inherit kernel;
    kernelVersion = kernel.modDirVersion;
    configfile = kernel.configfile;
    bootBin = config.boot.loader.systemd-boot.extraFiles."m1n1/boot.bin";
    vm = vmSys.config.system.build.vm;
    tools = pkgs.symlinkJoin {
        name = "precheck-tools";
        paths = with pkgs; [dtc kmod binutils gnugrep coreutils findutils diffutils];
    };
}
