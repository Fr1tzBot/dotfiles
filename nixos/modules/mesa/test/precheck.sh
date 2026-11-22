#!/usr/bin/env bash
# Pre-switch checks for the Touch ID module: static checks of the built system, then a KVM boot of it.
# Read-only for the host: builds into the Nix store, writes only to $WORK. Never touches /boot, /var/lib or modules.
#
#   test/precheck.sh [flake-dir] [host]        default: ~/Documents/dotfiles/nixos botzRus2
#   NO_VM=1 test/precheck.sh ...               static checks only
#
# Exit status: 0 = every check passed, 1 = a check failed, 2 = a build failed.
set -uo pipefail

here=$(cd "$(dirname "$0")" && pwd)
flake_dir=$(cd "${1:-$HOME/Documents/dotfiles/nixos}" && pwd)
host=${2:-botzRus2}
flake="path:$flake_dir" # path: so files git doesn't track yet are included
WORK=${WORK:-$(mktemp -d "${TMPDIR:-/tmp}/precheck.XXXXXX")}
mkdir -p "$WORK"

fails=0
pass() { printf '  ok    %s\n' "$*"; }
fail() { printf '  FAIL  %s\n' "$*"; fails=$((fails + 1)); }
info() { printf '  info  %s\n' "$*"; }
check() { # check <description> <command...>
    local d=$1
    shift
    if "$@" >/dev/null 2>&1; then pass "$d"; else fail "$d"; fi
}

get() { # get <attr>: build/evaluate one attribute of precheck.nix
    nix build --impure --no-link --print-out-paths -f "$here/precheck.nix" --argstr flake "$flake" --argstr host "$host" "$1"
}

echo "== build ($flake#$host; log in $WORK/build.log)"
for a in toplevel kernel bootBin configfile tools; do
    p=$(get "$a" 2>>"$WORK/build.log" | tail -n1) || {
        echo "  FAIL  building $a, see $WORK/build.log"
        tail -n 30 "$WORK/build.log"
        exit 2
    }
    printf -v "$a" '%s' "$p"
    info "$a $p"
done
kv=$(nix eval --impure --raw -f "$here/precheck.nix" --argstr flake "$flake" --argstr host "$host" kernelVersion)
PATH="$tools/bin:$PATH"
mods=$toplevel/kernel-modules/lib/modules/$kv
cfg=$configfile

echo "== kernel"
check "modules for $kv" test -d "$mods"
ko=$(find -L "$mods" -name 'apple-sep.ko*' | head -n1)
if [ -n "$ko" ]; then
    pass "apple-sep module: ${ko#"$mods"/}"
    vm=$(modinfo -F vermagic "$ko")
    case "$vm" in "$kv "*) pass "vermagic $vm" ;; *) fail "vermagic '$vm' does not start with $kv" ;; esac
    parms=$(modinfo -F parm "$ko" | cut -d: -f1)
    for p in xart_writes provision_keybag xart_guard key_store_v5 trusted_keys filevault_api os_uuid_hi os_uuid_lo; do
        grep -qx "$p" <<<"$parms" && pass "parameter $p" || fail "parameter $p missing"
    done
    info "module aliases: $(modinfo -F alias "$ko" | tr '\n' ' ')(none = no autoload; the blacklist is a guard)"
    check "dependencies resolve (modprobe --show-depends)" modprobe -d "$toplevel/kernel-modules" -S "$kv" --show-depends apple_sep
else
    fail "apple-sep.ko not found"
fi
for o in RUST=y APPLE_SEP=m ARM64_16K_PAGES=y EFI_STUB=y DRM_ASAHI=m NVME_APPLE=m SPI_APPLE=m CRYPTO_CMAC=y \
    BT_RFCOMM=m BT_HIDP=m SND_SEQUENCER=m DEBUG_INFO_NONE=y; do
    check "config $o" grep -qx "CONFIG_$o" "$cfg"
done
check 'config BINDGEN_VERSION_TEXT is the patched 0.73.2' grep -qx 'CONFIG_BINDGEN_VERSION_TEXT="bindgen 0.73.2"' "$cfg"
info "$(grep -E '^CONFIG_(APPLE_AURORA_BOOT_SECURITY_LOCKDOWN|SECURITY_LOCKDOWN_LSM|MODULE_SIG_FORCE)=' "$cfg" | tr '\n' ' ')"

echo "== device tree (t8103-j313)"
dtb=$(find -L "$kernel/dtbs" -name t8103-j313.dtb 2>/dev/null | head -n1)
if [ -n "$dtb" ]; then
    dts=$WORK/j313.dts
    dtc -q -I dtb -O dts -o "$dts" "$dtb" 2>/dev/null
    check "compatible apple,j313" grep -q 'compatible = "apple,j313"' "$dts"
    check 'mesa firmware-name "apple/mesacal-j313.bin"' grep -q 'firmware-name = "apple/mesacal-j313.bin"' "$dts"
    check 'a node with compatible "apple,sep"' grep -q '"apple,sep"' "$dts"
    check "boot.bin is assembled from this kernel's dtbs" grep -qF "$kernel/dtbs" <(nix derivation show "$bootBin" 2>/dev/null)
else
    fail "t8103-j313.dtb not in $kernel/dtbs"
fi

echo "== m1n1 / boot.bin"
check "boot.bin forwards apfs-preboot-uuid (Aurora m1n1)" grep -qa 'FDT: apfs-preboot-uuid' "$bootBin"
info "boot.bin built from: $(nix derivation show "$bootBin" 2>/dev/null | grep -oE '/nix/store/[a-z0-9]{32}-(m1n1|linux|uboot)[^/ "\\]*' | sort -u | xargs -r -n1 basename | tr '\n' ' ')"
check "boot.bin is in the system's closure (systemd-boot installs it)" grep -qx "$bootBin" <(nix-store -qR "$toplevel")

echo "== system configuration"
mp=$(awk 1 "$toplevel"/etc/modprobe.d/*.conf 2>/dev/null) # awk 1: a file without a final newline must not glue lines
check "blacklist apple_sep" grep -qx 'blacklist apple_sep' <<<"$mp"
check "options apple_sep (incl. key_store_v5=1 provision_keybag=0)" \
    grep -qE '^options apple_sep .*provision_keybag=0.*key_store_v5=1' <<<"$mp"
for s in doas polkit-1; do check "pam $s uses pam_fprintd" grep -q pam_fprintd "$toplevel/etc/pam.d/$s"; done
for s in login greetd sshd su passwd; do
    [ -e "$toplevel/etc/pam.d/$s" ] || continue
    if grep -q pam_fprintd "$toplevel/etc/pam.d/$s"; then fail "pam $s must not use pam_fprintd"; else pass "pam $s password-only"; fi
done
unit=$toplevel/etc/systemd/system/apple-sep.service
check "apple-sep.service exists" test -f "$unit"
check "apple-sep.service runs aurora-sep-ready" grep -q 'ExecStartPost=.*aurora-sep-ready' "$unit"
check "apple-sep.service is gated on the keybag" grep -q 'ConditionPathExists=/var/lib/aurora-sep-keybag.bin' "$unit"
ready=$(grep -o '/nix/store/[^ ]*aurora-sep-ready' "$unit" | head -n1)
check "aurora-sep-ready has a store shebang" grep -q '^#!/nix/store/' "$ready"
check "fprintd ordered after apple-sep" grep -Rq "After=.*apple-sep.service" "$toplevel/etc/systemd/system/fprintd.service" "$toplevel/etc/systemd/system/fprintd.service.d"
check "calibration link in tmpfiles" grep -Rq 'mesacal-j313.bin' "$toplevel/etc/tmpfiles.d/"
fp=$(grep -o '/nix/store/[^ ]*/libexec/fprintd' "$toplevel/etc/systemd/system/fprintd.service" | head -n1)
lf=$(nix-store -qR "${fp%/libexec/fprintd}" | grep -m1 -- '-libfprint-1')
check "libfprint ($(basename "$lf")) has the apple-sep driver" grep -qa 'apple-sep' "$lf"/lib/libfprint-2.so.2
if [ -e /run/current-system/kernel-params ]; then
    if diff -q /run/current-system/kernel-params "$toplevel/kernel-params" >/dev/null; then
        pass "kernel command line unchanged"
    else
        info "kernel command line changes: $(diff /run/current-system/kernel-params "$toplevel/kernel-params" | grep '^[<>]' | tr '\n' ' ')"
    fi
fi

if [ "${NO_VM:-0}" != 1 ]; then
    echo "== KVM boot (log in $WORK/vm.log)"
    vmout=$(get vm 2>>"$WORK/build.log" | tail -n1) || {
        echo "  FAIL  building the VM, see $WORK/build.log"
        exit 2
    }
    run=$(find "$vmout/bin" -name 'run-*-vm' | head -n1)
    rm -f "$WORK/vm.qcow2"
    (cd "$WORK" && NIX_DISK_IMAGE="$WORK/vm.qcow2" timeout 900 "$run" </dev/null >"$WORK/vm.log" 2>&1)
    rc=$?
    # markers only; the serial console can prefix a line with terminal escapes
    log=$WORK/vm-markers.log
    grep -ao 'PRECHECK .*' "$WORK/vm.log" | tr -d '\r' >"$log"
    sed 's/^/  vm    /' "$log"
    [ "$rc" = 124 ] && fail "VM did not power off within 15 min"
    check "VM ran the precheck service to the end" grep -qa '^PRECHECK done' "$log"
    check "guest runs kernel $kv" grep -qa "^PRECHECK uname $kv" "$log"
    # smartd: a guest has no SMART-capable disk
    if grep -a '^PRECHECK failed_unit' "$log" | grep -qv 'smartd.service'; then
        fail "failed units in the guest (listed above)"
    else
        pass "no unexpected failed units"
    fi
    check "apple_sep loads (Rust module init, parameters)" grep -qa '^PRECHECK apple_sep loaded' "$log"
    check "key_store_v5=1 reached the module" grep -qa '^PRECHECK param key_store_v5=1' "$log"
    check "provision_keybag=0 reached the module" grep -qa '^PRECHECK param provision_keybag=0' "$log"
    if grep -qa '^PRECHECK param_rejected' "$log"; then fail "the kernel rejected a module parameter"; else pass "no parameter rejected"; fi
    check "fprintd starts" grep -qa '^PRECHECK fprintd started' "$log"
    if grep -qaE 'Kernel panic|Oops|BUG:|Call trace' "$WORK/vm.log" || grep -qa '^PRECHECK kernel_bad' "$log"; then
        fail "kernel errors in the guest (see $log)"
    else
        pass "no panic/oops/BUG/warning in the guest kernel log"
    fi
fi

echo "== $( [ $fails = 0 ] && echo "all checks passed" || echo "$fails check(s) FAILED" ) (work dir $WORK)"
[ $fails = 0 ]
