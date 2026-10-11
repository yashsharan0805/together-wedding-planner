"""One conservative inventory for public exports and corresponding source."""
from pathlib import Path
import fnmatch
import re

ROOT_FILES = {
    'README.md', 'COPYING.md', 'LICENSE.md', 'NOTICE.md', 'SECURITY.md',
    'CONTRIBUTING.md', 'compose.yml', 'compose.corporate.yml',
    '.env.example', '.env.production.example', '.gitignore', '.dockerignore',
    '.vercelignore', 'Dockerfile.vercel', 'vercel.json',
}
ROOT_DIRS = {'dist', 'deploy', 'docs', 'scripts', '.github'}
BACKEND_DIRS = {'app', 'bin', 'config', 'db', 'lib', 'public', 'spec', 'test', 'vendor'}
BACKEND_FILES = {
    'Gemfile', 'Gemfile.lock', 'Rakefile', 'config.ru', 'COPYING.md', 'README.md',
    'Dockerfile.together', '.gitignore', '.dockerignore', '.rspec', '.ruby-version',
    '.rubocop.yml', '.rubocop_todo.yml',
}
EXCLUDED_DIRS = {
    '.git', '.bundle', '.local-certs', '.vercel', '.openai', 'node_modules',
    'coverage', 'log', 'tmp', 'storage', 'output', '__pycache__', '.venv',
}
PRIVATE_NAMES = (
    '*.key', '*.pem', '*.crt', '*.p12', '*.pfx', '*.yml.enc', '*.sqlite*',
    '*.dump', '*.sql.gz', 'client_secret*.json', '*service-account*.json',
    '*credentials*.json', '*secrets*.json', '*.pyc',
)


def eligible(relative):
    return (
        not EXCLUDED_DIRS.intersection(relative.parts)
        and not any(part.startswith('.playwright') for part in relative.parts)
        and not any(fnmatch.fnmatch(relative.name, pat) for pat in PRIVATE_NAMES)
        and (not relative.name.startswith('.env') or relative.name.endswith('.example'))
        and relative.name != 'together-source.tar.gz'
    )


def source_paths(root):
    """Works in the private nested checkout, a flat clone, or before git init."""
    paths = [root / name for name in ROOT_FILES if (root / name).is_file()]
    for folder in ROOT_DIRS | {'backend'}:
        base = root / folder
        if not base.exists():
            continue
        if base.is_symlink():
            raise RuntimeError(f'Refusing source directory symlink: {folder}')
        for path in base.rglob('*'):
            relative = path.relative_to(root)
            if not eligible(relative):
                continue
            if folder == 'backend':
                parts = relative.parts[1:]
                if len(parts) == 1 and path.name not in BACKEND_FILES:
                    continue
                if len(parts) > 1 and parts[0] not in BACKEND_DIRS:
                    continue
            if path.is_symlink():
                raise RuntimeError(f'Refusing source symlink: {relative}')
            if path.is_file():
                paths.append(path)
    for path in paths:
        if path.is_symlink():
            raise RuntimeError(f'Refusing source symlink: {path.relative_to(root)}')
    return sorted(set(paths))


def private_values(root):
    """Read values for comparison only; callers must never print the result."""
    values = set()
    sources = list(root.glob('.env*')) + list((root / 'backend').glob('.env*'))
    sources.append(root / 'output/playwright/neon-migrate.env')
    for path in sources:
        if path.name.endswith(('.example', '.erb')) or not path.is_file():
            continue
        for line in path.read_text(errors='replace').splitlines():
            if '=' not in line or line.lstrip().startswith('#'):
                continue
            key, value = line.split('=', 1)
            value = value.strip().strip('"\'')
            if any(word in key.upper() for word in ('SECRET', 'TOKEN', 'PASSWORD', 'DATABASE_URL', 'API_KEY')) and len(value) >= 12:
                values.add(value.encode())
    return values


PATTERNS = {
    'private key': re.compile(rb'-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----'),
    'provider token': re.compile(rb'(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,}|GOCSPX-[A-Za-z0-9_-]{20,}|AKIA[A-Z0-9]{16})'),
    'credentialed external database URL': re.compile(rb'(?:postgres(?:ql)?|mysql|rediss?)://[^\s:/]+:([^\s@]+)@([^\s/:?]+)'),
}


def scan_bytes(data, known_values):
    findings = []
    for value in known_values:
        if value in data:
            findings.append(('known private environment value', data[:data.index(value)].count(b'\n') + 1))
    for label, pattern in PATTERNS.items():
        for match in pattern.finditer(data):
            if label == 'credentialed external database URL' and match.group(2) in {b'localhost', b'127.0.0.1', b'db', b'valkey'}:
                continue
            if label == 'credentialed external database URL' and match.group(1) in {b'<password>', b'PASSWORD', b'YOUR_PASSWORD'}:
                continue
            findings.append((label, data[:match.start()].count(b'\n') + 1))
    return sorted(set(findings))


def assert_safe(root, paths):
    values = private_values(root)
    problems = []
    for path in paths:
        for label, line in scan_bytes(path.read_bytes(), values):
            display = path.relative_to(root) if path.is_relative_to(root) else path.name
            problems.append(f'{display}:{line}: {label} (value redacted)')
    if problems:
        raise RuntimeError('Publication scan failed:\n' + '\n'.join(problems))
    return len(paths)
