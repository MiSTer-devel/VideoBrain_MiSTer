#!/usr/bin/env python3
"""Create an empty VideoBrain printer image without replacing an existing file."""

import argparse
from datetime import datetime
import os
from pathlib import Path
import struct
import zlib


def create(path, size=1024 * 1024):
    if size % 512 or not 2048 <= size <= 16 * 1024 * 1024:
        raise ValueError('size must be 512-byte aligned, 2048 bytes..16 MiB')
    header = bytearray(512)
    struct.pack_into('<4sIIII', header, 0, b'VBP1', 1, 512, 32, size // 512)
    struct.pack_into('<I', header, 28, zlib.crc32(header))
    with path.open('xb') as image:
        image.write(header)
        for _ in range(size // 512 - 1):
            image.write(bytes(512))
        image.flush()
        os.fsync(image.fileno())


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('path', nargs='?', type=Path,
                        default=Path(datetime.now().strftime('Printer_%Y%m%d_%H%M%S_%f.vbp')))
    parser.add_argument('--size', type=int, default=1024 * 1024,
                        help='allocated bytes (default: 1048576)')
    args = parser.parse_args()
    try:
        create(args.path, args.size)
    except (OSError, ValueError) as error:
        parser.error(str(error))
    print(args.path)
