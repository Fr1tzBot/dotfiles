# modules/mesa: Touch ID on botzRus2

Native Touch ID for the M1 MacBook Air (J313) with Aurora's `apple_sep` driver, built from what the mesa-vault
HV runs established (linux16–linux19). Imported from `flake.nix` for botzRus2, enabled in `hosts/botzRus2/default.nix`
with `mesa.auroraTouchId.enable`.

**Status (2026-11-22):** works. The linux19 enrolment restores at boot, and `fprintd-verify` matches natively.
Not yet tried: fingerprint at `doas`/polkit, the lock screen, suspend/resume, a Touch ID lockout.

## What it changes
- **Kernel:** aurora-silicon/linux 6a08a08 (7.2.11) instead of linux-asahi, plus m1harness's test patch (it
  carries `key_store_v5`). Config `aurora-kernel-native.config`: Aurora's full config (`aurora-kernel.config`, booted
  in the HV) with debug info off. `aurora-kernel-fast.config` is the trimmed one that booted on 2026-11-22 without Wi-Fi
  (no `CRYPTO_CMAC`) or Bluetooth RFCOMM/HIDP; kept for reference only.
- **m1n1:** `patches/0001` forwards `/chosen/apfs-preboot-uuid` (the SEP's OS identity) to Linux. The new `boot.bin` also
  carries Aurora's DTBs, **for every generation in the boot menu**, older ones included.
- **apple_sep:** `xart_writes=1 provision_keybag=0 xart_guard=0 key_store_v5=1`. Loaded once per boot by
  `apple-sep.service`, only if `/var/lib/aurora-sep-keybag.bin` and the calibration exist. It never creates a keybag.
  The host state is copied to `/var/lib/touchid-backup/` before each load (10 kept).
- **Calibration:** the driver reloads `apple/mesacal-j313.bin` at every verify. tmpfiles links
  `/lib/firmware/apple/mesacal-j313.bin` to the private copy in `/var/lib/apple-sep-firmware`. A `firmware_class.path=`
  kernel parameter doesn't work on NixOS: udev activation overwrites that path with the store's firmware directory.
- **fprintd** with Aurora's libfprint/fprintd patches: resident, started after Touch ID is warmed up
  (`apple-sep-ready.service`), stopped before sleep, reader hidden while the lid is closed.
- **PAM:** Touch ID for `doas` and `polkit-1` only (`mesa.auroraTouchId.pamServices`). greetd/login stay password-only,
  because a fingerprint can't unlock gnome-keyring. Add the lock screen's PAM service to `pamServices` once known.
- **logind:** a short power-button press suspends instead of powering off (the sensor is the button); hold 5 s to power off.
- Tools: `touchid-status`, `touchid-seed`, `touchid-adopt`, `touchid-backup`.

## First boot (one time)
1. Build: `nix build .#nixosConfigurations.botzRus2.config.system.build.toplevel` (from `nixos/`).
2. Seed the private state (never in git or the Nix store). From the handoff `private/` directory:
   `doas sh modules/mesa/touchid-seed.sh linux19a-postmatch-varlib.tar.gz mesacal-j313.bin`
   It installs the keybag, catacombs and host state file by file (mode 600) and the calibration under
   `/var/lib/apple-sep-firmware/apple/`. It refuses to replace an existing keybag.
3. `doas nixos-rebuild boot --flake .#botzRus2`, then reboot.
4. Check: `uname -r` = 7.2.11, then `doas touchid-status`. Expect `apple-sep`/`apple-sep-ready` active,
   "enrolment survived reboot" / "Touch ID: restored 1" in the kernel log, and no xART write at boot.
5. Give fprintd the finger linux19 enrolled (no SEP write): `doas touchid-adopt --list`, then
   `doas touchid-adopt 0 fritz <finger>` (e.g. `right-index-finger`). Don't enrol the same finger again with
   `fprintd-enroll`: two templates for one finger make matches report the other identity.
6. First native match: `doas true` and touch the sensor. Every match writes xART (2 records in linux19), so do the
   macOS checks afterwards (mesa-vault "Containment policy").

## Rollback
Pick an older generation in systemd-boot. It still boots through the new `boot.bin` (Aurora DTBs). For a full
rollback, copy `boot.bin.nixos` over `boot.bin` on the NixOS ESP from macOS, then boot the previous generation.

## Not on this kernel
sep-bio interface v4: no password re-arm after a Touch ID lockout (Aurora's `touchid-rearm` needs v5), so a lockout lasts
until reboot. There's also no orphan delete.
