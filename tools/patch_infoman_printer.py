#!/usr/bin/env python3
"""Create an experimental Information Manager cartridge with printer corrections."""
import argparse
import hashlib
from pathlib import Path


INFOMAN_SHA256 = "9b580726ad5d899a316901ad4513622a9e66e8131da3d6ac3de40180a2200d8f"

# save 36c6 scroll count r0 in printer row counter 0c28
# stubs use padding and return through pi link, preserving cursor clear
PATCHES = (
    (0x36CA, "70 2a 0f df 17", "28 17 f8 2b 2b"),
    # lr a,r0 / dci 0c28 / st / jmp 3ff9
    (0x17F8, "bd bd bd bd bd bd bd bd", "40 2a 0c 28 17 29 3f f9"),
    # clr / dci 0fdf / st / pop
    (0x3FF9, "f0 f0 f0 f0 f0 f0", "70 2a 0f df 17 1c"),
)

# r2=0 after routing, r2=1 after later bytes
# wait 256 or 1 ds/bnz iterations before mark, preserving final routing bit
# retain start, eight data bits and two stop bits
SERIAL_IDLE_PATCH = (
    0x3E31, "20 3e 06 20 17 07", "32 94 fe 20 20 b1",
)


def rom_offset(address):
    if 0x1000 <= address < 0x1800:
        return address - 0x1000
    if 0x3000 <= address < 0x4000:
        return address - 0x2000
    raise ValueError(f"address outside cartridge ROM: {address:04X}")


def patch_rom(data, serial_idle=False):
    if len(data) != 8192 or hashlib.sha256(data).hexdigest() != INFOMAN_SHA256:
        raise ValueError("expected the original 8192-byte Information Manager ROM")
    patched = bytearray(data)
    patches = PATCHES + ((SERIAL_IDLE_PATCH,) if serial_idle else ())
    for address, before, after in patches:
        offset = rom_offset(address)
        expected, replacement = bytes.fromhex(before), bytes.fromhex(after)
        if (len(expected) != len(replacement)
                or data[offset:offset + len(expected)] != expected):
            raise ValueError(f"unexpected bytes at ${address:04X}")
        patched[offset:offset + len(replacement)] = replacement
    return bytes(patched)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="original cartridge image")
    parser.add_argument("output", type=Path, help="new experimental cartridge image")
    parser.add_argument("--serial-idle", action="store_true",
                        help="also prime serial idle after the 300-baud setup command")
    args = parser.parse_args()
    try:
        patched = patch_rom(args.source.read_bytes(), args.serial_idle)
        with args.output.open("xb") as output:
            output.write(patched)
    except (OSError, ValueError) as error:
        parser.exit(1, f"error: {error}\n")
    print(f"{args.output}: {len(patched)} bytes, "
          f"SHA256 {hashlib.sha256(patched).hexdigest()}")


if __name__ == "__main__":
    main()
