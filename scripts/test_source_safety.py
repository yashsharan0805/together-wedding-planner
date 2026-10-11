"""Synthetic publication guards; never reads or prints real credentials."""
from pathlib import Path
import io
import subprocess
import tarfile
import tempfile
import unittest
from source_inventory import assert_safe, eligible, source_paths

CHECK = Path(__file__).with_name('check-public-source.py')


class PublicationSafetyTest(unittest.TestCase):
    def test_known_value_blocks_publication_without_printing_it(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            secret = 'synthetic-private-value-' + 'x' * 30
            (root / '.env.production.local').write_text('SECRET_KEY_BASE=' + secret)
            (root / 'README.md').write_text(secret)
            with self.assertRaises(RuntimeError) as error:
                assert_safe(root, source_paths(root))
            self.assertNotIn(secret, str(error.exception))
            self.assertIn('README.md:1', str(error.exception))

    def test_secret_files_excluded_but_templates_retained(self):
        for name in ['.env', '.env.production.local', 'config/credentials.yml.enc',
                     'client_secret_download.json', '.vercel/project.json',
                     '.local-certs/ca.crt', 'storage/upload.pdf']:
            self.assertFalse(eligible(Path(name)), name)
        self.assertTrue(eligible(Path('.env.production.example')))

    def test_root_and_backend_symlinks_are_refused(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / 'private.txt'
            target.write_text('not distributable')
            (root / 'README.md').symlink_to(target)
            with self.assertRaises(RuntimeError):
                source_paths(root)
            (root / 'README.md').unlink()
            (root / 'backend').symlink_to(root, target_is_directory=True)
            with self.assertRaises(RuntimeError):
                source_paths(root)

    def test_archive_secret_paths_and_traversal_fail_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'dist').mkdir()
            archive = root / 'dist/together-source.tar.gz'
            for name in ['together/.env.production.local', 'together/../../private.txt']:
                with tarfile.open(archive, 'w:gz') as bundle:
                    member = tarfile.TarInfo(name)
                    member.size = 4
                    bundle.addfile(member, io.BytesIO(b'test'))
                result = subprocess.run(['python3', str(CHECK), '--root', str(root)], capture_output=True)
                self.assertNotEqual(result.returncode, 0)

    def test_legitimate_backend_and_font_notices_are_included(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in ['backend/Gemfile', 'backend/app/models/task.rb',
                         'backend/app/assets/fonts/example/OFL.txt']:
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text('synthetic source')
            self.assertEqual(len(source_paths(root)), 3)


if __name__ == '__main__':
    unittest.main()
