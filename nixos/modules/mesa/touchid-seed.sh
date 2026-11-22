#!/bin/sh
# touchid-seed: put saved apple_sep host state and the Mesa calibration into /var/lib, once.
#
#   doas touchid-seed <varlib.tar.gz> <mesacal-j313.bin>
#   (before the module is active: doas sh nixos/modules/mesa/touchid-seed.sh <archive> <calibration>)
#
# The archive is a dumpstate of /var/lib from an HV run under this same boot entry (mesa-vault linux19:
# linux19a-postmatch-varlib.tar.gz). It holds the Linux identity keybag, which must never be created a second time,
# so this refuses to overwrite one. Files are installed one by one: untarring the archive's "./" entry straight
# into /var/lib would reset /var/lib's own mode.
set -eu

die() {
    echo "touchid-seed: $*" >&2
    exit 1
}

[ "$#" -eq 2 ] || die "usage: touchid-seed <varlib.tar.gz> <mesacal-j313.bin>"
archive=$1
cal=$2
varlib=/var/lib
caldir=$varlib/apple-sep-firmware/apple
calname=mesacal-j313.bin

[ "$(id -u)" = 0 ] || die "run as root (doas)"
[ -r "$archive" ] || die "cannot read $archive"
[ -r "$cal" ] || die "cannot read $cal"
[ -s "$cal" ] || die "$cal is empty"
if grep -q '^apple_sep ' /proc/modules 2>/dev/null; then
    die "apple_sep is already loaded; seed before it loads (reboot with the keybag absent, then seed)"
fi
if [ -e "$varlib/aurora-sep-keybag.bin" ]; then
    die "$varlib/aurora-sep-keybag.bin already exists; refusing to replace a keybag"
fi

umask 077
tmp=$(mktemp -d /tmp/touchid-seed.XXXXXX)
trap 'rm -rf -- "$tmp"' EXIT HUP INT TERM

tar -xzf "$archive" -C "$tmp" --no-same-owner --no-same-permissions
[ -s "$tmp/aurora-sep-keybag.bin" ] || die "$archive has no aurora-sep-keybag.bin"

n=0
for f in "$tmp"/*; do
    name=${f##*/}
    case "$name" in
    aurora-sep-*.bin | apple-sep-*.bin) ;;
    *) die "unexpected file in archive: $name" ;;
    esac
    if [ ! -f "$f" ] || [ -L "$f" ]; then die "$name is not a regular file"; fi
    [ ! -e "$varlib/$name" ] || die "$varlib/$name already exists; refusing to mix host states"
done
for f in "$tmp"/*.bin; do
    install -m 600 -o root -g root "$f" "$varlib/${f##*/}"
    n=$((n + 1))
done
echo "touchid-seed: installed $n host-state files into $varlib"

install -d -m 700 -o root -g root "$varlib/apple-sep-firmware" "$caldir"
if [ -e "$caldir/$calname" ]; then
    cmp -s "$cal" "$caldir/$calname" || die "$caldir/$calname exists and differs; not replacing it"
    echo "touchid-seed: calibration already in place"
else
    install -m 600 -o root -g root "$cal" "$caldir/$calname"
    echo "touchid-seed: installed the calibration"
fi

cat <<'EOF'
touchid-seed: done. Next:
  - if the Touch ID module is active: doas systemctl start apple-sep-ready.service  (or reboot)
  - check with: doas touchid-status
EOF
