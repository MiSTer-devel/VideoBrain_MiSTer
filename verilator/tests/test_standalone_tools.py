"""Check independent tool entrypoints without repository imports or media."""

import binascii
import hashlib
import json
from pathlib import Path
import shutil
import struct
import subprocess
import sys
import tempfile
import unittest
import zlib


TOOLS = Path(__file__).resolve().parents[2] / 'tools'


class StandaloneToolTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)

    def tool(self, name):
        folder = self.root / Path(name).stem
        folder.mkdir()
        script = folder / name
        shutil.copy2(TOOLS / name, script)
        return script

    def run_tool(self, script, *args, code=0):
        result = subprocess.run([sys.executable, '-B', '-I', str(script), *map(str, args)],
                                cwd=self.root, capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, code, result.stdout + result.stderr)
        return result

    def test_sha1_report(self):
        script = self.tool('sha1.py')
        (script.parent / 'sub').mkdir()
        fixtures = {'Z.BIN': b'abc', 'sub/A.rom': b'', 'C.vbt': b'tape',
                    'B.VBK': b'keys', 'sub/D.vbp': b'printer'}
        for name, data in fixtures.items():
            (script.parent / name).write_bytes(data)
        (script.parent / 'ignored.txt').write_bytes(b'notes')
        (script.parent / 'ignored.zip').write_bytes(b'archive')
        self.run_tool(script)
        reports = list(script.parent.glob('sha1-hashes-by-title-videobrain_????????.txt'))
        self.assertEqual(len(reports), 1)
        report = reports[0]
        rows = [line.split('  ', 1) for line in report.read_text().splitlines()]
        self.assertEqual([name for _, name in rows],
                         ['sub/A.rom', 'B.VBK', 'C.vbt', 'sub/D.vbp', 'Z.BIN'])
        self.assertEqual({name: digest for digest, name in rows},
                         {name: hashlib.sha1(data).hexdigest() for name, data in fixtures.items()})
        self.assertEqual(rows[-1][0], 'a9993e364706816aba3e25717850c26c9cd0d89d')
        previous = report.read_bytes()
        self.run_tool(script, code=1)
        self.assertEqual(report.read_bytes(), previous)
        (script.parent / 'Z.BIN').write_bytes(b'changed')
        self.run_tool(script, '--overwrite')
        self.assertIn(hashlib.sha1(b'changed').hexdigest(), report.read_text())

    def test_keyboard_converter(self):
        script = self.tool('keyboard_input.py')
        source = self.root / 'Program.txt'
        source.write_text('1+1\n', encoding='utf-8')
        self.run_tool(script, source)
        data = source.with_suffix('.vbk').read_bytes()
        self.assertEqual(data[:6], b'VBK1\x04\x00')
        self.assertEqual(data[8:], bytes([0x61, 0x56, 0x61, 0x9b]))
        self.assertEqual(struct.unpack_from('<H', data, 6)[0], binascii.crc_hqx(data[8:], 0xffff))
        self.run_tool(script, source, source, code=1)
        self.assertEqual(source.read_text(), '1+1\n')

    def test_tape_trimmer(self):
        script = self.tool('trim_tape.py')
        source, output = self.root / 'Recorded.vbt', self.root / 'Trimmed.vbt'
        header = struct.pack('<4sII', b'VBT1', 14318180, 1).ljust(512, b'\0')
        data = (header + struct.pack('<I', 14318)).ljust(4096, b'\0')
        source.write_bytes(data)
        self.run_tool(script, source, output)
        self.assertEqual(output.read_bytes(), data[:1024])
        self.assertEqual(source.read_bytes(), data)
        self.run_tool(script, source, output, code=2)
        self.assertEqual(output.read_bytes(), data[:1024])

    def test_printer_creator_and_extractor(self):
        creator = self.tool('new_printer.py')
        extractor = self.tool('extract_printer.py')
        image = self.root / 'Printer.vbp'
        self.run_tool(creator, image)
        data = image.read_bytes()
        self.assertEqual(len(data), 1024 * 1024)
        self.assertEqual(struct.unpack_from('<4sIIII', data), (b'VBP1', 1, 512, 32, 2048))
        header = bytearray(data[:512])
        crc = struct.unpack_from('<I', header, 28)[0]
        header[28:32] = bytes(4)
        self.assertEqual(crc, zlib.crc32(header))
        self.assertEqual(data[512:], bytes(len(data) - 512))
        self.run_tool(creator, image, code=2)
        self.assertEqual(image.read_bytes(), data)
        invalid = self.root / 'Invalid.vbp'
        self.run_tool(creator, invalid, '--size', 1000, code=2)
        self.assertFalse(invalid.exists())
        self.run_tool(creator)
        self.assertEqual(len(list(self.root.glob('Printer_*.vbp'))), 1)
        result = self.run_tool(extractor, 'inspect', image)
        self.assertEqual(json.loads(result.stdout), {'sessions': [], 'error': None})
        output = self.root / 'Printer.bin'
        self.run_tool(extractor, 'export', image, output)
        self.assertEqual(output.read_bytes(), b'')
        self.assertEqual(image.read_bytes(), data)


if __name__ == '__main__':
    unittest.main()
