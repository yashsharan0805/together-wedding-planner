#!/usr/bin/env python3
"""Create a fresh, reviewable monorepo without modifying either local history."""
from pathlib import Path
import argparse
import shutil
import subprocess
from source_inventory import source_paths, assert_safe

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--destination', default='output/public-repo', help='Must not exist; existing directories are never overwritten.')
args = parser.parse_args()
target = Path(args.destination).expanduser().resolve()
if target == root or root.is_relative_to(target) or target.exists():
    raise SystemExit('Choose a new destination directory, not this checkout or its parent.')
if target.is_relative_to(root) and target.relative_to(root).parts[0] != 'output':
    raise SystemExit('Place exports outside this checkout or under ignored output/.')
paths = source_paths(root)
assert_safe(root, paths)
target.mkdir(parents=True)
for path in paths:
    destination = target / path.relative_to(root)
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, destination)
# Track the backend as ordinary source files, never a gitlink.
ignore = target / '.gitignore'
ignore.write_text('\n'.join(line for line in ignore.read_text().splitlines() if line.strip() != 'backend/') + '\n')
subprocess.run(['python3', str(target / 'scripts/package-source.py')], check=True)
assert_safe(root, source_paths(target))
print(f'Public source prepared: {target}')
print('No Git history, account link, credentials, or runtime records copied. Nothing pushed.')
