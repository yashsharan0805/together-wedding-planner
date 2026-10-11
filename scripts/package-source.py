#!/usr/bin/env python3
"""Package reviewed source without private credentials or runtime records."""
from pathlib import Path
import tarfile
from source_inventory import source_paths, assert_safe

root = Path(__file__).resolve().parents[1]
paths = source_paths(root)
assert_safe(root, paths)
archive = root / 'dist/together-source.tar.gz'


def public_metadata(member):
    # Do not publish the source owner's local account/group or filesystem times.
    member.uid = member.gid = member.mtime = 0
    member.uname = member.gname = ''
    member.pax_headers = {}
    member.mode = 0o755 if member.mode & 0o111 else 0o644
    return member


with tarfile.open(archive, 'w:gz') as bundle:
    for path in paths:
        bundle.add(path, arcname='together/' + str(path.relative_to(root)), recursive=False, filter=public_metadata)
print(f'Packaged {len(paths)} checked source files: {archive}')
