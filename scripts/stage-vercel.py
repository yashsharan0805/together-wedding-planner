#!/usr/bin/env python3
"""Stage only distributable source for Vercel, without local credentials or Git."""
from pathlib import Path
import argparse
import shutil
import subprocess
import tarfile
import tempfile

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--isolated', action='store_true', help='Stage outside the Git checkout so Vercel cannot select its parent project.')
options = parser.parse_args()
target = Path(tempfile.mkdtemp(prefix='together-vercel-')) if options.isolated else root / 'output/vercel-deploy'
subprocess.run(['python3', str(root / 'scripts/package-source.py')], check=True)
target.mkdir(parents=True, exist_ok=True)
with tarfile.open(root / 'dist/together-source.tar.gz') as archive:
    for member in archive.getmembers():
        relative = Path(member.name).relative_to('together')
        if '..' in relative.parts or not member.isfile():
            raise RuntimeError('Unexpected source archive entry')
        destination = target / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        with archive.extractfile(member) as source, destination.open('wb') as output:
            shutil.copyfileobj(source, output)
# Vercel must receive the backend even though the working checkout ignores it.
(target / '.gitignore').write_text('.vercel/\n.env*\n')
# Include the exact corresponding source served by this deployment.
shutil.copy2(root / 'dist/together-source.tar.gz', target / 'dist/together-source.tar.gz')
# Project identity contains only identifiers, never CLI tokens or environment values.
identity = root / '.vercel/project.json'
if identity.exists():
    (target / '.vercel').mkdir(exist_ok=True)
    shutil.copy2(identity, target / '.vercel/project.json')
print(f'Credential-free Vercel deployment folder: {target}')
