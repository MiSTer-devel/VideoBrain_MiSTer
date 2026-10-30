#!/usr/bin/env python3
"""Write a dated SHA1 report for VideoBrain media, sorted by title."""

import argparse
from datetime import date
import hashlib
from pathlib import Path


EXTENSIONS = {'.bin', '.vbt', '.vbk', '.vbp', '.rom'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('folder', nargs='?', type=Path,
                        default=Path(__file__).resolve().parent)
    parser.add_argument('--overwrite', action='store_true',
                        help="replace today's report if it already exists")
    args = parser.parse_args()
    root = args.folder.resolve()
    try:
        if not root.is_dir():
            raise ValueError('folder does not exist')
        files = [path for path in root.rglob('*') if path.is_file()
                 and not path.is_symlink() and path.suffix.lower() in EXTENSIONS]
        files.sort(key=lambda path: (path.stem.casefold(),
                                    path.relative_to(root).as_posix().casefold()))
        if not files:
            raise ValueError('no BIN, VBT, VBK, VBP or ROM files found')
        lines = []
        for path in files:
            digest = hashlib.sha1()
            with path.open('rb') as source:
                for chunk in iter(lambda: source.read(1024 * 1024), b''):
                    digest.update(chunk)
            lines.append(f'{digest.hexdigest()}  {path.relative_to(root).as_posix()}\n')
        output = root / f'sha1-hashes-by-title-videobrain_{date.today():%Y%m%d}.txt'
        with output.open('w' if args.overwrite else 'x', encoding='utf-8', newline='\n') as report:
            report.writelines(lines)
    except (OSError, ValueError) as error:
        parser.exit(1, f'error: {error}\n')
    print(f'{len(files)} hashes written to {output}')


if __name__ == '__main__':
    main()
