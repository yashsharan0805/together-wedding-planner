#!/usr/bin/env python3
"""Redacted source/archive check; use Gitleaks as a second, broader scanner."""
from pathlib import Path
import argparse
import tarfile
from source_inventory import source_paths, assert_safe, private_values, scan_bytes, eligible

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
args = parser.parse_args()
root = args.root.resolve()
count = assert_safe(root, source_paths(root))
values = private_values(root)
archive = root / 'dist/together-source.tar.gz'
archive_count = 0
if archive.exists():
    with tarfile.open(archive) as bundle:
        for member in bundle:
            relative = Path(member.name)
            if not relative.parts or relative.parts[0] != 'together' or '..' in relative.parts or not member.isfile():
                raise SystemExit('Unsafe source archive member (path/type).')
            if not eligible(relative):
                raise SystemExit(f'Forbidden source archive path: {relative}')
            for label, line in scan_bytes(bundle.extractfile(member).read(), values):
                raise SystemExit(f'{relative}:{line}: {label} (value redacted)')
            archive_count += 1
print(f'Publication checks passed: {count} source files, {archive_count} archive members. No values printed.')
