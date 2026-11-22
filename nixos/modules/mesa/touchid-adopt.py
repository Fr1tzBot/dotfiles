"""touchid-adopt: give fprintd a record for a fingerprint the SEP already holds.

The HV runs (mesa-vault linux19) enrolled a finger with the driver's own test tool, so the SEP and the kernel's
identity index know it but fprintd has no file for it. Enrolling the same finger again through fprintd would leave
two templates for one finger, and a match could then report the other one's UUID ("another enrolled finger").
This writes the fprintd record for the existing identity instead. It only lists identities on the SEP: no enrolment,
no match, no xART write.

  doas touchid-adopt --list
  doas touchid-adopt <index> <user> <finger>      finger as fprintd names it, e.g. right-index-finger
"""

import argparse
import os
import pwd
import subprocess
import sys

import gi

gi.require_version("FPrint", "2.0")
from gi.repository import FPrint  # noqa: E402

STORE = "/var/lib/fprint"
# libfprint driver id of Aurora's driver (FP_COMPONENT in drivers/aurora/aurora.c); "aurora" is only its source dir
DRIVER_IDS = ("apple-sep", "aurora")
# fprintd's names, in FpFinger order (1..10)
FINGERS = [
    "left-thumb", "left-index-finger", "left-middle-finger", "left-ring-finger", "left-little-finger",
    "right-thumb", "right-index-finger", "right-middle-finger", "right-ring-finger", "right-little-finger",
]


def die(msg):
    print(f"touchid-adopt: {msg}", file=sys.stderr)
    sys.exit(1)


def open_reader():
    ctx = FPrint.Context()
    ctx.enumerate()
    found = ctx.get_devices()
    devs = [d for d in found if d.get_driver() in DRIVER_IDS]
    if not devs:
        seen = ", ".join(f"{d.get_driver()} ({d.get_name()})" for d in found) or "none"
        die(f"no Apple SEP reader among libfprint's devices: {seen} "
            "(is apple-sep-ready.service active and the lid open?)")
    dev = devs[0]
    dev.open_sync(None)
    return dev


def known_records(dev):
    """Existing fprintd files for this reader: {path: (user, finger)}."""
    out = {}
    if not os.path.isdir(STORE):
        return out
    for user in os.listdir(STORE):
        d = os.path.join(STORE, user, dev.get_driver(), dev.get_device_id())
        if os.path.isdir(d):
            for f in os.listdir(d):
                out[os.path.join(d, f)] = (user, f)
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--list", action="store_true", help="list the identities the driver knows")
    ap.add_argument("index", nargs="?", type=int)
    ap.add_argument("user", nargs="?")
    ap.add_argument("finger", nargs="?", choices=FINGERS)
    a = ap.parse_args()

    if os.geteuid() != 0:
        die("run as root (doas)")
    if not a.list and (a.index is None or a.user is None or a.finger is None):
        ap.error("give --list, or <index> <user> <finger>")
    if a.user is not None:
        try:
            pwd.getpwnam(a.user)
        except KeyError:
            die(f"no such user: {a.user}")

    # fprintd holds the reader while it runs; D-Bus activation starts it again on the next request.
    subprocess.run(["systemctl", "stop", "fprintd.service"], check=False)

    dev = open_reader()
    try:
        prints = dev.list_prints_sync(None)
        if a.list:
            records = known_records(dev)
            print(f"reader: {dev.get_name()} (device id {dev.get_device_id()})")
            print(f"{len(prints)} identit{'y' if len(prints) == 1 else 'ies'} in the kernel index:")
            for i, p in enumerate(prints):
                print(f"  [{i}] label {p.get_description() or '(none)'!r}")
            print(f"{len(records)} fprintd record(s) for this reader:")
            for path, (user, f) in sorted(records.items()):
                print(f"  {user}: finger {f} ({path})")
            return

        if not 0 <= a.index < len(prints):
            die(f"index {a.index} out of range (0..{len(prints) - 1}); see --list")
        p = prints[a.index]
        finger = FINGERS.index(a.finger) + 1
        path = os.path.join(STORE, a.user, dev.get_driver(), dev.get_device_id(), f"{finger:x}")
        if os.path.exists(path):
            die(f"{path} exists: {a.user} already has {a.finger}; fprintd-delete it first")

        p.set_username(a.user)
        p.set_finger(FPrint.Finger(finger))
        data = p.serialize()
        if isinstance(data, tuple):  # (ok, data) on some PyGObject versions
            data = data[-1]
        data = bytes(data)

        os.makedirs(os.path.dirname(path), mode=0o700, exist_ok=True)
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, "wb") as f:
            f.write(data)
        print(f"touchid-adopt: {a.user} {a.finger} -> identity [{a.index}] ({path})")
        print("check with: fprintd-verify " + a.user)
    finally:
        dev.close_sync(None)


if __name__ == "__main__":
    main()
